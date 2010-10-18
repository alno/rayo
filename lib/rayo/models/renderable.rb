class Rayo::Models::Renderable

  attr_reader :storage
  attr_reader :file
  attr_reader :filter

  def initialize( storage, file, filter )
    @storage = storage
    @file = file
    @filter = filter
  end

  def source
    @source ||= @storage.load( file )
  end

  def render( parser )
    filter.call( parser.parse( source ) )
  end

end
