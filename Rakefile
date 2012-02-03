namespace :jekyll do
  desc 'Delete generated _site files'
  task :clean do
    system "rm -fR _site"
  end

  desc 'Run the jekyll dev server'
  task :server => [ :compile ] do
    system "ejekyll --server --auto"
  end

  desc 'Clean temporary files and run the server'
  task :compile => [ :clean, 'compass:clean', 'compass:compile' ] do
    system "ejekyll"
  end
end

namespace :compass do
  desc 'Delete temporary compass files'
  task :clean do
    system "rm -fR css"
  end

  desc 'Run the compass watch script'
  task :watch do
    system "compass watch"
  end

  desc 'Compile sass scripts'
  task :compile => [:clean] do
    system "compass compile -s compressed"
  end  
end

desc 'Clean out temporary files'
task :clean => [ 'compass:clean', 'jekyll:clean' ] do
end

desc 'Compile whole site'
task :compile => [ 'jekyll:compile' ] do
end

