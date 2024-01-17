# Load file
# path = "example.txt"
path = "input.txt"
input = File.readlines(path, chomp: true).map(&:chars)

=begin
- Start tile: top row single path tile
- Goal: single path tile in bottom row
- If stepping on a slope, you must go in that direction (<, >, v)
- Never step on the same tile twice
- Find the longest path

=end

class Advent
  attr_accessor :grid, :graph, :start, :destination, :dfs_visited

  PATH = "."
  FOREST = "#"

  def initialize(input)
    @grid = input
    @dfs_visited = {}
  end

  def dfs(point)
    return 0 if point == destination

    m = -Float::INFINITY

    dfs_visited[point] = true
    graph[point].each do |next_point, length|
      m = [m, dfs(next_point) + length].max

    end
    dfs_visited.delete(point)

    return m
  end

  def find_longest_path
    queue = []

    @start = [0, grid[0].index(PATH)]
    @destination = [grid.size - 1, grid[-1].index(PATH)]

    decision_points = [start, destination]

    # find points in graph where you can go at least 2 ways
    grid.each_with_index do |row, row_index|
      row.each_with_index do |char, col_index|
        next if char == FOREST
        neighbours = find_neighbours(row_index, col_index)
        decision_points << [row_index, col_index] if neighbours.size >= 3
      end
    end

    # draw a graph: for each poi connecting pois and the length to there are stored
    @graph = decision_points.each_with_object({}) { |point, graph| graph[point] = {} }

    #
    decision_points.each do |start_row, start_col|
      stack = [[0, start_row, start_col]]
      visited = {[start_row, start_col] => true}

      while !stack.empty?
        n, row, col = stack.pop

        if n != 0 && decision_points.include?([row, col])
          graph[[start_row, start_col]][[row, col]] = n
          next
        end

        find_neighbours(row, col).each do |new_row, new_col|

          if !visited[[new_row, new_col]]
            stack.push([n + 1, new_row, new_col])
            visited[[new_row, new_col]] = true

          end
        end
      end
    end

    puts "The result is: #{dfs(start)}"
  end

  def find_neighbours(row, col)
    neighbours = []

    offsets = {
      "^" => [[-1, 0]],
      "v" => [[1, 0]],
      "<" => [[0, -1]],
      ">" => [[0, 1]],
      "." => [[-1, 0], [1, 0], [0, -1], [0, 1]]
    }

    offsets[grid[row][col]].each do |dr, dc|
      new_row, new_col = row + dr, col + dc
      neighbours << [new_row, new_col] if in_grid?(new_row, new_col) && grid[new_row][new_col] != FOREST
    end

    # offsets = [[-1, 0], [0, -1], [0, 1], [1, 0]]

    # offsets.each do |dr, dc|
    #   new_row, new_col = row + dr, col + dc
    #   neighbours << [new_row, new_col] if in_grid?(new_row, new_col) && grid[new_row][new_col] != FOREST
    # end

    neighbours
  end

  def in_grid?(row, col)
    (0..grid.size - 1).include?(row) && (0..grid[0].size - 1).include?(col)
  end
end

advent = Advent.new(input)
advent.find_longest_path
