class Guides::Tutorial::Queries < GuideAction
  guide_route "/tutorial/queries"

  def self.title
    "Writing Custom Queries"
  end

  def markdown : String
    <<-MD
    ## Querying Records

    At this point, we've stored records in the database by using the `SaveOperation` and `Avram::Factory` classes.
    To pull the data back out, we will use the Query classes. These query objects are located in your `src/queries/` directory.
    We can see there are already two files in here; `fortune_query.cr` and `user_query.cr`.

    ### Simple queries

    The most basic query you can run is `SELECT * FROM table_name`.
    To query all of the users (`SELECT * FROM users`) it's as simple as `UserQuery.new`. If you need a specific record,
    we can use the `find` method and pass in the primary key value for the record we are looking for. (e.g. `UserQuery.find(4)`)

    The query objects are considered "lazy" which means that just instantiating the class doesn't execute the query. To
    run the query, you'll either iterate the collection using a method like `each` or `map`, or you will ask for a single
    record like calling `find` or `first`.

    Here are a few simple examples:

    ```crystal
    # SELECT * FROM users;
    UserQuery.new

    # SELECT * FROM users WHERE id = 4;
    UserQuery.find(4)
    ```

    When you need to get more granular with your query, you will want to run a `WHERE` query. In Lucky each of the columns
    on a model have an associated query method that requires the proper type to be passed. This keeps your queries type-safe.

    ```crystal
    # SELECT * FROM users WHERE email = 'test@test.com';
    UserQuery.new.email("test@test.com")

    # SELECT * FROM meals WHERE favorite = 't' AND name = 'tacos';
    MealQuery.new.favorite(true).name("tacos")
    ```

    As you can see, the methods are chainable. If the type is `Bool` then you must pass a boolean value. Passing in a `nil` value
    when the type isn't nilable will cause a compile-time error.

    > For more information on querying records read the [Querying Records](#{Guides::Database::Querying.path}) guide.

    ## Adding a Query

    It would be nice to show the last 10 fortunes on our home page. We already have a spot on the page, we just need to add the
    code to our `Home::Index` action, and then display the results on the `Home::IndexPage` page.

    Let's open up our `Home::Index` action in `src/actions/home/index.cr`. Inside of the `else` branch, we will add our query.

    ```crystal
    # src/actions/home/index.cr
    get "/" do
      if current_user?
        redirect Me::Show
      else
        # ORDER BY created_at DESC LIMIT 10
        latest_fortunes = FortuneQuery.new.created_at.desc_order.limit(10)

        # Pass these fortunes to our IndexPage
        html IndexPage, fortunes: latest_fortunes
      end
    end
    ```

    Since we need to pass data from our action to our page, we must update the `Home::IndexPage`
    so it knows that it `needs` this data. Open up the `Home::IndexPage` in `src/pages/home/index_page.cr`.
    At the top of the class we can add our `needs` line:

    ```crystal
    # src/pages/home/index_page.cr
    class Home::IndexPage < AuthLayout
      needs fortunes : FortuneQuery

      def content
        # ...our page content
      end
    end
    ```

    The key we specified in our action was `fortunes`, and the value is an instance of the `FortuneQuery`. Keep in mind
    that the queries are "lazy", so at this point, the data still hasn't been fetched. We must iterate over this data,
    or select a single record.

    Our `needs` on the page gives us a method by the same name `fortunes` which we can use to iterate over. Let's add
    some code inside of that "container" div we added:

    ```crystal
    # src/pages/home/index_page.cr
    def content
      div class: "px-4 py-5 my-5 text-center" do
        # ... previous markup
      end
      div class: "container" do
        # Add this block of code here
        div class: "list-group list-group-flush border-bottom scrollarea" do
          fortunes.each do |fortune|
            link to: Fortunes::Show.with(fortune.id), class: "list-group-item list-group-item-action py-3 lh-tight" do
              div class: "d-flex w-100 align-items-center justify-content-between" do
                small time_ago_in_words(fortune.created_at), class: "text-muted"
              end
              div fortune.text, class: "col-10 mb-1 small"
            end
          end
        end

      end
    end
    ```

    At this point we should make sure things are still working. Boot your app (`lucky dev`) to make sure everything compiles.
    Then view the beautiful new list. Everything work? Great!

    ## Your Turn

    We've started really filling in our app, but we can always do better. Give a little refactor a shot!

    Try this...

    * Create a new `latest` method in your `FortuneQuery` class.
    * Update your `Home::Index` action to use the new `latest` method.
    * Add a new `name : String` column to your `User` model. (hint: generate a new migration)
    * Update your `UserFactory` to generate a random `name`.
    * Update existing user records with a random name. (hint: the guides mention "bulk updating")
    * Update the fortunes to display the user's name that wrote it.

    MD
  end
end
