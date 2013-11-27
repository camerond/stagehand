set :js_dir, 'javascripts'
activate :livereload
activate :syntax
set :haml, { ugly: true }

(1..4).to_a.each do |i|
  proxy "/examples/#{i}", "/examples/index.html", :locals => { :example => i }, ignore: true
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end