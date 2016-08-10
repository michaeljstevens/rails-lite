require 'json'

class Flash

  attr_reader :now, :flash

  def initialize(req)
    tmp_flash = req.cookies["_rails_lite_app_flash"]
    if tmp_flash
      @flash = JSON.parse(tmp_flash)
      @now = JSON.parse(tmp_flash)
    else
      @flash = {}
      @now = {}
    end
  end

  def [](key)
    @now[key] || @flash[key]
  end

  def []=(key, val)
    @flash[key] = val
    @now[key] = val
  end

  def store_flash(res)
    res_flash = @flash.to_json
    res.set_cookie("_rails_lite_app_flash", {path: "/", value: res_flash})
  end

end
