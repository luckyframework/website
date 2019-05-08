class Blog::IndexPage < BlogLayout
  needs posts : Array(BasePost)

  def content
    div class: "mt-6" do
      2.times do
        @posts.each do |post|
          div class: "py-8 flex flex-col mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2" do
            link post.title, to: "#", class: "no-underline hover:underline hover:text-teal-darker font-normal text-2xl text-teal-dark tracking-medium"
            para class: "my-3 leading-loose" do
              raw post.summary
            end
            span class: "font-normal text-sm text-grey-dark uppercase tracking-wide mt-1" do
              render_published_at(post.published_at)
            end
          end
        end
      end
    end
  end

  def render_published_at(published_at)
    if published_at
      text "Published "
      time_ago_in_words published_at
    else
      text "Unpublished"
    end
  end
end
