class Guides::Database::SavingRecords < GuideAction
  ANCHOR_USING_WITH_HTML_FORMS = "perma-using-with-html-forms"
  ANCHOR_PARAM_KEY             = "perma-param-key"
  ANCHOR_PERMITTING_COLUMNS    = "perma-permitting-columns"
  ANCHOR_CHANGE_TRACKING       = "perma-change-tracking"
  ANCHOR_SAVING_WITHOUT_PARAMS = "perma-saving-without-params"
  ANCHOR_SAVING_ENUMS          = "perma-saving-enums"
  guide_route "/database/saving-records"

  def self.title
    "Saving and Updating records"
  end

  def markdown : String
    <<-MD
    ## Setting up an operation

    When you set up a model, a `{ModelName}::SaveOperation` will be created so that you can inherit
    from it and customize validations, callbacks, and what fields are allowed to be
    filled. `{ModelName}::SaveOperation` automatically defines an attribute for each model field.

    We’ll be using the migration and model from the [Querying
    guide](#{Guides::Database::Querying.path}). Once you have that set up, let’s set
    up a save operation:

    ```crystal
    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
    end
    ```

    > You can have more than one operation object to save a record in different ways.
    For example, default Lucky apps have a `SignUserUp` specifically for handling
    user sign ups.

    #{permalink(ANCHOR_PERMITTING_COLUMNS)}
    ## Allowing params to be saved with permit_columns

    By default you won’t be able to set any data from params. This is a security
    measure to make sure that parameters can only be set that you want to permit
    users to fill out. For example, you might not want your users to be able to
    set an admin status through the `SaveUser` operation, but setting the
    name is ok.

    To permit users to set columns from JSON or form params, use the
    `permit_columns` macro:

    ```crystal
    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
      permit_columns name
    end
    ```

    Now you will be able to fill out the user’s name from request params.

    ## Creating records

    > Actions have a `params` method that returns a `LuckyWeb::Params` object.
    This is used by the operation to get form params that are set by [submitting an
    HTML form](##{ANCHOR_USING_WITH_HTML_FORMS}) or [when saving with a JSON API](#{Guides::JsonAndApis::SavingToTheDatabase.path(anchor: Guides::JsonAndApis::SavingToTheDatabase::ANCHOR_SAVING_TO_THE_DATABASE)}).

    To create a record, you pass a block that is run whether the save is
    successful or not.

    You will *always* receive the operation object, but you will only get the saved
    record if there are no errors while saving. If there are errors, the record will
    be `nil`.

    ```crystal
    # inside of an action with some form params
    SaveUser.create(params) do |operation, user|
      if user # the user was saved
        html Users::ShowPage, user: user
      else
        html Users::NewPage, save_user: operation
      end
    end
    ```

    ## Updating records

    In contrast to `create`, `update` will always pass the record to the block. To check
    if any changes were persisted, you can call `operation.saved?`, or `operation.valid?`
    to check if the submitted data was saved.

    ```crystal
    # inside of an action with some form params
    user = UserQuery.new.first
    SaveUser.update(user, params) do |operation, updated_user|
      if operation.saved?
        html Users::ShowPage, user: updated_user
      else
        html Users::NewPage, save_operation: operation
      end
    end
    ```

    ### Saving with `update!` and `create!`

    `update!/create!` will raise an `Avram::InvalidOperationError` if the
    record fails to save or is invalid.
    This version is often used when [writing JSON APIs](#{Guides::JsonAndApis::SavingToTheDatabase.path})
    or for creating sample data in your the seed tasks in the `/tasks` folder.

    ```crystal
    user = UserQuery.first
    # Returns the updated user or raises
    updated_user = SaveUser.update!(user, params)
    ```

    > `params` is defined in your actions for you. You can also
    > [save without a params object](#saving-without-a-params-object), for example, in your specs, or in
    > a seeds file.

    ### Bulk updating

    Bulk updating is when you update one or more columns on more than one record at a time.
    This is a much faster procedure than iterating over each record to update individually.

    ```crystal
    # Query for all users that are inactive
    users = UserQuery.new.active(false)

    # Make them all active! Returns the total count of updated records.
    total_updated = users.update(active: true)
    ```

    > The bulk update is called on a Query object instead of a `SaveOperation`.

    ## Using with JSON endpoints

    See [Writing JSON APIs guide](#{Guides::JsonAndApis::RenderingJson.path(anchor: Guides::JsonAndApis::SavingToTheDatabase::ANCHOR_SAVING_TO_THE_DATABASE)}).

    #{permalink(ANCHOR_USING_WITH_HTML_FORMS)}
    ## Using with HTML forms

    You can use operations in HTML like this:

    > Remember: you *must* mark a field in `permit_columns` in order to set it from JSON/form params.
    > If it isn’t permitted the program will not compile.

    ```crystal
    # src/pages/users/new_page.cr
    class Users::NewPage < MainLayout
      needs save_user : SaveUser

      def content
        render_form(save_user)
      end

      private def render_form(operation)
        form_for Users::Create do
          label_for operation.name
          text_input operation.name

          submit "Save User"
        end
      end
    end
    ```

    > A private method `render_form` is extracted because it makes it easier
    > to see what a page looks like with a quick glance at the `content` method.

    ```crystal
    class Users::Create < BrowserAction
      post "/users" do
        # params will have the form params sent from the HTML form
        SaveUser.create(params) do |operation, user|
          if user # if the user was saved
            redirect to: Home::Index
          else
            # re-render the NewPage so the user can correct their mistakes
            html NewPage, save_user: operation
          end
        end
      end
    end
    ```

    #{permalink(ANCHOR_PARAM_KEY)}
    ### Specifying the param key

    When params are given to an operation, the operation will look for a top
    level key that params are nested under. By default the key will be the
    SaveOperation's underscored model name. (e.g. a `SaveUser` which inherits
    from `User::SaveOperation` will submit a `user` param key).

    For non `SaveOperations` (not backed by a database model) the `param_key`
    is the underscored class name. So `RequestPasswordReset` would look for
    params in a `request_password_reset` key.

    If you need to customize this, use the `param_key` macro in your operation.

    ```crystal
    class SaveAdmin < User::SaveOperation
      # Sets the param key to `admin` instead of the default `user` key.
      param_key :admin
    end
    ```

    > The `param_key` is required in the operation. This means HTML and JSON
    > params must be nested under the param key to be found. (e.g. HTML
    > `user:email=abc@example.com`, JSON `{"user":{"email":"abc@example.com"}}`)


    ### Form element inputs

    To see a list of all the different form element inputs, check out the
    [HTML Forms](#{Guides::Frontend::HtmlForms.path}) guide.

    ## What are attributes?

    Attributes defined in the operation do not return the value of the attribute. They return an `Avram::Attribute`
    that contains the value of the attribute, the name of the attribute, the param value, and any errors the attribute
    has.

    This means that to access their value you must call `value` on the attribute.

    ```crystal
    class SaveUser < User::SaveOperation
      def print_name_value
        pp name.value
      end
    end
    ```

    > All of the columns from a model exist in SaveOperations as attributes, as well as any additional `attribute` specified.

    #{permalink(ANCHOR_CHANGE_TRACKING)}
    ## Tracking changed attributes

    Sometimes you need to run code only when certain attributes have changed
    (sometimes called "dirty tracking"). Avram Attributes have a `changed?`
    and `original_value` method that makes it easy to see if an attribute has
    changed.

    The following change tracking methods are available:

    * `changed?` - returns `true` if the attribute value has changed.
    * `changed?(from: value)` - returns `true` if the attribute has changed
      from the passed in value to anything else.
    * `changed?(to: value)` - returns `true` if the attribute value has changed
      to the passed in value.
    * `original_value` - returns the original value before it was changed. If the
      attribute is unchanged, `value` and `original_value` will be the same.

    > You can also combine `from` and `to` together: `name.changed?(from: nil, to: "Joe")`

    Here is an example using `changed?` and `original_value` in an operation:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name, email, admin

      before_save do
        if admin.changed?(to: true)
          validate_company_email
        end
      end

      def validate_company_email
        if !email.value.ends_with?("@my-company.com")
          email.add_error("must be from @my-company.com to be an admin")
        end
      end

      after_save log_changes

      def log_changes(user : User)
        # Get changed attributes and log each of them
        attributes.select(&.changed?).each do |attribute|
          Log.dexter.info do
            {
              user_id: user.id,
              changed_attribute: attribute.name.to_s,
              from: attribute.original_value.to_s,
              to: attribute.value.to_s
            }
          end
        end
      end
    end
    ```

    ## Passing data without route params

    Often times you want to add extra data to a form that the user does not fill out.

    In this example, we'll associate a comment with a post:

    ```crystal
    class Posts::Comments::Create < BrowserAction
      post "/posts/:post_id/comments" do
        post = PostQuery.find(post_id)
        # Params contain the title and body, but not the post_id
        # So we set it ourselves
        SaveComment.create(params, post_id: post.id) do |operation, comment|
          # Do something with the form and comment
        end
      end
    end
    ```

    This sets the `post_id` when instantiating the operation. You can pass anything
    that is defined as a `column` on your model. Note that the attributes are type
    safe, so you don't need to worry about typos or passing the wrong types.
    Lucky is set up to make sure it works automatically.

    ## Passing extra data to operations

    Sometimes you need to pass extra data to operations that aren't in the form params.
    For example you might want to pass the currently signed in user so that you know
    who created a record. Here's how you do this:

    ```crystal
    # This is a great way to pass in an associated record
    class SaveUser < User::SaveOperation
      needs current_user : User

      before_save assign_user_id

      def assign_user_id
        modified_by_id.value = current_user.id
      end
    end

    SaveUser.create(params, current_user: a_user) do |operation, user|
      # do something
    end
    ```

    This will make it so that you must pass in `current_user` when creating or updating
    the `SaveUser`. It will make a getter available for `current_user` so you can use
    it in the operation, like in the `before_save` macro shown in the example.

    ## Non-database column attributes

    Sometimes you want users to submit data that isn't saved to the database. For that
    we use `attribute`.

    Here's an example of using `attribute` to create a sign up user operation:

    ```crystal
    # First we create a model
    # src/models/user.cr
    class User < BaseModel
      table do
        column name : String
        column email : String
        column encrypted_password : String
      end
    end
    ```

    ```crystal
    # src/operations/sign_user_up.cr
    require "crypto/bcrypt/password"

    class SignUserUp < User::SaveOperation
      # These are fields that will be saved to the database
      permit_columns name, email
      # Attributes that users can fill out, but aren't saved to the database
      attribute password : String
      attribute password_confirmation : String
      attribute terms_of_service : Bool

      before_save validate_data_inputs

      def validate_data_inputs
        # Make sure the user has checked the terms of service box
        validate_acceptance_of terms_of_service
        # Make sure the passwords match
        validate_confirmation_of password, with: password_confirmation
        encrypt_password(password.value)
      end

      private def encrypt_password(password_value : String?)
        if password_value
          encrypted_password.value = Crypto::Bcrypt::Password.create(password_value, cost: 10).to_s
        end
      end
    end
    ```

    ### Using attributes in an HTML form

    Using attributes in HTML works exactly the same as with database fields:

    ```crystal
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < MainLayout
      needs sign_up_user : SignUpUser

      def content
        render_form(@sign_up_user)
      end

      private def render_form(operation)
        form_for SignUps::Create do
          # labels omitted for brevity
          text_input operation.name
          email_input operation.email
          password_input operation.password
          password_input operation.password_confirmation
          checkbox operation.terms_of_service

          submit "Sign up"
        end
      end
    end
    ```

    ## Basic Operations

    Just like `attribute`, there may also be a time where you have an operation **not** tied to the database.
    Maybe a search operation, signing in a user, or even requesting a password reset.

    For these, you can use `Avram::Operation`:

    ```crystal
    # src/operations/search_data.cr
    class SearchData < Avram::Operation
      attribute query : String = ""
      attribute active : Bool = true

      def run
        validate_required query

        UserQuery.new.name.ilike(query.value).active(active.value)
      end
    end
    ```

    Just define your `run` method, and have it return some value, and you're set!

    These operations work similar to `SaveOperation`. You can use `attribute`, and `needs`, plus any of the validations that you need.
    There are a few differences though.

    ### Operation Callbacks

    You will use `before_run` and `after_run` for the callbacks. These work the same as `before_save` and `after_save` on `SaveOperation`.

    ### Using with HTML Forms

    Using operations in HTML works exactly the same as the rest:

    ```crystal
    # src/pages/searches/new_page.cr
    class Searches::NewPage < MainLayout
      needs search_data : SearchData

      def content
        render_form(@search_data)
      end

      private def render_form(operation)
        form_for Searches::Create do
          label_for operation.query
          text_input operation.query

          label_for operation.active
          checkbox operation.active

          submit "Filter Results"
        end
      end
    end
    ```

    Finally, using the operation in your action:

    ```crystal
    class Searches::Create < BrowserAction
      post "/searches" do
        SearchData.run(params) do |operation, results|
          # `valid?` is defined on `operation` for you!
          if operation.valid?
            html SearchResults::IndexPage, users: results
          else
            html Searches::NewPage, search_data: operation
          end
        end
      end
    end
    ```

    ### Handling errors

    Each `attribute` in your operation has an `add_error` method. This lets you specify errors directly on the attribute
    which can be used in forms to highlight specific fields.

    ```crystal
    class SignInUser < Avram::Operation
      attribute username : String
      attribute password : String

      def run
        user = UserQuery.new.username(username).first?

        unless Authentic.correct_password?(user, password.value.to_s)
          # Add an error to the `password` attribute.
          password.add_error "is wrong"
          return nil
        end

        user
      end
    end
    ```

    Then to get the errors, you can call `operation.errors`.

    ```crystal
    SignInUser.run(params) do |operation, user|
      operation.errors #=> {"password" => ["password is wrong"]}
    end
    ```

    If you need to set custom errors that are not on any attributes, you can use the `add_error` method.

    ```crystal
    def run
      user = UserQuery.new.username(username).first?

      if user.try(&.banned)
        add_error(:user_banned, "Sorry, you've been banned.")
      end
    end
    ```

    Now your `operation.errors` will include `{"user_banned" => ["Sorry, you've been banned"]}`.

    #{permalink(ANCHOR_SAVING_WITHOUT_PARAMS)}
    ## Saving without a params object

    This can be helpful if you’re saving something that doesn’t need an HTML form,
    like if you only need the params passed in the path.

    ```crystal
    SaveUser.create!(name: "Paul")

    # for updates
    SaveUser.update!(existing_user, name: "David")
    ```

    #{permalink(ANCHOR_SAVING_ENUMS)}
    ### Saving an enum value

    You can pass an instance of your `enum` to the column you wish to update.

    ```crystal
    SaveUser.create!(name: "Paul", role: User::Role::Superadmin)
    ```

    ## Ideas for naming

    In Lucky it is common to have multiple operations per model. This makes it easier to
    understand what an operation does and makes them easier to change later without
    breaking other flows.

    Here are some ideas for naming:

    * `ImportCsvUser` - great for operations that get data from a CSV.
    * `SignUpUser` - for signing up a new user. Encrypt passwords, send welcome emails, etc.
    * `SignInUser` - check that passwords match
    * `SaveAdminUser` - sometimes admin can set more fields than a regular user. It’s
      often a good idea to extract a new operation for those cases.
    MD
  end
end
