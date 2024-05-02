# frozen_string_literal: true

require 'toritori'
require 'nina/builder'

require_relative 'nina/version'

# Module that provides DSL for builders
module Nina
  class Error < StandardError; end

  # Definaes support methods and variables
  module ClassMethods
    def builders
      @builders ||= {}
    end

    def builders=(other)
      @builders = other
    end

    def builder(name, &block)
      builders[name] = Nina::Builder.new(name, abstract_factory: Class.new, &block)
      define_singleton_method(:"#{name}_builder") { builders[name] }
    end

    def inherited(subclass)
      super
      subclass.builders = builders.transform_values(&:copy)
    end
  end

  # Adds ability to delegeate methods via method_missing
  module MethodMissingDelegation
    def method_missing(name, *attrs, **kwargs, &block)
      if (prev = predecessors.lazy.detect { |o| o.public_methods.include?(name) })
        prev.public_send(name, *attrs, **kwargs, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      public_methods.detect { |m| m == :predecessor } || super
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.def_reader(accessor, on:, to:, delegate: false)
    on.define_singleton_method(accessor) { to }
    on.define_singleton_method(:predecessor) { to }
    def on.predecessors
      Enumerator.new do |y|
        obj = self
        y << obj = obj.predecessor while obj.methods.detect { |m| m == :predecessor }
      end
    end
    return unless delegate

    on.extend(MethodMissingDelegation)
  end

  def self.link(build, delegate: false, &block)
    result = nil
    build.each.inject(nil) do |prev, (name, object)|
      Nina.def_reader(name, on: prev, to: object, delegate: delegate) if prev
      yield(name, object) if block
      object.tap { |o| result ||= o }
    end
    result
  end

  def self.reverse_link(build, delegate: false, &block)
    build.each.with_index(-1).inject(nil) do |prev, ((name, object), idx)|
      Nina.def_reader(build.keys[idx], on: object, to: prev, delegate: delegate) if prev
      yield(name, object) if block
      object
    end
  end

  def self.enrich(build, target)
    build.each do |name, object|
      target.define_singleton_method(name) { object }
    end
    target
  end
end
