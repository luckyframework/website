class Guides::JsonAndApis::RenderingJson < GuideAction
  guide_route "/json-and-apis/rendering-json"

  def self.title
    "Rendering JSON"
  end

  def markdown
    <<-MD
    > This guide covers the basics of implementing a JSON API. If you have any
    questions about how to use Lucky in more complex ways, hop on our
    [chatroom](https://gitter.im/luckyframework/Lobby). We'd be happy to help!

    ## Respond with JSON

    To respond with JSON we use the `json` method in an action:

    ```crystal
    # in src/actions/api/articles/show.cr
    class Api::Articles::Show < ApiAction
      route do
        json({title: "My Post"})
        # Add an optional status code
        json({title: "My Post"}, Status::OK) # or use an integer like `200`
      end
    end
    ```

    > Here is a [list of all statuses Lucky
    supports](https://github.com/luckyframework/lucky/blob/9e390e12c9f517517f6526d26fde372dfd02585c/src/lucky/action.cr#L20-L80)

    ## Create a serializer

    Serializers help you customize the response, and allow you to share common
    JSON.

    Let’s create one for rendering the JSON for a single article.

    ```crystal
    # in src/serializers/api/articles/show_serializer.cr
    class Api::Articles::ShowSerializer < Lucky::Serializer
      def initialize(@article : Article)
      end

      def render
        {title: @article.title}
      end
    end

    # in the action
    class Api::Articles::Show < ApiAction
      route do
        article = ArticleQuery.new.find(id)
        json Api::Articles::ShowSerializer.new(article)
      end
    end
    ```

    > In the example, you could also use `ShowSerializer.new(article)`
    > because the action and the serializer classes are in the same
    > namespace (`Api::Articles`).

    ## Handling nested JSON and extra options

    Here’s how you can combine JSON for more complex responses. In this example
    we’ll render a list of articles and the total number of articles:

    ```crystal
    # in src/serializers/articles/index_serializer.cr
    class Articles::IndexSerializer < Lucky::Serializer
      def initialize(@articles : ArticleQuery, @total : Int64)
      end

      def render
        {
          # reuse the existing Articles::ShowSerializer
          articles: @articles.map { |article| ShowSerializer.new(article) },
          total: @total
        }
      end
    end

    # in src/actions/api/articles/index.cr
    class Api::Articles::Index < ApiAction
      route do
        articles = ArticleQuery.new
        total = ArticleQuery.new.count
        json Articles::IndexSerializer.new(articles, total)
      end
    end
    ```

    ## Sending empty responses

    Sometimes you just need to return a status code. For that we use the `head` method:

    ```crystal
    # inside an action
    head Status::Created
    # or use an integer
    head 201
    ```
    MD
  end
end
