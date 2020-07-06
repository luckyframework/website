class Guides::HttpAndRouting::SessionsAndCookies < GuideAction
  guide_route "/http-and-routing/sessions-and-cookies"

  def self.title
    "Sessions and Cookies"
  end

  def markdown : String
    <<-MD
    ## Cookies and Sessions

    You can set and access cookies/session values in Lucky like this:

    ```crystal
    class FooAction < BrowserAction
      get "/foo" do
        cookies.set("name", "Sally")
        cookies.get("name") # Will return "Sally"
        cookies.get?("person") # Will return nil

        # You can use Symbol for your key as well
        session.set(:name, "Sally")
        session.get(:name) # Will return "Sally"
        session.get("person") # oops! An exception is raised because this key doesn't exist
        plain_text "Cookies!"
      end
    end
    ```

    Cookies are encrypted by Lucky by default when you use `set`. If you
    need to set a raw value unencrypted, Lucky gives you that option:

    ```crystal
    cookies.set_raw("name", "Sally") # Sets a raw unencrypted cookie
    cookies.get_raw("name") # Will return "Sally"
    ```

    ### Clearing Sessions and Cookies

    If you need to remove a session, or delete a cookie, do this:

    ```crystal
    # Delete a specific session key
    session.delete(:name)

    # Clear the current session
    session.clear

    # Delete a specific cookie
    cookies.delete("name")
    cookies.deleted?("person") #=> false

    # Delete all cookies
    cookies.clear
    ```

    ## Configuring Cookies

    If you need to customize specific [cookie options](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie), each cookie is an instance of [HTTP::Cookie](https://crystal-lang.org/api/HTTP/Cookie.html), which gives you access to several helpful methods.

    ```crystal
    # This gives you a HTTP::Cookie or raise an exception
    c_is_for_cookie = cookies.get_raw("cookiedough")

    # Set the name of the cookie to "cookie-dough"
    c_is_for_cookie.name("cookie-dough")

    # Set the value of cookie-dough to "yum"
    c_is_for_cookie.value("yum")

    # Set the path for the cookie to "/baking"
    c_is_for_cookie.path("/baking")

    # Set the expires date to tomorrow
    c_is_for_cookie.expires(1.day.from_now)

    # Set the domain to cookie.monst.er
    c_is_for_cookie.domain("cookie.monst.er")

    # Make the cookie secure
    c_is_for_cookie.secure(true)

    # Set the cookie to HTTP only
    c_is_for_cookie.http_only(true)

    # Set the cookie SameSite to Lax. 
    # You can also use `:strict` here.
    c_is_for_cookie.samesite(:lax)
    ```

    ### Setting cookie defaults

    The `Lucky::CookieJar` configuration is located in your app's `config/cookies.cr` file.
    You can set defaults for your cookies when they're written.

    ```crystal
    # config/cookies.cr
    Lucky::CookieJar.configure do |settings|
      settings.on_set = ->(cookie : HTTP::Cookie) {
        cookie
          .secure(true)
          .http_only(true)
          .samesite(:strict)
          .expires(1.year.from_now)
          .domain("mydomain.com")
      }
    end
    ```

    ## Disabling Cookies

    There may be an action where you need disable writing cookies. For this, you
    can use the `disable_cookies` macro in the action you want to skip writing cookies.

    ```crystal
    class Api::Posts::Index < ApiAction
      disable_cookies

      get "/posts" do
        json([] of Post)
      end
    end
    ```

    This will disable writing all cookies, session, and flash messages for this action.
    If you need to do this for all of your actions, you can add the `disable_cookies` macro to
    the action you inherit from (For example the `ApiAction`).
    MD
  end
end
