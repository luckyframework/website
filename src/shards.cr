# Require your shards here
require "lucky_env"

LuckyEnv.load?(".env")

require "lucky"
require "carbon"
require "cmark"
require "cadmium_transliterator"
require "lexbor"
require "../vendor/**"
