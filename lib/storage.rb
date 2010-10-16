require File.join(File.dirname(__FILE__), 'root_page.rb')
require File.join(File.dirname(__FILE__), 'layout.rb')

class Storage

  def layout( name )
    @layouts ||= {}
    @layouts[name.to_s] ||= Layout.new( self, find_layout_file( name ) || raise( "Layout '#{name}' not found" ) )
  end

  def directory( content_type )
    File.join( File.dirname(__FILE__), '..', 'content', content_type.to_s )
  end

  def root_page
    @root_page ||= RootPage.new( self )
  end

  def page( path )
    root_page.descendant( path )
  end

  def status_page( path, status )
    StatusPage.new( self, root_page, path, status )
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

  def find_page_part_files( file )
    parts = {}
    Dir.glob file + ".*" do |part_file|
      name_parts = File.basename( part_file ).split('.')
      name_parts.shift # Remove base (slug or param)

      if content_ext? name_parts.last
        if name_parts.size == 1
          parts[ 'content' ] = part_file
        else
          parts[ name_parts.shift ] = part_file
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
