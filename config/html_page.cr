Lucky::HTMLPage.configure do |settings|
  settings.render_component_comments = !LuckyEnv.production?
end

@[Lucky::SvgInliner::Path("src/icons")]
module Lucky::SvgInliner
end
