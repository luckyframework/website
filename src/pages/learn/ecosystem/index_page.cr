class Learn::Ecosystem::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    # List all of the Lucky shards
    # Link to repos and API References. e.g. https://luckyframework.github.io/lucky/
    div class: "py-16 container" do
      ul class: "grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3" do
        mount ProjectCard,
          name: "Lucky",
          description: "The main shard for the Lucky framework.",
          slug: "lucky"
        mount ProjectCard,
          name: "Lucky Cli",
          description: "CLI for generating a new Lucky applications.",
          slug: "lucky_cli"
        mount ProjectCard,
          name: "Avram",
          description: "Lucky's ORM named after Henriette Avram.",
          slug: "avram"
        mount ProjectCard,
          name: "Authentic",
          description: "User authentication with Avram.",
          slug: "authentic"
        mount ProjectCard,
          name: "Avram Slugify",
          description: "Parameterize your Avram models.",
          slug: "avram_slugify"
        mount ProjectCard,
          name: "Carbon",
          description: "Create and Send emails. Many adapters supported.",
          slug: "carbon"
        mount ProjectCard,
          name: "Habitat",
          description: "Make any object configurable.",
          slug: "habitat"
        mount ProjectCard,
          name: "Breeze",
          description: "Development dashboard.",
          slug: "breeze"
        mount ProjectCard,
          name: "Dexter",
          description: "A Log utility and formatter.",
          slug: "dexter"
        mount ProjectCard,
          name: "LuckyTask",
          description: "Library for creating command line tasks.",
          slug: "lucky_task"
        mount ProjectCard,
          name: "Wordsmith",
          description: "Handles pluralization, ordinalizing words, etc.",
          slug: "wordsmith"
        mount ProjectCard,
          name: "Pulsar",
          description: "Publish and Subscribe to events.",
          slug: "pulsar"
        mount ProjectCard,
          name: "Lucky Router",
          description: "HTTP Path routing.",
          slug: "lucky_router"
        mount ProjectCard,
          name: "Lucky Flow",
          description: "Automated browser tests and control.",
          slug: "lucky_flow"
        mount ProjectCard,
          name: "Lucky Env",
          description: "Environment variable parser.",
          slug: "lucky_env"
      end
    end
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "The Lucky Ecosystem"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            text <<-TEXT
            The building blocks of the Lucky framework. Links and API References
            TEXT
          end
        end
      end
    end
  end
end
