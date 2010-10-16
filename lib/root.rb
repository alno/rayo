require File.join(File.dirname(__FILE__), 'page.rb')
require File.join(File.dirname(__FILE__), 'status_page.rb')

class Root < Page

  def initialize
    super

    self.root = self
    self.parent = nil
    self.slug = nil
    self.path = []
  end

  def directories
    [ File.join( File.dirname(__FILE__), '..', 'content' ) ]
  end

  def file
    @file ||= find_page_file( directories, 'index' )
  end

  def status_page( path, status )
    page = StatusPage.new( status )
    page.root = self
    page.parent = self
    page.path = path
    page
  end

  def params
    @params ||= { 'path' => path }
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
      res << file if File.directory?( File.join( file ) )
    end
    res
  end

  def find_page_parts( file )
    parts = {}
    Dir.glob file + ".*" do |part_file|
      name_parts = File.basename( part_file ).split('.')
      name_parts.shift # Remove base (slug or param)

      if name_parts.size == 1
        parts[ 'content' ] = part_file
      else
        parts[ name_parts.shift ] = part_file
      end
    end
    parts
  end

  private

  def page_ext
    '.yml'
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
