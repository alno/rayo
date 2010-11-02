require 'forwardable'

class Rayo::Config::Domain

  extend Forwardable

  def_delegators :@parent, :create_tagger, :languages, :page_exts, :renderable_exts, :filter

  def initialize( parent, name, exp )
    @parent = parent
    @name = name
    @exp = exp
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
