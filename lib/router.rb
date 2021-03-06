class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    # debugger
    (@http_method == req.request_method.downcase.to_sym) && !!(@pattern =~ req.path)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    # debugger
    matched_params = @pattern.match(req.path)
    # .match creates a MatchData object with the original string and the parsed names
    # the hash function takes the names and associcates them with the captures in a hash
    route_params = Hash[matched_params.names.zip(matched_params.captures)]
    # debugger
    controller_instance =  @controller_class.new(req, res, route_params)
    # debugger
    controller_instance.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    route = Route.new(pattern, method, controller_class, action_name)
    @routes << route
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.find {|route| route.matches?(req)} #use find, select creates an array
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matched_request = match(req)
    if matched_request
      matched_request.run(req, res)
    else
      res.status = 404
      res.write("The request was not found.")
    end
  end
end
