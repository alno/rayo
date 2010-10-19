module Rayo::Tags::ContentTags

  include Rayo::Taggable

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
    snippet_name = tag.attr['name']
    snippet = tag.globals.storage.snippet( snippet_name )

    if snippet
      snippet.render( tag.globals.page.parser )
    else
      error "No snippet '#{snippet_name}' found"
    end
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
