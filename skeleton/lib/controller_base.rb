#require 'active_support'
#require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require_relative './flash'


class ControllerBase
  attr_reader :req, :res, :params


  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params.merge(req.params)
    @already_built_response = false
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "can't redirect twice" if already_built_response?
    @res.status = 302
    @res['Location'] = url
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "can't render twice" if already_built_response?
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    current_dir = File.dirname(__FILE__)
    template_path = File.join(current_dir, "..",
    "views", self.class.name.underscore,
    "#{template_name}.html.erb")
    file = ERB.new(File.read(template_path)).result(binding)
    render_content(file, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if self.class.protect_from_forgery && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render(name) unless already_built_response?
  end

  def protect_from_forgery
    @@protect_from_forgery
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def form_authenticity_token
    @fat ||= SecureRandom.urlsafe_base64(32)
    res.set_cookie('authenticity_token', value: @fat, path: "/")
    @fat
  end

  def check_authenticity_token
    auth_cookie = @req.cookies['authenticity_token']
    if auth_cookie && auth_cookie == params['authenticity_token']
      true
    else
      raise "Invalid authenticity token"
    end
  end

end
