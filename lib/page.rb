require 'yaml'
require 'erubis'
require 'radius'

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
    return @children_cache[ slug ] if @children_cache.include? slug

    page = Page.new
    page.root = root
    page.parent = self
    page.slug = slug
    page.path = abs_path || self.path + [slug]
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= root.find_page_dirs( parent.directories, slug )
  end

  def file
    @file ||= root.find_page_file( parent.directories, slug )
  end

  def params
    return @params if @params

    segments = file.split(/[\/\\]/)[-path.size..-1] || raise( "File doesn't correspond to path" )

    @params = { 'path' => path }
    0.upto path.size - 1 do |i|
      @params[segments[i][1..-1]] = path[i] if segments[i][0..0] == '%'
    end
    @params
  end

  def context
    return @context if @context

    @context = { 'status' => 200 }
    @context.merge! load_context( file + '.yml' )
  end

  def parts
    return @parts if @parts

    @parts = parent ? parent.parts.clone : {}
    @parts.merge! root.find_page_parts( file ) if file
    @parts
  end

  def []( key )
    key = key.to_s

    context[ key ] || params[ key ]
  end

  def render
    "#{slug}|#{path.inspect}|#{file}|#{directories.inspect}|#{params.inspect}|#{context.inspect}|#{parts.inspect}"
  end

  private

  def load_context( filename )
    YAML::load( Erubis::Eruby.new( File.read( filename ) ).result( params ) )
  end

end
