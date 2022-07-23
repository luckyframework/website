class Guides::JsonAndApis::SavingToTheDatabase < GuideAction
  ANCHOR_SAVING_TO_THE_DATABASE = "perma-saving-to-the-database"
  guide_route "/json-and-apis/saving-to-the-database"

  def self.title
    "Saving to the Database"
  end

  def markdown : String
    <<-MD
    #{permalink(ANCHOR_SAVING_TO_THE_DATABASE)}
    ## Saving to the database with JSON params

    Operations automatically know how to handle JSON params. They just need to be
    formatted in a way Avram knows how to handle.

    Let’s say you have an operation called `SaveArticle`. Lucky will look for the data
    nested under the `article` key. The key is derived from the model name.

    We need to remember to add columns `permit_columns {{column name}}` or
    the attribute will be ignored. In this case, add `permit_columns title` to
    the `SaveArticle` to allow the `title` field to be saved. Learn more
    about [permitting columns to be saved with params](#{Guides::Database::SavingRecords.path(anchor: Guides::Database::SavingRecords::ANCHOR_PERMITTING_COLUMNS)}).

    ```crystal
    class SaveArticle < Article::SaveOperation
      permit_columns title
    end
    ```

    > By default Avram will look for the params under the `article` key. You
    > can [change the param key](#{Guides::Database::SavingRecords.path(anchor: Guides::Database::SavingRecords::ANCHOR_PARAM_KEY)})
    > to anything you want though.

    Then submit these params:

    > Remember to set the `Content-type` header to `application/json` so
    > Lucky knows that it should process the params as JSON.

    ```json
    {
      "article": {
        "title": "A new article"
      }
    }
    ```

    And save it in an Action:

    ```crystal
    class Api::Articles::Create < ApiAction
      post "/api/articles" do
        article = SaveArticle.create!(params)
        head HTTP::Status::Created
      end
    end
    ```

    You'll note that we use `create!` instead of `create` with a block. This
    means that Avram will raise an error if the operation fails. This error
    is handled by `Errors::Show`. By default Lucky handles invalid operations
    with a nice JSON error message that includes what went wrong, and what param
    caused the issue.

    Learn more about this in the [error
    handling guide](#{Guides::HttpAndRouting::ErrorHandling.path})
    MD
  end
end
