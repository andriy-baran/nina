# frozen_string_literal: true

# This should be a kind of factory that creates complex objects
# from simple ones. It should use torirori to create objects.
# It also enriches objects with some methods that make them more
# like linked lists.
module Nina
  # Generates module that adds support for objects creation
  class Builder
    attr_reader :name, :abstract_factory, :def_block, :callbacks

    # A way to call methods from initalization proc on base_class
    class Initialization < BasicObject
      attr_reader :allow_list

      def initialize(allow_list, atts = {})
        @allow_list = allow_list
        @atts = atts
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @allow_list.include?(method)

        @atts[method] = [args, kwargs, block]
      end

      def respond_to_missing?(method, include_private = false)
        @allow_list.include?(method) || super
      end

      def to_h
        @atts
      end
    end

    # Utility to get user defined callbacks
    class Callbacks < Initialization
      def copy
        Callbacks.new(@allow_list, to_h.dup)
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @allow_list.include?(method)

        @atts[method] unless block
        @atts[method] ||= []
        @atts[method] << block
      end

      def respond_to_missing?(method, include_private = false)
        super
      end
    end

    # Definaes support methods and variables for concrete builder
    module ClassMethods
      def build_order_list
        @build_order_list ||= []
      end

      def build_order_list=(other)
        @build_order_list = other.dup.freeze
      end

      def inherited(subclass)
        super
        subclass.build_order_list = build_order_list.dup.freeze
      end

      def factory(name, *args, **kwargs, &block)
        build_order_list << name
        super
        define_singleton_method(name) do |klass = nil, &definition|
          factories[__method__].subclass.base_class(klass) if klass
          factories[__method__].subclass(&definition) if definition
        end
      end
    end

    def copy
      self.class.new(name, abstract_factory: abstract_factory)
    end

    def with_callbacks(&block)
      c = callbacks&.copy || Callbacks.new(abstract_factory.factories.keys)
      yield c if block

      self.class.new(name, abstract_factory: abstract_factory, callbacks: c)
    end

    def initialize(name, abstract_factory: nil, callbacks: nil, &def_block)
      @name = name
      @def_block = def_block
      @abstract_factory = abstract_factory.include(Toritori).extend(ClassMethods)
      @abstract_factory.class_eval(&def_block) if def_block
      @abstract_factory.build_order_list.freeze
      @initialization = Initialization.new(@abstract_factory.factories.keys)
      @assembler = Assembler.new(@abstract_factory)
      @callbacks = callbacks
    end

    def wrap(delegate: false, &block)
      yield @initialization if block

      @assembler.inject(
        @abstract_factory.build_order_list,
        @initialization.to_h,
        callbacks: callbacks,
        delegate: delegate
      )
    end

    def nest(delegate: false, &block)
      yield @initialization if block

      @assembler.inject(
        @abstract_factory.build_order_list.reverse,
        @initialization.to_h,
        callbacks: callbacks,
        delegate: delegate
      )
    end

    def subclass(&def_block)
      return unless def_block

      @abstract_factory = Class.new(abstract_factory)
      @abstract_factory.class_eval(&def_block)
      @abstract_factory.build_order_list.freeze
      @initialization = Initialization.new(@abstract_factory.factories.keys)
      @assembler = Assembler.new(@abstract_factory)
    end
  end
end
