$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'bundler/setup'

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'active_record'
require 'active_hash'
require 'komagire'

RSpec.configure do |config|
  config.color = true
  config.mock_framework = :rspec
  config.before :all do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  end
end

def create_temp_table(name, &block)
  fail 'no block given!' unless block_given?

  before :each do
    m = ActiveRecord::Migration.new
    m.verbose = false
    m.create_table name, &block
  end

  after :each do
    m = ActiveRecord::Migration.new
    m.verbose = false
    m.drop_table name
  end
end
