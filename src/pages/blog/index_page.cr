class Blog::IndexPage < BlogLayout
  needs posts : Array(BasePost)

  def middle_section
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "flex container mx-auto" do
        div class: "mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2 pt-12 pb-16" do
          h1 "Want to stay up to date?", class: " text-white font-normal text-2xl mb-3 text-shadow"
          div class: "flex flex-row w-full shadow-lg rounded-lg" do
            input type: "email",
              class: "bg-white p-4 text-lg w-full rounded-l-lg border-b border-teal-darker",
              placeholder: "Enter your email"
            input type: "submit",
              value: "Subscribe",
              class: "py-3 px-5 rounded-r-lg cursor-pointer text-white text-shadow uppercase tracking-wide font-bold bg-lucky-green-vertical-gradient hover:bg-lucky-green-vertical-gradient-dark text-sm border-b border-teal-darker"
          end
        end
      end
    end
  end

  def content
    div class: "mt-6" do
      2.times do
        @posts.each do |post|
          div class: "py-8 flex flex-col mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2" do
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
  end
end
