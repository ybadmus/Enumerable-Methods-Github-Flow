# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/ModuleLength
module Enumerable
  def my_each
    return to_enum(:self) unless block_given?

    i = 0
    while i < to_a.length
      yield to_a[i]
      i += 1
    end
    self
  end

  def my_each_with_index
    return to_enum(:self) unless block_given?

    i = 0
    while i < to_a.length
      yield to_a[i], i
      i += 1
    end
    self
  end

  def my_select
    return to_enum(:self) unless block_given?

    new_arr = []
    to_a.my_each { |city| new_arr << city if yield city }
    new_arr
  end

  def my_all?(param = nil)
    has_block = block_given?
    ret = true
    if has_block && param.nil?
      to_a.my_each { |item| ret = false unless yield item }
      return ret
    end

    if !has_block && !param.nil?
      if param.instance_of?(Regexp) || param.instance_of?(String)
        to_a.my_each { |item| ret = false unless item.match(param) }
      elsif param.instance_of?(Class)
        to_a.my_each { |item| ret = false unless [item.class, item.class.superclass].include?(param) }
      else
        to_a.my_each { |item| ret = false unless item == param }
      end
      return ret
    end
    raise ArgumentError, 'Too many arguments, Expected 1!' if has_block && !param.nil?

    to_a.my_each { |item| ret = false unless item }
    ret
  end

  def my_any?(param = nil)
    has_block = block_given?
    ret = false

    if has_block && param.nil?
      to_a.my_each { |item| ret = true if yield item }
      return ret
    end

    if !has_block && !param.nil?
      if param.instance_of?(Regexp) || param.instance_of?(String)
        to_a.my_each { |item| ret = true if item.match(param) }
      elsif param.instance_of?(Class)
        to_a.my_each { |item| ret = true if [item.class, item.class.superclass].include?(param) }
      else
        to_a.my_each { |item| ret = true if item == param }
      end
      return ret
    end

    raise ArgumentError, 'Too many arguments, Expected 1!' if has_block && !param.nil?

    to_a.my_each { |item| ret = true if item }
    ret
  end

  def my_none?(param = nil)
    has_block = block_given? ? true : false
    ret = true
    if has_block && param.nil?
      to_a.my_each { |item| ret = false if yield item }
      return ret
    end
    if !has_block && !param.nil?
      if param.instance_of?(Regexp) || param.instance_of?(String)
        to_a.my_each { |item| ret = false if item.match(param) }
      elsif param.instance_of?(Class)
        to_a.my_each { |item| ret = false if [item.class, item.class.superclass].include?(param) }
      else
        to_a.my_each { |item| ret = false if item == param }
      end
      return ret
    end
    raise ArgumentError, 'Too many arguments, Expected 1!' if has_block && !param.nil?

    to_a.my_each { |item| ret = false if item }
    ret
  end

  def my_count(param = nil)
    if !param.nil? && !block_given?
      count = 0
      to_a.my_each { |item| count += 1 if item == param }
      return count
    end
    return p to_a.length if param.nil? && !block_given?
    raise LocalJumpError, 'Too many arguments, Expected 1!' if !param.nil? && block_given?

    count = 0
    to_a.my_each { |item| count += 1 if yield item }
    p count
  end

  def my_map(proc = nil)
    return to_enum(:self) unless block_given? || proc

    new_arr = []
    if proc
      my_each { |item| new_arr << proc.call(item) }
    else
      to_a.my_each { |item| new_arr << yield(item) }
    end
    new_arr
  end

  def my_inject(initial = nil, symb = nil)
    if block_given?
      if initial.nil? && symb.nil?
        accumulator = to_a[0]
        to_a.my_each_with_index { |item, index| accumulator = yield(accumulator, item) if index.positive? }
        p accumulator
      elsif !initial.nil? && symb.nil?
        accumulator = initial
        to_a.my_each { |item, _index| accumulator = yield(accumulator, item) }
        p accumulator
      end
    else
      raise LocalJumpError, 'Too many arguments, Expected 1!' if initial.nil? && symb.nil?

      if !initial.nil? && symb.nil?
        accumulator = to_a[0]
        to_a.my_each_with_index { |item, index| accumulator = accumulator.send(initial, item) if index.positive? }
        p accumulator
      elsif !initial.nil? && !symb.nil?
        my_inject_ext(symb, initial)
      end
    end
  end
end

# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/ModuleLength

def multiply_els(param = nil)
  param&.my_inject { |accumulator, item| accumulator * item }
end

def my_inject_ext(symb, initial)
  accumulator = initial
  to_a.my_each { |item| accumulator = accumulator.send(symb, item) } if symb.is_a?(Symbol) || symb.is_a?(String)
  accumulator
end
