class Guides::Tutorial::UsingComponents < GuideAction
  guide_route "/tutorial/components"

  def self.title
    "Using Components"
  end

  def markdown : String
    <<-MD
    ## What are Components?

    In Lucky, Components are small, reusable bits of HTML that relate to some smaller portion of a site.
    We create a separate class for these, and they go in your `src/components/` directory. We've already
    seen two of them in use in our `AuthLayout`. The `Shared::LayoutHead`, and `Shared::FlashMessages`.

    Let's take a look at the `Shared::LayoutHead` in `src/components/shared/layout_head.cr`. In this file,
    we can see all of the markup that would go in our website's `<head>` tags are here. They are in the `render`
    method which is required for all components.

    At the top of this file are two `needs` lines. The `needs page_title` and `needs context`. These help keep
    the type-safety in your application by requiring that you pass these bits of data in to the component, and
    ensure they are the correct type.

    ## Reusing Components

    We currently have two separate layouts, but our custom footer is only in the `AuthLayout`. Let's create a
    new component that will allow us to render our footer in both layouts. From your terminal, enter `lucky gen.component Shared::Footer`

    ```bash
    lucky gen.component Shared::Footer
    ```

    Next, we need to open up our `AuthLayout` in `src/pages/auth_layout.cr`, and move our `footer` block in to the `render` method of
    our newly generate component `Shared::Footer`.

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

    Then in our `AuthLayout`, we will need to `mount` our new component. Replace the old footer markup with the `mount`

    ```diff
      # src/pages/auth_layout.cr
    - footer class: "footer mt-auto py-3 bg-light" do
    - #...
    - end
    + mount Shared::Footer
    ```

    ## Your Turn

    Getting the hang of Components can really help to clean up your code, as well as make
    testing your views a lot easier. Now it's your turn to play with them a bit.

    Try this...

    * Generate a new component for a nav bar
    * Mount your new component in both layouts
    MD
  end
end
