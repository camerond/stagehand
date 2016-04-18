activate :livereload
activate :syntax
activate :relative_assets
activate :directory_indexes

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
set :js_dir, 'javascripts'

set :haml, {
  :ugly => true,
  :format => :html5
}
set :sass, {
  :style => :expanded,
  :line_comments => false
}

proxy "/faq/index.html", "/faq"
ignore "/test.html" if build?

(1..4).to_a.each do |i|
  proxy "/examples/#{i}/index.html", "/examples/index.html", :locals => { :example => i }, ignore: true
end
