require "../../../spec_helper"

describe Api::HtmlConversions::Create do
  it "returns a 200 response with converted content" do
    response = ApiClient.exec(Api::HtmlConversions::Create.with(input: "<div>Test</div>"))

    response.should send_json(200, content: "div \"Test\"\n")
  end

  it "returns a 503 (Service Unavailable) when HTML conversions are disabled" do
    ENV["DISABLE_HTML_CONVERSION_API"] = "Shut it down!"

    response = ApiClient.exec(Api::HtmlConversions::Create.with(input: "<div>Test</div>"))

    response.status_code.should eq(503)
  end
end
