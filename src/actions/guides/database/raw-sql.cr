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

    Since we have direct access to the database instance, we can run whatever query we want as
    long as it's valid sql for the [postgresql driver that Lucky uses](https://github.com/will/crystal-pg).

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

    [crystal-db](https://github.com/crystal-lang/crystal-db) comes with a powerful
    [DB.mapping](https://github.com/crystal-lang/crystal-db/blob/master/src/db/mapping.cr) macro that makes
    it simple to map a database query to a class by defining the keys and types of each column.

    Let's create a `ComplexPost` class in our models folder and define the database mapping.

    ```crystal
    # src/models/complex_post.cr
    class ComplexPost
      DB.mapping({
        id: Int64,
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

    Believe it or not, that's all it takes! `complex_posts` is now of the type `Array(ComplexPost)`
    and ready to be used in your templates or returned by your JSON api.

    ## SQL with dynamic args

    If you need to pass in an external value to your query, you will need to add placeholders
    where your values will be inserted. This is to avoid doing string interpolation which could
    lead to potential security holes and [SQL injection](https://www.w3schools.com/sql/sql_injection.asp).

    The placeholder for raw SQL uses the `$N` notation where `N` is the number of args being passed in.
    For example, if you need to pass in 2 args, you'll use the placeholder `$1` for the first arg value,
    and `$2` for the second arg value, and so on.

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
    JOIN users ON users.id = posts.user_id
    WHERE posts.published_at BETWEEN ($1 AND $2);
    SQL

    complex_posts = AppDatabase.run do |db|
      db.query_all sql, args: [4.hours.ago, 1.hour.ago], as: ComplexPost
    end
    ```

    This returns `Array(ComplexPost)` where the posts were published_at between 4 hours ago, and 1 hour ago.

    > The `args` argument is always an Array, even for a single argument.

    MD
  end
end
