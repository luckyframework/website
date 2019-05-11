class PostQuery
  POSTS = [] of BasePost

  def all
    POSTS
  end

  def find?(slug : String) : BasePost?
    POSTS.find { |post| post.slug == slug }
  end
end
