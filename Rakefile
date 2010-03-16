# MiniCaptcha
#
# Rakefile for the plugin.
#
# Copyright (c) 2009-2010 György (George) Schreiber (gy.schreiber@mobility.hu)


require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'MiniCaptcha'
  s.version = '0.0.2'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'MIT-LICENSE']
  s.summary = 'very simple, file-based captcha plugin'
  s.description = s.summary
  s.author = 'György Schreiber'
  s.email = 'gy.schreiber@mobility.hu'
  # s.executables = ['your_executable_here']
  s.files = %w(MIT-LICENSE README Rakefile) + Dir.glob("{bin,lib,spec,installables}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "MilkyCaptcha Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
end