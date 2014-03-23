require "sinatra/base"
require "coffee-script"
require "slim"
require "sass"

class App < Sinatra::Base
  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get "/" do
    slim :index
  end

  get "/application.js" do
    coffee :application
  end

  get "/application.css" do
    sass :application
  end
end
