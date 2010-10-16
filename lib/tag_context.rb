class TagContext < Radius::Context

  attr_reader :page

  def initialize(page)
    super()

    @page = page

    globals.page = @page

    tagger = @page.storage.tagger
    tagger.methods.each do |name|
      define_tag(name[4..-1]) { |tag_binding| tagger.send name, tag_binding } if name[0..3] == 'tag:'
    end
  end

end
