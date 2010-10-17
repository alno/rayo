require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class Rayo::Config

  attr_accessor :content_dir
  attr_accessor :languages
  attr_accessor :page_exts

  def initialize
    @languages = ['en']
    @page_exts = ['.yml']

    @filters = {}

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
  def add_tags( tag_module )
    @tagger.extend tag_module
  end

  # Add filter
  def add_filter( ext, &filter )
    @filters[".#{ext}"] = filter
  end

  # Create new object containing all defined tags
  def create_tagger
    @tagger.clone
  end

  def directory( content_type )
    File.join( @content_dir, content_type.to_s )
  end

  def renderable_exts
    @filters.keys
  end

  def filter( ext )
    @filters[ ext.to_s ]
  end

end
