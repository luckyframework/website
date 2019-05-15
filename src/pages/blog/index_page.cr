class Blog::IndexPage < BlogLayout
  needs posts : Array(BasePost)

  def middle_section
    div class: "#{responsive_container_classes} pt-8 pb-10 md:pt-12 md:pb-16" do
      h1 "Want to stay up to date?", class: " text-white font-normal md:text-2xl mb-5 md:mb-3 text-shadow"
      div class: "flex flex-row w-full shadow-lg rounded-lg" do
        input type: "email",
          class: "bg-white p-4 md:p-4 md:text-lg w-full rounded-l md:rounded-l-lg border-b border-teal-darker",
          placeholder: "Enter your email"
        input type: "submit",
          value: "Subscribe",
          class: "py-3 px-5 rounded-r md:rounded-r-lg cursor-pointer text-white text-shadow uppercase tracking-wide font-bold bg-lucky-green-vertical-gradient hover:bg-lucky-green-vertical-gradient-dark text-sm border-b border-teal-darker"
      end
    end
  end

  def content
    div class: "md:mt-6" do
      @posts.each do |post|
        div class: "py-8 flex flex-col #{responsive_container_classes}" do
          link post.title,
            to: Blog::Show.with(post.slug),
            class: "no-underline hover:underline hover:text-teal-darker font-normal text-2xl text-teal-dark tracking-medium"
          para class: "my-3 leading-loose" do
            raw post.summary
          end
          mount PublishedAt.new(post.published_at)
        end
      end
    end
  end

  def responsive_container_classes
    "mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2 px-5"
  end
end
