require 'yaml'
require 'erubis'
require 'radius'

require File.join(File.dirname(__FILE__), '..', 'tag_context.rb')

class Rayo::Models::Page

  attr_reader :storage, :parent, :lang, :path, :format

  def initialize( storage, parent, lang, path, format )
    @storage = storage
    @parent = parent
    @lang = lang
    @path = path
    @format = format
  end

  def descendant( relative_path )
    relative_path.inject( self ) do |page,slug|
      return nil unless page

      page.child( slug )
    end
  end

  def children
    @children ||= @storage.find_pages( directories, @lang, @format ).map{|name| child( name ) }
  end

  def relative( url )
    path = url.split '/'

    if path.first && path.first.empty?
      @storage.root_page( @lang, @format ).descendant( path[1..-1] )
    else
      descendant( path )
    end
  end

  def child( slug )
    @children_cache ||= {}
    return @children_cache[ slug ] if @children_cache.include? slug

    page = Rayo::Models::Page.new( @storage, self, @lang, @path + [slug], @format )
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= @storage.find_page_dirs( @parent.directories, @lang, @path.last, @format )
  end

  def file
    @file ||= @storage.find_page_file( @parent.directories, @lang, @path.last, @format )
  end

  def parts
    @parts ||= file ? @storage.find_page_parts( file, @lang, @format ) : {}
  end

  def find_part( part_name, inherit = false )
    page = self
    part = self.parts[part_name]

    while inherit && !part && page.parent do
      page = page.parent
      part = page.parts[part_name]
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

  def layout
    @layout ||= @storage.layout( @lang, context['layout'], @format )
  end

  def []( key )
    key = key.to_s

    context[ key ] || params[ key ]
  end

  def render
    layout.render( parser )
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
