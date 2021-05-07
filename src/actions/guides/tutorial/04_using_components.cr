class Guides::Tutorial::UsingComponents < GuideAction
  guide_route "/tutorial/components"

  def self.title
    "Using Components"
  end

  def markdown : String
    <<-MD
    ## What are Components?

    In Lucky, Components are small, reusable bits of HTML that relate to some smaller portion of a site.
    We create a separate class for these and they go in your `src/components/` directory. We've already
    seen two of them in use in our `AuthLayout`. The `Shared::LayoutHead`, and `Shared::FlashMessages`.

    Let's take a look at the `Shared::LayoutHead` component in `src/components/shared/layout_head.cr`. In this file,
    we can see all of the markup that would go in our website's `<head>` tags are here. They are in the `render`
    method (required for all components).

    At the top of this file are two `needs` lines. The `needs page_title : String` and `needs context : HTTP::Server::Context`.
    You will find `needs` in several different classes in Lucky. It's used for type-safety when a class requires specific data.

    ## Reusing Components

    We currently have two separate layouts, but our custom footer is only in the `AuthLayout`. Let's create a
    new component that will allow us to render our footer in both layouts:
    ```bash
    lucky gen.component Shared::Footer
    ```

    Next we need to open up our `AuthLayout` in `src/pages/auth_layout.cr` and move our `footer` block in to the `render` method of
    our newly generated `Shared::Footer` component.

    ```diff
      # src/pages/auth_layout.cr
    - footer class: "footer mt-auto py-3 bg-light" do
    -   div class: "container" do
    -     span "CloverApp", class: "text-muted"
    -   end
    - end
    + mount Shared::Footer
    ```

    Then in our `Shared::Footer`, paste our code in the `render` method:

    ```crystal
    # src/components/shared/footer.cr
    def render
      footer class: "footer mt-auto py-3 bg-light" do
        div class: "container" do
          span "CloverApp", class: "text-muted"
        end
      end
    end
    ```

    The `mount` method takes the component class and handles setting it up and calling render.
    As an added benefit, if you inspect your page's markup, you'll see HTML comments wrapped around each
    component. This allows you to see which component is responsible for the markup being rendered.

    When creating your own components that require specific data (i.e. HTTP context), you will add your `needs`
    for that data, then in your `mount`, you'll pass each as a named argument. (e.g. `moung Shared::Footer, copyright_year: 3099`)

    > For more information on components, read the [Components](#{Guides::Frontend::RenderingHtml.path(anchor: Guides::Frontend::RenderingHtml::ANCHOR_COMPONENTS)})
    > guide in Rendering HTML.

    ## Your Turn

    Getting the hang of Components can really help to clean up your code and using them well can make
    testing your views easier. Now it's your turn to play with them a bit.

    Try this...

    * Generate a new component for a nav bar
    * Mount your new component in both layouts
    MD
  end
end
