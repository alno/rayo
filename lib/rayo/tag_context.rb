class Rayo::TagContext < Radius::Context

  attr_reader :page

  def initialize(page)
    super()

    @page = page

    globals.page = @page
    globals.storage = @page.storage
    globals.config = @page.storage.config

    tagger = @page.storage.config.create_tagger
    tagger.methods.each do |name|
      define_tag(name[4..-1]) { |tag_binding| tagger.send name, tag_binding } if name[0..3] == 'tag:'
    end
  end

  def render_tag(name, attributes = {}, &block)
    super
  rescue Exception => e
    error("#{e.message} <pre>#{e.backtrace.join("\n")}</pre>")
  end

  def tag_missing(name, attributes = {}, &block)
    super
  rescue Radius::UndefinedTagError => e
    error("#{e.message} <pre>#{e.backtrace.join("\n")}</pre>")
  end

  def error( text )
    "<strong class=\"error\">#{text}</strong>"
  end

  def with_format( format )
    old_format = globals.format
    globals.format = format

    result = yield

    globals.format = old_format

    result
  end

end
