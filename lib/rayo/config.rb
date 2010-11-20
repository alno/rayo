require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class Rayo::Config

  attr_accessor :content_dir
  attr_accessor :cache_dir

  attr_accessor :languages
  attr_accessor :page_exts

  attr_accessor :default_format
  attr_accessor :default_domain

  def initialize
    @languages = ['en']
    @page_exts = ['.yml']

    @formats = {}
    @domains = []

    @tagger = Object.new
    @tagger.extend Rayo::Taggable

    # Default tags
    add_tags Rayo::Tags::PropertyTags
    add_tags Rayo::Tags::ContentTags
    add_tags Rayo::Tags::NavigationTags

    # Default format
    @default_format = 'html'
  end

  # Add tags defined in module
  #
  # @param [Module] module defining tags to use
  def add_tags( tag_module )
    @tagger.extend tag_module
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

  # Add filter
  #
  # @param [String,Symbol] renderable file extension
  # @param [String,Symbol] requested content format
  # @param [Proc] filter proc which accepts source and return it in processed form
  def add_filter( from, to = nil, &filter )
    format( to ).add_filter( from, &filter )
  end

  def format( name = nil )
    name ||= default_format

    @formats[name.to_s] ||= Rayo::Config::Format.new name
  end

  def domain( host )
    if @domains.empty?
      self # No multidomain support
    else
      @domains.find { |domain| domain.matches? host } || @domains.find { |domain| domain.name == @default_domain }
    end
  end

end

require File.join(File.dirname(__FILE__), 'config/domain.rb')
require File.join(File.dirname(__FILE__), 'config/format.rb')
