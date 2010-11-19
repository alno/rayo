class Rayo::Models::Renderable

  attr_reader :storage
  attr_reader :file
  attr_reader :format
  attr_reader :filter

  def initialize( storage, file, format, filter )
    @storage = storage
    @file = file
    @format = format
    @filter = filter
  end

  def source
    @source ||= @storage.load( file )
  end

  def render( parser )
    parser.context.with_format @format do
      filter.call( parser.parse( source ) )
    end
  end

end
