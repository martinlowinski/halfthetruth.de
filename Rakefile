require "rubygems"
require "stringex"
require "highline/import"

# Configuration
public_dir      = "_site"    # compiled site directory
posts_dir       = "_posts"    # directory for blog files
new_post_ext    = "markdown"  # default new post file extension when using the new_post task


# Jekyll
namespace :jekyll do
  desc 'Delete generated _site files'
  task :clean do
    system "rm -fR #{public_dir}"
  end

  desc 'Run the jekyll dev server'
  task :server => [ :compile ] do
    system "jekyll --server --auto"
  end

  desc 'Clean temporary files and run the server'
  task :compile => [ :clean, 'compass:clean', 'compass:compile' ] do
    system "jekyll"
  end
end


# Compass & Sass
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


# Working tasks
# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{posts_dir}"
task :new_post, :title do |t, args|
  args.with_defaults(:title => 'new-post')
  title = args.title
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "author: Martin Lowinski"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "tags: "
    post.puts "---"
  end
  system "$EDITOR #{filename}"
end


# Global
desc 'Clean out temporary files'
task :clean => [ 'compass:clean', 'jekyll:clean' ] do
end

desc 'Compile whole site'
task :compile => [ 'jekyll:compile' ] do
end

