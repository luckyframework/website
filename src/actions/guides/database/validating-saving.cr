class Guides::Database::ValidatingSaving < GuideAction
  ANCHOR_USING_WITH_HTML_FORMS = "perma-using-with-html-forms"
  ANCHOR_PARAM_KEY             = "perma-param-key"
  ANCHOR_PERMITTING_COLUMNS    = "perma-permitting-columns"
  guide_route "/database/validating-saving"

  def self.title
    "Validating and Saving"
  end

  def markdown
    <<-MD
    ## Setting up an operation

    When you set up a model, a `{ModelName}::SaveOperation` will be created so that you can inherit
    from it and customize validations, callbacks, and what fields are allowed to be
    filled. `{ModelName}::SaveOperation` automatically defines an attribute for each model field.

    We’ll be using the migration and model from the [Querying
    guide](#{Guides::Database::QueryingDeleting.path}). Once you have that set up, let’s set
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
    ## Allowing params to be saved

    By default you won’t be able to set any data from params. This is a security
    measure to make sure that parameters can only be set that you want to allow
    users to fill out. For example, you might not want your users to be able to
    set an admin status through the `SaveUser` operation.

    To allow users to set columns from JSON/form params, use the `permit_columns` macro:

    ```crystal
    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
      permit_columns name
    end
    ```

    Now you will be able to fill out the user’s name from params.

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
        html Users::NewPage, operation: operation
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
      needs operation : SaveUser

      def contentj
        render_form(@operation)
      end

      private def render_form(op)
        form_for Users::Create do
          label_for op.name
          text_input op.name
          errors_for op.name

          submit "Save User"
        end
      end
    end
    ```

    > A private method `render_form` is extracted because it makes it easier to
    reference the form as `op`. It also makes it easier to see what a page looks like
    with a quick glance at the `content` method.

    ```crystal
    class Users::Create < BrowserAction
      route do
        # params will have the form params sent from the HTML form
        SaveUser.create(params) do |form, user|
          if user # if the user was saved
            redirect to: Home::Index
          else
            # re-render the NewPage so the user can correct their mistakes
            html NewPage, user_form: form
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

    For non `SaveOperations` (not backed by a databse model) the `param_key`
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

    ### Simplify inputs with `Shared::Field`

    In the above form we had to write a fair amount of code to show a label, input,
    and errors tag. Lucky generates a `Shared::Field` component that you can use
    and customize to make this simpler. It is found in `src/components/shared/field.cr`
    and is used in pages like this:

    ```crystal
    # This will render a label, an input, and any errors for the 'name'
    mount Shared::Field.new(op.name)

    # You can customize the generated input
    mount Shared::Field.new(operation.email), &.email_input
    mount Shared::Field.new(operation.email), &.email_input(autofocus: "true")
    mount Shared::Field.new(operation.username), &.email_input(placeholder: "Username")

    # You can append to or replace the HTML class on the input
    mount Shared::Field.new(operation.name), &.text_input(append_class: "custom-input-class")
    mount Shared::Field.new(operation.nickname), &.text_input(replace_class: "compact-input")
    ```

    Look in `src/components/shared/field.cr` to see even more options and customize
    the generated markup.

    > You can also duplicate and rename the component for different styles of input
    > fields in your app. For example, you might have a `CompactField` component,
    > or a `FieldWithoutLabel` component.

    ### Select, email input, and other special inputs

    The main inputs that you can use with Lucky:

    * `text_input`
    * `email_input`
    * `color_input`
    * `hidden_input`
    * `number_input`
    * `telephone_input`
    * `url_input`
    * `search_input`
    * `password_input`
    * `range_input`
    * `textarea`

    ```crystal
    # Example using an email input
    email_input op.email, optional_html_attributes: "anything"
    ```

    ### Submit

    Call `submit` with the text to display

    ```crystal
    # In a page
    submit "Text", optional_html_attributes: "anything you want"
    ```

    ### Checkboxes

    ```crystal
    # If checked, will set the `admin` column to true
    checkbox op.admin, value: "true"
    ```

    ### Select with options

    ```crystal
    # Assuming you have a form with a permitted category_id
    select_input op.category_id do
      options_for_select(op.category_id, categories_for_select)
    end

    private def categories_for_select
      CategoryQuery.new.map do |category|
        # The first element is the display name
        # The second element is the value sent to the form
        {category.title, category.id}
      end
    end
    ```

    ### Labels

    ```crystal
    label_for op.title # Will display "Title"
    label_for op.title, "Custom Title" # Will display "Custom Title"
    label_for op.title do
      text "Custom Title"
      strong "(required)"
    end
    ```

    ## Validating data

    Lucky comes with a few built in validations:

    * `validate_required` - ensures that a field is not `nil` or blank (e.g. `""`).
    * `validate_confirmation_of` - ensures that fields have the same values.
    * `validate_acceptance_of` - great for checking if someone accepts terms of service.
    * `validate_inclusion_of` - check that value is in a list of accepted values.
    * `validate_size_of` - check the size of a number.
    * `validate_uniqueness_of` - to only allow one record with a field's value

    > Note: non-nillable (required) fields automatically use
    `validate_required`. They will run after all other `before_save` callbacks have run. This way data
    with missing fields will never be sent to the database.

    ### Using validations

    You can use validations inside of `before_save` callbacks:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name, password, password_confirmation, terms_of_service, age

      before_save do
        validate_required name
        validate_confirmation_of password, with: password_confirmation
        validate_acceptance_of terms_of_service
        validate_inclusion_of age, in: [30, 40, 50]
        validate_uniqueness_of name
        # Alternatively, pass optional second argument to use a custom query
        validate_uniqueness_of name, query: UserQuery.new.name.lower
        # Showing these version as an example
        # You would not want all three of these on a real form
        validate_size_of name, is: 4 # Name must be 4 characters long
        validate_size_of name, min: 4 # Can't be too short
        validate_size_of name, max: 8 # Must have a short name
      end

      before_save reject_scary_monsters

      def reject_scary_monsters
        if name.value == "Skeletor"
          name.add_error "Mmmyyaahhh!"
        end
      end
    end
    ```

    The `before_save` callbacks will run just before calling `save`. They each return `true` if
    the attributes are all `valid?`. They will also run if you call the `valid?` method.

    ## What are attributes?

    First you’ll need to know that the attributes defined in the operation do not return the
    value of the attribute. They return a `Avram::Attribute` that contains the value
    of the attribute, the name of the attribute, the param value, and any errors the attribute
    has.

    This means that to access their value you must call `value` on the attribute.

    ```crystal
    class SaveUser < User::SaveOperation
      def print_name_value
        pp name.value
      end
    end
    ```

    ## Custom validations

    You can easily create your own validations. For example, let’s say we want to
    make sure the user is old enough to use the site.

    ```crystal
    before_save validate_user_is_old_enough

    private def validate_user_is_old_enough
      # The value might be `nil` so we need to use `try`.
      age.value.try do |value|
        if value < 13
          age.add_error "must be at least 13 to use this site"
        end
      end
    end
    ```

    ## Callbacks

    > Callbacks often get a bad rep because they can quickly lead to hard to
    maintain code. One reason for this is situations arrive when you want callbacks
    to run only in certain conditions. In Lucky this situation is quickly solved
    by adding a new operation. For example you might have a `SignUpUser` for a `User`
    that encrypts the users password and sends a welcome email after saving. Or you
    might have an `SaveAdminUser` that saves a user and sends an admin specific
    email.

    ### Callbacks for running before and after save

    * `before_save` - Ran before the record is saved.
    * `after_save` - Ran after the record is saved.
    * `after_commit` - Ran after `after_save`, and the database transaction has committed.

    Create a method you'd like to run and then pass the method name to the
    callback macro. Note that the methods used by the `after_*` callbacks needs
    to accept the newly created record. In this example, a `Post`.

    ```crystal
    class SavePost < Post::SaveOperation
      before_save run_this_before_save
      after_save run_this_after_save
      after_commit run_this_after_commit

      def run_this_before_save
        # do something
      end

      def run_this_after_save(newly_created_post : Post)
        # do something
      end

      def run_this_after_commit(newly_created_post : Post)
        # do something
      end
    end
    ```

    ### When to use `after_save` vs. `after_commit`

    The `after_save` callback is a great place to do other database saves because if something goes
    wrong the whole transaction would be rolled back.

    ```crystal
    class SaveComment < Comment::SaveOperation
      after_save also_update_post

      # If this fails, we roll back the comment save too
      def also_update_post(saved_comment : Comment)
        SavePost.update!(latest_comment: saved_comment.body)
      end
    end
    ```

    The `after_commit` callback is best used for things like email notifications and such
    since this is only called if the records were actually saved in to the database.

    ```crystal
    class SaveComment < Comment::SaveOperation
      after_commit notify_user_of_new_comment

      def notify_user_of_new_comment(new_comment : Comment)
        NewCommentNotificationEmail.new(new_comment, to: comment.author!).deliver_now
      end
    end
    ```

    ## Passing data without route params

    Often times you want to add extra data to a form that the user does not fill out.

    In this example, we'll associate a comment with a post:

    ```crystal
    class Posts::Comments::Create < BrowserAction
      route do
        post = PostQuery.find(id)
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
    it in the form, like in the `before_save` macro shown in the example.

    ### Declaring needs only for update, create, or save

    Sometimes you only want to pass extra data when creating or updating a record.
    You can use the `on` option to do that:

    * `:update` if only required for update
    * `:create` if only required for create
    * `:save` if required for update and create, but not when calling `new`

    ```crystal
    class SaveComment < Comment::SaveOperation
      needs author : User, on: :create # can also be `:update`, `:save`

      before_save prepare_comment

      def prepare_comment
        author.try do |user|
          authored_by_id.value = user.id
        end
      end
    end
    ```

    > Note that `author` is not required when calling `SaveUser.new` when using
    the `on` option. This means `author` can be `nil` in the form. That's why we
    needed to use `try` in the `prepare_comment` method.

    ```crystal
    # You must pass an author when creating
    SaveComment.create(params, author: a_user) do |operation, user|
      # do something
    end

    # But you can't when you are updating
    SaveComment.update(comment, params) do |operation, user|
      # do something
    end

    # You also can't pass it in when instantiating a new SaveComment
    SaveComment.new
    ```

    > **When should I use `on`?** If you are building a server rendered HTML app,
    then you will almost always wants to use `on :save|:update|:create` because
    you will call `SaveComment.new` without the needs. If you are building a JSON API
    you may want to omit the `on` option since you rarely use `.new`. If you omit
    `on` then you don't need to worry about the value ever being `nil`, which can
    make your program more reliable and easier to understand.

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

      private def render_form(op)
        form_for SignUps::Create do
          # labels and errors_for ommitted for brevity
          text_input op.name
          email_input op.email
          password_input op.password
          password_input op.password_confirmation
          checkbox op.terms_of_service

          submit "Sign up"
        end
      end
    end
    ```

    ## Basic Operations

    Just like `attribute`, there may also be a time where you have an operation **not** tied to the database.
    Maybe a search form, or a contact form that just sends an email.

    For these, you can use `Avram::Operation`:

    ```crystal
    # src/operations/search_data.cr
    class SearchData < Avram::Operation
      attribute query : String = ""
      attribute active : Bool = true

      def submit
        validate_required query

        yield self, UserQuery.new.name.ilike(query.value).active(active.value)
      end
    end
    ```

    > Note: The convention is to define a `submit` method that yields the operation, and your result;
    > however, you can name this method whatever you want with any signature.

    Using operations in HTML works exactly the same as the rest:

    ```crystal
    # src/pages/searches/new_page.cr
    class Searches::NewPage < MainLayout
      needs search_data : SearchData

      def content
        render_form(@search_data)
      end

      private def render_form(op)
        form_for Searches::Create do
          label_for op.query
          text_input op.query

          label_for op.active
          checkbox op.active

          submit "Filter Results"
        end
      end
    end
    ```

    Finally, using the operation in your action:

    ```crystal
    class Searches::Create < BrowserAction
      route do
        SearchData.new(params).submit do |operation, results|
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

    ## Saving without a params object

    This can be helpful if you’re saving something that doesn’t need an HTML form,
    like if you only need the params passed in the path.

    ```crystal
    SaveUser.create!(name: "Paul")

    # for updates
    SaveUser.update!(existing_user, name: "David")
    ```

    ## Sharing common validations, callbacks, etc.

    When using multiple operations for one model you often want to share a common set of
    validations, allowances, etc.

    You can do this with a module:

    ```crystal
    # src/operations/mixins/age_validation.cr
    module AgeValidation
      private def validate_old_enough_to_use_website
        # The value of age might be `nil` so we need to use `try`
        age.value.try do |value|
          if value < 13
            age.add_error "must be at least 13 to use this site"
          end
        end
      end
    end
    ```

    Then in your form:

    ```crystal
    # src/operations/save_admin_user.cr
    class SaveAdminUser < User::SaveOperation
      include AgeValidation
      permit_columns email, age

      before_save do
        validate_old_enough_to_use_website
        admin.value = true
      end
    end
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
      often a good idea to extract a new form for those cases.
    MD
  end
end
