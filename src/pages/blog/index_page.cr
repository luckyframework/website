class Blog::IndexPage < BlogLayout
  needs posts : Array(BasePost)

  def middle_section
    div class: "#{responsive_container_classes} pt-8 pb-10 md:pt-12 md:pb-16" do
      h1 "Want to stay up to date?", class: " text-white font-normal text-2xl mb-5 md:mb-3 text-shadow"

      form action: "https://gmail.us20.list-manage.com/subscribe/post?u=b742935e1ac2e7aabaa8b9da9&id=a7ae9d7f32", class: "validate", id: "mc-embedded-subscribe-form", method: "post", name: "mc-embedded-subscribe-form", novalidate: "", target: "_blank" do
        div class: "flex flex-row w-full shadow-lg rounded-lg" do
          input type: "email",
            name: "EMAIL",
            class: "bg-white p-4 md:p-4 md:text-lg w-full rounded-l md:rounded-l-lg border-b border-teal-darker",
            placeholder: "Enter your email"
          div aria_hidden: "true", style: "position: absolute; left: -5000px;" do
            input name: "b_b742935e1ac2e7aabaa8b9da9_a7ae9d7f32", tabindex: "-1", type: "text", value: ""
          end
          input type: "submit",
            value: "Subscribe",
            class: "py-3 px-5 rounded-r md:rounded-r-lg cursor-pointer text-white text-shadow uppercase tracking-wide font-bold bg-lucky-green-vertical-gradient hover:bg-lucky-green-vertical-gradient-dark text-sm border-b border-teal-darker"
        end
      end
    end
  end

  def content
    div class: "md:mt-6" do
      @posts.each do |post|
        div class: "py-8 flex flex-col #{responsive_container_classes}" do
          mount PublishedAt.new(post)
          link post.title,
            to: Blog::Show.with(post.slug),
            class: "no-underline mt-2 hover:underline hover:text-teal-darker font-normal text-2xl text-teal-dark tracking-medium"
          para class: "my-3 leading-loose" do
            raw post.summary
          end
        end
      end
    end
  end

  def responsive_container_classes
    "mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2 px-5"
  end
end
