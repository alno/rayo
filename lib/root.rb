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

  def params
    @params ||= {}
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
