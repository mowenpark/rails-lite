require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  res.write("Hello world!")
  res.finish
end

app2 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new

  new_path = req.path
  res.write('#new_path')
end

app3 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new


  if req.path.start_with?("/i/love/app/academy")
    res.status = 302
    res.write('/i/love/app/academy')
  else
    res.write("Nothing to see here")
  end

  res.finish
end

Rack::Server.start(
  app: app3,
  Port: 3000
)
