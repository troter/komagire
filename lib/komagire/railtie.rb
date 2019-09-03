# frozen_string_literal: true

module Komagire
  class Railtie < Rails::Railtie
    initializer 'komagire' do
      ActiveSupport.on_load :active_record do
        extend Komagire::ActiveRecordExtension
      end
    end
  end
end
