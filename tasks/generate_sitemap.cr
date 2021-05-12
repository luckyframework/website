require "sitemapper"

Sitemapper.configure do |c|
  c.host = "https://luckyframework.org"
  c.use_index = false
  c.compress = false
end

class GenerateSitemap < LuckyTask::Task
  summary "Generate the sitemap.xml for this luckyframework.org"

  def call
    sitemaps = Sitemapper.build do
      add(Home::Index.path, changefreq: "yearly", priority: 0.9)
      add(HtmlConversions::New.path, changefreq: "yearly", priority: 0.2)
      add(Blog::Index.path, changefreq: "monthly", priority: 0.6)
      add(Learn::Index.path, changefreq: "yearly", priority: 0.4)
      add(Learn::AwesomeLucky::Index.path, changefreq: "monthly", priority: 0.5)
      add(Learn::Community::Index.path, changefreq: "monthly", priority: 0.5)
      add(Learn::Ecosystem::Index.path, changefreq: "monthly", priority: 0.5)

      GuidesList.guides.each do |guide|
        modification_time = get_modification_time_of_file(guide.guide_file_path)
        add(guide.path,
          lastmod: modification_time,
          changefreq: "monthly",
          priority: 0.7)
      end

      PostQuery.new.all_posts_newest_first.each do |post|
        add(Blog::Show.with(post.slug).path,
          lastmod: post.published_at,
          changefreq: "yearly",
          priority: 0.7)
      end
    end

    Sitemapper.store(sitemaps, "./public")
  end

  private def get_modification_time_of_file(file_location : String) : Time
    command = "git log -1 --format=%cd #{file_location}"
    output = IO::Memory.new
    Process.run(command, shell: true, output: output)

    Time.parse(output.to_s.chomp, "%a %b %d %H:%M:%S %Y %z", Time::Location::UTC)
  end
end
