class Api::HtmlConversions::Create < ApiAction
  before halt_if_html_conversion_disabled

  param input : String = ""

  post "/api/html_conversions" do
    output = HTML2Lucky::Converter.new(input).convert

    json({content: output}, :ok)
  end

  private def halt_if_html_conversion_disabled
    if ENV["DISABLE_HTML_CONVERSION_API"]?
      head :service_unavailable
    else
      continue
    end
  end
end
