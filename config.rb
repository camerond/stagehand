activate :livereload
activate :syntax
activate :relative_assets

set :markdown_engine, :redcarpet
set :js_dir, 'javascripts'
set :relative_links, true

set :haml, {
  :ugly => true,
  :format => :html5
}
set :sass, {
  :style => :expanded,
  :line_comments => false
}

proxy "/", "/index,html"

(1..4).to_a.each do |i|
  proxy "/examples/#{i}", "/examples/index.html", :locals => { :example => i }, ignore: true
  proxy "/examples/#{i}/index.html", "/examples/index.html", :locals => { :example => i }, ignore: true
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end
