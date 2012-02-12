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
    puts 'Delete generated _site files'
    system "rm -fR #{public_dir}"
  end

  desc 'Clean temporary files and compile'
  task :compile => [ :clean ] do
    puts 'Clean temporary files and compile'
    system "jekyll"
  end
end


# Compass & Sass
namespace :compass do
  desc 'Delete generated compass/sass files'
  task :clean do
    puts 'Delete generated compass/sass files'
    system "rm -fR css"
  end

  desc 'Run the compass watch script'
  task :watch do
    puts 'Run the compass watch script'
    system "compass watch"
  end

  desc 'Compile compass/sass scripts'
  task :compile => [ :clean ] do
    puts 'Compile compass/sass scripts'
    system "compass compile"
  end  
end


# Working tasks
# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new draft post in #{posts_dir}"
task :post, :title do |t, args|
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
    post.puts "slug: #{title.to_url}"
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "author: Martin Lowinski"
    post.puts "comments: true"
    post.puts "published: false"
    post.puts "categories: "
    post.puts "tags: "
    post.puts "---"
  end
  system "$EDITOR #{filename}"
end

desc 'List all draft posts'
task :drafts do
  puts `find ./_posts -type f -exec grep -H 'published: false' {} \\;`
end


# Global
desc 'Clean out temporary files'
task :clean => [ 'compass:clean', 'jekyll:clean' ] do
end

desc 'Compile whole site'
task :compile => [ 'compass:compile', 'jekyll:compile' ] do
end

desc 'Run dev environment'
task :dev => [ :clean, 'compass:compile' ] do
  system "foreman start"
end


