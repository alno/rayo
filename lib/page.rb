class Page

  attr_accessor :root # Root of page hierarchy
  attr_accessor :parent # Parent page

  attr_accessor :slug # Page slug

  def descendant( relative_path )
    relative_path.inject( self ) {|page,slug| page.child( slug ) }
  end

  def child( slug )
    @children_cache ||= {}
    @children_cache[ slug ] if @children_cache.include? slug

    page = Page.new
    page.root = root
    page.parent = self
    page.slug = slug
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= root.find_page_dirs( parent, slug )
  end

  def file
    @file ||= root.find_page_file( parent, slug )
  end

end
