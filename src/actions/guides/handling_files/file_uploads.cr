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
      config.storages["cache"] = Storage::FileSystem.new("uploads", prefix: "cache")
      config.storages["store"] = Storage::FileSystem.new("uploads")
    end
    ```

    ## SaveOperation setup

    The `file_attribute` is used in your save operation to specify the name of the param attribute that will contain the file.

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name
      file_attribute :profile_picture

      before_save do
        profile_picture.value.try { |pic| upload_pic(pic) }
      end

      private def upload_pic(pic)
        result = Shrine.upload(File.read(pic.tempfile.path), "store", metadata: { "filename" => pic.filename })
        profile_picture_path.value = result.url
      end
    end
    ```

    ## Action setup

    Your action code will look standard with no additional code needed.

    ```crystal
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

    MD
  end
end
