class Guides::GettingStarted::BuildingSomethingReal < GuideAction
  guide_route "/getting-started/building-something-real"

  def self.title
    "Building Something Real"
  end

  def markdown : String
    <<-MD
    ## What are we building?

    Let's build a blog! It will have users, and those users will author posts. When we're done, it'll look a little something like this:

    TODO_INSERT_IMAGE_MAYBE?

    ## Creating the Project

    We'll follow the steps in the [Starting a Lucky Project](#{Guides::GettingStarted::StartingProject.path}) section to generate the beginnings of a full web application with authentication out of the box:

    `lucky init.custom my_blog`

    Open the directory in the editor of your choice, follow the instructions to [start the server](#{Guides::GettingStarted::StartingProject.path(anchor: Guides::GettingStarted::StartingProject::ANCHOR_START_SERVER)}), and you'll see something like this at the address `lucky:dev` output tells you to use:

    ![Lucky Welcome Page](#{Lucky::AssetHelpers.asset("images/building_something_real/lucky_welcome_page.png")})


    ## Modeling a Post

    We can use the built-in Lucky model generator to [generate a model](#{Guides::Database::Models.path(anchor: Guides::Database::Models::ANCHOR_GENERATE_A_MODEL)}) for a `Post`. Lucky can help us out by generating a few of the basic columns like the `title` and `body`:

    `lucky gen.model Post title:String body:String`

    Let's walk through the components Lucky creates from this command.

    ### Post Migration

    First of all, Lucky generates a new migration in `db/migrations` for our `Post` model. You can read in depth about migrations [here](#{Guides::Database::Migrations.path}), but our `Post` model doesn't need anything too fancy:

    ```crystal
    class CreatePosts::V20200715203055 < Avram::Migrator::Migration::V1
      # Run with `lucky db.migrate`
      def migrate
        create table_for(Post) do
          primary_key id : Int64
          add_timestamps
          add title : String
          add body : String
          add_belongs_to author : User, on_delete: :cascade
        end
      end

      # Run with `lucky db.rollback`
      def rollback
        drop table_for(Post)
      end
    end
    ```

    The only thing we had to add was the `add_belongs_to author : User` line to tell our database that a `Post` will have a foreign key to a `User` through a column called `author_id`. We also dictate that if a User is deleted, we should delete their posts as well. There are [other options](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_BELONGS_TO)}), but we'll stick with `on_delete: :cascade` for our blog.

    ### Post Model

    This will continue on, followed by setting up a basic Index, New, Create, Edit, Update, Delete set of actions and pages...
    MD
  end
end
