set :js_dir, 'javascripts'
activate :livereload
activate :syntax
set :haml, { ugly: true }

(1..7).to_a.each do |i|
  proxy "/examples/#{i}", "/examples/index.html", :locals => { :example => i }, ignore: true
end