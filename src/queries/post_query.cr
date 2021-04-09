class PostQuery
  POSTS = [] of BasePost

  def all
    if Lucky::Env.development?
      all_posts_newest_first
    else
      only_published_today_or_earlier
    end
  end

  def all_posts_newest_first
    POSTS.sort_by(&.published_at).reverse!
  end

  def only_published_today_or_earlier
    all_posts_newest_first.select { |post| post.published_at <= Time.utc }
  end

  def find?(slug : String) : BasePost?
    POSTS.find { |post| post.slug == slug }
  end
end
