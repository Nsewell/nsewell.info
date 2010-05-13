require 'rubygems'
require 'compass'
require 'sinatra'
require 'haml'
require 'pony'

require 'email'
require 'post'

Article.path = File.dirname(__FILE__) + "/articles"
#set :public, File.dirname(__FILE__) + '/public'


class Date
  def xmlschema
    strftime("%Y-%m-%dT%H:%M:%S%Z")
  end unless defined?(xmlschema)
end

helpers do
  def article_path(article)
    "/articles/#{article.slug}"
  end
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

def partial(name, locals={})
  haml "_#{name}".to_sym, :layout => false, :locals => locals
end

def figure(src, opts={})
  partial :figure, :src => "/images/#{src}",
                   :caption => opts[:caption],
                   :alt => (opts[:alt] || opts[:caption]),
                   :type => opts[:type],
                   :link => opts[:link],
                   :link_title => (opts[:link_title] || opts[:alt])
end

# at a minimum, the main sass file must reside within the ./views directory. here, we create a ./views/stylesheets directory where all of the sass files can safely reside.
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"stylesheets/#{params[:name]}", Compass.sass_engine_options
end


#get '/js/:name.js' do
#  content_type 'script/javascript', :charset => 'utf-8'
#end
get '/css/:name.css' do
  content_type 'text/stylesheet', :charset => 'utf-8'
end
get '/css/:name.woff' do
  content_type 'font/woff', :charset => 'utf-8'
end

before do
  @articles = Article.all.sort
end

get '/about' do
  haml :colophon
end

get '/colophon' do
  haml :colophon
end

get '/' do
  haml :index, :format => :html5 || raise(Sinatra::NotFound)
end

get '/articles' do
  haml :index, :format => :html5 || raise(Sinatra::NotFound)
end
get '/articles/' do
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

get '/articles/:slug' do
  @article = Article[params[:slug]]
  begin
    haml :article, :format => :html5
  rescue Exception => e
    @error = e
    haml :error, :format => :html5
  end
end

#get '/test' do
#end

post '/colophon' do 
  email(params[:name], params[:mail], params[:body]) 
  haml :colophon
end

not_found do
  'This is nowhere to be found'
end

#get /*/ do
#  "Sorry, can't find what you're looking for!"
#end
