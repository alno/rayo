class Root < Page

  def initialize
    super

    self.root = self
    self.parent = nil
    self.slug = nil
    self.path = []
  end

  def directories
    [ '.' ]
  end

  def file
    return @file if defined? @file

    @file = 'index'
    @file = nil unless File.file?( File.join( absdir, @file ) + page_ext )
    @file
  end

  def params
    @params ||= {}
  end

  def find_page_file( parent, slug )
    glob parent, slug, page_ext do |file|
      return file if File.file?( File.join( absdir, file ) + page_ext )
    end
    nil
  end

  def find_page_dirs( parent, slug )
    res = []
    glob parent, slug, '' do |file|
      res << file if File.directory?( File.join( absdir, file ) )
    end
    res
  end

  def absdir
    File.join( File.dirname(__FILE__), '..', 'content' )
  end

  private

  def page_ext
    '.page'
  end

  def glob( parent, slug, ext )
    parent.directories.each do |dir|
      yield File.join( dir, slug )

      Dir.glob File.join( absdir, dir, '%*' + ext ) do |file|
        yield File.join( dir, File.basename( file, ext ) )
      end
    end
  end

end
