class Guides::Frontend::HtmlForms < GuideAction
  guide_route "/frontend/html-forms"

  def self.title
    "HTML Forms"
  end

  def markdown : String
    <<-MD
    ### Overview

    You can generate form tags like `<form>`, `<input>`, etc... using
    [methods like `form` and `input`](#{Guides::Frontend::RenderingHtml.path}),
    but the recommended way is to use Lucky's form helpers.

    All of these methods will go in your `content` method of your page, or in a component.

    ## Form tag

    The `form_for` method takes any route or [Action Class](#{Guides::HttpAndRouting::RoutingAndParams.path}), any html options, and a block
    to encompass the whole form.

    As well as defining the `<form>` tag for you, the `form_for` method will also include an optional
    `csrf_hidden_input` by default. To disable this option, look in your `config/form_helpers.cr`.

    ```crystal
    form_for(Posts::Create, class: "inline-form") do
    end
    ```

    Will generate this

    ```html
    <form method="post" action="/posts" class="inline-form">
      <input type="hidden" name="_csrf" value="some_token" />
    </form>
    ```

    The Action class already has a route defined that defines which HTTP method to use (GET, PUT, etc.). When passing
    the action class in, Lucky will use the defined HTTP method automatically.

    You can also pass in a route path using `with` if the action requires params to be passed in.

    ```crystal
    form_for(Posts::Create.with(author_id: @current_user.id)) do
    end
    ```

    ### Custom forms

    If you need more control over how your form is displayed, you can always use the `form`
    method directly, and pass any options you'd like.

    ```crystal
    form(method: "get", class: "custom-form", action: Search::Index.path) do
    end
    ```

    ## Input fields

    All of the input helper methods take an `Avram::PermittedAttribute`. These are created
    from declaring an `attribute` or `permit_columns` in your `Avram::Operation`.
    See the [Operations Guide](#{Guides::Database::ValidatingSaving.path(anchor: Guides::Database::ValidatingSaving::ANCHOR_PERMITTING_COLUMNS)}) for more info.

    > For these examples, `op` will refer to an instance of an `Avram::Operation` (e.g. `SaveUser`).

    ### text input

    ```crystal
    text_input(op.full_name, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="text"
           id="param_key_full_name"
           name="param_key:full_name"
           value=""
           class="custom-input"
           required />
    ```

    ### password input

    ```crystal
    password_input(op.password, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="password"
           id="param_key_password"
           name="param_key:password"
           value=""
           class="custom-input"
           required />
    ```

    ### email input

    ```crystal
    email_input(op.email, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="email"
           id="param_key_email"
           name="param_key:email"
           value=""
           class="custom-input"
           required />
    ```

    ### hidden input

    ```crystal
    hidden_input(op.shh_secret, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="hidden"
           id="param_key_shh_secret"
           name="param_key:shh_secret"
           value=""
           class="custom-input"
           required />
    ```

    ### file input

    ```crystal
    file_input(op.users_face, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="file"
           id="param_key_users_face"
           name="param_key:users_face"
           value=""
           class="custom-input"
           required />
    ```

    ### color input

    ```crystal
    color_input(op.theme_color, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="color"
           id="param_key_theme_color"
           name="param_key:theme_color"
           value=""
           class="custom-input"
           required />
    ```

    ### number input

    ```crystal
    number_input(op.score, attrs: [:required], class: "custom-input", min: "0", max: "10")
    ```

    ```html
    <input type="number"
           id="param_key_score"
           name="param_key:score"
           value=""
           class="custom-input"
           min="0"
           max="10"
           required />
    ```

    ### url input

    ```crystal
    url_input(op.website, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="url"
           id="param_key_website"
           name="param_key:website"
           value=""
           class="custom-input"
           required />
    ```

    ### search input

    ```crystal
    search_input(op.search, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="search"
           id="param_key_search"
           name="param_key:search"
           value=""
           class="custom-input"
           required />
    ```

    ### range input

    ```crystal
    range_input(op.distance, attrs: [:required], class: "custom-input", min: "10", max: "100", step: "10")
    ```

    ```html
    <input type="range"
           id="param_key_distance"
           name="param_key:distance"
           value=""
           class="custom-input"
           min="0"
           max="100"
           step="10"
           required />
    ```

    ### telephone input

    ```crystal
    telephone_input(op.mobile_num, attrs: [:required], class: "custom-input", pattern: "[0-9]{3}-[0-9]{3}-[0-9]{4}")
    ```

    ```html
    <input type="tel"
           id="param_key_mobile_num"
           name="param_key:mobile_num"
           value=""
           class="custom-input"
           pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}"
           required />
    ```

    ### time input

    ```crystal
    time_input(op.appointment_time, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="time"
           id="param_key_appointment_time"
           name="param_key:appointment_time"
           value=""
           class="custom-input"
           required />
    ```

    ### date input

    ```crystal
    date_input(op.anniversary, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="date"
           id="param_key_anniversary"
           name="param_key:anniversary"
           value=""
           class="custom-input"
           required />
    ```

    ### datetime input

    ```crystal
    datetime_input(op.expired_at, attrs: [:required], class: "custom-input")
    ```

    ```html
    <input type="datetime-local"
           id="param_key_expired_at"
           name="param_key:expired_at"
           value=""
           class="custom-input"
           required />
    ```

    > The `datetime` input generates a `type="datetime-local"`, and not `type="datetime"`.
    > The [datetime input](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime)
    > is deprecated in favor of the new one. As always, be sure to check browser support since
    > these are still not fully recognized.

    ### custom input

    You can use the `input` method to craft any custom input you'd like.

    ```crystal
    input(type: "text", value: "taco", name: "food", attrs: [:required])
    ```

    ```html
    <input type="text" value="taco" name="food" required />
    ```

    ## Textareas

    The content of the `<textarea>` will come from the value of the attribute (i.e. `op.content`)

    ```crystal
    textarea(op.content, attrs: [:readonly], rows: "10", cols: "20")
    ```

    ```html
    <textarea id="param_key_content" name="param_key:content" rows="10" cols="20" readonly>
    </textarea>
    ```

    ## Select fields

    For select fields, you'll use a combination of `select_tag` and the `options_for_select` methods.
    The selected value will be determined by the current value of the attribute (i.e. `op.car_make`)

    ```crystal
    select_tag(op.car_make, class: "custom-select") do
      options_for_select(op.car_make, [{"Honda", 1}, {"Toyota", 2}])
    end
    ```

    ```html
    <select name="param_key:car_make" class="custom-select">
      <option value="1">Honda</option>
      <option value="2" selected="true">Toyota</option>
      <option value="3">Ford</option>
      <option value="4">Volkswagen</option>
    </select>
    ```

    The second argument to `options_for_select` takes an `Array(Tuple(String, String | Int32 | Int64))`. If your data is coming from a query, you can easily map that data in to this format.

    ```crystal
    # Use with `options_for_select(op.car_make, options_for_cars)`
    private def options_for_cars
      CarQuery.all.map do |car|
        {car.make, car.id}
      end
    end
    ```

    ## Checkboxes / Radios

    ### Checkbox

    The `checkbox` method will auto generate a secondary hidden input that will hold the
    unchecked value of your attribute. This allows params to still contain a value even if a
    checkbox is not checked.

    ```crystal
    checkbox(op.with_cheese, "no", "yes", class: "custom-check")
    ```

    ```html
    <input type="hidden" name="param_key:with_cheese" value="no" />
    <input type="checkbox"
           id="param_key_with_cheese"
           name="param_key:with_cheese"
           value="yes"
           class="custom-check"
           checked="true" />
    ```

    ### Radio

    ```crystal
    input(op.question_five, type: "radio", name: "\#{op.param_key}:\#{op.question_five.name}", value: "Yes")
    input(op.question_five, type: "radio", name: "\#{op.param_key}:\#{op.question_five.name}", value: "No")
    ```

    ```html
    <input type="radio"
           name="param_key:question_five"
           value="Yes" />
    <input type="radio"
           name="param_key:question_five"
           value="No" />
    ```

    > ISSUE REF: https://github.com/luckyframework/lucky/issues/1023

    ## Buttons

    ### button tag

    ```crystal
    button("Go!", role: "submit", class: "btn")
    ```

    ```html
    <button role="submit" class="btn">Go!</button>
    ```

    ### submit input

    ```crystal
    submit("Go!", class: "btn")
    ```

    ```html
    <input type="submit" value="Go!" class="btn" />
    ```

    ## Labels

    The text will be derived from the name of the attribute.

    ```crystal
    label_for(op.first_name, class: "custom-label")
    ```

    If you need custom text, you can pass it in as the second argument.

    ```crystal
    label_for(op.first_name, "Enter your First name:", class: "custom-label")
    ```

    or use a block for extra customization

    ```crystal
    label_for(op.first_name) do
      strong("First Name: ")
    end
    ```

    ```html
    <label for="param_key_first_name" class="custom-label">First Name</label>
    ```

    ## Saving Data

    HTML Forms in Lucky are based around the concept of [Operations](#{Guides::Database::ValidatingSaving.path}). We use these for securing param values from form inputs, and doing validations.

    For info on interacting with databases, see the [saving
    data with operations](#{Guides::Database::ValidatingSaving.path(anchor: Guides::Database::ValidatingSaving::ANCHOR_USING_WITH_HTML_FORMS)}) guide.

    ## Displaying Errors

    If your permitted column / attribute fails any sort of validation, it's common to
    display an error about why it failed. For this, Lucky generates a component you can use
    in `src/components/shared/field_errors.cr`.

    ```crystal
    mount Shared::FieldErrors.new(op.email)
    ```

    ```html
    <div class="error">Email must be valid</div>
    ```

    ## Simple Example

    ```crystal
    # src/operations/save_post.cr
    class SavePost < Post::SaveOperation
      permit_columns title, body
    end

    # src/pages/posts/edit_page.cr
    class Posts::EditPage < MainLayout
      needs op : SavePost

      def content
        form_for(Posts::Update) do
          para do
            label_for(@op.title)
            text_input(@op.title)
            error_for(@op.title)
          end

          para do
            label_for(@op.body)
            textarea(@op.body)
            error_for(@op.body)
          end

          submit("Update Post", class: "btn")
        end
      end

      private def error_for(field)
        mount Shared::FieldErrors.new(field)
      end
    end
    ```

    ## Shared Components

    In the above form we had to write a fair amount of code to show a label, input, and error.
    Lucky generates a `Shared::Field` component that you can use and customize to make
    this simpler. It is found in `src/components/shared/field.cr`, and is used in pages
    like this:

    ```crystal
    # This will render a label, an input, and any validation errors for the 'name'
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
    MD
  end
end
