require 'erb'
require 'byebug'

class ShowExceptions

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    begin
      app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    path = "#{File.dirname(__FILE__)}/rescue.html.erb"
    body = ERB.new(File.read(path)).result(binding)
    ['500', {'Content-type' => 'text/html'}, body]
  end

end
