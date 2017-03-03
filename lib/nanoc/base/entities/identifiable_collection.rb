module Nanoc::Int
  # @api private
  class IdentifiableCollection
    include Nanoc::Int::ContractsSupport
    include Enumerable

    extend Forwardable

    def_delegator :@objects, :each
    def_delegator :@objects, :size

    contract C::Or[Hash, C::Named['Nanoc::Int::Configuration']], C::IterOf[C::RespondTo[:identifier]] => C::Any
    def initialize(config, objects = [])
      @config = config
      @objects = objects
    end

    def self.from(enum, config)
      new(config, enum)
    end

    contract C::None => self
    def freeze
      @objects.freeze
      @objects.each(&:freeze)
      build_mapping
      super
    end

    contract C::Any => C::Maybe[C::RespondTo[:identifier]]
    def [](arg)
      case arg
      when Nanoc::Identifier
        object_with_identifier(arg)
      when String
        object_with_identifier(arg) || object_matching_glob(arg)
      when Regexp
        @objects.find { |i| i.identifier.to_s =~ arg }
      else
        raise ArgumentError, "don’t know how to fetch objects by #{arg.inspect}"
      end
    end

    contract C::None => C::ArrayOf[C::RespondTo[:identifier]]
    def to_a
      @objects
    end

    contract C::None => C::Bool
    def empty?
      @objects.empty?
    end

    def add(obj)
      self.class.new(@config, @objects + [obj])
    end

    def reject(&block)
      self.class.new(@config, @objects.reject(&block))
    end

    protected

    def object_with_identifier(identifier)
      if frozen?
        @mapping[identifier.to_s]
      else
        @objects.find { |i| i.identifier == identifier }
      end
    end

    def object_matching_glob(glob)
      if use_globs?
        pat = Nanoc::Int::Pattern.from(glob)
        @objects.find { |i| pat.match?(i.identifier) }
      else
        nil
      end
    end

    def build_mapping
      @mapping = {}
      @objects.each do |object|
        @mapping[object.identifier.to_s] = object
      end
      @mapping.freeze
    end

    def use_globs?
      @config[:string_pattern_type] == 'glob'
    end
  end
end
