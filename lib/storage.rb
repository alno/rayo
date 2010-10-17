require File.join(File.dirname(__FILE__), 'models', 'root_page.rb')
require File.join(File.dirname(__FILE__), 'models', 'renderable.rb')

require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class Storage

  def initialize
    @layouts = {}
    @snippets = {}

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

  def snippet( name )
    name = name.to_s

    @snipetts[name] ||= Models::Renderable.new( find_renderable_file( :snippets, name ) || raise( "Snippet '#{name}' not found" ) )
  end

  def layout( name )
    name = name.to_s

    @layouts[name] ||= Models::Renderable.new( find_renderable_file( :layouts,  name ) || raise( "Layout '#{name}' not found" ) )
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

  def find_pages( dirs )
    res = []
    glob dirs, '*', '' do |file|
      ext = File.extname( file )
      base = File.basename( file, ext )

      unless base == 'index' && dir == directory(:pages)
        res << base if valid_page?( base ) && (page_directory?( file ) || page_file?( file ))
      end
    end
    res
  end

  def find_renderable_file( type, name )
    glob [directory( type )], name, '.*' do |file|
      return file if renderable_file? file
    end
    nil
  end

  def find_page_file( dirs, slug )
    glob dirs, slug, page_ext do |file|
      return file if page_file? file
    end
    nil
  end

  def find_page_dirs( dirs, slug )
    res = []
    glob dirs, slug, '' do |file|
      res << file if page_directory? file
    end
    res
  end

  def find_page_parts( dirs, slug )
    parts = {}
    glob dirs, slug, '.*' do |file|
      if renderable_file? file
        name_parts = File.basename( file ).split('.')
        name_parts.shift # Remove base (slug or param)

        if name_parts.size == 1
          parts[ 'body' ] = Models::Renderable.new( file )
        else
          parts[ name_parts.shift ] = Models::Renderable.new( file )
        end
      end
    end
    parts
  end

  private

  def renderable_file?( file )
     File.file?( file ) && [ 'html' ].include?( File.extname( file )[1..-1] )
  end

  def page_file?( file )
    File.file?( file ) && File.extname( file ) == page_ext
  end

  def page_directory?( dir )
    File.directory?( dir ) && File.extname( dir ).empty?
  end

  def page_ext
    '.yml'
  end

  def valid_page?( name )
    name  =~ /^[\w\d_-]+$/
  end

  def glob( dirs, slug, ext, &block )
    dirs.each do |dir|
      Dir.glob( File.join( dir, slug + ext ), &block )
      Dir.glob( File.join( dir, '%*' + ext ), &block ) if slug != '*'
    end
  end

end
