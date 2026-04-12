class Guides::HandlingFiles::ExtractingMetadata < GuideAction
  guide_route "/handling-files/extracting-metadata"

  def self.title
    "Extracting Metadata"
  end

  def markdown : String
    <<-MD
    ## What is metadata extraction?

    Every uploaded file carries information beyond its bytes: a filename, a
    MIME type, a size in bytes, and depending on what kind of file it is,
    things like image dimensions, audio duration, or PDF page count. Latch
    represents this with **extractors**: small structs that read a file as it
    moves through an uploader and write values into the stored file's
    metadata.

    The extracted values are persisted alongside the file location in your
    database (the `metadata` object inside the `StoredFile` JSON), so you can
    read them back without touching the storage backend.

    ## Built-in extractors

    Every uploader registers three extractors automatically. You don't have to
    do anything to enable them:

    - `FilenameFromIO` → `filename`
    - `MimeFromIO` → `mime_type` (from the upload's `Content-Type`)
    - `SizeFromIO` → `size` (in bytes)

    These show up as methods on the resulting `StoredFile`:

    ```crystal
    user.avatar.try(&.filename)  # => "photo.jpg"
    user.avatar.try(&.mime_type) # => "image/jpeg"
    user.avatar.try(&.size)      # => 102400
    ```

    Latch ships a handful of additional extractors that depend on external
    tools. Register them with the `extract` macro on your uploader:

    ```crystal
    struct AvatarUploader
      include Latch::Uploader

      extract mime_type, using: Latch::Extractor::MimeFromFile
      extract dimensions, using: Latch::Extractor::DimensionsFromMagick
    end
    ```

    The bundled extractors are:

    - `MimeFromExtension` → `mime_type` from the file's extension only
    - `MimeFromFile` → `mime_type` via the `file` CLI tool (more accurate
      than the upload's `Content-Type` header)
    - `DimensionsFromMagick` → `width` and `height` via `magick` or `identify`
    - `DimensionsFromVips` → `width` and `height` via `vipsheader`

    Registering a dimensions extractor adds typed `width` and `height` methods
    to the uploader's `StoredFile`:

    ```crystal
    user.avatar.try(&.width)  # => 2000
    user.avatar.try(&.height) # => 1333
    ```

    > The `MimeFromFile`, `DimensionsFromMagick`, and `DimensionsFromVips`
    > extractors shell out to external tools. Make sure those tools are
    > installed on every machine that runs uploads: your dev box, your CI
    > runner, and your production servers.

    ## Custom single-value extractors

    For anything that isn't covered by the built-ins, write a struct that
    includes `Latch::Extractor` and implements `extract`:

    ```crystal
    # src/uploaders/extractors/page_count_extractor.cr
    struct PageCountExtractor
      include Latch::Extractor

      def extract(uploaded_file, metadata, **options) : Int32?
        count_pages(uploaded_file.tempfile)
      end

      private def count_pages(tempfile : File) : Int32?
        # call out to pdfinfo, poppler, etc.
      end
    end
    ```

    Register it under whatever metadata key you want:

    ```crystal
    struct InvoiceUploader
      include Latch::Uploader
      extract pages, using: PageCountExtractor
    end

    invoice.document.try(&.pages) # => 24
    ```

    The return value of `extract` is what gets stored under that key.

    ## Multi-value extractors

    Sometimes a single extractor produces several related values, like image
    dimensions, video duration plus codec, or EXIF data. Write directly into the
    `metadata` hash and use the `@[Latch::MetadataMethods]` annotation to
    generate typed accessors for each value:

    ```crystal
    @[Latch::MetadataMethods(width : Int32, height : Int32)]
    struct CustomDimensionsExtractor
      include Latch::Extractor

      def extract(uploaded_file, metadata, **options) : Nil
        width, height = read_dimensions(uploaded_file.tempfile)
        metadata["width"] = width
        metadata["height"] = height
      end
    end
    ```

    Latch uses the annotation to generate `width : Int32` and `height : Int32`
    methods on every `StoredFile` belonging to an uploader that registers this
    extractor, with no manual cast required at the call site.

    ## Where metadata lives

    Extractor output is persisted as part of the `StoredFile` JSON, in a
    Shrine-compatible shape:

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

    Because the values are stored in the database alongside the file
    reference, reading metadata costs nothing at request time. You don't have
    to touch the storage backend to render an image's width or check whether
    a PDF has more than ten pages.

    ## Next steps

    Metadata describes what a file *is*. Processing changes what it *looks
    like*: resizing images, transcoding videos, generating thumbnails. That's
    next: [Processing Files](#{Guides::HandlingFiles::ProcessingFiles.path}).
    MD
  end
end
