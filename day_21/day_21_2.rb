# Load file
# path = "example.txt"
# path = "expanded_example.txt"
path = "garden.txt"
# path = "expanded_garden.txt"
input = File.readlines(path, chomp: true).map(&:chars)

class Advent
  attr_accessor :grid

  GROUND = "."
  ROCK = "#"
  START = "S"
  STEP = "O"

  def initialize(input)
    @grid = input
  end

  def print_grid
    grid.each do |row|
      puts row.join
    end
  end

  def solve(num)

    plots_reached = [0]
    (1..num).each do |n|
      trace_steps(n)
      plots_reached << grid.join.count(STEP) if n % 2 == 0
    end

    p plots_reached

    growth = []
    (1..plots_reached.size - 1).each do |i|
      growth << plots_reached[i] - plots_reached[i - 1]
    end

    puts
    p growth

    # trace_steps(num)

    output = grid.map { |row| row.join }.join("\n")
    File.open("output.txt", "w") do |file|
      file.write(output)
    end

    puts "The result is: #{grid.join.count(STEP)}"
  end

  def trace_steps(n)
    queue = []

    bfs_start = [[(grid.size / 2), (grid.size / 2)], 0]

    queue.push(bfs_start)

    visited = {}

    while !queue.empty?
      coordinates, steps = queue.shift
      current_row, current_col = coordinates

      break if steps > n

      if grid[current_row][current_col] != ROCK && !visited[coordinates]
        grid[current_row][current_col] = STEP if steps % 2 == 0
        visited[coordinates] = true

        neighbours = find_neighbours(current_row, current_col)
        neighbours.each { |neighbour| queue.push([neighbour, steps + 1]) }
      end
    end
  end

  def find_neighbours(row, col)
    offsets = [[-1, 0], [0, -1], [0, 1], [1, 0]]

    neighbours = []

    offsets.each do |dr, dc|
      new_row, new_col = row + dr, col + dc
      neighbours << [new_row, new_col] if in_grid?(new_row, new_col)
    end

    neighbours
  end

  def in_grid?(row, col)
    (0..grid.size - 1).include?(row) && (0..grid[0].size - 1).include?(col)
  end

end

advent = Advent.new(input)

advent.solve(100)

# grid = input.map do |row|
#   row * 100
# end

# grid *= 10

# output = grid.map { |row| row.join }.join("\n")
# File.open("expanded_garden.txt", "w") do |file|
#   file.write(output)
# end
