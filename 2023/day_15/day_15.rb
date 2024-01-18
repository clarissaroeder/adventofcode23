=begin
- Run hash algorithm on the letters before - or = (the label)
  -> Number of the box to work on
- = / - identify the operation to perform:
  -: go to the box, remove lens with the given label if present,
        and move all lenses behind it forward

  =: is followed by a number indicating the focal length of the lens to be added
    - mark the lens with the label
    - two scenarios:
      - if there already is a lens with the same label, replace with new lens
      - if there isn't already a lens with the same label, append the lens
=end

# Load file
# path = "example.txt"
path = "input.txt"
input = File.readlines(path, chomp: true).first.split(",")

# --- Part 1 --- #
# def hash(string)
#   result = 0

#   string.each_char do |char|
#     result += char.ord
#     result *= 17
#     result %= 256
#   end

#   result
# end

# p(input.sum { |string| hash(string) })

# --- Part 2 --- #
class Lens
  attr_reader :label, :focal_length

  def initialize(label, focal_length)
    @label = label
    @focal_length = focal_length.to_i
  end
end

class Box
  attr_reader :number
  attr_accessor :lenses

  def initialize(number)
    @number = number
    @lenses = []
  end

  def perform(operation, lens_details)
    label, focal_length = lens_details

    if operation == "="
      add(label, focal_length)
    else
      remove(label)
    end
  end

  def add(label, focal_length)
    if lenses.any? { |lens| lens.label == label }
      index = lenses.index { |lens| lens.label == label }
      lenses[index] = Lens.new(label, focal_length)
    else
      lenses << Lens.new(label, focal_length)
    end
  end

  def remove(label)
    return unless lenses.any? { |lens| lens.label == label }
    index = lenses.index { |lens| lens.label == label }
    lenses.delete_at(index)
  end

  def focusing_powers
    sum = 0
    lenses.each_with_index do |lens, slot|
      sum += (number + 1) * (slot + 1) * lens.focal_length
    end
    sum
  end
end

class Advent
  attr_reader :sequence
  attr_accessor :boxes

  def initialize(input)
    @sequence = input
    @boxes = []
    256.times do |n|
      @boxes << Box.new(n)
    end
  end

  def solve
    hashmap
    total_focusing_power
  end

  def hashmap
    sequence.each do |step|
      lens = step.split(/[-=]/)
      operation = step.include?("=") ? "=" : "-"

      box = boxes[hash(lens[0])]
      box.perform(operation, lens)
    end
  end

  def total_focusing_power
    total = boxes.sum(&:focusing_powers)

    puts "The total is: #{total}"
  end

  def hash(label)
    result = 0

    label.each_char do |char|
      result += char.ord
      result *= 17
      result %= 256
    end

    result
  end
end

advent = Advent.new(input)
advent.solve
