require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

include AudioAddict
require_relative 'spec_mixin'
include SpecMixin

reset_config

Dir.mkdir 'spec/tmp' unless Dir.exist? 'spec/tmp'

RSpec.configure do |c|
  c.include SpecMixin
  c.include Colsole
end
