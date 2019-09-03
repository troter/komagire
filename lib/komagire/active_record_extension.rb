# frozen_string_literal: true

module Komagire
  module ActiveRecordExtension
    # @param [Symbol] part_id
    # @param [Symbol] attribute
    # @param [String] content_class_name
    # @param [Symbol] content_class_attribute
    # @param [Hash] options
    # @option options [Hash] :komagire ({}) options that are passed to the Komagire::KeyList
    def composed_of_komagire_key_list(part_id, attribute, content_class_name, content_class_attribute, options={})
      komagire_options = options.delete(:komagire) || {}
      options = {
        class_name: 'Komagire::KeyList',
        mapping: [[attribute.to_s, 'cskeys']],
        allow_nil: false,
        constructor: lambda { |cskeys|
          Komagire::KeyList.new(content_class_name, content_class_attribute, cskeys, komagire_options)
        },
        converter: lambda { |value|
          Komagire::KeyList.new(content_class_name, content_class_attribute, value, komagire_options)
        },
      }.merge(options)
      composed_of part_id, options
    end

    # @param [Symbol] part_id
    # @param [Symbol] attribute
    # @param [String] content_class_name
    # @param [Hash] options
    # @option options [Hash] :komagire ({}) options that are passed to the Komagire::KeyList
    def composed_of_komagire_id_list(part_id, attribute, content_class_name, options={})
      komagire_options = options.delete(:komagire) || {}
      options = {
        class_name: 'Komagire::IdList',
        mapping: [[attribute.to_s, 'csids']],
        allow_nil: false,
        constructor: lambda { |cskeys|
          Komagire::IdList.new(content_class_name, cskeys, komagire_options)
        },
        converter: lambda { |value|
          Komagire::IdList.new(content_class_name, value, komagire_options)
        },
      }.merge(options)
      composed_of part_id, options
    end
  end
end
