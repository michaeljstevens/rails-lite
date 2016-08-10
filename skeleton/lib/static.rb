require 'byebug'

class Static

  ROOT = "/public/"

  MIMES = {
    '.jpg' => 'image/jpeg',
    '.txt' => 'text/plain',
    '.png' => 'image/png',
    '.zip' => 'application/zip'
  }

  attr_reader :app

  def initialize(app)
    @app = app

  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path
    if path.include?(ROOT)
      res_path = "#{File.dirname(__FILE__)}/..#{path}"
      ext = "." + res_path[-3 .. -1]
      begin
        body = File.read(res_path)
        res = Rack::Response.new
        res.status = 200
        res['Content-type'] = MIMES[ext]
        res.write(body)
        res.finish
      rescue
        res = Rack::Response.new
        res.status = 404
        res.finish
      end
    end
  end

end
