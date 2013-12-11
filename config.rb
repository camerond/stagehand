set :js_dir, 'javascripts'
activate :livereload
activate :syntax
activate :relative_assets
set :haml, { ugly: true }
set :sass, {
  :style => :expanded,
  :line_comments => false
}

(1..4).to_a.each do |i|
  proxy "/examples/#{i}/index.html", "/examples/index.html", :locals => { :example => i }, ignore: true
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end

helpers do
  def rel_link_to(content, url, *args)
    if development?
      link_to(content, url, *args)
    else
      link_to(content, "/stagehand#{url}", *args)
    end
  end
  def rel_url(url)
    if development?
      url
    else
      "/stagehand#{url}"
    end
  end
end
