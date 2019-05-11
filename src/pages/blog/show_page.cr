class Blog::ShowPage < BlogLayout
  needs post : BasePost

  def middle_section
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "flex container mx-auto" do
        div class: "mx-auto pt-12 pb-16 #{width_classes}" do
          div class: "mb-2" do
            mount PublishedAt.new(@post.published_at, color: "text-blue-lighter")
          end
          h1 @post.title, class: " text-white font-normal text-4xl mb-3 text-shadow font-bold"
          para class: "text-white text-xl leading-loose text-blue-lightest" do
            raw @post.summary
          end
        end
      end
    end
  end

  def content
    div class: "mt-6" do
      div class: "py-8 flex flex-col mx-auto #{width_classes}" do
        div class: "my-3 leading-loose text-lg markdown-content" do
          raw CustomMarkdownRenderer.render_to_html(@post.content)
        end
      end
    end
  end

  def width_classes
    "w-full md:w-3/4 lg:w-4/5 xl:w-3/5"
  end
end
