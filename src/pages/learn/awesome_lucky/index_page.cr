class Learn::AwesomeLucky::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    div class: "flex flex-col flex-1 justify-start mt-5" do
      render_blog_posts_list
      render_tools_list
      render_sites_list
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
      mount AwesomeLink,
        text: "Designing Lucky: Rock Solid Actions & Routing ",
        url: "https://thoughtbot.com/blog/designing-lucky-actions-routing"
    end
  end

  # A list of awesome tools to make developing Lucky applications easier
  private def render_tools_list
    mount AwesomeListGroup, group_title: "Tools" do
      mount AwesomeLink,
        text: "LuckyDiff",
        url: "https://luckydiff.com",
        description: "Compare generated apps between Lucky versions."
      mount AwesomeLink,
        text: "HTML to Lucky converter",
        url: "https://luckyframework.org/html",
        description: "Convert your HTML markup in to Lucky supported Crystal code"
      mount AwesomeLink,
        text: "Kindmetrics",
        url: "https://github.com/kindmetrics/kindmetrics",
        description: "A privacy focused open-source analytics server"
      mount AwesomeLink,
        text: "Lucky Jumpstart",
        url: "https://github.com/stephendolan/lucky_jumpstart",
        description: "Build Lucky apps even faster"
      mount AwesomeLink,
        text: "Lucky Hasura Docker",
        url: "https://github.com/KCErb/lucky-hasura-docker/",
        description: "Get up and running with Hasura and Docker using Lucky"
    end
  end

  private def render_sites_list
    mount AwesomeListGroup, group_title: "Built-with Lucky" do
      mount AwesomeLink,
        text: "Official Lucky Website",
        url: "https://luckyframework.org",
        description: "The official site for the Lucky Framework"
      mount AwesomeLink,
        text: "Lucky Diff",
        url: "https://luckydiff.com",
        description: "Compare generated apps between Lucky versions."
      mount AwesomeLink,
        text: "Lucky Casts",
        url: "https://luckycasts.com",
        description: "Video screencasts on Lucky and the Crystal programming language"
      mount AwesomeLink,
        text: "Lucky Bits",
        url: "https://www.luckybits.link",
        description: "Create small link snippets to share with friends"
      mount AwesomeLink,
        text: "The Offline Pink",
        url: "https://the.offline.pink",
        description: "Service availability monitoring"
      mount AwesomeLink,
        text: "Valheim Server Hosting",
        url: "https://valheimserverhosting.com",
        description: "Server hosting for the Valheim game"
      mount AwesomeLink,
        text: "Read Rust",
        url: "https://readrust.net",
        description: "A collection of information on the Rust programming language... Yes, it's built with Lucky!"
      mount AwesomeLink,
        text: "Ask CR",
        url: "https://askcr.io/",
        description: "Stackoverflow-like site geared toward the Crystal programming language"
    end
  end

  # A list of Lucky specific shards to enhance your application
  private def render_shards_list
    mount AwesomeListGroup, group_title: "Shards" do
      mount AwesomeLink,
        text: "Lucky Basic Auth",
        url: "https://github.com/jwoertink/lucky-basic-auth",
        description: "Add basic-auth to any action in your Lucky application"
      mount AwesomeLink,
        text: "Lucky Cluster",
        url: "https://github.com/jwoertink/lucky-cluster",
        description: "Enable multi-process with reuseport for your Lucky application"
      mount AwesomeLink,
        text: "Shield",
        url: "https://github.com/grottopress/shield",
        description: "Comprehensive security solution and authentication for Lucky"
      mount AwesomeLink,
        text: "Avram Slugify",
        url: "https://github.com/luckyframework/avram_slugify",
        description: "Turn a column in to a parameterized slug for URLs"
      mount AwesomeLink,
        text: "Lucky SVG builder",
        url: "https://github.com/tilitribe/lucky_svg_sprite.cr",
        description: "Turn your SVG markup in to reusable Lucky components"
      mount AwesomeLink,
        text: "Breeze",
        url: "https://github.com/luckyframework/breeze",
        description: "A development dashboard and logging enhancement"
      mount AwesomeLink,
        text: "Have I Been Pwned",
        url: "https://github.com/watzon/lucky_have_i_been_pwned_validator",
        description: "A validator for your User model to check if the password has been leaked"
      mount AwesomeLink,
        text: "Lucky Encrypted Columns",
        url: "https://github.com/microgit-com/lucky_encrypted",
        description: "Encrypt your columns"
      mount AwesomeLink,
        text: "Multi-Auth",
        url: "https://github.com/msa7/multi_auth#lucky-integration-example",
        description: "OAuth with multiple different service"
      mount AwesomeLink,
        text: "Carbon SendGrid Adapter",
        url: "https://github.com/luckyframework/carbon_sendgrid_adapter",
        description: "Send mail with Carbon using SendGrid"
      mount AwesomeLink,
        text: "Carbon SES Adapter",
        url: "https://github.com/keizo3/carbon_aws_ses_adapter",
        description: "Send mail with Carbon using SES"
      mount AwesomeLink,
        text: "Carbon SendInBlue Adapter",
        url: "https://github.com/atnos/carbon_send_in_blue_adapter",
        description: "Send mail with Carbon using SendInBlue"
      mount AwesomeLink,
        text: "Carbon Mailgun Adapter",
        url: "https://github.com/atnos/carbon_mailgun_adapter",
        description: "Send mail with Carbon using Mailgun"
      mount AwesomeLink,
        text: "Carbon SMTP Adapter",
        url: "https://github.com/oneiros/carbon_smtp_adapter",
        description: "Send mail with Carbon using standard SMTP"
      mount AwesomeLink,
        text: "Carbon SparkPost Adapter",
        url: "https://github.com/Swiss-Crystal/carbon_sparkpost_adapter",
        description: "Send mail with Carbon using SparkPost"
      mount AwesomeLink,
        text: "Carbon PostMark Adapter",
        url: "https://github.com/makisu/carbon_postmark_adapter",
        description: "Send mail with Carbon using PostMark"
      mount AwesomeLink,
        text: "Lucky PG Extras",
        url: "https://github.com/matthewmcgarvey/lucky_pg_extras",
        description: "Extra insights in to your postgres database"
      mount AwesomeLink,
        text: "Lucky Legacy routing",
        url: "https://github.com/matthewmcgarvey/lucky_legacy_routing",
        description: "Keep using the old route and nested_route helpers in your actions"
      mount AwesomeLink,
        text: "Lucky Styleable",
        url: "https://github.com/matthewmcgarvey/lucky_styleable",
        description: "Scoped CSS for your Lucky Components"
      mount AwesomeLink,
        text: "Pundit",
        url: "https://github.com/stephendolan/pundit",
        description: "Shard for managing authorization in Lucky applications"
      mount AwesomeLink,
        text: "LuckyCan",
        url: "https://github.com/confact/lucky_can",
        description: "A nice way to handle authorization rules for your Lucky app"
      mount AwesomeLink,
        text: "Lucky Redis Session",
        url: "https://github.com/sungchuldotdev/lucky_redis_session",
        description: "Middleware handler to use Redis as a back-end for storing sessions"
      mount AwesomeLink,
        text: "LuckySvelt",
        url: "https://github.com/lucky-svelte/lucky_svelte",
        description: "View helpers for rendering Svelt JS components in Lucky"
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
