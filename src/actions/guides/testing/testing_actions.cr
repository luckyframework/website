class Guides::Testing::TestingActions < GuideAction
  guide_route "/testing/testing-actions"

  def self.title
    "Testing Actions"
  end

  def markdown : String
    <<-MD
    ## Setup

    Located in your app's `spec/support/` directory is an `ApiClient` that you can use to make requests
    to your app's Action classes. Use this object to set any custom headers, or params you need.

    ### Making requests

    All requests can be made by using `ApiClient.exec`, and passing the action class. Lucky will automatically
    infer which HTTP method to use based on route defined in the Action class.

    ```crystal
    # GET /users
    ApiClient.exec(Users::Index)

    # POST /posts
    ApiClient.exec(Posts::Create)
    ```

    You can also pass path and query params using `with` if your Action requires them.

    ```crystal
    # PUT /users/1
    ApiClient.exec(Users::Update.with(user.id))

    # DELETE /posts/3
    ApiClient.exec(Posts::Delete.with(post.id))

    # or pass additional query params
    ApiClient.exec(Posts::Search.with(q: "Lucky"))
    ```

    Read more on [URL generation](#{Guides::HttpAndRouting::LinkGeneration.path}).

    ### Setting body params

    The second argument to the `exec` method will take a `NamedTuple` of params you want to send.
    In most cases, these params will be sent to an [Operation](#{Guides::Database::SavingRecords.path}),
    so these params will need to be nested with the proper [param_key](#{Guides::Database::SavingRecords.path(anchor: Guides::Database::SavingRecords::ANCHOR_PARAM_KEY)}).

    ```crystal
    ApiClient.exec(Posts::Create, post: {title: "My next Taco Dish", posted_at: 1.day.ago})

    ApiClient.exec(Users::Update.with(user.id), user: {email: "updated@email.co"})
    ```

    When you need custom control over the format of the body params (i.e. sending streaming JSON data, etc...), you can use
    the `exec_raw` method.

    ```crystal
    test_data = <<-JSON
      { "event_id": "1"}
      { "type": "event"}
      { "event_id": "2", "type": "event", "platform": ""}
    JSON
    ApiClient.new.exec_raw(EventLogs::Create, test_data)
    ```

    > Sending raw strings can be unsafe and is only used as an escape hatch when standard formats will not work

    ### Setting headers

    If you need to set custom headers, you'll use the `headers` method on an instance of the `ApiClient`.

    ```crystal
    client = ApiClient.new

    client
      .headers("Accept": "application/vnd.api.v1+json")
      .headers("Set-Cookie": "remember_me=1")
      .headers("Authorization": "Bearer abc123")

    # Then make your request:
    client.exec(Api::Users::Index)
    ```

    ### Creating methods for common setup

    Let's say your API uses a Range header to determine which range of items should be included.
    We can create a method on our `ApiClient` to make this easier to reuse.

    ```crystal
    # spec/support/api_client.cr
    class ApiClient < Lucky::BaseHTTPClient
      # ...

      def page(page : Int32, per_page = 10)
        # Set pagination headers
        headers("Range":  "order,id \#{page * per_page}; order=desc,max=\#{per_page}")
      end
    end
    ```

    Now we can use this in our tests

    ```crystal
    response = ApiClient.new.page(2).exec(Api::Users::Index)
    ```

    ### User Auth

    If you generated your app with User Authentication, your API endpoints may require being
    authenticated to access those endpoints. You can use the `ApiClient.auth(user)` method
    to set the proper header.

    ```crystal
    user = UserFactory.create

    ApiClient.auth(user).exec(Api::Records::Index)
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
        rocket = RocketFactory.create &.name("Dragon 1")
        response = ApiClient.auth(current_user).exec(Api::Rockets::Show.with(rocket.id))

        # The JSON response should have the key `name` with a value `"Dragon 1"`.
        response.should send_json(200, name: "Dragon 1")
      end

      it "returns a 401 for unauthenticated requests" do
        response = ApiClient.exec(Api::Rockets::Show.with(4))

        response.status_code.should eq(401)
      end
    end

    private def current_user : User
      UserFactory.create &.email("me@lucky.org")
    end
    ```

    The `send_json` method will check that the HTTP status matches, and the JSON response
    contains your expected values.

    MD
  end
end
