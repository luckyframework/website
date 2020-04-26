class Guides::Database::RawSql < GuideAction
  guide_route "/database/raw-sql"

  def self.title
    "Raw SQL and Queries"
  end

  def markdown : String
    <<-MD
    ## Executing Raw SQL

    We can execute raw sql using `Avram::Database` which gives us direct access to our app's
    [database instance](http://crystal-lang.github.io/crystal-db/api/latest/DB.html). The result
    of the query will be a [DB::ResultSet](http://crystal-lang.github.io/crystal-db/api/latest/DB/ResultSet.html)
    which we will later map to classes that can be easily used in our app.

    ```crystal
    posts_result_set = AppDatabase.run do |db|
      db.query_all "SELECT * FROM posts;"
    end
    ```

    ## Custom Queries

    Since we have direct access to the database instance, we can run whatever query we want as long as it's valid sql for the [postgresql driver that Lucky uses](https://github.com/will/crystal-pg).

    Let's create a query with a non-trivial `SELECT` statement that we can map to a Crystal class.

    > Note: This assumes we have post and user tables already created

    ```crystal
    sql = <<-SQL
      SELECT
        posts.id,
        posts.title,
        ('PREFIX: ' || posts.content) as custom_key, -- custom key for fun
        json_build_object(
          'name', users.name,
          'email', users.email
        ) as author
      FROM posts
      JOIN users
      ON users.id = posts.user_id;
    SQL
    ```

    ## Map the Query to a Class

    [crystal-db](https://github.com/crystal-lang/crystal-db) comes with a powerful [DB.mapping](https://github.com/crystal-lang/crystal-db/blob/master/src/db/mapping.cr) macro that makes it simple to map a database query to a class by defining the keys and types of each column.

    Let's create a `ComplexPost` class in our models folder and define the database mapping.

    ```crystal
    # src/models/complex_post.cr
    class ComplexPost
      DB.mapping({
        id: Int32,
        title: String,
        content: {
            type: String,
            nilable: false,
            key: "custom_key"
        },
        author: JSON::Any
      })
    end
    ```

    ## Putting it All Together

    Now we can make our query and instantiate `ComplexPosts` from the result easily using the `as` method.

    ```crystal
    complex_posts = AppDatabase.run do |db|
      db.query_all sql, as: ComplexPost
    end
    ```

    Believe it or not, that's all it takes! `complex_posts` is now of the type `Array(ComplexPost)` and ready to be used in your templates or returned by your JSON api.
    MD
  end
end
