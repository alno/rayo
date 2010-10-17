require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class CmsConfig

  def initialize
    @filters = {}

    register_filter!('html') { |source| source }

    @tagger = Object.new
    @tagger.extend Taggable

    register_tag_library! Tags::PropertyTags
    register_tag_library! Tags::ContentTags
    register_tag_library! Tags::NavigationTags
  end

  def register_tag_library!( tag_module )
    @tagger.extend tag_module
  end

  def register_filter!( ext, &filter )
    @filters[".#{ext}"] = filter
  end

  def tagger
    @tagger.clone
  end

  def directory( content_type )
    File.join( File.dirname(__FILE__), '..', 'content', content_type.to_s )
  end

  def page_exts
    ['.yml']
  end

  def renderable_exts
    @filters.keys
  end

  def filter( ext )
    @filters[ ext.to_s ]
  end

  def languages
    ['ru','en']
  end

end
