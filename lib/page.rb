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

    if file
      segments = file.split(/[\/\\]/)[-path.size..-1] || raise( "File doesn't correspond to path" )

      @params = {}
      0.upto path.size - 1 do |i|
        @params[segments[i][1..-1]] = path[i] if segments[i][0..0] == '%'
      end
      @params
    else
      @params = {}
    end
  end

  def context
    return @context if @context

    if file
      @context = { 'status' => 200 }
      @context.merge! YAML::load( Erubis::Eruby.new( File.read( file + '.yml' ) ).result( { :path => path }.merge! params ) )
    else
      @context = { 'status' => 404 }
    end
  end

  def []( key )
    key = key.to_s

    context[ key ] || params[ key ]
  end

  def render
    "#{slug}|#{path.inspect}|#{file}|#{directories.inspect}|#{params.inspect}|#{context.inspect}"
  end

end
