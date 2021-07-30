class Learn::AwesomeLucky::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    div class: "flex flex-col flex-1 justify-start mt-5" do
      render_blog_posts_list
      render_tools_list
      render_shards_list
    end
  end

  # A list of awesome blog posts about using Lucky
  private def render_blog_posts_list
    mount AwesomeListGroup, group_title: "Blog Posts" do
      mount AwesomeLink,
        text: "Lucky, an experimental new web framework by thoughtbot",
        url: "https://thoughtbot.com/blog/lucky-an-experimental-new-web-framework-by-thoughtbot"
      mount AwesomeLink,
        text: "Ruby on Rails to Lucky on Crystal: Blazing fast, fewer bugs, and even more fun.",
        url: "https://hackernoon.com/ruby-on-rails-to-lucky-on-crystal-blazing-fast-fewer-bugs-and-even-more-fun-104010913fec"
      mount AwesomeLink,
        text: "Blogs on Dev.to",
        url: "https://dev.to/t/lucky"
    end
  end

  # A list of awesome tools to make developing Lucky applications easier
  private def render_tools_list
    mount AwesomeListGroup, group_title: "Tools" do
      mount AwesomeLink,
        text: "LuckyDiff",
        url: "https://luckydiff.com",
        description: "Compare generated apps between Lucky versions."
    end
  end

  # A list of Lucky specific shards to enhance your application
  private def render_shards_list
    mount AwesomeListGroup, group_title: "Shards" do
      mount AwesomeLink,
        text: "Lucky Basic Auth",
        url: "https://github.com/jwoertink/lucky-basic-auth"
      mount AwesomeLink,
        text: "Lucky Cluster",
        url: "https://github.com/jwoertink/lucky-cluster",
        description: "Enable multi-process with reuseport for your Lucky application"
    end
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "Awesome Lucky"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            text <<-TEXT
            A categorized community-driven collection of awesome Lucky libraries, tools, resources.
            TEXT
            br
            text "Originally provided by the Awesome"
            nbsp
            a "@andrewmcodes", href: "https://github.com/andrewmcodes", target: "_blank"
          end
        end
      end
    end
  end
end
