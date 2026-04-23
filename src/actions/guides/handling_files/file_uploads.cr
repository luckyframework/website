class Guides::HandlingFiles::FileUploads < GuideAction
  guide_route "/handling-files/file-uploads"

  def self.title
    "File Uploads"
  end

  def markdown : String
    <<-MD
    ## Birds-eye view

    Lucky handles file uploads through [Latch](https://github.com/wout/latch),
    a Crystal library purpose-built for attaching files to your application.
    Latch is short for **L**ucky **At**ta**ch**ment, and while it works with any
    Crystal framework it ships with first-class Lucky and Avram support.

    A typical Latch setup involves three things:

    - An **uploader** describes how a file is stored, what metadata is
       extracted from it, and how it should be processed.
    - A **storage backend** persists the file: locally on disk, in S3 (or any
       S3-compatible service), or in memory for tests.
    - An **Avram integration** lets you attach a file to a model column with
       a single macro, with caching, promotion, replacement, and cleanup all
       handled for you.

    Here is a complete example end-to-end:

    ```crystal
    # src/uploaders/avatar_uploader.cr
    struct AvatarUploader
      include Latch::Uploader

      struct VersionsProcessor
        include Latch::Processor::Magick

        original resize: "2000x2000>"
        variant thumb, resize: "200x200", crop: "200x200+0+0", gravity: "center"
      end

      extract dimensions, using: Latch::Extractor::DimensionsFromMagick
      process versions, using: VersionsProcessor
    end

    # src/models/user.cr
    class User < BaseModel
      include Latch::Avram::Model

      table do
        attach avatar : AvatarUploader::StoredFile?
      end
    end

    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
      attach avatar, process: true

      before_save do
        validate_file_size_of avatar_file, max: 5_000_000
        validate_file_mime_type_of avatar_file, in: %w[image/png image/jpeg image/webp]
      end
    end
    ```

    Saving a user with an attached file is then no different from any other
    Avram operation:

    ```crystal
    user = SaveUser.create!(params)
    user.avatar.try(&.url)              # => "/uploads/user/1/avatar/a1b2c3d4.jpg"
    user.avatar.try(&.versions_thumb.url) # => ".../versions_thumb.jpg"
    user.avatar.try(&.width)            # => 2000
    ```

    The remaining guides in this section walk through each piece in detail:

    - [Setup and Configuration](#{Guides::HandlingFiles::Setup.path}). Install
      Latch and configure your storage backends.
    - [Uploaders](#{Guides::HandlingFiles::Uploaders.path}). Define how files
      are stored and what their `StoredFile` looks like.
    - [Extracting Metadata](#{Guides::HandlingFiles::ExtractingMetadata.path}).
      Pull data like dimensions, page counts, or anything else out of an upload.
    - [Processing Files](#{Guides::HandlingFiles::ProcessingFiles.path}).
      Generate variants with ImageMagick, FFmpeg, or libvips.
    - [Avram Integration](#{Guides::HandlingFiles::AvramIntegration.path}).
      Attach files to models, validate uploads, and process them in the
      background with Mel or Mosquito.

    ## A note on Shrine.cr

    Earlier versions of this guide recommended
    [Shrine.cr](https://github.com/jetrockets/shrine.cr), a port of Ruby's
    Shrine library. That project is no longer actively maintained, and its
    Ruby-flavoured API never really fit Crystal's macro-driven style.

    Latch was written from the ground up for Crystal and leans on its macro
    system for compile-time validation of processor options, generated
    `StoredFile` accessors, and zero-runtime-cost integration with Avram. It is
    not a port of Shrine.

    For the sake of interoperability, however, Latch serializes `StoredFile`
    objects in a format that is compatible with Shrine's database
    representation:

    ```json
    {
      "id": "uploads/a1b2c3d4.jpg",
      "storage": "store",
      "metadata": {
        "filename": "photo.jpg",
        "size": 102400,
        "mime_type": "image/jpeg",
        "width": 2000,
        "height": 1333
      }
    }
    ```

    This means existing data uploaded by Shrine.cr (or even by Ruby's Shrine)
    can be read back through Latch without a migration, as long as the
    underlying files remain in the same storage location.

    ## Where to get help

    These guides cover the most common cases for building file upload features
    in a Lucky app. For an exhaustive reference of every macro, option, and
    extension point, see the
    [Latch README](https://github.com/wout/latch/blob/main/README.md) and the
    [API docs](https://wout.github.io/latch/). Each of the following pages
    links into the relevant section of the README where applicable.
    MD
  end
end
