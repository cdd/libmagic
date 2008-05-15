require 'rubygems'
require 'hoe'
require './lib/libmagic.rb'

Hoe.new('libmagic', Magic::VERSION) do |p|
  # p.rubyforge_name = 'libmagicx' # if different than lowercase project name
  p.developer('Moses Hohman', 'moses@moseshohman.com')
  p.spec_extras = {:extensions => ['ext/extconf.rb']}
end

task :extension