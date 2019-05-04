class Guides::HttpAndRouting::SessionsAndCookies < GuideAction
  guide_route "/http-and-routing/sessions-and-cookies"

  def self.title
    "Sessions and Cookies"
  end

  def markdown
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
        text "Cookies!"
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

    If you need to remove a session

    ```crystal
    # Delete a specific session key
    session.delete(:name)

    # Clear the current session
    session.clear

    # Delete a specific cookie
    cookies.delete("name")

    # Delete all cookies
    cookies.clear
    ```
    MD
  end
end
