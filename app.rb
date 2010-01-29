require 'init'

require 'lib/article'
require 'lib/numerals'

Article.path = 'articles'

class Object
  def try(method)
    send method if respond_to? method
  end
end

class Date
  def xmlschema
    strftime("%Y-%m-%dT%H:%M:%S%Z")
  end unless defined?(xmlschema)
end


helpers do
  def hidden
    {:style => 'display:none;'}
  end
  def article_path(article)
    "/articles/#{article.slug}"
  end
  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end
  def absoluteify_links(html)
    html.
      gsub(/href=(["'])(\/.*?)(["'])/, 'href=\1http://thelincolnshirepoacher.com\2\3').
      gsub(/src=(["'])(\/.*?)(["'])/, 'src=\1http://thelincolnshirepoacher.com\2\3')
  end
  def strip_tags(html)
    html.gsub(/<\/?[^>]*>/, '')
  end
  def transform_ampersands(html)
    html.gsub(' & '," <span class='amp'>&</span> ")
  end
  def render_article(article)
    haml(transform_ampersands(article.template), :layout => false)
  end
  def current_article?(article)
    @article == article
  end
  def article_title
    base = 'The Lincolnshire Poacher by Chris Lloyd'
    if request.path == '/'
      base
    else
      [@article.try(:title),base].reject{|t|t.nil?}.join(' &mdash; ')
    end
  end
  def meta_tags
    {
      :author => 'Chris Lloyd',
      :keywords => %w(chris lloyd ruby javascript programming software development language university uni ui ux rb js).join(', '),
      :description => 'An ongoing collection of articles by Chris Lloyd.',
      'MSSmartTagsPreventParsing' => true,
      :robots => 'all'
    }
  end
  def figure(src, opts={})
    partial :figure, :src => "/images/#{src}",
                     :caption => opts[:caption],
                     :alt => (opts[:alt] || opts[:caption]),
                     :type => opts[:type],
                     :link => opts[:link],
                     :link_title => (opts[:link_title] || opts[:alt])
  end
  def previous_article(article)
    Article.recent[Article.recent.index(article) +1]
  end
  def next_article(article)
    index = Article.recent.index(article)
    Article.recent[index -1] if index > 0
  end
  def analytics_code
    request.host == 'thelincolnshirepoacher.com' ? 'UA-256176-12' : 'UA-256176-7'
  end

end

get '/' do
  @article = Article.recent.first
  haml :index
end

get '/articles/:slug/?' do |slug|
  (@article = Article[slug]) ? haml(:article) : pass
end

get '/colophon/?' do
  haml :colophon
end

# Legacy
get '/post/:tumblr/:slug/?' do |tumblr, slug|
  (@article = Article.find_from_tumblr(tumblr, slug)) ? redirect(article_path(@article), 301) : pass
end

get '/feed.atom' do
  @articles = Article.recent[0..14]
  content_type 'application/atom+xml'
  haml :feed, :layout => false
end

# Legacy
get '/rss/?' do
  redirect 'http://feeds.feedburner.com/thelincolnshirepoacher', 301
end

get '/sitemap.xml' do
  @articles = Article.recent
  content_type 'application/xml'
  haml :sitemap, :layout => false
end

get /^\/css\/(.+)\.css/ do |style_file|
  sass_file = File.join('public','sass',"#{style_file}.sass")
  pass unless File.exist?(sass_file)
  content_type :css
  sass File.read(sass_file)
end
