class Guides::HandlingFiles::AvramIntegration < GuideAction
  guide_route "/handling-files/avram-integration"

  def self.title
    "Avram Integration"
  end

  def markdown : String
    <<-MD
    ## Overview

    Latch's Avram integration lets you attach a file to a model column with a
    single macro on the model and a single macro on the save operation. From
    there, the upload lifecycle (caching the file before save, promoting it
    after commit, replacing the previous file on update, and removing it on
    delete) happens automatically as part of any normal Avram operation.

    This guide assumes you've already
    [set up Latch](#{Guides::HandlingFiles::Setup.path}) and defined an
    [uploader](#{Guides::HandlingFiles::Uploaders.path}). The running example
    is `User#avatar`, but the same pattern applies to any attachment.

    ## The model

    Include `Latch::Avram::Model` in your model and use `attach` inside the
    `table` block. The column type is the uploader's `StoredFile`, optionally
    nilable:

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      include Latch::Avram::Model

      table do
        attach avatar : AvatarUploader::StoredFile?
      end
    end
    ```

    Drop the `?` to make the attachment required. A non-nilable attachment is
    enforced at the database level (`JSON::Any` instead of `JSON::Any?`) and
    on the save operation, where a missing file causes the save to fail:

    ```crystal
    table do
      attach avatar : AvatarUploader::StoredFile
    end
    ```

    Required attachments don't get a `delete_<column>` virtual attribute,
    since clearing them on their own would put the record in an invalid
    state. Replace the file by uploading a new one instead.

    Behind the scenes, `attach` declares a `jsonb` column that stores the
    serialised `StoredFile`. Your migration adds a single `JSON::Any?` column
    (or `JSON::Any` if the attachment is required):

    ```crystal
    # db/migrations/20260101000001_add_avatar_to_users.cr
    class AddAvatarToUsers::V20260101000001 < Avram::Migrator::Migration::V1
      def migrate
        alter table_for(User) do
          add avatar : JSON::Any?
        end
      end

      def rollback
        alter table_for(User) do
          remove :avatar
        end
      end
    end
    ```

    ## The save operation

    On the save operation side, `attach` registers a file attribute and the
    lifecycle hooks that move the file through cache and store:

    ```crystal
    # src/operations/save_user.cr
    class SaveUser < User::SaveOperation
      permit_columns name, email
      attach avatar
    end
    ```

    By default the file attribute is named `<column>_file`, so `avatar_file`
    in this case. Override it with `field_name` if you need a different param
    name (for example, to match an existing form):

    ```crystal
    attach avatar, field_name: "avatar_upload"
    ```

    For nilable attachments, Latch also adds a virtual `delete_<column>`
    attribute, so users can clear an avatar without uploading a new one:

    ```crystal
    SaveUser.update!(user, delete_avatar: true)
    ```

    ## Validating uploads

    Validations live in a `before_save` block, just like every other Avram
    validation. Latch ships two helpers (`validate_file_size_of` and
    `validate_file_mime_type_of`) that operate on the virtual file attribute:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name, email
      attach avatar

      before_save do
        validate_file_size_of avatar_file, max: 5_000_000
        validate_file_mime_type_of avatar_file,
          in: %w[image/png image/jpeg image/webp]
      end
    end
    ```

    `validate_file_mime_type_of` also accepts a regular expression with
    `with:`, which is handy for "any image" or "any video":

    ```crystal
    validate_file_mime_type_of avatar_file, with: /\\Aimage\\/.+\\z/
    ```

    Validation failures attach to the file attribute and surface in the form
    just like any other field error.

    ## Processing after upload

    To process the file inline as part of the save, pass `process: true`:

    ```crystal
    attach avatar, process: true
    ```

    Variants are then ready to read on the returned record:

    ```crystal
    user = SaveUser.create!(params)
    user.avatar.try(&.versions_thumb.url)
    ```

    Inline processing is fine for small images, but anything heavier (high
    resolution photos, videos, PDFs with hundreds of pages) should run in a
    background job so the user isn't kept waiting on the response.

    ## Background processing

    Pass a block to `attach` instead of `process: true`. The block runs after
    the file has been promoted, with the saved record yielded in. Enqueue
    your background job from there:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns name, email

      attach avatar do |user|
        User::AvatarProcessingJob.run(user_id: user.id)
      end
    end
    ```

    ### With Mel

    [Mel](https://github.com/GrottoPress/mel) is a background job library for
    Crystal. A processing job is a struct that includes `Mel::Job::Now` (or
    one of the scheduled variants):

    ```crystal
    # src/jobs/user/avatar_processing_job.cr
    struct User::AvatarProcessingJob
      include Mel::Job::Now

      def initialize(@user_id : Int64)
      end

      def run
        user = UserQuery.find(@user_id)
        user.avatar.try(&.process)
      end
    end
    ```

    ### With Mosquito

    [Mosquito](https://github.com/mosquito-cr/mosquito) works the same way.
    Define a queued job that takes the user ID as a parameter and calls
    `process` inside `perform`:

    ```crystal
    # src/jobs/user/avatar_processing_job.cr
    class User::AvatarProcessingJob < Mosquito::QueuedJob
      param user_id : Int64

      def perform
        user = UserQuery.find(user_id)
        user.avatar.try(&.process)
      end
    end
    ```

    Then enqueue from the operation block:

    ```crystal
    attach avatar do |user|
      User::AvatarProcessingJob.new(user_id: user.id).enqueue
    end
    ```

    Anything that can call a method asynchronously will work. Latch makes no
    assumptions about your job library.

    ## The upload lifecycle

    For a complete picture of what `attach` actually does, here's what
    happens to a file as it moves through a save operation:

    - **Before save:** the uploaded file is written to the cache storage.
      This means a failed validation doesn't lose the file, so the form can
      redisplay with the cached file still attached.
    - **After commit:** the cached file is promoted to the permanent store.
    - **After promotion:** if `process: true` is set, processors run inline.
      Otherwise the block (if any) is invoked with the saved record.
    - **On update:** when a new file replaces an old one, the old file (and
      any of its variants) is deleted from the store.
    - **On delete:** when the record is destroyed, the attached file is
      removed.

    ## The form

    The form side is plain Lucky. Use `multipart: true` so the browser sends
    the file as `multipart/form-data`, and `file_input` for the actual upload
    field. Latch's file attribute (`avatar_file`) plugs into the existing
    `Shared::Field` component without any extra wiring:

    ```crystal
    # src/pages/users/new_page.cr
    class Users::NewPage < MainLayout
      needs op : SaveUser

      def content
        form_for Users::Create, multipart: true do
          mount Shared::Field, op.name
          mount Shared::Field, op.email
          mount Shared::Field, op.avatar_file, &.file_input
          submit "Save"
        end
      end
    end
    ```

    For a nilable attachment with the `delete_avatar` checkbox:

    ```crystal
    if op.record.try(&.avatar)
      mount Shared::Field, op.delete_avatar, &.checkbox
    end
    ```

    ## The action

    Actions need no special handling. File attributes are part of `params`,
    and Latch picks them up automatically inside `attach`:

    ```crystal
    # src/actions/users/create.cr
    class Users::Create < BrowserAction
      post "/users" do
        SaveUser.create(params) do |op, user|
          if user
            redirect to: Users::Show.with(user.id)
          else
            html NewPage, op: op
          end
        end
      end
    end
    ```

    ## Rendering

    On the read side, a stored file knows its own URL, and any variant
    accessors generated by your processor work the same way. The most common
    pattern is a small helper on the page that handles the nilable case:

    ```crystal
    # src/pages/users/show_page.cr
    class Users::ShowPage < MainLayout
      needs user : User

      def content
        img src: avatar_url, alt: user.name
      end

      private def avatar_url : String
        if avatar = user.avatar.try(&.versions_thumb?)
          avatar.url
        else
          asset("images/avatar_placeholder.png")
        end
      end
    end
    ```

    The nilable `versions_thumb?` accessor returns `nil` if the variant
    hasn't been processed yet, which is useful when uploads are processed in
    the background and you need to render something sensible in the meantime.

    For files in private storage, swap `avatar.url` for a presigned URL:

    ```crystal
    avatar.url(expires_in: 1.hour)
    ```

    ## Where to go next

    That's the end of the file uploads tour. For everything that wasn't
    covered here (alternative storage backends, the full processor option
    reference, custom extractors, the full StoredFile API), see the
    [Latch README](https://github.com/wout/latch/blob/main/README.md) and the
    [Latch API docs](https://wout.github.io/latch/).
    MD
  end
end
