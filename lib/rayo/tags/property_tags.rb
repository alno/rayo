module Rayo::Tags::PropertyTags

  include Rayo::Taggable

  tag 'title' do |tag|
    tag.locals.page.context['title']
  end

  tag 'description' do |tag|
    tag.locals.page.context['description']
  end

  tag 'path' do |tag|
    curpath = tag.globals.page.path
    path = tag.locals.page.path

    i = 0
    while i < path.size && i < curpath.size && path[i] == curpath[i] do
      i = i + 1
    end

    '../' * (curpath.size - i) + path[i..-1].join('/')
  end

  tag 'link' do |tag|
    "<a href=\"#{send 'tag:path', tag}\">#{send 'tag:title', tag}</a>"
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
