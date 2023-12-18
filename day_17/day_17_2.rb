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

    # priority queue in form of a heap
    queue = Heap.new{|a, b| a[0] < b[0]}
    visited = Set[]

    # add to queue the first two possible continuations:
    # [heat loss, position, direction moved, number of straight steps]
    queue.add([grid[0][1], [0, 1], :east, 1])
    queue.add([grid[1][0], [1, 0], :south, 1])

    while !queue.empty?
      # break if counter == 5
      heat_loss, current_position, direction_moved, straight_steps = queue.pop

      # states to account for node being visited from different directions
      state = [current_position, direction_moved, straight_steps]
      next if visited.include?(state)
      visited.add(state)

      # break if current is target
      if current_position == target_position && straight_steps >= 4
        puts "The result is #{heat_loss}"
        break
      end

      # find turns when you can
      if straight_steps >= 4
        next_positions = make_turns(current_position, direction_moved)
        next_positions.each do |turn|
          next_position, new_direction = turn
          if in_grid?(next_position)
            next_row, next_column = next_position
            queue.add([heat_loss + grid[next_row][next_column], next_position, new_direction, 1])
          end
        end
      end

      # move straight while you can
      if straight_steps < 10
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
