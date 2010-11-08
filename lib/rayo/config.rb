require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class Rayo::Config

  attr_accessor :content_dir
  attr_accessor :languages
  attr_accessor :page_exts

  attr_accessor :default_format

  attr_reader :renderable_exts

  def initialize
    @default_format = 'html'
    @renderable_exts = []

    @languages = ['en']
    @page_exts = ['.yml']

    @filters = {}
    @domains = []

    # Default filters
    add_filter('html'){|source| source }

    @tagger = Object.new
    @tagger.extend Rayo::Taggable

    # Default tags
    add_tags Rayo::Tags::PropertyTags
    add_tags Rayo::Tags::ContentTags
    add_tags Rayo::Tags::NavigationTags
  end

  # Add tags defined in module
  #
  # @param [Module] module defining tags to use
  def add_tags( tag_module )
    @tagger.extend tag_module
  end

  # Add filter
  #
  # @param [String,Symbol] renderable file extension
  # @param [String,Symbol] requested content format
  # @param [Proc] filter proc which accepts source and return it in processed form
  def add_filter( from, to = default_format, &filter )
    @filters["#{from}-#{to}"] = filter
    @renderable_exts << ".#{from}" unless @renderable_exts.include? ".#{from}"
  end

  # Add domain
  #
  # @param [String] domain name
  # @param [Regexp,String] host pattern
  def add_domain( name, exp = nil )
    @domains << Rayo::Config::Domain.new( self, name, exp )
  end

  # Create new object containing all defined tags
  def create_tagger
    @tagger.clone
  end

  def directory( content_type )
    File.join( @content_dir, content_type.to_s )
  end

  # Get filter by renderable extension and requested content extension
  #
  # @param [String,Symbol] renderable file extension
  # @param [String,Symbol] requested content format
  def filter( from, to = default_format )
    @filters["#{from}-#{to}"]
  end

  def domain( host )
    if @domains.empty?
      self # No multidomain support
    else
      @domains.find { |domain| domain.matches? host }
    end
  end

end

require File.join(File.dirname(__FILE__), 'config/domain.rb')
