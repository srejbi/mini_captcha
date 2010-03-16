# MiniCaptcha
#
# Install script for the plugin.
#
# Copyright (c) 2009-2010 György (George) Schreiber (gy.schreiber@mobility.hu)

require 'fileutils'

begin
  puts "Creating MiniCaptcha subview..."
  mkdir(File.join(RAILS_ROOT, "app/views/mini_captcha")) unless File.exist?(File.join(RAILS_ROOT, "app/views/mini_captcha"))
  FileUtils.cp_r(
    File.join(File.dirname(__FILE__), "installables/views/_mini_captcha.html.erb"),
    File.join(RAILS_ROOT, "app/views/mini_captcha/_mini_captcha." + (Rails::VERSION::STRING > '1.8' ? 'rhtml' : 'html.erb'))
  )
  puts "View created."

  puts "Copying stylesheet..."
  mkdir(File.join(RAILS_ROOT, "public/stylesheets")) unless File.exist?(File.join(RAILS_ROOT, "public/stylesheets"))
  FileUtils.cp_r(
    File.join(File.dirname(__FILE__), "installables/public/stylesheets/_mini_captcha.css"),
    File.join(RAILS_ROOT, "public/stylesheets/_mini_captcha.css")
  )
  puts "Stylesheet copied."


  puts "TODO: add the following line to your 'config/routes.rb':"
  puts "route \"map.mini_captcha '/mini_captcha/:action', :controller => 'mini_captcha'\", :action => 'show_image'"

  puts "TODO: also, include in your main CSS the _mini_captcha.css file."

  rescue StandardError => err
  puts "An error has occurred:"
  puts err
end