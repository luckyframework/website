class Guides::HttpAndRouting::Flash < GuideAction
  guide_route "/http-and-routing/flash"

  def self.title
    "Flash Messages"
  end

  def markdown : String
    <<-MD
    ## Flash messages

    You can show messages using `flash`. A flash message is a simple String that is
    passed between two actions. This lets a user know if an action was a success
    or a failure. (e.g. "Record was saved successfully")

    ### Type safe flash messages

    The built-in message types are `success`, `failure` and `info`. Using these
    will cause compile-time errors if you accidentally mistype something. It is
    recommended to stick to these whenever possible.

    ```crystal
    # In an action
    flash.success = "It worked!"
    flash.failure = "That did not work"
    flash.info = "Be cool"
    ```

    These will be rendered by the flash component in
    `src/components/shared/flash_messages.cr`. The flash component is called from
    your `MainLayout` and `AuthLayout` (found in `src/pages/`) by the
    `render_flash` method.

    You can modify the layout or the component to add HTML classes, change where
    flash is rendered, etc.

    ### Setting other messages

    The built-in messages are `success`, `failure` and `info`, but you can use anything
    you'd like:

    ```crystal
    flash.set("something_special", "Super spesh")
    flash.get("something_special") # => "Super spesh"
    ```
    MD
  end
end
