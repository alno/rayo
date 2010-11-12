require 'forwardable'

class Rayo::Config::Domain

  extend Forwardable

  def_delegators :@parent, :create_tagger, :languages, :page_exts, :renderable_exts, :filter

  attr_reader :name

  def initialize( parent, name, exp )
    @parent = parent
    @name = name
    @exp = exp || Regexp.new( "^#{Regexp.quote( name )}\.?$" )
  end

  def matches?( host )
    host =~ @exp
  end

  def directory( content_type )
    if content_type == :pages
      File.join( @parent.directory( content_type ), @name )
    else
      @parent.directory( content_type )
    end
  end

end
