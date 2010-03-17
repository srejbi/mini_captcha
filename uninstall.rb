# MiniCaptcha
#
# Install script for the plugin.
#
# Copyright (c) 2009-2010 György (George) Schreiber (gy.schreiber@mobility.hu)

require 'fileutils'

begin
  puts "Removing MiniCaptcha subview..."
  if File.exist?(vd = File.join(RAILS_ROOT, "app/views/mini_captcha"))
    if File.exists?(vf = File.join(RAILS_ROOT, "app/views/mini_captcha/_mini_captcha." + (Rails::VERSION::STRING > '1.8' ? 'rhtml' : 'html.erb')))
      File.delete(vf)
      puts "View deleted."
    end
    unless File.fnmatch("*", vd, File::FNM_PATHNAME)
      Dir.rmdir(vd)
      puts "View directory deleted."
    end
  end

  puts "Removing stylesheet..."
  if File.exists?(sf = File.join(RAILS_ROOT, "public/stylesheets/_mini_captcha.css"))
    File.delete(sf)
    puts "Stylesheet deleted."
  end

  puts "TODO: locate and remove the following line to your 'config/routes.rb':"
  puts "route \"map.mini_captcha '/mini_captcha/:action', :controller => 'mini_captcha'\", :action => 'show_image'"

  puts "TODO: also, remove the reference to the _mini_captcha.css from your main CSS file."

  rescue StandardError => err
  puts "An error has occurred:"
  puts err
end