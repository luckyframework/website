class Guides::JsonAndApis::SavingToTheDatabase < GuideAction
  ANCHOR_SAVING_TO_THE_DATABASE = "perma-saving-to-the-database"
  guide_route "/json-and-apis/saving-to-the-database"

  def self.title
    "Saving to the Database"
  end

  def markdown
    <<-MD
    #{permalink(ANCHOR_SAVING_TO_THE_DATABASE)}
    ## Saving to the database with JSON params

    Forms automatically know how to handle JSON params. They just need to be
    formatted in a way Avram knows how to handle.

    Let’s say you have an operation called `SaveArticle`. Lucky will look for the data
    nested under the `article` key:

    > Remember to add `permit_columns {{field name}}` or the field will be ignored. In
    > this case, add `permit_columns title` to the `SaveArticle` to allow the `title`
    > field to be saved.

    ```json
    {
      "article": {
        "title": "A new article"
      }
    }
    ```

    And then save it like you normally would:

    ```crystal
    class Api::Articles::Create < ApiAction
      route do
        SaveArticle.create(params) do |operation, article|
          if article
            json Articles::ShowSerializer.new(article), Status::Created
          else
            head Status::UnprocessableEntity
          end
        end
      end
    end
    ```

    > Remember to set the content type to `application/json` so Lucky knows that
    it should process the request as JSON.
    MD
  end
end
