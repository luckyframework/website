class Guides::HandlingFiles::Uploaders < GuideAction
  guide_route "/handling-files/uploaders"

  def self.title
    "Uploaders"
  end

  def markdown : String
    <<-MD
    ## What is an uploader?

    An *uploader* is a small struct that ties together everything Latch needs
    to know about a particular kind of file: where it should be stored, what
    metadata to extract from it, and how it should be processed. You typically
    define one per attachment type, like `AvatarUploader`, `InvoicePdfUploader`,
    `ProductImageUploader`, and so on.

    The minimum is a struct that includes `Latch::Uploader`:

    ```crystal
    # src/uploaders/avatar_uploader.cr
    struct AvatarUploader
      include Latch::Uploader
    end
    ```

    Lucky apps don't generate `src/uploaders` by default. Create the
    directory and add a `require` line to `src/app.cr` so the compiler picks
    it up. It must come *before* `./models/**`, because your models will
    reference the uploader's `StoredFile` type:

    ```crystal
    # src/app.cr
    require "./shards"

    require "../config/server"
    require "./app_database"
    require "../config/**"
    require "./models/base_model"
    require "./uploaders/**" # <- add this before models
    require "./models/**"
    # ...
    ```

    ## What you get for free

    Including `Latch::Uploader` does three things:

    - Generates a `StoredFile` subclass nested inside the uploader, e.g.
      `AvatarUploader::StoredFile`. This is the type you store on your
      models.
    - Registers three default metadata extractors: `filename`, `mime_type`,
      and `size`. You can read these directly off any stored file.
    - Wires the uploader up to the `"cache"` and `"store"` storages from your
      `config/latch.cr`.

    Once defined, you can move files through the uploader manually:

    ```crystal
    # Cache: temporary storage, e.g. between form submissions
    cached = AvatarUploader.cache(uploaded_file)

    # Promote a cached file to permanent storage
    stored = AvatarUploader.promote(cached)

    # Or store directly, skipping the cache stage
    stored = AvatarUploader.store(uploaded_file)
    ```

    In a Lucky app you'll rarely need to call these methods yourself. The
    [Avram integration](#{Guides::HandlingFiles::AvramIntegration.path}) takes
    care of caching and promotion as part of the save lifecycle. They're useful
    when you need to ingest files outside of an Avram operation, for example
    from a background job that pulls data from an external API.

    ## Customising the upload location

    By default, Latch generates a unique location for every upload using the
    `path_prefix` from `config/latch.cr` and a random ID. Override
    `generate_location` if you want full control over where files end up:

    ```crystal
    struct AvatarUploader
      include Latch::Uploader

      def generate_location(uploaded_file, metadata, **options) : String
        date = Time.utc.to_s("%Y/%m/%d")
        File.join("avatars", date, super)
      end
    end
    ```

    Calling `super` keeps the default unique-ID behaviour, so you only have to
    add the parts you care about.

    ## Custom storage keys

    The default `"cache"` and `"store"` keys cover most apps, but you might
    want certain files to live in a different storage. For example, sensitive
    documents in a private S3 bucket while images go to a public CDN. The
    `storages` macro lets each uploader pick its own keys:

    ```crystal
    struct InvoiceUploader
      include Latch::Uploader

      storages cache: "tmp", store: "private"
    end
    ```

    Both keys must exist in `Latch.settings.storages`.

    ## Working with stored files

    Every uploader produces its own `StoredFile` subclass when files are
    cached, promoted, or stored. A `StoredFile` is a JSON-serialisable value
    object (that's why you can put it in a database column), but it also has a
    handful of convenience methods for working with the underlying file:

    ```crystal
    stored.url       # storage URL
    stored.exists?   # check existence
    stored.extension # file extension, e.g. ".jpg"
    stored.delete    # remove from storage

    stored.open { |io| io.gets_to_end }            # read content
    stored.download { |tempfile| tempfile.path }   # download to a tempfile
    stored.stream(response.output)                 # stream to any IO
    ```

    ## Extending StoredFile with custom methods

    Each uploader's `StoredFile` is a real class, so you can reopen it and add
    methods that make sense for your domain:

    ```crystal
    struct AvatarUploader
      include Latch::Uploader

      extract dimensions, using: Latch::Extractor::DimensionsFromMagick

      class StoredFile
        def aspect_ratio : Float64
          width.to_f / height
        end

        def landscape? : Bool
          aspect_ratio > 1
        end
      end
    end

    user.avatar.try(&.aspect_ratio)
    ```

    The methods are scoped to that uploader's stored files, so different
    uploaders can have different helpers without bleeding into one another.

    ## Next steps

    Once your uploader is in place, the next thing to teach it is what to
    learn from incoming files. Continue to
    [Extracting Metadata](#{Guides::HandlingFiles::ExtractingMetadata.path}).
    MD
  end
end
