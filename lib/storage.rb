require File.join(File.dirname(__FILE__), 'models', 'root_page.rb')
require File.join(File.dirname(__FILE__), 'models', 'renderable.rb')

require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/standard_tags.rb')

class Storage

  def initialize
    @tagger = Object.new
    @tagger.extend Taggable

    add_tag_library! Tags::StandardTags
  end

  def add_tag_library!( tag_module )
    @tagger.extend tag_module
  end

  def tagger
    @tagger.clone
  end

  def layout( name )
    @layouts ||= {}
    @layouts[name.to_s] ||= Models::Renderable.new( find_layout_file( name ) || raise( "Layout '#{name}' not found" ) )
  end

  def directory( content_type )
    File.join( File.dirname(__FILE__), '..', 'content', content_type.to_s )
  end

  def root_page
    @root_page ||= Models::RootPage.new( self )
  end

  def page( path )
    root_page.descendant( path )
  end

  def status_page( path, status )
    Models::StatusPage.new( self, root_page, path, status )
  end

  def find_layout_file( name )
    Dir.glob File.join( directory( :layouts ), name.to_s + '.*' ) do |file|
      return file if File.file?( file ) && content_ext?( File.extname( file )[1..-1] )
    end
    nil
  end

  def find_page_file( dirs, slug )
    glob dirs, slug, page_ext do |file|
      return file if File.file?( File.join( file ) + page_ext )
    end
    nil
  end

  def find_page_dirs( dirs, slug )
    res = []
    glob dirs, slug, '' do |file|
      res << file if File.directory?( file )
    end
    res
  end

  def find_page_parts( file )
    parts = {}
    Dir.glob file + ".*" do |part_file|
      name_parts = File.basename( part_file ).split('.')
      name_parts.shift # Remove base (slug or param)

      if content_ext? name_parts.last
        if name_parts.size == 1
          parts[ 'body' ] = Models::Renderable.new( part_file )
        else
          parts[ name_parts.shift ] = Models::Renderable.new( part_file )
        end
      end
    end
    parts
  end

  private

  def page_ext
    '.yml'
  end

  def content_ext?( ext )
    [ 'html' ].include? ext
  end

  def glob( dirs, slug, ext )
    dirs.each do |dir|
      yield File.join( dir, slug )

      Dir.glob File.join( dir, '%*' + ext ) do |file|
        yield File.join( dir, File.basename( file, ext ) )
      end
    end
  end

end
