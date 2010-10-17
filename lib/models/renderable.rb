class Models::Renderable

  attr_reader :file
  attr_reader :filter

  def initialize( file, filter )
    @file = file
    @filter = filter
  end

  def source
    @source ||= File.read( file )
  end

  def render( parser )
    filter.call( parser.parse( source ) )
  end

end
