# -*- coding: utf-8 -*-

# Ensure that the lib/ directory is used before the one installed in
# the system to get the right version, then require the library
# itself.
$:.insert(0, File.expand_path("../lib", __FILE__))

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.pattern = "test/*_test.rb"
  t.verbose = true
end
