class Guides::Database::ValidatingSavingDeleting < GuideAction
  ANCHOR_USING_WITH_HTML_FORMS = "perma-using-with-html-forms"
  guide_route "/database/validating-saving-deleting"

  def self.title
    "Validating, Saving, and Deleting"
  end

  def markdown
    <<-MD
    ## Setting up a form

    When you set up a model, a `{ModelName}::BaseForm` will be created so that you can inherit
    from it and customize validations, callbacks, and what fields are allowed to be
    filled. `{ModelName}::BaseForm` automatically defines a form field for each model field.

    We’ll be using the migration and model from the [Querying
    guide](#{Guides::Database::Querying.path}). Once you have that set up, let’s set
    up a form:

    ```crystal
    # src/forms/user_form.cr
    class UserForm < User::BaseForm
    end
    ```

    > You can have more than one form object to save a record in different ways.
    For example, default Lucky apps have a `SignUpForm` specifically for handling
    user sign ups.

    ## Allowing params to be saved

    By default you won’t be able to set any data from params. This is a security
    measure to make sure that parameters can only be set that you want to allow
    users to fill out. For example, you might not want your users to be able to
    set an admin status through the `UserForm`.

    To allow a field to be saved to the database, use the `fillable` macro:

    ```crystal
    # src/forms/user_form.cr
    class UserForm < User::BaseForm
      fillable name
    end
    ```

    Now you will be able to fill out the user’s name with form params.

    ## Creating records

    > Actions have a `params` method that returns a `LuckyWeb::Params` object.
    This is used by the form to get form params that are set by [submitting an
    HTML form](##{ANCHOR_USING_WITH_HTML_FORMS}) or [when saving with a JSON API](#{Guides::JsonAndApis::SavingToTheDatabase.path(anchor: Guides::JsonAndApis::SavingToTheDatabase::ANCHOR_SAVING_TO_THE_DATABASE)}).

    To create a record, you pass a block that is run whether the save is
    successful or not.

    You will *always* receive the form object, but you will only get the saved
    user if there are no errors while saving. If there are errors, the user will
    be `nil`.

    ```crystal
    # inside of an action with some form params
    UserForm.create(params) do |form, user|
      if user # the user was saved
        render Users::ShowPage, user: user
      else
        render Users::NewPage, form: form
      end
    end
    ```

    ## Updating records

    In contrast to `create`, `update` will always pass the record to the block. To check
    if any changes were persisted, you can call `form.saved?`, or `form.valid?`
    to check if the submitted data was saved.

    ```crystal
    # inside of an action with some form params
    user = UserQuery.new.first
    UserForm.update(user, params) do |form, updated_user|
      if form.saved?
        render Users::ShowPage, user: updated_user
      else
        render Users::NewPage, form: form
      end
    end
    ```

    ### Update with `update!`

    `update!` will raise if the form fails to save or is invalid.
    This version is often used when [writing JSON APIs](#{Guides::JsonAndApis::RenderingJson.path})
    or for creating sample data in your the seed tasks in the `/tasks` folder.

    ```crystal
    user = UserQuery.new.first
    # Returns the updated user or raises
    updated_user = UserForm.update!(user, params)
    ```

    ## Using with JSON endpoints

    See [Writing JSON APIs guide](#{Guides::JsonAndApis::RenderingJson.path(anchor: Guides::JsonAndApis::SavingToTheDatabase::ANCHOR_SAVING_TO_THE_DATABASE)}).

    #{permalink(ANCHOR_USING_WITH_HTML_FORMS)}
    ## Using with HTML forms

    You can use forms in HTML like this:

    > Remember: you *must* mark a field as `fillable` in order to use it in a
    > form. If it isn’t fillable the program will not compile.

    ```crystal
    # src/pages/users/new_page.cr
    class Users::NewPage < MainLayout
      needs user_form : UserForm

      def content
        render_form(@user_form)
      end

      private def render_form(f)
        form_for Users::Create do
          label_for f.name
          text_input f.name
          errors_for f.name

          submit "Save User"
        end
      end
    end
    ```

    > A private method `render_form` is extracted because it makes it easier to
    reference the form as `f`. It also makes it easier to see what a page looks like
    with a quick glance at the `render` method.

    ```crystal
    class Users::Create < BrowserAction
      route do
        # params will have the form params sent from the HTML form
        UserForm.create(params) do |form, user|
          if user # if the user was saved
            redirect to: Home::Index
          else
            # re-render the NewPage so the user can correct their mistakes
            render NewPage, user_form: form
          end
        end
      end
    end
    ```

    ### Simplify inputs with `Shared::Field`

    In the above form we had to write a fair amount of code to show a label, input,
    and errors tag. Lucky generates a `Shared::Field` component that you can use
    and customize to make this simpler. It is found in `src/components/shared/field.cr`
    and is used in pages like this:

    ```crystal
    # This will render a label, an input, and any errors for the 'name'
    mount Shared::Field.new(f.name)

    # You can customize the generated input
    mount Shared::Field.new(form.email), &.email_input
    mount Shared::Field.new(form.email), &.email_input(autofocus: "true")
    mount Shared::Field.new(form.username), &.email_input(placeholder: "Username")

    # You can append to or replace the HTML class on the input
    mount Shared::Field.new(form.name), &.text_input(append_class: "custom-input-class")
    mount Shared::Field.new(form.nickname), &.text_input(replace_class: "compact-input")
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
    email_input f.email, optional_html_attributes: "anything"
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
    checkbox f.admin, value: "true"
    ```

    ### Select with options

    ```crystal
    # Assuming you have a form with a fillable category_id
    select_input f.category_id do
      options_for_select(f.category_id, categories_for_select)
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
    label_for f.title # Will display "Title"
    label_for f.title, "Custom Title" # Will display "Custom Title"
    label_for f.title do
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
    `validate_required`. They will run after the `prepare` callback. This way data
    with missing fields will never be sent to the database.

    ### Using validations

    You can use validations inside of the `prepare` callback:

    ```crystal
    class UserForm < User::BaseForm
      fillable name, password, password_confirmation, terms_of_service, age

      def prepare
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
    end
    ```

    The `prepare` method is called when you call `valid?` on the form or when you
    try to `save` or `update` it.

    ## What are fields?

    First you’ll need to know that the fields defined in the form do not return the
    value of the field. They return a `Avram::Field` that contains the value
    of the field, the name of the field, the param value, and any errors the field
    has.

    This means that to access their value you must call `value` on the field.

    ```crystal
    class UserForm < User::BaseForm
      def prepare
        pp name.value
      end
    end
    ```

    ## Custom validations

    You can easily create your own validations. For example, let’s say we want to
    make sure the user is old enough to use the site.

    ```crystal
    def prepare
      validate_user_is_old_enough
    end

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
    by adding a new form. For example you might have a `SignUpForm` for a `User`
    that encrypts the users password and sends a welcome email after saving. Or you
    might have an `AdminUserForm` that saves a user and sends an admin specific
    email.

    ### Prepare callback

    The `prepare` callback is run whenever a form is validated or saved. It is
    customized by defining a `prepare` method. Validations and custom parsing
    that is required for validation generally go in this callback.

    ```crystal
    class PostForm < Post::BaseForm
      def prepare
        validate_size_of title, min: 3
      end
    end
    ```

    ### Callbacks for running before and after save

    * `before_save`
    * `before_create`
    * `before_update`
    * `after_save`
    * `after_create`
    * `after_update`

    Create a method you'd like to run and then pass the method name to the
    callback macro. Note that the methods used by the `after_*` callbacks needs
    to accept the newly created record. In this example, a `Post`.

    ```crystal
    class PostForm < Post::BaseForm
      before_save run_this_before_save
      after_create run_this_after_create

      def run_this_before_save
        # do something
      end

      def run_this_after_create(newly_created_post : Post)
        # do something
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
        CommentForm.create(params, post_id: post.id) do |form, comment|
          # Do something with the form and comment
        end
      end
    end
    ```

    This sets the `post_id` when instantiating the form. You can pass anything
    that is defined as a `column` on your model. Note that the fields are type
    safe, so you don't need to worry about typos or passing the wrong types.
    Lucky is set up to make sure it works automatically.

    ## Passing extra data to forms

    Sometimes you need to pass extra data to forms that aren't in the form params.
    For example you might want to pass the currently signed in user so that you know
    who created a record. Here's how you do this:

    ```crystal
    # This is a great way to pass in an associated record
    class UserForm < User::BaseForm
      needs current_user : User

      def prepare
        modified_by_id.value = current_user.id
      end
    end

    UserForm.create(params, current_user: a_user) do |form, user|
      # do something
    end
    ```

    This will make it so that you must pass in `current_user` when creating or updating
    the `UserForm`. It will make a getter available for `current_user` so you can use
    it in the form, like in the `prepare` method shown in the example.

    ### Declaring needs only for update, create, or save

    Sometimes you only want to pass extra data when creating or updating a record.
    You can use the `on` option to do that:

    * `:update` if only required for update
    * `:create` if only required for create
    * `:save` if required for update and create, but not when calling `new`

    ```crystal
    class CommentForm < Comment::BaseForm
      needs author : User, on: :create # can also be `:update`, `:save`

      def prepare
        author.try do |user|
          authored_by_id.value = user.id
        end
      end
    end
    ```

    > Note that `author` is not required when calling `UserForm.new` when using
    the `on` option. This means `author` can be `nil` in the form. That's why we
    needed to use `try` in the `prepare` method.

    ```crystal
    # You must pass an author when creating
    CommentForm.create(params, author: a_user) do |form, user|
      # do something
    end

    # But you can't when you are updating
    CommentForm.update(comment, params) do |form, user|
      # do something
    end

    # You also can't pass it in when instantiating a new CommentForm
    CommentForm.new
    ```

    > **When should I use `on`?** If you are building an server rendered HTML app
    then you will almost always wants to use `on :save|:update|:create` because
    you will call `MyForm.new` without the needs. If you are building a JSON API
    you may want to omit the `on` option since you rarely use `.new`. If you omit
    `on` then you don't need to worry about the value ever being `nil`, which can
    make your program more reliable and easier to understand.

    ## Virtual fields

    Sometimes you want users to submit data that isn't saved to the database. For that
    we use `virtual`.

    Here's an example of using `virtual` to create a sign up form:

    ```crystal
    # First we create a model
    # src/models/user.cr
    class User < BaseModel
      table :users do
        field name : String
        field email : String
        field encrypted_password : String
      end
    end
    ```

    ```crystal
    # src/forms/sign_up_form.cr
    require "crypto/bcrypt/password"

    class SignUpForm < User::BaseForm
      # These are fields that will be saved to the database
      fillable name, email
      # Fields that users can fill out, but aren't saved to the database
      virtual password : String
      virtual password_confirmation : String
      virtual terms_of_service : Bool

      def prepare
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

    ### Using virtual fields in an HTML form

    Using virtual fields in HTML works exactly the same as with database fields:

    ```crystal
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < MainLayout
      needs sign_up_form : SignUpForm

      def content
        render_form(@sign_up_form)
      end

      private def render_form(f)
        form_for SignUps::Create do
          # labels and errors_for ommitted for brevity
          f.text_input f.name
          f.text_input f.email
          f.password_input f.password
          f.password_input f.password_confirmation
          f.checkbox f.terms_of_service

          submit "Sign up"
        end
      end
    end
    ```

    ## Virtual Forms

    Just like `virtual` fields, there may also be a time where you have a form **not** tied to the database. Maybe a search form, or a contact form that just sends an email.

    For these, you can use `Avram::VirtualForm`:

    ```crystal
    # src/forms/search_form.cr
    class SearchForm < Avram::VirtualForm
      virtual query : String = ""
      virtual active : Bool = true

      def submit
        validate_required query

        yield self, UserQuery.new.name.ilike(query.value).active(active.value)
      end
    end
    ```
    > Note: The convention is to define a `submit` method that yields the form, and your result; however, you can name this method whatever you want with any signature.

    Using virtual forms in HTML works exactly the same as the rest:

    ```crystal
    # src/pages/searches/new_page.cr
    class Searches::NewPage < MainLayout
      needs search_form : SearchForm

      def content
        render_form(@search_form)
      end

      private def render_form(f)
        form_for Searches::Create do
          label_for f.query
          text_input f.query

          label_for f.active
          checkbox f.active

          submit "Filter Results"
        end
      end
    end
    ```

    Finally, using the virtual form in your action:

    ```crystal
    class Searches::Create < BrowserAction
      route do
        SearchForm.new(params).submit do |form, results|
          if form.valid?
            render SearchResults::IndexPage, users: results
          else
            render Searches::NewPage, search_form: form
          end
        end
      end
    end
    ```


    ## Saving forms without a params object

    This can be helpful if you’re saving something that doesn’t need an HTML form,
    like if you only need the params passed in the path.

    ```crystal
    UserForm.create!(name: "Paul")

    # for updates
    UserForm.update!(existing_user, name: "David")
    ```

    ## Sharing common validations, callbacks, etc.

    When using multiple forms for one model you often want to share a common set of
    validations, allowances, etc.

    You can do this with a module:

    ```crystal
    # src/forms/mixins/age_validation.cr
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
    # src/forms/admin_user_form.cr
    class AdminUserForm < User::BaseForm
      include AgeValidation
      fillable email, age

      def prepare
        # Call the validation
        validate_old_enough_to_use_website
        admin.value = true
      end
    end
    ```

    ## Ideas for naming

    In Lucky it is common to have multiple forms per model. This makes it easier to
    understand what a form does and makes them easier to change later without
    breaking other flows.

    Here are some ideas for naming:

    * `Csv{ModelName}Form` - great for forms that get data from a CSV. e.g. `CsvUserImportForm`
    * `SignUpForm` - for signing up a new user. Encrypt passwords, send welcome emails, etc.
    * `SignInForm` - check that passwords match
    * `Admin{ModelName}Form` - sometimes admin can set more fields than a regular user. It’s
      often a good idea to extract a new form for those cases.
    MD
  end
end
