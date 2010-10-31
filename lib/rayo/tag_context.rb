class Rayo::TagContext < Radius::Context

  attr_reader :page

  def initialize(page)
    super()

    @page = page

    globals.page = @page
    globals.storage = @page.storage

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

end
