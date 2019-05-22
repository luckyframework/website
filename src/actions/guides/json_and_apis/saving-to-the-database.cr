class Guides::JsonAndApis::SavingToTheDatabase < GuideAction
  ANCHOR_SAVING_TO_THE_DATABASE = "saving-to-the-database_"
  guide_route "/json-and-apis/saving-to-the-database"

  def self.title
    "Saving to the Database"
  end

  def markdown
    <<-MD
    <div id="#{ANCHOR_SAVING_TO_THE_DATABASE}"></div>

    ## Saving to the database

    Forms automatically know how to handle JSON params. They just need to be
    formatted in a way Avram knows how to handle.

    Let’s say you have a form called `ArticleForm`. Lucky will look for the data
    nested under an `article` key:

    > Remember to add `fillable {{field name}}` or the field will be ignored. In
    > this case, add `fillable title` to the `ArticleForm` to allow the `title`
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
        ArticleForm.create(params) do |form, article|
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
