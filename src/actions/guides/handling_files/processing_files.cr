class Guides::HandlingFiles::ProcessingFiles < GuideAction
  guide_route "/handling-files/processing-files"

  def self.title
    "Processing Files"
  end

  def markdown : String
    <<-MD
    ## What is processing?

    Processing transforms an uploaded file into one or more **variants**, and
    can optionally rewrite the original itself. The most common use case is
    images: store one canonical version of an avatar capped at 2000×2000, and
    generate a 200×200 square thumbnail to display in the navbar.

    Latch keeps processing decoupled from uploading. A file can be uploaded
    now and processed later, processed inline as part of a save, or processed
    in a background job. Variants run in parallel, are addressable by name on
    the resulting `StoredFile`, and can be regenerated at any time without
    re-uploading.

    Latch ships with three processor backends (ImageMagick, FFmpeg, and
    libvips), plus a hook for writing your own.

    ## Defining a processor

    A processor is a struct that includes one of the built-in processor
    modules, declares an optional `original`, and lists its variants:

    ```crystal
    # src/uploaders/avatar_uploader.cr
    struct AvatarUploader
      include Latch::Uploader

      struct VersionsProcessor
        include Latch::Processor::Magick

        original resize: "2000x2000>"
        variant large, resize: "800x800"
        variant thumb, resize: "200x200", crop: "200x200+0+0", gravity: "center"
      end

      process versions, using: VersionsProcessor
    end
    ```

    The `process` macro on the uploader registers the processor under a name
    (`versions` here). That name becomes the prefix for the generated variant
    accessors on `StoredFile`:

    ```crystal
    user.avatar.try(&.versions_large.url) # => ".../versions_large.jpg"
    user.avatar.try(&.versions_thumb.url) # => ".../versions_thumb.jpg"
    ```

    Each variant accessor returns a `StoredFile` even if the variant hasn't
    been generated yet. For templates where you want to render only what
    actually exists, use the nilable accessor:

    ```crystal
    if thumb = user.avatar.try(&.versions_thumb?)
      img src: thumb.url
    end
    ```

    ## ImageMagick

    `Latch::Processor::Magick` wraps `magick convert` and is the right pick
    for the vast majority of image processing. Options are validated at
    compile time, so a typo in `quality` or `resize` is caught when you build
    your app, not in production:

    ```crystal
    struct AvatarProcessor
      include Latch::Processor::Magick

      original resize: "2000x2000>", strip: true, quality: 85
      variant large, resize: "800x800", quality: 85
      variant thumb,
        resize: "200x200^",
        crop: "200x200+0+0",
        gravity: "center",
        quality: 80
    end
    ```

    Available options include `auto_orient`, `background`, `colorspace`,
    `crop`, `density`, `extent`, `flatten`, `gaussian_blur`, `gravity`,
    `interlace`, `quality`, `resize`, `rotate`, `sampling_factor`, `sharpen`,
    `strip`, and `thumbnail`. The full list with descriptions lives in the
    [Latch README](https://github.com/wout/latch/blob/main/README.md#imagemagick-processor).

    > ImageMagick must be installed on every machine running uploads. On
    > Debian/Ubuntu: `apt install imagemagick`. On macOS: `brew install
    > imagemagick`.

    ## FFmpeg

    `Latch::Processor::FFmpeg` wraps `ffmpeg` and is the right pick when you
    need to transcode videos, strip audio tracks, or generate thumbnail frames
    from a video:

    ```crystal
    struct VideoProcessor
      include Latch::Processor::FFmpeg

      original video_codec: "libx264", crf: "23", preset: "fast"
      variant preview, scale: "640:-1", video_codec: "libx264", crf: "28"
      variant thumb, frames: "1", format: "image2", scale: "320:-1"
    end
    ```

    See the
    [FFmpeg processor section](https://github.com/wout/latch/blob/main/README.md#ffmpeg-processor)
    of the Latch README for the complete option reference.

    ## libvips

    `Latch::Processor::Vips` uses `vipsthumbnail` and `vips copy`. It's
    significantly faster than ImageMagick for resize-heavy workloads and uses
    far less memory, which makes it a good choice if you process a high
    volume of images:

    ```crystal
    struct AvatarProcessor
      include Latch::Processor::Vips

      original resize: "2000x2000>", strip: true
      variant large, resize: "800x800"
      variant thumb, resize: "200x200", crop: true, quality: 85
    end
    ```

    See the
    [Vips processor section](https://github.com/wout/latch/blob/main/README.md#vips-processor)
    for the full option list.

    ## Processing the original

    The `original` macro processes the uploaded file *in place*. There is no
    extra copy. Variants are always processed *before* the original, so they
    operate on the highest-quality source available, and only after every
    variant succeeds is the original overwritten.

    ```crystal
    struct AvatarProcessor
      include Latch::Processor::Magick

      original resize: "2000x2000>"   # cap any oversize uploads
      variant thumb, resize: "200x200"
    end
    ```

    If you don't declare an `original`, the upload is left untouched and only
    the variants are generated.

    ## When does processing run?

    Processing is decoupled from uploading, so you have three options:

    - **Inline, automatically.** In a `SaveOperation`, pass `process: true`
      to the `attach` macro and Latch will run the processor right after
      promoting the file. See
      [Avram Integration](#{Guides::HandlingFiles::AvramIntegration.path}).
    - **In a background job.** Pass a block to `attach` instead of
      `process: true` and enqueue a job that calls `record.avatar.process`.
      Recommended for anything heavier than a few small thumbnails.
    - **Manually.** Call `stored.process` yourself, useful in scripts or
      one-off backfills:

    ```crystal
    UserQuery.new.each do |user|
      user.avatar.try(&.process)
    end
    ```

    ## Error handling

    Processing errors are wrapped in `Latch::ProcessingError`, with the
    underlying exception available via `cause`:

    ```crystal
    begin
      stored.process
    rescue ex : Latch::ProcessingError
      Log.error { "\#{ex.message}: \#{ex.cause}" }
    end
    ```

    The most common causes are missing CLI tools (`Latch::CliToolNotFound`)
    and invalid input files (`IO::Error`).

    ## Custom processors

    If none of the built-in backends fit, you can define your own. The
    short form is to declare option types with `@[Latch::VariantOptions(...)]`
    and use the `process` macro inside a module. The block runs once per
    variant with `tempfile`, `variant_options`, and `variant_name` in scope,
    and should return an `IO`:

    ```crystal
    @[Latch::VariantOptions(quality: Int32)]
    module MyQualityProcessor
      include Latch::Processor

      process do
        do_your_thing(tempfile, variant_options) # returns an IO
      end
    end

    struct QualityProcessor
      include MyQualityProcessor

      variant high, quality: 95
      variant low, quality: 30
    end
    ```

    For full control (for example, to upload variants directly to a separate
    bucket), bypass the `process` macro and define `self.process` yourself.
    See
    [Custom processors](https://github.com/wout/latch/blob/main/README.md#custom-processors)
    in the Latch README for the long form.

    ## Next steps

    Now that you know how to define uploaders and processors, the last piece
    is wiring them into your Avram models, save operations, and forms. Head to
    [Avram Integration](#{Guides::HandlingFiles::AvramIntegration.path}).
    MD
  end
end
