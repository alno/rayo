require 'yaml'
require 'erubis'
require 'radius'

require File.join(File.dirname(__FILE__), '..', 'tag_context.rb')

class Rayo::Models::Page

  attr_reader :storage, :parent, :path

  def initialize( storage, parent, path )
    @storage = storage
    @parent = parent
    @path = path
  end

  def descendant( relative_path )
    relative_path.inject( self ) {|page,slug| page.child( slug ) }
  end

  def children
    @children ||= @storage.find_pages( directories ).map{|name| child( name ) }
  end

  def child( slug )
    @children_cache ||= {}
    return @children_cache[ slug ] if @children_cache.include? slug

    page = Rayo::Models::Page.new( @storage, self, @path + [slug] )
    page = nil if page.file.nil? && page.directories.empty?

    @children_cache[ slug ] = page
  end

  def directories
    @directories ||= @storage.find_page_dirs( @parent.directories, @path.last )
  end

  def file
    @file ||= @storage.find_page_file( @parent.directories, @path.last )
  end

  def parts
    @parts ||= file ? @storage.find_page_parts( file ) : {}
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
    @layout ||= @storage.layout( context['layout'] )
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
    YAML::load( Erubis::Eruby.new( File.read( filename ) ).result( params ) )
  end

end
