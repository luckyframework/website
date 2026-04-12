class Guides::HandlingFiles::Setup < GuideAction
  guide_route "/handling-files/setup"

  def self.title
    "Setup and Configuration"
  end

  def markdown : String
    <<-MD
    ## Installing Latch

    Add Latch to your `shard.yml` and run `shards install`:

    ```yaml
    dependencies:
      latch:
        github: wout/latch
    ```

    Then require it from `src/shards.cr`. The require you pick determines
    which framework integrations are loaded:

    ```crystal
    # src/shards.cr
    require "avram"
    require "lucky"
    require "carbon"
    require "authentic"
    require "latch"
    require "latch/lucky/avram" # Lucky + Avram (the default for new Lucky apps)
    ```

    If you only need Lucky without Avram (for example, in an API-only app that
    streams uploads straight to S3), use the lighter integration:

    ```crystal
    require "latch/lucky/uploaded_file"
    ```

    And if you use Avram outside of Lucky:

    ```crystal
    require "latch/avram/model"
    ```

    ## Configuring storage

    Latch routes every upload through a *named* storage backend. By convention
    there are two: `"cache"` for temporary uploads (the file as it sits between
    a form submission and a successful save) and `"store"` for permanent
    storage. Configure both in a new file at `config/latch.cr`:

    ```crystal
    # config/latch.cr
    Latch.configure do |settings|
      settings.storages["cache"] = Latch::Storage::FileSystem.new(
        directory: "uploads", prefix: "cache"
      )
      settings.storages["store"] = Latch::Storage::FileSystem.new(
        directory: "uploads"
      )
      settings.path_prefix = ":model/:id/:attachment"
    end
    ```

    The `path_prefix` controls where files end up inside a storage backend. The
    placeholders above expand to, for example, `user/42/avatar/a1b2c3d4.jpg`.
    You can use any combination of `:model`, `:id`, and `:attachment`, or omit
    `path_prefix` entirely if you'd prefer the default flat layout.

    > By default the `FileSystem` storage writes to a directory inside your
    > project root. If you want files to be served by Lucky's static handler,
    > point `directory` at `public/uploads` instead.

    ## Storage backends

    Latch ships with three storage backends out of the box.

    ### FileSystem

    Useful for development, single-server deployments, and anywhere you want
    files written to local disk:

    ```crystal
    Latch::Storage::FileSystem.new(
      directory: "uploads",
      prefix: "cache",                                  # optional subdirectory
      clean: true,                                      # remove empty parents on delete
      permissions: File::Permissions.new(0o644),
      directory_permissions: File::Permissions.new(0o755)
    )
    ```

    ### S3

    Use the S3 backend for production deployments, or for any S3-compatible
    service such as Cloudflare R2, Tigris, or
    [RustFS](https://github.com/rustfs/rustfs) (the open-source successor to
    MinIO):

    ```crystal
    Latch::Storage::S3.new(
      bucket: "my-bucket",
      region: "eu-west-1",
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      endpoint: "http://localhost:9000",   # optional, for S3-compatible services
      prefix: "uploads",                   # optional key prefix
      public: false,                       # set to true for public-read ACL
      upload_options: {
        "Cache-Control" => "max-age=31536000",
      }
    )
    ```

    The S3 backend depends on the `awscr-s3` shard, so add it to your
    `shard.yml` alongside Latch:

    ```yaml
    dependencies:
      latch:
        github: wout/latch
      awscr-s3:
        github: taylorfinnell/awscr-s3
    ```

    Once configured, you can generate presigned URLs from any stored file:

    ```crystal
    user.avatar.try(&.url(expires_in: 1.hour))
    ```

    ### Memory

    The in-memory backend is intended for tests. It keeps everything in
    process, so there are no files to clean up between specs:

    ```crystal
    Latch::Storage::Memory.new(base_url: "https://cdn.example.com")
    ```

    See [Working with the test environment](#anchor-test-environment) below
    for the recommended setup.

    ## Per-environment configuration

    A typical Lucky app uses different backends in development, test, and
    production. The cleanest way to express that is to switch on
    `Lucky::Env`:

    ```crystal
    # config/latch.cr
    Latch.configure do |settings|
      if LuckyEnv.test?
        settings.storages["cache"] = Latch::Storage::Memory.new
        settings.storages["store"] = Latch::Storage::Memory.new
      elsif LuckyEnv.production?
        settings.storages["cache"] = Latch::Storage::S3.new(
          bucket: ENV.fetch("S3_BUCKET"),
          region: ENV.fetch("AWS_REGION"),
          access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
          secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
          prefix: "cache"
        )
        settings.storages["store"] = Latch::Storage::S3.new(
          bucket: ENV.fetch("S3_BUCKET"),
          region: ENV.fetch("AWS_REGION"),
          access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
          secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
          prefix: "uploads"
        )
      else
        settings.storages["cache"] = Latch::Storage::FileSystem.new(
          directory: "uploads", prefix: "cache"
        )
        settings.storages["store"] = Latch::Storage::FileSystem.new(
          directory: "uploads"
        )
      end

      settings.path_prefix = ":model/:id/:attachment"
    end
    ```

    ## Working with the test environment

    With the in-memory backend in place, every spec starts with empty storage.
    To make sure no file leaks between examples, clear the storages in a
    `Spec.before_each` hook:

    ```crystal
    # spec/spec_helper.cr
    Spec.before_each do
      Latch.settings.storages.each_value(&.as(Latch::Storage::Memory).clear!)
    end
    ```

    Custom storages, for example an S3-compatible service running locally,
    can be plugged in the same way. See
    [Custom storage](https://github.com/wout/latch/blob/main/README.md#custom-storage)
    in the Latch README for the storage interface.

    ## Next steps

    With Latch installed and configured, you're ready to define an
    [uploader](#{Guides::HandlingFiles::Uploaders.path}): the struct that
    describes how a particular kind of file is stored and what metadata it
    carries.
    MD
  end
end
