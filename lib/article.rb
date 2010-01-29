class Article

  def self.path=(path)
    @path = path
  end

  def self.files
    Dir["#{File.expand_path(@path)}/*.haml"]
  end

  def self.all
    @all ||= files.collect {|f| new(f, File.read(f)) }
  end

  def self.recent
    all.sort.reverse
  end

  def self.find_from_tumblr(tumblr, slug)
    all.find {|a| a.slug == slug && a.tumblr == tumblr }
  end

  def self.[](slug)
    all.find {|p| p.slug == slug }
  end

  attr_accessor :path, :template

  def initialize(path, contents)
    @path, @template = path, contents
  end

  def id
    slug
  end

  def slug
    File.basename(self.path, '.*')
  end

  [:title, :tumblr, :type].each do |attr|
    define_method(attr) { slot(attr) }
  end

  [:published, :updated].each do |stamp|
    define_method(stamp) do
      if time = slot(stamp)
        Time.local(*time.match(self.class.date_regexp).to_a[1..-1])
      end
    end
  end

  def <=>(other)
    published <=> other.published
  end

  def previous; self; end
  def next; self; end

# private

  def self.date_regexp
    /(\d+)-(\d+)-(\d+)\s(\d+):(\d+)/
  end

  def self.comment_regexp
    /\<![ \r\n\t]*(--([^\-]|[\r\n]|-[^\-])*--[ \r\n\t]*)\>/
  end

  def slot(name)
    template[/^-#\s+#{name}:\s*(.*)$/, 1].try(:strip)
  end

  def number
    articles = self.class.recent
    articles.size - articles.index(self)
  end

end
