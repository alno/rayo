class Page

  attr_accessor :root # Root of page hierarchy
  attr_accessor :parent # Parent page

  attr_accessor :slug # Page slug
  attr_accessor :path # Page path

  def descendant( relative_path )
    relative_path.inject( self ) {|page,slug| page.child( slug ) }
  end

  def child( slug, abs_path = nil )
    @children_cache ||= {}
    @children_cache[ slug ] if @children_cache.include? slug

    page = Page.new
    page.root = root
    page.parent = self
    page.slug = slug
    page.path = abs_path || self.path + [slug]
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= root.find_page_dirs( parent, slug )
  end

  def file
    @file ||= root.find_page_file( parent, slug )
  end

  def params
    return @params if @params

    @params = {}

    segments = file.split(/[\/\\]/)[-path.size..-1] || raise( "File doesn't correspond to path" )

    0.upto path.size - 1 do |i|
      @params[segments[i][1..-1]] = path[i] if segments[i][0..0] == '%'
    end

    @params
  end

  def render
    "#{slug}|#{path.inspect}|#{file}|#{directories.inspect}|#{params.inspect}"
  end

end
