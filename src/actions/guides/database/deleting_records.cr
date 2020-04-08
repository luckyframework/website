class Guides::Database::DeletingRecords < GuideAction
  guide_route "/database/deleting-records"

  def self.title
    "Deleting records"
  end

  def markdown : String
    <<-MD
    ## Deleting Records

    ### Delete one

    Deleting a single record is actually done on the [model](#{Guides::Database::Models.path}) directly.
    Since each query returns an instance of the model, you can just call `delete` on that record.

    ```crystal
    user = UserQuery.find(4)

    # DELETE FROM users WHERE users.id = 4
    user.delete
    ```

    ### Bulk delete

    If you need to bulk delete a group of records based on a where query, you can use `delete` at
    the end of your query. This returns the number of records deleted.

    ```crystal
    # DELETE FROM users WHERE banned_at IS NOT NULL
    UserQuery.new.banned_at.is_not_nil.delete
    ```

    ## Soft Deletes

    A "soft delete" is when you want to hide a record as if it were deleted, but you want to keep the actual
    record in your database. This allows you to restore the record without losing any previous data or associations.

    Avram comes with some built-in modules to help working with soft deleted records a lot easier. Let's add it
    to an existing `Article` model.

    * We need to add a new `soft_deleted_at : Time?` column to our table that we want soft deletes.

    ```
    # Run this in your terminal
    lucky gen.migration AddSoftDeleteToArticle
    ```

    * Open your new `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_soft_delete_to_article.cr` file.

    ```crystal
    def migrate
      alter table_for(Article) do
        add soft_deleted_at : Time?
      end
    end
    ```

    * Now open your `src/models/article.cr` file.

    ```crystal
    class Article < BaseModel
      # Include this module
      include Avram::SoftDelete::Model

      table do
        # Add this to your table
        column soft_deleted_at : Time?
      end
    end
    ```

    * Next you just need to update `src/queries/article_query.cr`.

    ```crystal
    class ArticleQuery < Article::BaseQuery
      # Add this module
      include Avram::SoftDelete::Query
    end
    ```

    ### Marking a record as soft deleted

    Your model instance will now have a `soft_delete` method to mark that record as soft deleted, as well as,
    a `soft_deleted?` method to check if the record has been marked as soft deleted.

    ```crystal
    article = ArticleQuery.first

    # Check to see if soft_deleted_at is present
    article.soft_deleted? #=> false

    # Save the record as soft deleted
    article.soft_delete

    # Reload the model to get the new value
    article.reload.soft_deleted? #=> true
    ```

    ### Marking all records as soft deleted

    You can bulk update a group of records as soft deleted with the `soft_delete` method called on a Query object
    instead of the model directly.

    ```crystal
    articles_to_delete = ArticleQuery.new.created_at.gt(3.years.ago)

    # Marks only the articles created over 3 years ago as soft deleted
    articles_to_delete.soft_delete
    ```

    ### Restore a soft deleted record

    If you need to restore a soft deleted record, you can use the `restore` method.

    ```crystal
    # Set the `soft_deleted_at` back to `nil`
    article.restore
    ```

    ### Restoring all soft deleted records

    The same as bulk updating records as soft deleted, we can also bulk update to restore them with
    the `restore` method.

    ```crystal
    articles_to_restore = ArticleQuery.new.only_soft_deleted

    # Restore all of the soft deleted records
    articles_to_restore.restore
    ```

    ### Query soft deleted records

    ```crystal
    # Return all articles that are not soft deleted
    ArticleQuery.new.only_kept

    # Return all articles that are soft deleted
    ArticleQuery.new.only_soft_deleted

    # Return all articles whether soft deleted or not
    ArticleQuery.new.with_soft_deleted
    ```

    ## Truncating

    ### Truncate table

    If you need to delete every record in the entire table, you can use `truncate`.

    `TRUNCATE TABLE users`

    ```crystal
    UserQuery.truncate
    ```

    ### Truncate database

    You can also truncate your entire database by calling `truncate` on your database class.

    ```crystal
    AppDatabase.truncate
    ```

    > This method is great for tests; horrible for production. Also note this method is not chainable.
    MD
  end
end
