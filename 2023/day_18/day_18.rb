=begin
P
  - given a set of digging directions, draw the hole to be dug in a graph
  - calculate the surface area

  - bfs, but draw your own graph?
  - give the nodes a colour variable

#######
#.....#
###...#
..#...#
..#...#
###.###
#...#..
##..###
.#....#
.######


=end

# Load file
# path = "example.txt"
path = "plan.txt"
input = File.readlines(path, chomp: true).map(&:split)

GROUND = "."
TRENCH = "#"

class Graph
  attr_accessor :grid, :total_steps
  attr_reader :input, :coordinates

  def initialize(input)
    @input = input
    @grid = [[TRENCH]]
    @coordinates = [[0, 0]]
    @total_steps = 0
  end

  def solve
    # Part 1
    # draw_trench
    # pad_grid
    # flood
    # puts "The result is: #{count}"

    # Part 2
    calculate_coordinates
    shoelace
  end

  def shoelace
    sum = 0

    (0..coordinates.size - 2).each do |index|
      va = coordinates[index]
      vb = coordinates[index + 1]

      sum += (va[0] * vb[1]) - (vb[0] * va[1])
    end

    area = (sum.abs) / 2

    inner_area = area - ((total_steps) / 2) + 1
    puts "The result is: #{inner_area + total_steps}"
  end

  def calculate_coordinates
    current_row, current_col = coordinates[0]

    counter = 0
    input.each do |instruction|

      _, _, colour = instruction
      direction, steps = convert(colour)
      self.total_steps += steps

      case direction
      when "R"
        # (1..steps).each { |i| coordinates << [current_row, current_col + i] }
        current_col += steps
        coordinates << [current_row, current_col]
      when "L"
        # (1..steps).each { |i| coordinates << [current_row, current_col - i] }
        current_col -= steps
        coordinates << [current_row, current_col]
      when "D"
        # (1..steps).each { |i| coordinates << [current_row + i, current_col] }
        current_row += steps
        coordinates << [current_row, current_col]
      when "U"
        # (1..steps).each { |i| coordinates << [current_row - i, current_col] }
        current_row -= steps
        coordinates << [current_row, current_col]
      end

      counter += 1
    end
  end

  def convert(colour)
    steps = colour[2..-3].hex
    direction = case colour[-2]
    when "0" then "R"
    when "1" then "D"
    when "2" then "L"
    when "3" then "U"
    end
    [direction, steps]
  end

  def count
    counter = 0
    grid.each do |row|
      row.each { |node| counter += 1 if node == TRENCH }
    end
    counter
  end

  def flood
    queue = []
    bfs_start = [0, 0]

    queue.push(bfs_start)

    while !queue.empty?
      current_row, current_col = queue.shift

      if grid[current_row][current_col] == GROUND
        grid[current_row][current_col] = "0"
        neighbours = find_neighbours(current_row, current_col)
        neighbours.each { |neighbour| queue << neighbour if grid[neighbour[0]][neighbour[1]] == GROUND }
      end
    end

    grid.map! do |row|
      row.map! { |node| node == "0" ? GROUND : TRENCH }
    end
  end

  def find_neighbours(row, column)
    offsets = [[-1, -1], [-1, 0], [-1, 1],
               [0, -1], [0, 1],
               [1, -1], [1, 0], [1, 1]]

    neighbours = []

    offsets.each do |dr, dc|
      new_row,  new_col = row + dr, column + dc
      neighbours << [new_row, new_col] if in_grid?(new_row, new_col)
    end

    neighbours
  end

  def in_grid?(row, column)
    (0..grid.size - 1).include?(row) && (0..grid[0].size - 1).include?(column)
  end

  def pad_grid
    columns = grid[0].size
    rows = grid.size

    grid.prepend(Array.new(columns, GROUND))
    grid.each { |row| row << GROUND }
    grid << Array.new(columns + 1, GROUND)
    grid.each { |row| row.prepend(GROUND) }
  end

  def draw_trench
    current_row = 0
    current_column = 0

    counter = 0
    input.each do |instruction|
      direction, steps, colour = instruction
      steps = steps.to_i

      case direction
      when "R"
        # expand if necessary
        if (current_column + steps) > (grid[current_row].size - 1)
          diff = (current_column + steps) - (grid[current_row].size - 1)
          grid.each { |row| diff.times { row << GROUND } }
        end

        # draw trenches
        ((current_column + 1)..(current_column + steps)).each do |col_index|
          grid[current_row][col_index] = TRENCH
        end

        current_column += steps
      when "L"
        # expand if necessary
        if current_column - steps < 0
          diff = (current_column - steps).abs
          grid.each { |row| diff.times { row.prepend(GROUND) } }

          # draw trenches
          (0..(steps - 1)).each do |col_index|
            grid[current_row][col_index] = TRENCH
          end

          current_column = 0
        else
          # draw trenches
          ((current_column - steps)..(current_column - 1)).each do |col_index|
            grid[current_row][col_index] = TRENCH
          end

          current_column -= steps
        end
      when "U"
        # expand if necessary
        if current_row - steps < 0
          diff = (current_row - steps).abs
          diff.times { grid.prepend(Array.new(grid[current_row].size, GROUND)) }

          (0..(steps - 1)).each do |row_index|
            grid[row_index][current_column] = TRENCH
          end

          current_row = 0
        else
          # draw trenches
          ((current_row - steps)..(current_row - 1)).each do |row_index|
            grid[row_index][current_column] = TRENCH
          end

          current_row -= steps
        end
      when "D"
        # expand if necessary
        if (current_row + steps) > grid.size - 1
          diff = (current_row + steps) - (grid.size - 1)
          diff.times { grid << Array.new(grid[current_row].size, GROUND) }
        end

        # draw trenches
        ((current_row + 1)..(current_row + steps)).each do |row_index|
          grid[row_index][current_column] = TRENCH
        end

        current_row += steps
      end
      counter += 1
    end
  end

  def print_grid
    output = grid.map { |row| row.join }.join("\n")
    File.open("output.txt", "w") do |file|
      file.write(output)
    end
  end
end

advent = Graph.new(input)
advent.solve
# advent.print_grid
