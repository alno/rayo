class Layout

  attr_reader :storage, :file

  def initialize( storage, file )
    @storage = storage
    @file = file
  end

  def source
    @source ||= File.read( file )
  end

  def render( parser )
    parser.parse( source )
  end

end
