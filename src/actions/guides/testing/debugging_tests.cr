class Guides::Testing::DebuggingTests < GuideAction
  guide_route "/testing/debugging"

  def self.title
    "Debugging Tests"
  end

  def markdown : String
    <<-MD
    ## Introduction

    Determining why a given test is failing can sometimes be difficult. This guide serves as a jumping-off point for some tips and tricks that you can leverage to resolve these issues more quickly for your Lucky applications.

    ## Lucky Flow

    ### Taking Screenshots

    When you're running an integration spec that tests your application interface using Lucky Flow, sometimes getting a picture of what's going on at a certain point on the screen can be incredibly helpful when diagnosing a failing test.

    Say that we have the following spec file:

    ```crystal
    require "../spec_helper"

    describe "Authentication flow" do
      it "works" do
        flow = AuthenticationFlow.new("test@example.com")

        flow.sign_up "password"
        flow.should_be_signed_in
        flow.sign_out
        flow.sign_in "wrong-password"
        flow.should_have_password_error
        flow.sign_in "password"
        flow.should_be_signed_in
      end
    end
    ```

    If we wanted to see what the state of the interface looks like after the `flow.should_be_signed_in` step, all we need to do is insert a `flow.open_screenshot` method call like so:

    ```crystal
    require "../spec_helper"

    describe "Authentication flow" do
      it "works" do
        flow = AuthenticationFlow.new("test@example.com")

        flow.sign_up "password"
        flow.should_be_signed_in

        # Take a picture of the screen, then open the file up
        flow.open_screenshot

        flow.sign_out
        flow.sign_in "wrong-password"
        flow.should_have_password_error
        flow.sign_in "password"
        flow.should_be_signed_in
      end
    end
    ```

    The next time this test file runs, a screenshot of the state of the interface at that point in time will be opened in your default image viewer
    allowing you to diagnose the problem, and get one step closer to a passing test!

    If you'd like to output screenshots to a different location from LuckyFlow, you can easily modify the path defined by the `screenshot_directory` setting:

    ```crystal
    LuckyFlow.configure do
      settings.screenshot_directory = "./tmp/my_custom_folder"
    end
    ```

    > If `open_screenshot` fails, or you don't want the image to auto-open, you can use `flow.take_screenshot`.
    > Look for the image in the `./tmp/screenshots` folder to open the image manually.

    ### Showing the browser

    In your `spec/setup/configure_lucky_flow.cr` file, you can update the `driver` setting to
    `LuckyFlow::Drivers::Chrome`. By updating this, when you run your specs, you will see the
    browser open up and watch it run through each flow.

    ```crystal
    # spec/setup/configure_lucky_flow.cr
    LuckyFlow.configure do |settings|

      # Update this setting
      settings.driver = LuckyFlow::Drivers::Chrome

      # Set back to `LuckyFlow::Drivers::HeadlessChrome` or
      # just remove the setting when you're done.
    end
    ```

    ### Pausing the flow

    Within your flow object, you can call the `pause` method which will temporarily pause your
    flow on whichever page it's on.

    ```crystal
    # spec/support/flows/publish_post_flow.cr
    def start_draft
      visit Articles::Index

      pause

      click "@new-post"
    end
    ```

    Once you're satisifed, go back to your terminal and hit the "enter" key to resume your flow.

    > This is best used in conjunction with the non-headless driver option.
    MD
  end
end
