# Load file
# path = "example.txt"
path = "maps.txt"
input = File.readlines(path, chomp: true)

def parse_input(input)
  directions = input[0]
  nodes = {}

  input[2..-1].each do |node|
    origin, destinations = node.split(" = ")
    destinations = destinations[1..-2].split(", ")
    nodes[origin] = destinations
  end

  [directions, nodes]
end

# --- PART 1 --- #
START = 'AAA'
GOAL = 'ZZZ'

def find_number_of_steps(directions, nodes)
  counter = 0
  next_node = START

  while next_node != GOAL
    direction = directions[counter % directions.size ]

    next_node = case direction
                when "R" then nodes[next_node][1]
                when "L" then nodes[next_node][0]
                end

    counter += 1
  end

  counter
end

# --- PART 2 --- #
# def traverse_nodes(directions, nodes, start_nodes, counter)
#   next_nodes = []

#   if counter == directions.size
#     directions += directions
#   end

#   direction = directions[counter]

#   start_nodes.each do |origin|
#     # puts "origin: #{origin}"
#     # puts "connections: #{nodes}"
#     next_node = case direction
#                 when "R" then nodes[origin][1]
#                 when "L" then nodes[origin][0]
#                 end

#     next_nodes << next_node
#   end

#   if next_nodes.all? { |node| node.end_with?('Z') }
#     counter += 1
#     return counter
#   else
#     traverse_nodes(directions, nodes, next_nodes, counter + 1)
#   end
# end

def find_number_of_steps(directions, nodes, start_node)
  counter = 0
  next_node = start_node

  while !next_node.end_with?('Z')
    direction = directions[counter % directions.size]

    next_node = case direction
                when "R" then nodes[next_node][1]
                when "L" then nodes[next_node][0]
                end

    counter += 1
  end

  counter
end

def find_lcm(directions, nodes)
  start_nodes = nodes.keys.select { |node| node.end_with?('A') }

  steps = []

  start_nodes.each do |start|
    steps << find_number_of_steps(directions, nodes, start)
  end

  result = steps.first

  (1..(steps.size - 1)).each do |idx|
    p steps[idx]
    result = result.lcm(steps[idx])
  end

  result
end

# Main
directions, nodes = parse_input(input)
p find_lcm(directions, nodes)
