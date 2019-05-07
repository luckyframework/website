class Guides::Database::Testing < GuideAction
  guide_route "/database/testing"

  def self.title
    "Creating Test Data"
  end

  def markdown
    <<-MD
    ## Creating a Box

    ```crystal
    # spec/support/boxes/post_box.cr
    class PostBox < Avram::Box
      def initialize
        title "My Post"
        body "Test Body"
      end
    end
    ```

    ## Saving records

    ```crystal
    PostBox.create
    PostBox.create_pair
    ```

    ### Overriding data

    ```crystal
    PostBox.create &.title("Draft").body("custom body")
    PostBox.create_pair &.title("Draft")
    ```
    MD
  end
end
