class TestStorage < Rayo::Storage

  def files
    @files ||= {}
  end

  def dir( name )
    unless files.include? name
      files[name] = nil
      dir File.dirname( name )
    end
  end

  def file( name, content )
    files[name] = content
    dir File.dirname( name )
  end

  def load( name )
    files[name]
  end

  private

  def dir_glob( mask )
    files.keys.each do |file|
      yield file if File.fnmatch? mask, file, File::FNM_PATHNAME
    end
  end

end
