class CacheControlHandler
  include HTTP::Handler

  def call(context)
    context.response.headers["Cache-Control"] = "public, s-maxage=#{180.days.to_i}, maxage=#{90.days.to_i}"
    context.response.headers["Expires"] = 1.month.from_now.to_s("%a, %d %b %Y %H:%M:%S %z")
    call_next(context)
  end
end
