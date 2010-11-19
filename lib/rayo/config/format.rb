class Rayo::Config::Format

  attr_reader :name
  attr_reader :renderable_exts

  def initialize( name )
    @name = name.to_s
    @filters = { @name => lambda{|source| source} }
    @renderable_exts = [ ".#{name}" ]
  end

  # Add filter
  #
  # @param [String,Symbol] renderable file extension
  # @param [Proc] filter proc which accepts source and return it in processed form
  def add_filter( from, &filter )
    @filters[from.to_s] = filter
    @renderable_exts << ".#{from}" unless @renderable_exts.include? ".#{from}"
  end

  def filter( from )
    @filters[from.to_s]
  end

end
