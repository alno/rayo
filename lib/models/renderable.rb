class Models::Renderable

  attr_reader :file

  def initialize( file )
    @file = file
  end

  def source
    @source ||= File.read( file )
  end

  def render( parser )
    parser.parse( source )
  end

end
