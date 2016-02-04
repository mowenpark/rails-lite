require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # debugger
    cookie = req.cookies["_rails_lite_app"]
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

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    # cookie = { path: '/', value: @data.to_json }
    res.set_cookie("_rails_lite_app", {path: "/", value: @cookie_val.to_json})
  end
end
