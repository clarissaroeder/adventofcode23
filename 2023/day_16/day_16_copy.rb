=begin
P
  - Find the number of tiles in the grid that get "energised"
  - A beam of light starts at the top left corner going rightward
  - / and \ are mirros reflecting light 90° depending on where it comes from
  - | and - are splitters:
    - if entering the pointy end, they pass through
    - if entering the flat, they split in 2
  - . is empty space

D
  - Nested array: matrix of the grid
  - Make a tile class?

A
  - Tile class:
    - Tile type
    - Energised (boolean?)

  - Grid class:
    - matrix of Tiles

  - track_beam(starting row, starting column, direction)

    - start_tile = grid[row][column]
    - push the start tile to the queue

    - loop:
      - define current_tile and set it to start_tile
      - check base cases:
        - return if the current tile = nil (out of bounds)
        - return if the current tile has been visited from current direction

      - energise the current tile
      - set current tile to visited from current direction

      - based on the current tile type, and the current direction:
        determine new direction -> Helper
      - based on the new direction and the current coords (row, column):
        determine the next tile coords -> Helper

      - if the new direction is "split:"
        - call self (track beam) twice for both new beams
          - input: current row and column, and new directions respectively
            - new directions: depend on the current tile type
              - if -: then up and down
              - if |: then left and right
        - return (or break??)
      - else
        - based on the new direction and the current position in the grid:
          determine next coords and save in row and column -> Helper
        - extract next_tile from grid with new coords
          - return if next tile is nil? (out of bounds)
          - has the new tile been visited before from the same direction?
            - if yes:
              - return (loop detected)
            - if not:
              - set current_tile to be next_tile

=end

# Load file
# path = "example.txt"
path = "contraption.txt"
input = File.readlines(path, chomp: true).map(&:chars)

class Tile
  attr_reader :type, :energised, :right, :left, :up, :down

  def initialize(type)
    @type = type
    @energised = false
    @right = false
    @left = false
    @up = false
    @down = false
  end

  def reset
    @energised = false
    @right = false
    @left = false
    @up = false
    @down = false
  end

  def energise
    @energised = true
  end

  def visit(direction)
    case direction
    when "right" then @right = true
    when "left" then @left = true
    when "up" then @up = true
    when "down" then @down = true
    end
  end

  def visited?(direction)
    case direction
    when "right" then right
    when "left" then left
    when "up" then up
    when "down" then down
    end
  end

  def to_s
    type
  end
end

class Advent
  attr_reader :grid

  def initialize(input)
    @grid = input.map { |row| row.map { |type| Tile.new(type) } }
  end

  def reset
    grid.each { |row| row.each(&:reset) }
  end

  def solve
    # Part 1
    # track_beam(0, 0, "right")
    # puts "The result is: #{count_energised}"

    # Part 2
    puts "The result is: #{find_most_energised_tiles}"
  end

  def find_most_energised_tiles
    result = 0
    number_of_rows = grid.size - 1
    number_of_columns = grid[0].size - 1

    (0..number_of_rows).each do |row|
      # from leftmost column to the right
      track_beam(row, 0, "right")
      energised_counter = count_energised
      result = energised_counter if energised_counter > result
      reset

      # from rightmost column to the left
      track_beam(row, number_of_columns, "left")
      energised_counter = count_energised
      result = energised_counter if energised_counter > result
      reset
    end

    (0..number_of_columns).each do |col|
      # from topmost row down
      track_beam(0, col, "down")
      energised_counter = count_energised
      result = energised_counter if energised_counter > result
      reset

      # from bottommost row up
      track_beam(number_of_rows, col, "up")
      energised_counter = count_energised
      result = energised_counter if energised_counter > result
      reset
    end

    result
  end

  def count_energised
    grid.flatten.count { |tile| tile.energised == true }
  end

  def track_beam(row, column, direction)
    current_tile = grid[row][column]

    loop do
      return if current_tile.nil?                # base case 1: out of bounds
      return if current_tile.visited?(direction) # base case 2: loop detected

      current_tile.energise
      current_tile.visit(direction)

      direction = find_next_direction(current_tile.type, direction)

      if direction == "split"
        new_directions = split_directions(current_tile.type)
        track_beam(row, column, new_directions[0])
        track_beam(row, column, new_directions[1])
        return                                   # base case 3: split into two
      else
        row, column = find_next_coords(row, column, direction)

        valid_tile = (0..(grid.size - 1)).include?(row) &&
                     (0..(grid[0].size - 1)).include?(column)

        next_tile = valid_tile ? grid[row][column] : nil
        current_tile = next_tile
      end
    end
  end

  def split_directions(type)
    case type
    when "|" then ["up", "down"]
    when "-" then ["left", "right"]
    end
  end

  def find_next_coords(row, column, direction)
    case direction
    when "right" then [row, column + 1]
    when "left" then [row, column - 1]
    when "up" then [row - 1, column]
    when "down" then [row + 1, column]
    end
  end

  def find_next_direction(type, direction)
    case type
    when "." then direction
    when "/"
      case direction
      when "right" then "up"
      when "left" then "down"
      when "up" then "right"
      when "down" then "left"
      end
    when "\\"
      case direction
      when "right" then "down"
      when "left" then "up"
      when "up" then "left"
      when "down" then "right"
      end
    when "|"
      case direction
      when "up" then "up"
      when "down" then "down"
      else
        "split"
      end
    when "-"
      case direction
      when "right" then "right"
      when "left" then "left"
      else
        "split"
      end
    end
  end
end

advent = Advent.new(input)
advent.solve
