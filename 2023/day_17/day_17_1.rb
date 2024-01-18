=begin
P
  - find the path with the smallest heat loss from a source to target
  - the value of an element represents how much heat loss occurs upon "entering" that node

D
  - Graph class
  - Node class: heat_loss, position ??

A
  -> modify dijkstra for step restrictions

  - identify source and target node
  - define an empty priority queue (heap), that will return the node with the lowest heat_loss
  - define an empty visited set

  - add the first two possible steps to the queue (the neighbours of source)
    -> what to add to the queue: some sort of state as dijkstra normally doesn't track state???
      -> the current heat loss accumulation, the current position, the direction in which
         was moved, and number of straight steps

  - while the queue is not empty:
    - set a current variable to the first element in the queue
    - capture the current state: allow nodes at the current position to be revisited but
      from different directions/at different step numbers
    - if current state is in visited: skip to next iteration
    - add current state to visited

    - if current node == target node: break and print result

    - find the next possible steps:
      - every node can always turn: find 90 degree positions

      - if steps < 3: find next straight ahead position
      - no backwards position!

      - add next possible steps to queue: add the current heat loss to the heat loss a
=end

require "set"
require "rb_heap"

# Load file
# path = "example.txt"
path = "citymap.txt"
input = File.readlines(path, chomp: true).map(&:chars).map { |row| row.map(&:to_i) }

class Graph
  attr_reader :grid, :rows, :columns

  def initialize(input)
    @grid = input
    @rows = grid.size - 1
    @columns = grid[0].size - 1
  end

  def solve
    target_position = [rows, columns]

    queue = Heap.new{|a, b| a[0] < b[0]}
    visited = Set[]

    # [heat loss, position, direction moved, number of straight steps]
    queue.add([grid[0][1], [0, 1], :east, 1])
    queue.add([grid[1][0], [1, 0], :south, 1])

    while !queue.empty?
      heat_loss, current_position, direction_moved, straight_steps = queue.pop

      state = [current_position, direction_moved, straight_steps]
      next if visited.include?(state)
      visited.add(state)

      if current_position == target_position
        puts "The result is #{heat_loss}"
        break
      end

      # every node can always turn: find turns
      next_positions = make_turns(current_position, direction_moved)
      next_positions.each do |turn|
        next_position, new_direction = turn
        if in_grid?(next_position)
          next_row, next_column = next_position
          queue.add([heat_loss + grid[next_row][next_column], next_position, new_direction, 1])
        end
      end

      # move straight if you can
      if straight_steps < 3
        next_position = go_straight(current_position, direction_moved)
        if in_grid?(next_position)
          next_row, next_column = next_position
          queue.add([heat_loss + grid[next_row][next_column], next_position, direction_moved, straight_steps + 1])
        end
      end
    end
  end

  def go_straight(position, direction_moved)
    case direction_moved
    when :south then [position[0] + 1, position[1]]
    when :north then [position[0] - 1, position[1]]
    when :east then [position[0], position[1] + 1]
    when :west then [position[0], position[1] - 1]
    end
  end

  def make_turns(position, direction_moved)
    case direction_moved
    when :south, :north
      [[[position[0], position[1] - 1], :west], [[position[0], position[1] + 1], :east]]
    when :east, :west
      [[[position[0] - 1, position[1]], :north], [[position[0] + 1, position[1]], :south]]
    end
  end

  def in_grid?(position)
    (0..rows).include?(position[0]) && (0..columns).include?(position[1])
  end
end

# Main
advent = Graph.new(input)
advent.solve
