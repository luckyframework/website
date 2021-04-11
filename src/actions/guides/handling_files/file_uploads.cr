class Guides::HandlingFiles::FileUploads < GuideAction
  guide_route "/handling-files/file-uploads"

  def self.title
    "Uploading Files"
  end

  def markdown : String
    <<-MD
    ## Setup

    For handling file uploads, we will use [Shrine.cr](https://github.com/jetrockets/shrine.cr).

    Start by adding the `shrine` shard to your `shard.yml` and run `shards install`.

    ```yaml
    dependencies:
      shrine:
        github: jetrockets/shrine.cr
    ```

    Next you will require the shard in `src/shards.cr`

    ```crystal
    # src/shards.cr

    # Require your shards here
    require "avram"
    require "lucky"
    require "carbon"
    require "authentic"
    require "shrine"
    ```

    Lastly, we can create a config file for configuring where our uploaded files will be stored.
    Create a new file in `confg/shrine.cr`

    ```crystal
    # config/shrine.cr
    Shrine.configure do |config|
      config.storages["cache"] = Shrine::Storage::FileSystem.new("uploads", prefix: "cache")
      config.storages["store"] = Shrine::Storage::FileSystem.new("uploads")
    end
    ```

    ## Model setup

    We need to store a reference ID to the image in our database.

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      table do
        column profile_image_id : String
      end
    end
    ```

    ## SaveOperation setup

    The `file_attribute` is used in your save operation to specify the name of the param attribute that will contain the file.

    ```crystal
    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
      permit_columns name
      file_attribute :profile_picture

      before_save do
        profile_picture.value.try { |pic| upload_pic(pic) }
      end

      private def upload_pic(pic)
        result = Shrine.upload(File.new(pic.tempfile.path), "store", metadata: { "filename" => pic.filename })

        # If the new file is uploaded, no reason to keep the old one!
        # If multiple models can share an image, run a query before deleting
        # to ensure you're not breaking any references.
        if old_image = profile_image_id.original_value
          delete_old_profile_image(old_image)
        end

        profile_image_id.value = result.id
      end

      private def delete_old_profile_image(old_image)
        storage = Shrine.find_storage("store")
        if storage.exists?(old_image)
          storage.delete(old_image)
        end
      end
    end
    ```

    ## Action setup

    Your action code will look standard with no additional code needed.

    ```crystal
    # src/actions/users/create.cr
    class Users::Create < BrowserAction
      post "/users" do
        SaveUser.create(params) do |op, user|
          if user
            redirect to: Users::Show.with(user.id)
          else
            html Users::NewPage, op: op
          end
        end
      end
    end
    ```

    ## Page setup

    The two main items to take note of is the `form_for` uses the `multipart: true` option to properly set the `enctype`,
    and the use of the `file_input`.

    ```crystal
    # src/pages/users/new_page.cr
    class Users::NewPage < MainLayout
      needs op : SaveUser

      def content
        form_for Users::Create, multipart: true do
          mount Shared::Field, op.name
          mount Shared::Field, op.profile_picture, &.file_input
        end
      end
    end
    ```

    ## Rendering images

    When you're ready to render the uploaded image

    ```crystal
    # src/pages/users/show_page.cr
    class Users::ShowPage < MainLayout
      needs user : User

      def content
        img src: profile_url(user)
      end

      private def profile_url(user) : String
        Shrine.find_storage("store").url(user.profile_image_id)
      end
    end
    ```
    MD
  end
end
