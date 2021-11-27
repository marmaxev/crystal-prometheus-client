require "./label_set_validator"

module Prometheus
  module Client
    class Metric
      getter name, docstring, base_labels

      def initialize(@name : Symbol, @docstring : String, @base_labels = {} of Symbol => String)
        validate_name
        validate_docstring

        @validator = LabelSetValidator.new
      end

      def observe(labels = {} of Symbol => String, value : Float64 = 0.0); end

      def values
        @values ||= Hash(Hash(Symbol, String), Float64).new { |h, k| h[k] = 0.0 }
      end

      def get(labels = {} of Symbol => String)
        values[label_set_for(labels)]
      end

      RE_NAME = /\A[a-zA-Z_:][a-zA-Z0-9_:]*\Z/

      private def validate_name
        raise ArgumentError.new("metric name must match #{RE_NAME}") unless name.to_s =~ RE_NAME
      end

      private def validate_docstring
        raise ArgumentError.new("docstring must be given") if docstring.empty?
      end

      private def label_set_for(labels : Hash(Symbol, String))
        @validator.validate(labels)
      end
    end
  end
end
