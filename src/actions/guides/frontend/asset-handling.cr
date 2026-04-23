class Guides::Frontend::AssetHandling < GuideAction
  guide_route "/frontend/asset-handling"

  def self.title
    "Asset Handling"
  end

  ANCHOR_BUN             = "perma-bun"
  ANCHOR_CONFIGURATION   = "perma-configuration"
  ANCHOR_ENTRY_POINTS    = "perma-entry-points"
  ANCHOR_JAVASCRIPT      = "perma-javascript"
  ANCHOR_CSS             = "perma-css"
  ANCHOR_STATIC_ASSETS   = "perma-static-assets"
  ANCHOR_PLUGINS         = "perma-plugins"
  ANCHOR_CUSTOM_PLUGINS  = "perma-custom-plugins"
  ANCHOR_LOADING_ASSETS  = "perma-loading-assets"
  ANCHOR_LIVE_RELOAD     = "perma-live-reload"
  ANCHOR_FINGERPRINTING  = "perma-fingerprinting"
  ANCHOR_COMPRESSION     = "perma-compression"
  ANCHOR_ASSET_HOST      = "perma-asset-host"
  ANCHOR_DEPLOYING       = "perma-deploying"
  ANCHOR_LEGACY_BUNDLERS = "perma-legacy-bundlers"

  def markdown : String
    <<-MD
    #{permalink(ANCHOR_BUN)}
    ## Asset handling with Bun

    Lucky uses [Bun](https://bun.sh) as its built-in asset bundler. It handles JavaScript, TypeScript, CSS, images, and fonts out of the box with zero configuration. Bun is extremely fast and requires no additional dependencies beyond Bun itself.

    The default setup works for most apps without any configuration. When you need more control, everything can be customized through a single `config/bun.json` file.

    #{permalink(ANCHOR_CONFIGURATION)}
    ## Configuration

    Lucky's Bun integration works without the configuration file. The defaults are:

    * Entry points: `src/js/app.js` and `src/css/app.css`
    * Output directory: `public/assets`
    * Public path: `/assets`
    * Static asset directories: `src/images` and `src/fonts`
    * Watch directories: `src/js`, `src/css`, `src/images`, and `src/fonts`
    * Plugins: `aliases` and `cssGlobs` for CSS, `aliases` and `jsGlobs` for JavaScript
    * Manifest: `public/bun-manifest.json`
    * Dev server: `127.0.0.1:3002`

    To customize these defaults, create a `config/bun.json` file in your project root:

    ```json
    {
      "entryPoints": {
        "js": ["src/js/app.js", "src/js/admin.js"],
        "css": "src/css/app.css"
      },
      "staticDirs": ["src/images", "src/fonts"],
      "watchDirs": ["src/js", "src/css", "src/images", "src/fonts"],
      "outDir": "public/assets",
      "publicPath": "/assets",
      "manifestPath": "public/bun-manifest.json",
      "plugins": {
        "css": ["aliases", "cssGlobs"],
        "js": ["aliases", "jsGlobs"]
      },
      "devServer": {
        "host": "127.0.0.1",
        "port": 3002
      }
    }
    ```

    All fields are optional. Only include the ones you want to override.

    > Entry points can be a single string or an array of strings.

    ### Docker and remote development

    If you're running Lucky inside Docker or a remote container, you may need the dev server to listen on all interfaces while the browser connects to a specific host:

    ```json
    {
      "devServer": {
        "host": "localhost",
        "listenHost": "0.0.0.0",
        "port": 3002
      }
    }
    ```

    #{permalink(ANCHOR_JAVASCRIPT)}
    ## Structuring your JavaScript

    The default entry point for JavaScript is `src/js/app.js`. Bun supports JavaScript, TypeScript, JSX, and TSX out of the box, so you can use `.js`, `.ts`, `.jsx`, or `.tsx` files without any additional setup.

    To add new JavaScript, create files in `src/js/` and import them from your entry point:

    ```javascript
    // src/js/app.js
    import "./my-component.js"
    ```

    #{permalink(ANCHOR_ENTRY_POINTS)}
    ### Multiple entry points

    If you need separate bundles (for example, an admin area), add additional entry points in `config/bun.json`:

    ```json
    {
      "entryPoints": {
        "js": ["src/js/app.js", "src/js/admin.js"]
      }
    }
    ```

    Each entry point produces its own output file.

    #{permalink(ANCHOR_CSS)}
    ## Structuring your CSS

    The default CSS entry point is `src/css/app.css`. Organize your styles by creating files in `src/css/` and importing them:

    ```css
    /* src/css/app.css */
    @import './components/buttons.css';
    @import './components/forms.css';
    ```

    ### Glob imports in CSS

    Lucky includes a `cssGlobs` plugin that lets you import multiple CSS files with a glob pattern:

    ```css
    /* Import all CSS files in the components directory */
    @import './components/**/*.css';
    ```

    This expands to individual `@import` statements for each matching file, sorted alphabetically for deterministic output.

    #{permalink(ANCHOR_STATIC_ASSETS)}
    ## Images, fonts and other static assets

    Place images in `src/images/` and fonts in `src/fonts/`. These directories are configured as `staticDirs` by default. All files in these directories are copied to the output directory and included in the asset manifest.

    In production, static assets are fingerprinted with a content hash just like JavaScript and CSS files.

    You can add more static directories in `config/bun.json`:

    ```json
    {
      "staticDirs": ["src/images", "src/fonts", "src/pdfs"]
    }
    ```

    ### Root aliases in CSS

    The `aliases` plugin lets you reference files from the project root using `$/` in CSS `url()` declarations:

    ```css
    background: url('$/src/images/my-background.jpg');
    ```

    This resolves to the absolute path at build time, so you don't need to worry about relative path depth.

    #{permalink(ANCHOR_PLUGINS)}
    ## Built-in plugins

    Lucky's Bun setup comes with three built-in plugins enabled by default:

    * **aliases**: Resolves `$/` root aliases in both CSS and JavaScript imports. For example, `import x from '$/lib/utils.js'` resolves to the project root.
    * **cssGlobs**: Expands glob patterns in CSS `@import` statements, as described in the CSS section above.
    * **jsGlobs**: Compiles glob imports in JavaScript into an object mapping filenames to their default exports.

    ### The jsGlobs plugin

    The `jsGlobs` plugin lets you import multiple modules at once using a `glob:` prefix:

    ```javascript
    import components from 'glob:./components/**/*.js'
    ```

    This generates an object where each key is the relative filename (without extension) and the value is the module's default export:

    ```javascript
    // Generated code:
    import _glob_components_tooltip from './components/tooltip.js'
    import _glob_components_shared_modal from './components/shared/modal.js'
    const components = {
      'tooltip': _glob_components_tooltip,
      'shared/modal': _glob_components_shared_modal
    }
    ```

    > The `components` object in the example above can then be used to, for example, register Alpine.js components or Stimulus.js controllers in one go.

    #{permalink(ANCHOR_CUSTOM_PLUGINS)}
    ### Custom plugins

    You can add your own plugins by referencing a file path in `config/bun.json`:

    ```json
    {
      "plugins": {
        "css": ["aliases", "cssGlobs", "config/bun/my-css-plugin.js"],
        "js": ["aliases", "jsGlobs"]
      }
    }
    ```

    > When you override the `plugins` key, it replaces the defaults entirely. Make sure to include the built-in plugins you still want.

    A plugin is a JavaScript file that exports a factory function. The factory receives a context object (with `root`, `config`, `dev`, `prod`, and `manifest` properties) and returns one of two things:

    **A transform function** that takes the file content as a string and returns the transformed content. All built-in plugins use this approach. Transforms are chained in order and run on every file matching the plugin type (CSS or JS).

    ```javascript
    // config/bun/my-css-plugin.js
    export default function myPlugin(context) {
      return (content, args) => {
        return content.replace(/old-token/g, 'new-token')
      }
    }
    ```

    **A raw Bun plugin object** for when you need to hook into Bun's build pipeline at a lower level, for example to handle custom file types or custom loaders. See the [Bun plugin documentation](https://bun.sh/docs/bundler/plugins) for details.

    ```javascript
    // config/bun/my-bun-plugin.js
    export default function myPlugin(context) {
      return {
        name: 'my-plugin',
        setup(build) {
          build.onLoad({filter: /\\.custom$/}, async (args) => {
            return {contents: '...', loader: 'js'}
          })
        }
      }
    }
    ```

    #{permalink(ANCHOR_LOADING_ASSETS)}
    ## Loading assets

    Use the `asset` macro in pages and components to get the path to a built asset:

    ```crystal
    # In a page or component
    # Will find the asset in public/assets/images/logo.png
    img src: asset("images/logo.png")
    ```

    Assets are checked at compile time. If an asset is not found, Lucky will let you know and suggest similar asset names if you made a typo.

    Use `css_link` and `js_link` for stylesheets and scripts:

    ```crystal
    # In your layout's head
    css_link asset("css/app.css")
    js_link asset("js/app.js")
    ```

    If the path of the asset is only known at runtime, use the `dynamic_asset` method instead:

    ```crystal
    img src: dynamic_asset("images/\#{name}.png")
    ```

    > `dynamic_asset` does not check assets at compile time. Make sure to test that the asset exists.

    ### Using assets outside of pages and components

    You can use `Lucky::AssetHelpers.asset` just about anywhere:

    ```crystal
    Lucky::AssetHelpers.asset("images/logo.png")
    ```

    #{permalink(ANCHOR_LIVE_RELOAD)}
    ## Live reload

    Lucky's Bun integration includes a built-in live reload server. When you run `lucky dev`, a WebSocket server starts on port 3002 (configurable) and watches your asset directories for changes.

    To enable live reload in your pages, add the reload tag to your layout:

    ```crystal
    # In your main layout
    bun_reload_connect_tag
    ```

    This tag only renders in development, so there is no need to wrap it in a conditional.

    When you change a CSS file, only the stylesheets are hot-reloaded without a full page refresh. Changes to JavaScript, images, or fonts trigger a full page reload.

    #{permalink(ANCHOR_FINGERPRINTING)}
    ## Asset fingerprinting

    In production, all assets are fingerprinted with a content hash appended to the filename (e.g. `app-8dc912a1.js`). This allows browsers to cache assets indefinitely. When an asset changes, the hash changes and browsers automatically fetch the new version.

    In development, assets use plain filenames without hashes for easier debugging.

    Make sure to use the `asset` macro to get the correct fingerprinted paths.

    #{permalink(ANCHOR_COMPRESSION)}
    ## Disabling asset caching in development

    Lucky includes a `Lucky::DevAssetCacheHandler` middleware that prevents the browser from caching assets during development. This ensures you always see the latest version of your assets without needing to hard-refresh.

    Add it to your middleware stack in `src/app_server.cr` with the `enabled` parameter to limit it to development:

    ```crystal
    # In src/app_server.cr
    def middleware : Array(HTTP::Handler)
      [
        # ...
        Lucky::DevAssetCacheHandler.new(enabled: LuckyEnv.development?),
        Lucky::StaticFileHandler.new("./public", fallthrough: false, directory_listing: false),
        # ...
      ] of HTTP::Handler
    end
    ```

    When enabled, it sets `Cache-Control: no-store, no-cache, must-revalidate` on all asset responses so the browser always fetches fresh files.

    #{permalink(ANCHOR_ASSET_HOST)}
    ## Asset host

    Once your app is in production, you may want to serve up your assets through a
    [CDN](https://en.wikipedia.org/wiki/Content_delivery_network). To specify a different
    host, you'll use the `asset_host` option in `config/server.cr`.

    ```crystal
    # In config/server.cr
    Lucky::Server.configure do |settings|
      if LuckyEnv.production?
        settings.asset_host = "https://mycdnhost.com"
      else
        # Serve up assets locally in development and test
        settings.asset_host = ""
      end
    end
    ```

    #{permalink(ANCHOR_DEPLOYING)}
    ## Deploying to production

    Before compiling your project for production, build the assets with:

    ```bash
    bun run src/bun/bake.js --prod
    ```

    This minifies all JavaScript and CSS, fingerprints every asset, and generates the manifest at `public/bun-manifest.json`. Then compile your Lucky app as usual.

    ## Loading the asset manifest

    Lucky loads the asset manifest at compile time. In your `src/app.cr`, you should have:

    ```crystal
    Lucky::AssetHelpers.load_manifest
    ```

    This loads the Bun manifest by default. If you are migrating from an older setup, you can specify a different bundler:

    ```crystal
    # Laravel Mix:
    Lucky::AssetHelpers.load_manifest(from: :mix)

    # Vite:
    Lucky::AssetHelpers.load_manifest(from: :vite)
    ```

    #{permalink(ANCHOR_LEGACY_BUNDLERS)}
    ## Legacy bundlers (Mix and Vite)

    Older Lucky projects may use Laravel Mix (Webpack) or Vite for asset handling. These setups are still supported for backwards compatibility, but new projects use Bun by default.

    If you are starting a new project, there is no need to set up Mix or Vite. If you have an existing project using one of these bundlers, it will continue to work, just make sure to pass the `from:` option when loading the manifest as shown above.
    MD
  end
end
