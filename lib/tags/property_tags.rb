module Tags::PropertyTags

  include Taggable

  tag 'title' do |tag|
    tag.locals.page.context['title']
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
    "<a href=\"#{send 'tag:path', tag}\">#{tag.locals.page.context['title']}</a>"
  end

end
