class StaticArray
  attr_reader :store

  def initialize(capacity)
    @store = Array.new(capacity)
  end

  def [](i)
    validate!(i)
    self.store[i]
  end

  def []=(i, val)
    validate!(i)
    self.store[i] = val
  end

  def length
    self.store.length
  end

  private

  def validate!(i)
    raise "Overflow error" unless i.between?(0, self.store.length - 1)
  end
end

class DynamicArray
  include Enumerable

  attr_accessor :count

  def initialize(capacity = 8)
    @store = StaticArray.new(capacity)
    @count = 0
  end

  def [](i)
    i += @count if i.negative?
    return nil if i.negative?
    @store[i]
  rescue RuntimeError
    resize!
    retry
  end

  def []=(i, val)
    i += @count if i.negative?
    return nil if i.negative?
    if i > @count
      (i - @count).times { |j| self << nil }
      @count += 1
    end
    @store[i] = val
  rescue RuntimeError
    resize!
    retry
  end

  def capacity
    @store.length
  end

  def include?(val)
    self.any? { |el| el == val }
  end

  def push(val)
    self[count] = val
    @count += 1
    val
  end

  def unshift(val)
    (@count - 1).downto(0) { |i| self[i + 1] = self[i] }
    @count += 1
    self[0] = val
  end

  def pop
    return nil if count == 0
    @count -= 1
    popped, self[count] = self[count], nil
    popped
  end

  def shift
    return nil if @count == 0
    @count -= 1
    shifted, self[0] = self[0], nil
    (1..@count).each { |i| self[i - 1] = self[i] }
    shifted
  end

  def first
    self[0]
  end

  def last
    self[@count - 1]
  end

  def each(&prc)
    @count.times { |i| prc.call(self[i]) }
  end

  def to_s
    "[" + inject([]) { |acc, el| acc << el }.join(", ") + "]"
  end

  def ==(other)
    return false unless [Array, DynamicArray].include?(other.class)
    self.inject([]) { |acc, el| acc << el } == other.inject([]) { |acc, el| acc << el }
  end

  alias_method :<<, :push
  [:length, :size].each { |method| alias_method method, :count }

  private

  def resize!
    old_store = @store.store
    @store = StaticArray.new(old_store.length * 2)
    old_store.each_with_index { |el, i| self[i] = el }
  end
end
