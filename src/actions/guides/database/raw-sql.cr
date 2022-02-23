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
    posts_result_set = AppDatabase.query_all("SELECT * FROM posts", as: Post)
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
    complex_posts = AppDatabase.query_all(sql, as: ComplexPost)
    ```

    Believe it or not, that's all it takes! `complex_posts` is now of the type `Array(ComplexPost)`
    and ready to be used in your pages or returned by your JSON API.

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

    complex_posts = AppDatabase.query_all(
      sql,
      # 4.hours.ago maps to the $1 placeholder, and 1.hour.ago maps to the $2 placeholder
      args: [4.hours.ago, 1.hour.ago],
      as: ComplexPost
    )
    ```

    This returns `Array(ComplexPost)` where the posts were published_at between 4 hours ago, and 1 hour ago.

    > The `args` argument is always an Array, even for a single argument.

    ## Additional Supported Methods

    The `query_all` method is the most common since it returns an Array of rows. However,
    crystal-db supports many other methods you can use. Each of these are class methods
    called on your database class. (e.g. `AppDatabase`)

    * exec - Used to execute SQL. Best used with Inserts, Deletes, Updates, or queries like refreshing views.
    * scalar - Returns a single value like a select count, or other aggregate value
    * query_all - Returns an Array of records.
    * query_one - Returns a single records, or raises an exception if no record is found.
    * query_one? - Same as `query_one`, but will return `nil` instead of raising an exception.

    > Each of these methods use the same signature for convienience.

    ```crystal
    AppDatabase.exec "REFRESH MATERIALIZED VIEW reports"
    AppDatabase.scalar "SELECT SUM(amount) FROM payments WHERE user_id = $1", args: [user.id]
    # The `queryable` arg is used for logging within Breeze
    AppDatabase.query_all large_sql, queryable: "PostQuery", as: ComplexPost
    AppDatabase.query_one "SELECT * FROM users WHERE id = -1" # raises an exception
    AppDatabase.query_one? "SELECT * FROM users WHERE id = -1" # returns nil
    ```

    ### Escape hatch

    In addition to these methods, you can also drop down to crystal-db directly by using the `run` method
    which returns the `db` instance to the block.

    ```crystal
    AppDatabase.run do |crystal_db|
      # call any `DB::QueryMethods` from here as needed
    end
    ```
    MD
  end
end
