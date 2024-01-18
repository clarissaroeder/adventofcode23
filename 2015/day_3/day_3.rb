# Load file
path = "input.txt"
instructions = File.readlines(path, chomp: true)[0].chars

directions = { "^" => [-1, 0], ">" => [0, 1], "v" => [1, 0], "<" => [0, -1] }

# Part 1
visited = {}
start = [0, 0]

visited[start] = true

instructions.each do |inst|
  start = start.zip(directions[inst]).map { |x, y| x + y }
  visited[start] = true
end

puts "The result is: #{visited.size}"

# Part 2
visited = {}

santa = [0, 0]
robo_santa = [0, 0]

visited[santa] = true

instructions.each_with_index do |inst, idx|
  if idx.even?
    santa = santa.zip(directions[inst]).map { |x, y| x + y }
    visited[santa] = true
  elsif idx.odd?
    robo_santa = robo_santa.zip(directions[inst]).map { |x, y| x + y }
    visited[robo_santa] = true
  end
end

puts "The result is: #{visited.size}"