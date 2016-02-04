require 'json'
require 'byebug'

class Flash

  def initialize(req)
    @now_flash = {}
    cookie = req.cookies["_rails_lite_flash"]
    if cookie
      @cookie_val = JSON.parse(cookie)
    else
      @cookie_val = {}
    end
  end

  def [](key)
    @cookie_val[key]
  end

  def []=(key, val)
    @cookie_val[key] = val
  end

  def now
    @now_flash
  end

  def store_flash(res)
    res.set_cookie("_rails_lite_flash", {path: "/", value: @cookie_val.to_json})
  end

end
