module Tags::StandardTags

  include Taggable

  tag 'page' do |tag|
    tag.locals.page = tag.globals.page
  end

  tag 'title' do |tag|
    tag.locals.page.context['title']
  end

  tag 'content' do |tag|
    part_name = tag.attr['part'] || 'body'
    inherit = tag.attr['inherit'] == 'true'

    page = tag.locals.page
    part = page.parts[part_name]

    while inherit && !part && page.parent do
      page = page.parent
      part = page.parts[part_name]
    end

    if part
      part.render( tag.globals.page.parser )
    else
      error "No part '#{part_name}' found for page '#{tag.locals.page.path}'"
    end
  end

  tag 'content_for_layout' do |tag|
    send 'tag:content', tag
  end

  tag 'snippet' do |tag|
    number = (tag.attr['times'] || '1').to_i
    result = ''
    number.times { result << tag.expand }
    result
  end

  tag 'hello' do
     'Hello world'
  end

  tag 'repeat' do |tag|
    number = (tag.attr['times'] || '1').to_i
    result = ''
    number.times { result << tag.expand }
    result
  end

end
