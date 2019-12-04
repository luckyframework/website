{% if !flag?(:without_zlib) %}
  require "gzip"
{% end %}

module Lucky::DynamicCompressionHandler
  COMPRESS_ONLY_THESE_EXTENSIONS = ["", ".html", ".htm", ".txt", ".json", ".xml"]

  Habitat.create do
    setting compress_server_generated_content : Bool = false
  end

  def gzip(context)
    {% if !flag?(:without_zlib) %}
      if should_gzip?(context)
        context.response.headers["Content-Encoding"] = "gzip"
        context.response.output = Gzip::Writer.new(context.response.output, sync_close: true)
      end
    {% end %}
    context
  end

  private def should_gzip?(context)
    settings.compress_server_generated_content &&
      context.request.headers.includes_word?("Accept-Encoding", "gzip") &&
      COMPRESS_ONLY_THESE_EXTENSIONS.includes?(File.extname(context.request.path))
  end
end

# Minor modifications needed to these classes to use Lucky::DynamicGzipHandler

class Lucky::RouteHandler
  include Lucky::DynamicCompressionHandler

  def call(context)
    handler = Lucky::Router.find_action(context.request)
    if handler
      Lucky.logger.debug({handled_by: handler.payload.to_s})
      handler.payload.new(gzip(context), handler.params).perform_action
    else
      call_next(context)
    end
  end
end

class Lucky::RouteNotFoundHandler
  include Lucky::DynamicCompressionHandler

  def call(context)
    gzip(context)
    if has_fallback?(context)
      Lucky.logger.debug(handled_by_fallback: fallback_action.name.to_s)
      fallback_action.new(context, {} of String => String).perform_action
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
