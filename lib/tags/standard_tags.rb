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

    tag.locals.page.parts[part_name]
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
