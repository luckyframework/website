class Guides::JsonAndApis::Cors < GuideAction
  guide_route "/json-and-apis/cors"

  def self.title
    "Cross-Origin Resource Sharing (CORS)"
  end

  def markdown
    <<-MD
    ## Handling CORS

    When working with an API, you may need to set some [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers. Doing this in Lucky is pretty easy!

    In your `src/actions/api_action.cr`, you can use a `before` action to set your headers.

    ```crystal
    abstract class ApiAction < Lucky::Action
      before set_cors_headers

      def set_cors_headers
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Headers"] =
          "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range"
        continue
      end
    end
    ```

    > Note: the before action method must return `continue`, or a `LuckyWeb::Response`. See [Actions and Routing](/guides/actions-and-routing/#run-code-before-or-after-actions-with-pipes) for more info.
    MD
  end
end
