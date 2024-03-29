# frozen_string_literal: true

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
      @sort = options[:sort] || false
      @cskeys = _convert(cskeys)
      super(_find_by_cskeys)
    end

    # comma separated keys
    #
    # @return [String]
    def cskeys
      key_values = compact.map(&@attribute).uniq.tap {|values| values.sort! if @sort }
      ([''] + key_values + ['']).join(@delimiter)
    end

    private

    def _convert(cskeys)
      Converter.new(@content_class_name, @attribute, @delimiter).convert(cskeys)
    end

    def _keys
      @cskeys.split(@delimiter).uniq
    end

    def _find_by_cskeys
      keys = _keys
      return [] if keys.empty?

      values = content_class_name.constantize.where(@attribute => keys).compact
      if @sort
        values.sort_by { |v| v.public_send(@attribute) }
      else
        values.index_by { |v| v.public_send(@attribute).to_s }.values_at(*keys)
      end
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

          raise DifferentContentClass
        else
          values = if value.is_a?(Array) then value
                   elsif value.respond_to?(:to_a) then value.to_a
                   elsif value.respond_to?(:to_ary) then value.to_ary
                   else
                     raise ArgumentError
                   end
          convert_to_cskeys_from_array(values.compact)
        end
      end

      def convert_to_cskeys_from_array(values)
        if values.all? { |v| v.is_a?(String) }
          values.join(delimiter)
        elsif values.all? { |v| v.is_a?(content_class_name.constantize) }
          values.map(&attribute).join(delimiter)
        else
          raise ArgumentError
        end
      end
    end
  end
end
