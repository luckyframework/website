class Errors::Show < Lucky::ErrorAction
  DEFAULT_MESSAGE = "Something went wrong."
  default_format :html
  dont_report [Lucky::RouteNotFoundError]

  def render(error : Lucky::RouteNotFoundError)
    if html?
      error_html "Sorry, we couldn't find that page.", status: 404
    else
      error_json "Not found", status: 404
    end
  end

  # Always keep this below other 'render' methods or it may override your
  # custom 'render' methods.
  def render(error : Lucky::RenderableError)
    if html?
      error_html DEFAULT_MESSAGE, status: error.renderable_status
    else
      error_json error.renderable_message, status: error.renderable_status
    end
  end

  # If none of the 'render' methods return a response for the raised Exception,
  # Lucky will use this method.
  def default_render(error : Exception) : Lucky::Response
    if html?
      error_html DEFAULT_MESSAGE, status: 500
    else
      error_json DEFAULT_MESSAGE, status: 500
    end
  end

  private def error_html(message : String, status : Int)
    context.response.status_code = status
    html_with_status Errors::ShowPage, status, message: message, status_code: status
  end

  private def error_json(message : String, status : Int, details = nil, param = nil)
    json ErrorSerializer.new(message: message, details: details, param: param), status: status
  end

  private def report(error : Exception) : Nil
    # Send to Rollbar, send an email, etc.
  end
end
