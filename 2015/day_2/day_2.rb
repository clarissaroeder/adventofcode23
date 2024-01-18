# Load file
path = "input.txt"
dimensions = File.readlines(path, chomp: true).map { |line| line.split('x').map(&:to_i) }

# Part 1
paper = 0

dimensions.each do |dimension|
  sides = []

  dimension.combination(2) { |x, y| sides << (x * y) }

  sides.each { |side| paper += (2 * side) }
  paper += sides.min
end

puts "The result is: #{paper}"

# Part 2
ribbon = 0

dimensions.each do |dimension|
  dimension = dimension.sort

  ribbon += (2 * dimension[0])
  ribbon += (2 * dimension[1])

  ribbon += dimension.reduce(:*)
end

puts "The result is: #{ribbon}"