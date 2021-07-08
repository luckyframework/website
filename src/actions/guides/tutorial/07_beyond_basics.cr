class Guides::Tutorial::BeyondBasics < GuideAction
  guide_route "/tutorial/beyond-basics"

  def self.title
    "Beyond the Basics"
  end

  def markdown : String
    <<-MD
    ## Fixing Fortune Forms

    Right now, if we try to create a new fortune through our app, we will get an error because
    no `user_id` is set. We can get this value from our `current_user` method as this is available
    once we've logged in.

    We will need to update many of Fortune actions, as well as our `SaveFortune` operation to include
    this.

    ### Updating the operation

    Open up the `SaveFortune` operation in `src/operations/save_fortune.cr`. We need to tell this operation
    that it `needs` the `current_user`. Update with this code:

    ```crystal
    # src/operations/save_fortune.cr
    class SaveFortune < Fortune::SaveOperation
      permit_columns text
      needs current_user : User

      before_save do
        user_id.value = current_user.id
      end
    end
    ```

    We are telling this operation that it must include the `current_user` object. Then before we save
    the fortune record we assign a value to `user_id` attribute.

    > For more information on attributes read the [What are attributes](#{Guides::Database::CallbacksAndValidations.path(anchor: Guides::Database::CallbacksAndValidations::ANCHOR_ATTRIBUTES)})
    > guide in Callbacks and Validations.

    ### Passing data to the operation

    With the addition of the `needs` any time we instantiate the `SaveFortune`, we must pass in the `current_user` object.
    For now this is in the following fortune actions: `Fortunes::New`, `Fortunes::Create`, `Fortunes::Edit`, and `Fortunes::Update`.

    We will start the `Fortunes::New` action in `src/actions/fortunes/new.cr`. Update with this code:

    ```crystal
    # src/actions/fortunes/new.cr
    html NewPage, operation: SaveFortune.new(current_user: current_user)
    ```

    Next is our `Fortunes::Create` action in `src/actions/fortunes/create.cr`. Update with this code:

    ```crystal
    # src/actions/fortunes/create.cr
    SaveFortune.create(params, current_user: current_user) do |operation, fortune|
    ```

    Next is the `Fortunes::Edit` action in `src/actions/fortunes/edit.cr`. Update with this code:

    ```crystal
    # src/actions/fortunes/edit.cr
    html EditPage,
      operation: SaveFortune.new(fortune, current_user: current_user),
      fortune: fortune
    ```

    And last is the `Fortunes::Update` action in `src/actions/fortunes/update.cr`. Update with this code:

    ```crystal
    # src/actions/fortunes/update.cr
    SaveFortune.update(fortune, params, current_user: current_user) do |operation, updated_fortune|
    ```

    We've updated a lot of code. Now is a good time to boot your app and make sure everything compiles as it should.
    Once booted you can sign in to your account and visit the `/fortunes/new` page. See that creating a new fortune
    will assign it to your account.

    ## Authenticating Actions

    Since each fortune is specific to a user no other user should be allowed to edit or delete another user's
    fortune. We must detect that a fortune doesn't belong to a user, and handle this appropriately.

    We will need to update several actions: `Fortunes::Edit`, `Fortunes::Update`, and `Fortunes::Delete` to
    ensure we're protecting against unauthorized updates. This is a good time to try a mixin.

    ### Adding an action mixin

    Mixins are just modules you can reuse in multiple classes. You'll find some existing mixins in the
    `src/actions/mixins/` directory. We will create a new on called `OnlyAllowCurrentUser` in `src/actions/mixins/only_allow_current_user.cr`.
    The idea of this mixin will be to check that the `current_user` owns the `fortune`. If not, then we will raise an error.

    Add this file with this code:

    ```crystal
    # src/actions/mixins/only_allow_current_user.cr
    module OnlyAllowCurrentUser
      class UnauthorizedEntryError < Lucky::Error
      end

      def ensure_owned_by_current_user!(fortune : Fortune)
        if fortune.user_id != current_user.id
          raise UnauthorizedEntryError.new
        end
      end
    end
    ```

    Now we will take a look at custom error handling. Any error that happens in your application will be caught by
    the `Errors::Show` action. This allows you to keep error handling in a single location, as well as customize
    how the errors are displayed. You can even send errors off to a 3rd party reporting service in here.

    Open up the `src/actions/errors/show.cr` action. You'll be adding an extra `render` method in her, but keep in
    mind that the order of these matters in Crystal. We will add our code after the `Avram::InvalidOperationError` overload.

    ```crystal
    # src/actions/errors/show.cr
    # Add this after the `Avram::InvalidOperationError` overload
    def render(error : OnlyAllowCurrentUser::UnauthorizedEntryError)
      error_html "You're not authorized to do this", status: 401
    end
    ```

    Before we give this a shot, we just need to add the code to use our new `ensure_owned_by_current_user!` method.
    We will try this in our `Fortunes::Edit` action first. Open the `src/actions/fortunes/edit.cr` file, and update this code:

    ```crystal
    # src/actions/fortunes/edit.cr
    get "/fortunes/:fortune_id/edit" do
      fortune = FortuneQuery.find(fortune_id)
      ensure_owned_by_current_user!(fortune)

      html EditPage,
        operation: SaveFortune.new(fortune, current_user: current_user),
        fortune: fortune
    end
    ```

    Save your files, boot your app, and give it a shot. Try editing a fortune that doesn't belong to you; you
    should see the [exception page](https://github.com/crystal-loot/exception_page) with a code snippet, and
    stack trace. This page is helpful when debugging, but only shows up in development. To see what your users
    will see, open up `config/error_handler.cr`, and set the `show_debug_output` setting to `false`.

    Once your app recompiles, try the action again, and you'll now see the default Lucky error page with
    your custom message, and the 401 status. Be sure to set that setting back once you've had a chance to
    check it out.

    > For more information on error handling, read the [Error Handling](#{Guides::HttpAndRouting::ErrorHandling.path}) guide.

    ## Updating Pages

    We've blocked the fortune actions for fortunes we don't own, but the action links still exist. We can now
    update the `Fortunes::ShowPage` to only display action links when we own fortune. Open the `Fortunes::ShowPage`
    in `src/pages/fortunes/show_page.cr`, and update with this code:

    ```crystal
    def content
      link "Back to all Fortunes", Fortunes::Index
      h1 "Fortune with id: \#{fortune.id}"

      if fortune.user_id == current_user.id
        render_actions
      end

      render_fortune_fields
    end
    ```

    It's as simple as that!

    ## Final Thoughts

    This tutorial is only meant to give you a quick overview and taste of how a Lucky app is
    structured. When it comes to developing applications, you will have your own preferences
    regarding where you want code to go, what you want to name things, and how logic should be structured.

    We recommend deleting your app, and giving this tutorial a shot again. Think of it like a movie,
    you may have missed something the first time around! Maybe the second time will allow you to get
    a little more adventurous with your code.

    As always, if you run in to any issues, please join us in the [Discord Chat](#{Chat::Index.path})
    and someone will be around more than willing to help you out.

    > If you find any issues in this tutorial, please [Open an issue](https://github.com/luckyframework/website/issues) on
    > the Lucky website repo so we can correct it.

    MD
  end
end
