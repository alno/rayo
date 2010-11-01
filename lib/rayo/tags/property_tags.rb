module Rayo::Tags::PropertyTags

  include Rayo::Taggable

  tag 'title' do |tag|
    tag.locals.page.context['title']
  end

  tag 'description' do |tag|
    tag.locals.page.context['description']
  end

  tag 'path' do |tag|
    basepath = tag.globals.page.path[0..-2]
    path = tag.locals.page.path

    i = 0
    while i < path.size && i < basepath.size && path[i] == basepath[i] do
      i = i + 1
    end

    '../' * (basepath.size - i) + path[i..-1].join('/')
  end

  tag 'link' do |tag|
    "<a href=\"#{send 'tag:path', tag}\">#{tag.single? ? send( 'tag:title', tag ) : tag.expand}</a>"
  end

  tag 'if_url' do |tag|
    if_url( tag ) && tag.expand || ''
  end

  tag 'unless_url' do |tag|
    if_url( tag ) && '' || tag.expand
  end

  tag 'date' do |tag|
    Time.now.strftime(tag.attr['format'] || '%A, %B %d, %Y')
  end

  private

  def if_url( tag )
    tag.locals.page.path =~ Regexp.new( tag.attr['matches'] )
  end

end
