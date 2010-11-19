require 'yaml'
require 'erubis'
require 'radius'

require File.join(File.dirname(__FILE__), '..', 'tag_context.rb')

class Rayo::Models::Page

  attr_reader :storage, :parent, :lang, :path

  def initialize( storage, parent, lang, path )
    @storage = storage
    @parent = parent
    @lang = lang
    @path = path

    @parts = {}
    @layouts = {}
  end

  def descendant( relative_path )
    relative_path.inject( self ) do |page,slug|
      return nil unless page

      page.child( slug )
    end
  end

  def children
    @children ||= @storage.find_pages( directories, @lang ).map{|name| child( name ) }
  end

  def relative( url )
    path = url.split '/'

    if path.first && path.first.empty?
      @storage.root_page( @lang ).descendant( path[1..-1] )
    else
      descendant( path )
    end
  end

  def child( slug )
    @children_cache ||= {}
    return @children_cache[ slug ] if @children_cache.include? slug

    page = Rayo::Models::Page.new( @storage, self, @lang, @path + [slug] )
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= @storage.find_page_dirs( @parent.directories, @lang, @path.last )
  end

  def file
    @file ||= @storage.find_page_file( @parent.directories, @lang, @path.last )
  end

  # Get page parts for given format
  # @param [String,Symbol] part format
  # @return [List<Rayo::Models::Renderable>] part list
  def parts( format )
    @parts[format.to_s] ||= file ? @storage.find_page_parts( file, @lang, format.to_s ) : {}
  end

  # Find page part for given format
  # @param [String,Symbol] part format
  # @param [String,Symbol] part name
  # @param [Boolean] search in super classes
  # @return [List<Rayo::Models::Renderable>] part list
  def find_part( format, part_name, inherit = false )
    page = self
    part = self.parts(format)[part_name]

    while inherit && !part && page.parent do
      page = page.parent
      part = page.parts(format)[part_name]
    end

    part
  end

  def params
    return @params if @params

    segments = file[0..-(File.extname(file).length+1)].split(/[\/\\]/)[-@path.size..-1] || raise( "File doesn't correspond to path" )

    @params = {}

    segments.each_with_index do |segment,i|
      @params[segment[1..-1]] = @path[i] if segment[0..0] == '%'
    end

    @params['path'] = path
    @params
  end

  def context
    return @context if @context

    @context = @parent ? @parent.context.merge({ 'status' => 200 }) : { 'status' => 200 }
    @context.merge! load_context( file ) if file
    @context
  end

  def layout(format)
    @layouts[format.to_s] ||= @storage.layout( @lang, context['layout'], format )
  end

  def []( key )
    key = key.to_s

    context[ key ] || params[ key ]
  end

  def render( format )
    if l = layout( format )
      l.render( parser )
    else
      "Layout: '#{context['layout']}'' not found with format '#{format}'"
    end
  end

  def parser
    @parser ||= Radius::Parser.new( Rayo::TagContext.new( self ), :tag_prefix => 'r' )
  end

  private

  def load_context( filename )
    cont = @storage.load( filename )

    if cont && !cont.strip.empty?
      YAML::load( Erubis::Eruby.new( cont ).result( params ) )
    else
      {}
    end
  end

end
