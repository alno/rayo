module Rayo::Tags::NavigationTags

  include Rayo::Taggable

  tag 'find' do |tag|
    url = tag.attr['url']
    path = url.split('/')

    if path.first.empty?
      path.shift
      page = tag.locals.page.storage.root_page
    else
      page = tag.locals.page
    end

    page = page.descendant( path )

    if page
      tag.locals.page = page
      tag.expand
    else
      error "No page '#{url}' found"
    end
  end

  tag 'children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end

  tag 'children:count' do |tag|
    tag.locals.children.size
  end

  tag 'children:first' do |tag|
    if first = tag.locals.children.first
      tag.locals.page = first
      tag.expand
    end
  end

  tag 'children:last' do |tag|
    if first = tag.locals.children.last
      tag.locals.page = first
      tag.expand
    end
  end

  tag 'children:each' do |tag|
    result = ''

    children = tag.locals.children
    children.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == children.length - 1
      result << tag.expand
    end
    result
  end

end
