# frozen_string_literal: true

require 'komagire/version'
require 'komagire/key_list'
require 'komagire/id_list'
require 'komagire/active_record_extension'

module Komagire
end

begin
  require 'rails'
rescue LoadError
  # ignore
end

if defined? Rails
  require 'komagire/railtie'
else
  require 'active_support'
  ActiveSupport.on_load :active_record do
    extend Komagire::ActiveRecordExtension
  end
end
