require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    tmp_cookie = req.cookies["_rails_lite_app"]
    if tmp_cookie
      @cookie = JSON.parse(tmp_cookie)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res_cookie = @cookie.to_json
    res.set_cookie("_rails_lite_app", {path: "/", value: res_cookie})
  end

end
