class Storage

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

  def find_page_part_files( file )
    parts = {}
    Dir.glob file + ".*" do |part_file|
      name_parts = File.basename( part_file ).split('.')
      name_parts.shift # Remove base (slug or param)

      if page_part_ext? name_parts.last
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

  def page_part_ext?( ext )
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
