# frozen_string_literal: true

module Komagire
  class IdList < KeyList
    # @param [String] content_class_name
    # @param [String] cskeys comma separated keys
    # @param [Hash] options
    # @option options [Symbol] :primary_Key
    # @option options [String] :delimiter (Komagire::DEFAULT_DELIMITER)
    def initialize(content_class_name, cskeys, options = {})
      key = options.delete(:primary_key) || :id
      super(content_class_name, key, cskeys, options)
    end

    # comma separated ids
    #
    # @return [String]
    def csids
      cskeys
    end

    private

    def _convert(cskeys)
      Converter.new(@content_class_name, @attribute, @delimiter).convert(cskeys)
    end

    def _find_by_cskeys
      ancestors = content_class_name.constantize.ancestors.map(&:to_s)
      if ancestors.include?('ActiveHash::Base')
        values = _keys.map { |id| content_class_name.constantize.find_by_id(id) }.compact
        if @sort
          values.sort_by(&:id)
        else
          values
        end
      else
        super
      end
    end

    class Converter < KeyList::Converter
      def convert_to_cskeys_from_array(values)
        if values.all? { |v| v.is_a?(String) }
          values.join(delimiter)
        elsif values.all? { |v| v.is_a?(Integer) }
          values.join(delimiter)
        elsif values.all? { |v| v.is_a?(content_class_name.constantize) }
          values.map(&attribute).join(delimiter)
        else
          raise DifferentContentClass
        end
      end
    end
  end
end
