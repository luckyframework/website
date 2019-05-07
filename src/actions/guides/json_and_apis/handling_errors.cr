class Guides::JsonAndApis::HandlingErrors < GuideAction
  guide_route "/json-and-apis/handling-errors"

  def self.title
    "Handling Errors"
  end

  def markdown
    <<-MD
    ## Handling errors productively

    The above example works, but it would be a pain to handle errors like this in
    every single action where we create something.

    Instead we'll use the `Errors::ShowSerializer` that is generated with a new
    Lucky project (`src/serializers/errors/show_serializer.cr`) to show errors anytime
    an error fails to save.

    ```crystal
    # in src/actions/errors/show.cr
    class Errors::Show < Lucky::ErrorAction
      def handle_error(error : Avram::InvalidFormError(T))
        if json?
          json Errors::ShowSerializer.new(
            message: "Failed to save",
            details: error.message
          ), Status::UnprocessableEntity
        else
          # Show regular error page if this happens with HTML request
          render_error_page status: 500
        end
      end
    end
    ```

    Now that invalid form errors are handled automatically, we can switch to
    using `create!` in our action:

    ```crystal
    class Api::Articles::Create < ApiAction
      route do
        # create! will raise if the params are invalid
        # The InvalidFormError will be caught and handled automatically
        article = ArticleForm.create!(params)
        json ShowJSON.new(article), Status::Created
      end
    end
    ```
    MD
  end
end
