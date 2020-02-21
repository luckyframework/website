require "./shards"

# Load .env file before any other config or app code
Dotenv.load?

# Load the asset manifest in public/mix-manifest.json
Lucky::AssetHelpers.load_manifest

require "./app_database"
require "./models/base_model"
require "./models/mixins/**"
require "./models/**"
require "./posts/base_post"
require "./posts/*"
require "./queries/mixins/**"
require "./queries/**"
require "./operations/mixins/**"
require "./operations/**"
require "./serializers/**"
require "./emails/base_email"
require "./emails/**"
require "./actions/mixins/**"
require "./actions/**"
require "./components/base_component"
require "./components/**"
require "./pages/**"
require "../config/env"
require "../config/**"
require "../db/migrations/**"
require "./utils/**"
require "./handlers/**"
require "./app_server"
