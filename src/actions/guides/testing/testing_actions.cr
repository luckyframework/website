class Guides::Testing::TestingActions < GuideAction
  guide_route "/testing/testing-actions"

  def self.title
    "Testing Actions"
  end

  def markdown : String
    <<-MD
    ## Setup

    Located in your app's `spec/support/` directory is an `AppClient` that you can use to make requests
    to your app's Action classes. Use this object to set any custom headers, or params you need.

    ### Making requests

    All requests can be made by using `AppClient.exec`, and passing the action class. Lucky will automatically
    infer which HTTP method to use based on route defined in the Action class.

    ```crystal
    # GET /users
    AppClient.exec(Users::Index)

    # POST /posts
    AppClient.exec(Posts::Create)
    ```

    You can also pass path and query params using `with` if your Action requires them.

    ```crystal
    # PUT /users/1
    AppClient.exec(Users::Update.with(user.id))

    # DELETE /posts/3
    AppClient.exec(Posts::Delete.with(post.id))

    # or pass additional query params
    AppClient.exec(Posts::Search.with(q: "Lucky"))
    ```

    Read more on [URL generation](#{Guides::HttpAndRouting::LinkGeneration.path}).

    ### Setting body params

    The second argument to the `exec` method will take a `NamedTuple` of params you want to send.
    In most cases, these params will be sent to an [Operation](#{Guides::Database::ValidatingSaving.path}),
    so these params will need to be nested with the proper [param_key](#{Guides::Database::ValidatingSaving.path(anchor: Guides::Database::ValidatingSaving::ANCHOR_PARAM_KEY)}).

    ```crystal
    AppClient.exec(Posts::Create, post: {title: "My next Taco Dish", posted_at: 1.day.ago})

    AppClient.exec(Users::Update.with(user.id), user: {email: "updated@email.co"})
    ```

    ### Setting headers

    If you need to set custom headers, you'll use the `headers` method on an instance of the `AppClient`.

    ```crystal
    client = AppClient.new

    client
      .headers("Accept", "application/vnd.api.v1+json")
      .headers("Set-Cookie", "remember_me=1")
      .headers("Authorization", "Bearer abc123")

    # Then make your request:
    client.exec(Api::Users::Index)
    ```

    ### Creating methods for common setup

    Let's say your API uses a Range header to determine which range of items should be included.
    We can create a method on our `AppClient` to make this easier to reuse.

    ```crystal
    # spec/support/app_client.cr
    class AppClient < Lucky::BaseHTTPClient
      # ...

      def page(page : Int32, per_page = 10)
        # Set pagination headers
        headers("Range",  "order,id \#{page * per_page}; order=desc,max=\#{per_page}"
      end
    end
    ```

    Now we can use this in our tests

    ```crystal
    response = AppClient.new.page(2).exec(Api::Users::Index)
    ```

    ### User Auth

    If you generated your app with User Authentication, your API endpoints may require being
    authenticated to access those endpoints. You can use the `AppClient.auth(user)` method
    to set the proper header.

    ```crystal
    user = UserBox.create

    AppClient.auth(user).exec(Api::Records::Index)
    ```

    ## JSON Actions

    If you need to test your JSON API, or any action that has a JSON response, Lucky gives you some
    built-in helper methods to make testing responses easier.

    We will use this action as an example:

    ```crystal
    class Api::Rockets::Show < ApiAction
      get "/api/rockets/:rocket_id" do
        rocket = RocketQuery.find(rocket_id)
        json({id: rocket.id, type: rocket.type, name: rocket.name})
      end
    end
    ```

    ```crystal
    # spec/requests/api/rockets/show_spec.cr
    require "../../../spec_helper"

    describe Api::Rockets::Show do
      it "returns a 200 response with the rocket name" do
        rocket = RocketBox.create &.name("Dragon 1")
        response = AppClient.auth(current_user).exec(Api::Rockets::Show.with(rocket.id))

        # The JSON response should have the key `name` with a value `"Dragon 1"`.
        response.should send_json(200, name: "Dragon 1")
      end

      it "returns a 401 for unauthenticated requests" do
        response = AppClient.exec(Api::Rockets::Show.with(4))

        response.status_code.should eq(401)
      end
    end

    private def current_user : User
      UserBox.create &.email("me@lucky.org")
    end
    ```

    The `send_json` method will check that the HTTP status matches, and the JSON response
    contains your expected values.

    MD
  end
end
