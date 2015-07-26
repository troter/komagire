require 'delegate'

module Komagire
  DEFAULT_DELIMITER = ','

  DifferentContentClass = Class.new(StandardError)

  class KeyList < SimpleDelegator
    attr_reader :content_class_name, :attribute

    # @param [String] content_class_name
    # @param [Symbol] attribute
    # @param [String] cskeys comma separated keys
    # @param [Hash] options
    # @option options [String] :delimiter (Komagire::DEFAULT_DELIMITER)
    def initialize(content_class_name, attribute, cskeys, options = {})
      @content_class_name = content_class_name
      @attribute = attribute
      @delimiter = options[:delimiter] || Komagire::DEFAULT_DELIMITER
      @cskeys = _convert(cskeys)
      super(_find_by_cskeys)
    end

    # comma separated keys
    #
    # @return [String]
    def cskeys
      ([''] + map(&@attribute).sort.uniq + ['']).join(@delimiter)
    end

    def freeze
      case __getobj__
      when ActiveRecord::Relation
        # avoid ActiveRecord::Relation is frozen
      else
        super
      end
    end

    private

    def _convert(cskeys)
      Converter.new(@content_class_name, @attribute, @delimiter).convert(cskeys)
    end

    def _keys
      @cskeys.split(@delimiter).sort.uniq
    end

    def _find_by_cskeys
      content_class_name.constantize.where(@attribute => _keys)
    end

    class Converter
      attr_reader :content_class_name, :attribute, :delimiter

      def initialize(content_class_name, attribute, delimiter)
        @content_class_name = content_class_name
        @attribute = attribute
        @delimiter = delimiter
      end

      def convert(value)
        convert_to_cskeys(value) || ''
      end

      def convert_to_cskeys(value)
        case value
        when String
          value
        when Komagire::KeyList
          if value.content_class_name == content_class_name && value.attribute == attribute
            return value.cskeys
          end
          fail DifferentContentClass
        else
          values = case
                   when value.is_a?(Array) then value
                   when value.respond_to?(:to_a) then value.to_a
                   when value.respond_to?(:to_ary) then value.to_ary
                   else
                     fail ArgumentError
                   end
          convert_to_cskeys_from_array(values.compact)
        end
      end

      def convert_to_cskeys_from_array(values)
        case
        when values.all? { |v| v.is_a?(String) }
          values.join(delimiter)
        when values.all? { |v| v.is_a?(content_class_name.constantize) }
          values.map(&attribute).join(delimiter)
        else
          fail ArgumentError
        end
      end
    end
  end
end
