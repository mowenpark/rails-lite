require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "double redirect" if already_built_response?
    @res.status = 302
    @res['Location'] = url

    @already_built_response = true

    session.store_session(@res)

    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "double redirect" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)

    @already_built_response = true

    session.store_session(@res)

    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "double render" if already_built_response?
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(dir_path, "..", "views",self.class.to_s.underscore,"#{template_name}.html.erb")
    # creates a template file name
    template_code = File.read(template_fname)
    # debugger - reads a template from your directory
    render_content(
    # calls the previous render content method
      ERB.new(template_code).result(binding),
      #erb evaluates the template and binding makes all the scoped variables available
      "text/html"
    )

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
