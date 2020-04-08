class Guides::Database::DeletingRecords < GuideAction
  guide_route "/database/deleting-records"

  def self.title
    "Deleting records"
  end

  def markdown : String
    <<-MD
    ## Deleting Records

    ### Delete one

    Deleting a single record is done on the [model](#{Guides::Database::Models.path}) directly.

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

    * First, we need to add a new `soft_deleted_at : Time?` column to the table that needs soft deletes.

    ```
    # Run this in your terminal
    lucky gen.migration AddSoftDeleteToArticles
    ```

    * Open your new `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_soft_delete_to_articles.cr` file.

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
      # Include this module to add methods for
      # soft deleting and restoring
      include Avram::SoftDelete::Model

      table do
        # Add the new column to your model
        column soft_deleted_at : Time?
      end
    end
    ```

    * Next you need to update `src/queries/article_query.cr`.

    ```crystal
    class ArticleQuery < Article::BaseQuery
      # Include this module to add methods for
      # querying and soft deleting records
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

    ### Soft deleting in bulk

    You can bulk update a group of records as soft deleted with the `soft_delete` method on your Query object.

    ```crystal
    articles_to_delete = ArticleQuery.new.created_at.gt(3.years.ago)

    # Marks the articles created over 3 years ago as soft deleted
    articles_to_delete.soft_delete
    ```

    ### Restore a soft deleted record

    If you need to restore a soft deleted record, you can use the `restore` method.

    ```crystal
    # Set the `soft_deleted_at` back to `nil`
    article.restore
    ```

    ### Bulk restoring soft deleted records

    The same as we can bulk soft delet records, we can also bulk update to restore them with
    the `restore` method.

    ```crystal
    articles_to_restore = ArticleQuery.new.published_at.lt(1.week.ago)

    # Restore recently published articles
    articles_to_restore.restore
    ```

    ### Query soft deleted records

    ```crystal
    # Return all articles that are not soft deleted
    ArticleQuery.new.only_kept

    # Return all articles that are soft deleted
    ArticleQuery.new.only_soft_deleted
    ```

    ### Default queries without soft deleted

    If you want to filter out soft deleted records by default, it's really easy to do.
    Just add the `only_kept` method to your `initialize`.

    ```crystal
    class ArticleQuery < Article::BaseQuery
      include Avram::SoftDelete::Query

      # All queries will scope to only_kept
      def initialize
        only_kept
      end
    end
    ```

    ```crystal
    # Return all articles that are not soft deleted
    ArticleQuery.new
    ```

    Even with your default scope, you can still return soft deleted records when you need.

    ```crystal
    # Return all articles, both `kept` and soft deleted
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
