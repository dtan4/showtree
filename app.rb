require "json"
require "open-uri"

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new

  configure do
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = "/assets"
      config.digest = true
    end

    sprockets.append_path "assets/javascripts"
    sprockets.append_path "assets/stylesheets"
    sprockets.append_path Bootstrap.stylesheets_path
    sprockets.append_path Bootstrap.fonts_path
    sprockets.append_path Bootstrap.javascripts_path
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers Sprockets::Helpers

  helpers do
    def get_element_attributes(element)
      {
       name: element.name,
       class: element.attr("class") || "",
       id: element.attr("id") || "",
       children: get_children(element)
      }
    end

    def get_children(element)
      children = []
      element.children.select { |el| el.is_a? Nokogiri::XML::Element }.each do |el|
        children << get_element_attributes(el)
      end if element.children.length > 0

      children
    end
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

  get "/getjson" do
    content_type :json

    url = params[:url]
    body = Nokogiri::HTML.parse(open(url).read).css("body").first
    json_data = get_element_attributes(body)
    JSON.generate json_data
  end
end
