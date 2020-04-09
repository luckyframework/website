class Blog::ShowPage < BlogLayout
  needs post : BasePost

  def middle_section
    div class: "mx-auto pt-6 pb-8 md:pt-12 md:pb-16 #{responsive_container_classes}" do
      div class: "mb-2" do
        mount PublishedAt.new(post, color: "text-blue-lighter")
      end
      h1 post.title, class: " text-white font-normal text-2xl md:text-4xl mb-3 text-shadow font-bold"
      para class: "text-white md:text-xl leading-loose text-blue-lightest" do
        raw post.summary
      end
    end
  end

  def content
    div class: "md:mt-6" do
      div class: "py-6 md:py-8 flex flex-col mx-auto #{responsive_container_classes}" do
        div class: "my-3 leading-loose md:text-lg markdown-content" do
          raw CustomMarkdownRenderer.render_to_html(post.content)
        end
      end
    end
  end

  def responsive_container_classes
    "w-full md:w-3/4 lg:w-4/5 xl:w-3/5 px-5"
  end
end
