require 'rubygems'
require 'compass'
require 'sinatra'
require 'haml'

require 'article'

Article.path = File.dirname(__FILE__) + "/articles"

class Date
  def xmlschema
    strftime("%Y-%m-%dT%H:%M:%S%Z")
  end unless defined?(xmlschema)
end

configure :production do
  # Configure stuff here you'll want to only be run at Heroku at boot
end

# configure compass
Compass.configuration do |config|
  config.project_path = File.dirname(__FILE__)
  config.sass_dir = File.join(Sinatra::Application.views, 'stylesheets')
  config.output_style = :compact
end

# at a minimum, the main sass file must reside within the ./views directory. here, we create a ./views/stylesheets directory where all of the sass files can safely reside.
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"stylesheets/#{params[:name]}", Compass.sass_engine_options
end

before do
  @articles = Article.all.sort
end

get '/' do
  haml :index, :format => :html5 || raise(Sinatra::NotFound)
end

get '/sitemap.xml' do
  content_type 'application/xml'
  haml :sitemap, :layout => false
end

get '/articles.atom' do
  content_type 'application/atom+xml'
  haml :feed, :layout => false
end

get '/:slug' do
  @article = Article[params[:slug]]
  begin
    haml :article, :format => :html5
  rescue Exception => e
    @error = e
    haml :error, :format => :html5
  end
end

