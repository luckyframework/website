class Guides::Authentication::Api < GuideAction
  ANCHOR_OPTIONAL_TOKEN = "perma-optional-token"
  guide_route "/authentication/api"

  def self.title
    "API Authentication"
  end

  def markdown : String
    <<-MD
    ## Authenticating a request

    By default all actions inherited from `ApiAction` will require an auth
    token because the `ApiAction` in `src/actions/api_action.cr` includes the
    `Api::Auth::RequireAuthToken`. This modules requires an auth token or the
    action will return a 401 unauthorized error.

    We'll go over how to make an action accessible by [unauthenticated requests](##{ANCHOR_OPTIONAL_TOKEN})
    later in the guide.

    ### Sending an authentication token

    You can get an auth token by signing up/in a user, but for this example
    we'll assume our token is `"fake-token"`.

    There are 2 ways to send this token.

    * With an `Authorization` header
    * With an `auth_token` param in the query params or in the body.

    ### Examples using curl

    Using an `Authorization` header:

    ```bash
    curl localhost:5000/api/some_endpoint \
      -H "Authorization: Bearer fake-token"
    ```

    Using an `auth_token` query param:

    ```bash
    curl localhost:5000/api/some_endpoint?auth_token=fake-token
    ```

    Using a body param:

    ```bash
    curl localhost:5000/api/some_endpoint \
      -d "auth_token=fake-token"
    ```

    > You could also include the token in JSON params: `{"auth_token":"fake-token"}`

    #{permalink(ANCHOR_OPTIONAL_TOKEN)}
    ## Allowing requests without a token

    For actions that do not require an authentication token, include the
    `Api::Auth::SkipRequireAuthToken` mixin defined in
    `src/actions/mixins/api/auth/skip_require_auth_token.cr`.

    For example:

    ```crystal
    class Api::PublicComments::Index < ApiAction
      include Api::Auth::SkipRequireAuthToken
    end
    ```

    ### Allowing unauthenticated requests by default

    If most of your actions do not require an auth token you can remove
    `Api::Auth::RequireAuthToken` from `ApiAction`.

    Then in your actions that *do* require authentication, add
    `Api::Auth::RequireAuthToken`:

    ```crystal
    class Api::SecretProjects::Index < ApiAction
      include Api::Auth::RequireAuthToken
    end
    ```

    ## Sign up

    The `Api::SignUps::Create` action in `src/actions/api/sign_ups/create.cr`
    handles user sign ups. It requires an email, password, and password_confirmation
    and returns a token for authenticating the user.

    ### Curl example

    ```bash
    curl localhost:5000/api/sign_ups \
      -X POST \
      -d "user:email=person@example.com" \
      -d "user:password=password" \
      -d "user:password_confirmation=password"
    ```

    Which returns a token like:

    ```json
    {"token":"some-long-token"}
    ```

    ### Customizing sign up

    To add additional fields, change validations, or customize sign up,
    check out the `SignUpUser` operation in `src/operations/sign_up_user.cr`.

    ## Sign in (generate an auth token)

    The `Api::SignIns::Create` action in `src/actions/api/sign_ins/create.cr`
    handles creating a new token. It requires an email and password
    and returns a token for authenticating the user.

    ### Curl example

    ```bash
    curl localhost:5000/api/sign_ins \
      -X POST \
      -d "user:email=person@example.com" \
      -d "user:password=password"
    ```

    Which returns a token like:

    ```json
    {"token":"some-long-token"}
    ```

    ### Customizing sign in

    To add additional attributes, change validations, or customize sign in,
    check out the `SignInUser` operation in `src/operations/sign_in_user.cr`.

    ## Show current user

    The `Api::Me::Show` in `src/actions/api/me/show.cr` returns the user for
    the given token. Use the token returned by sign in or sign up in either
    the `Authorization` header or in an `auth_token` param.

    ### Using curl to sign up a user

    ```bash
    curl localhost:5000/api/me \
      -H "Authorization: Bearer {{token-returned-from-sign-in/up}}"
    ```

    Returns:

    ```json
    {"email":"person@example.com"}
    ```

    ### Customize response

    You can add or modify the JSON response by changing the `UserSerializer`
    in `src/serializers/user_serializer.cr`.
    MD
  end
end
