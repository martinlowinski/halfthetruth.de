desc 'nuke, build and compass'
task :generate do
  sh 'rm -rf _site'
  jekyll
end

def jekyll
  # time to give me generation times
  # I'm just curious about how long it takes
  sh 'ejekyll'
  # compass already configured via config.rb in root
  sh 'compass compile'
end
