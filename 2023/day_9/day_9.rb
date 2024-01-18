# Load file
# path = "example_oasis.txt"
path = "oasis.txt"
input = File.readlines(path, chomp: true).map { |line| line.split.map(&:to_i) }

=begin
  P
    Input: lines of integers, representing a history of a value
    Objective: extrapolate what the next value in that sequence should be (for each line of integers)
    Output: the sum of all the extrapolated numbers

    - Negative numbers: take absolute numbers

  E
    0 3 6 9 12 15 ->

    0   3   6   9  12  15  18
    3   3   3   3   3   3
    0   0   0   0   0

  D
    - Input: nested array: each inner array represents one line (the history of one value) and  has a number of integers
    - In between: for every line, you need a number of new arrays holding the difference values between two numbers above

  A
    - Define an empty "differences" array
    - Iterate over the history:
      - Calculate the difference between two adjacent values
      - Append that value to the differences array
    - Repeat with the newly generated set of differences, unless these are all 0


  Notes:
    - currently not transforming any negative numbers... taking the difference from [index + 1] - [index]
=end

class History
  attr_accessor :differences, :next_value, :previous_value

  def initialize(history)
    @differences = []
    find_differences(history)
    extrapolate_next_value
    extrapolate_previous_value
  end

  def extrapolate_previous_value
    (0..(differences.size - 1)).each do |index|
      if index == 0
        differences[0].unshift(0)
      else
        value = differences[index].first - differences[index - 1].first
        differences[index].unshift(value)
      end
    end

    self.previous_value = differences[-1].first
  end

  def extrapolate_next_value
    (0..(differences.size - 1)).each do |index|
      if index == 0
        differences[0] << 0
      else
        differences[index] << differences[index - 1].last + differences[index].last
      end
    end

    self.next_value = differences[-1].last
  end

  def find_differences(history)
    self.differences << history
    sequence = history
    temp = []

    (0..(history.size - 2)).each do |index|
      temp << sequence[index + 1] - sequence[index]
    end

    if temp.all? { |num| num.zero? }
      self.differences << temp
      self.differences = differences.reverse
    else
      find_differences(temp)
    end
  end
end

class Oasis
  attr_accessor :report

  def initialize(input)
    get_report(input)
  end

  def get_report(input)
    @report = []
    input.each { |history| @report << History.new(history)}
  end

  def sum_next_values
    values = report.map { |history| history.next_value }
    sum = values.reduce { |sum, value| sum += value }
    puts "The result is: #{sum}"
  end

  def sum_previous_values
    values = report.map { |history| history.previous_value }
    sum = values.reduce { |sum, value| sum += value }
    puts "The result is: #{sum}"
  end
end

oasis = Oasis.new(input)
oasis.sum_next_values
oasis.sum_previous_values
