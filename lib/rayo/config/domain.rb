require 'forwardable'

class Rayo::Config::Domain

  extend Forwardable

  def_delegators :@parent, :create_tagger, :languages, :page_exts, :format, :default_format

  attr_reader :name
  attr_writer :cache_dir

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

  # Get cache directory for this domain. If it was not set explicitly it'll be global cache_dir with domain name appended
  def cache_dir
    @cache_dir || @parent.cache_dir && File.join( @parent.cache_dir, @name )
  end

end
