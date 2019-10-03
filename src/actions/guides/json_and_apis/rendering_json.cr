class Guides::JsonAndApis::RenderingJson < GuideAction
  guide_route "/json-and-apis/rendering-json"

  def self.title
    "Rendering JSON"
  end

  def markdown : String
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
    JSON across endpoints.

    Let’s create one for rendering the JSON for an article.

    ```crystal
    # In src/serializers/article_serializer.cr
    class ArticleSerializer < BaseSerializer
      def initialize(@article : Article)
      end

      def render
        {title: @article.title}
      end
    end

    # In the action
    class Api::Articles::Show < ApiAction
      route do
        article = ArticleQuery.new.find(id)
        json ArticlesSerializer.new(article)
      end
    end
    ```

    ## Rendering a collection with serializers

    Lucky apps are generated with a `BaseSerializer` in `src/serializers/base_serializer.cr`.
    This serializer has a `for_collection` method defined that renders a collection
    of objects.

    Here's how you'd use it:

    ```crystal
    class Api::Articles::Index < ApiAction
      route do
        articles = ArticleQuery.new
        json ArticlesSerializer.for_collection(articles)
      end
    end
    ```

    ## Nesting serializers

    Here’s how you can combine serializers for more complex responses. In this
    example we’ll render a list of articles along with their comments.

    First we'll create a serializer for comments:

    ```crystal
    # in src/serializers/comment_serializer.cr
    class CommentSerializer < BaseSerializer
      def initialize(@comment : Comment)
      end

      def render
        {body: @comment.body}
      end
    end
    ```

    ```crystal
    # in src/serializers/article_serializer.cr
    class ArticleSerializer < BaseSerializer
      def initialize(@article : Article)
      end

      def render
        {
          title: @article.title,
          comments: CommentSerializer.for_collection(@articles.comments)
        }
      end
    end

    ## Customizing collection rendering

    Let's say you want collection rendering to include a root key. We can change
    the generated `self.for_collection` method on the `BaseSerializer`.

    ```
    # src/serializers/base_serializer.cr
    abstract class BaseSerializer < Lucky::Serializer
      def self.for_collection(collection : Enumerable, *args, **named_args)
        {
          # The root key will be the 'self.collection_key' defined on
          # serializers that inhherit from this class.
          self.collection_key => collection.map do |object|
            new(object, *args, **named_args)
          end
        }
      end
    end
    ```

    Now add the 'self.collection_key'  to the `ArticleSerializer`:

    ```crystal
    class ArticleSerializer < BaseSerializer
      # 'render' and 'initialize' ommitted for brevity.

      # This will be the key for collections
      def self.collection_key
        "articles"
      end
    ```

    This is an example of how serializers are regular Crystal objects so you can
    use methods and arguments in all kinds of ways to customize serializers.

    ## Sending empty responses

    Sometimes you just need to return a status code. For that we use the `head` method:

    ```crystal
    # inside an action
    head :created
    # or use an integer
    head 201
    ```
    MD
  end
end
