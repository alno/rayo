require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class CmsConfig

  def initialize
    @tagger = Object.new
    @tagger.extend Taggable

    add_tag_library! Tags::PropertyTags
    add_tag_library! Tags::ContentTags
    add_tag_library! Tags::NavigationTags
  end

  def add_tag_library!( tag_module )
    @tagger.extend tag_module
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
    ['.html']
  end

  def languages
    ['ru','en']
  end

end
