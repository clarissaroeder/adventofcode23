# Load file
# path = "example.txt"
path = "pipes.txt"
input = File.readlines(path, chomp: true).map(&:chars)

class Tile
  attr_reader :row, :column, :position
  attr_accessor :connecting_positions, :pipe, :pipe_loop

  def initialize(pipe, row, column)
    @pipe = pipe
    @position = [row, column]
    @row = row
    @column = column
  end

  def find_connecting_positions
    self.connecting_positions = case pipe
                                when "|" then [[row - 1, column], [row + 1, column]] # [north, south]
                                when "-" then [[row, column - 1], [row, column + 1]] # [west, east]
                                when "L" then [[row - 1, column], [row, column + 1]] # [north, east]
                                when "J" then [[row - 1, column], [row, column - 1]] # [north, west]
                                when "7" then [[row + 1, column], [row, column - 1]] # [south, west]
                                when "F" then [[row + 1, column], [row, column + 1]] # [south, east]
                                else
                                  []
                                end
  end
end

class Map
  attr_accessor :tiles, :start_tile, :expanded_tiles, :start_position

  def initialize(input)
    draw_tiles(input)
    @start_tile = tiles.select { |tile| tile.pipe == "S" }.first
    @start_position = @start_tile.position
  end

  def count_enclosed_tiles
    counter = 0
    tiles.each do |tile|
      if tile.pipe == "."
        expanded_counterpart = expanded_tiles[[tile.row * 3 + 1, tile.column * 3 + 1]]
        counter += 1 if expanded_counterpart.pipe == "."
      end
    end

    puts "Part 2 result is: #{counter}"
  end

  def flood
    queue = []
    bfs_start = expanded_tiles[[0, 0]]

    queue.push(bfs_start)
    # puts "Queue: #{queue}"

    while !queue.empty?
      current = queue.shift
      # p current
      if current.pipe == "."
        current.pipe = "X"
        neighbours = find_neighbours(current)
        # puts "neighbours: #{neighbours}"
        neighbours.each { |neighbour| queue.push(neighbour) if neighbour.pipe == "." }
        # puts "queue: #{queue}"
        # break
      end
    end
  end

  def find_neighbours(tile)
    neighbours = []

    # above
    if tile.row - 1 >= 0
      neighbours << expanded_tiles[[tile.row - 1, tile.column]]
      # neighbours << expanded_tiles.select { |t| t.position == [tile.row - 1, tile.column]}.first
    end

    # below
    if tile.row + 1 <= (tiles.last.row * 3 + 2)
      neighbours << expanded_tiles[[tile.row + 1, tile.column]]
      # neighbours << expanded_tiles.select { |t| t.position == [tile.row + 1, tile.column]}.first
    end

    # left
    if tile.column - 1 >= 0
      neighbours << expanded_tiles[[tile.row, tile.column - 1]]
      # neighbours << expanded_tiles.select { |t| t.position == [tile.row, tile.column - 1]}.first
    end

    # right
    if tile.column + 1 <= (tiles.last.column * 3 + 2)
      neighbours << expanded_tiles[[tile.row, tile.column + 1]]
      # neighbours << expanded_tiles.select { |t| t.position == [tile.row, tile.column + 1]}.first
    end

    p tile if neighbours.any? { |neighbour| neighbour.nil? }

    neighbours
  end

  def expand_tiles
    self.expanded_tiles = {}

    tiles.each do |tile|
      expand(tile)
      # break if expanded_tiles.size == 2
    end

    puts "Expanded size: #{expanded_tiles.keys.size}"

    (0...420).each do |i|
      (0...420).each do |j|
        p "missing #{i} #{j}" if expanded_tiles[[i, j]].nil?
      end
    end
  end

  def expand(tile)
    expanded_rows = (tile.row * 3..((tile.row * 3) + 2)).to_a
    expanded_columns = (tile.column * 3..((tile.column * 3) + 2)).to_a

    # If not part of the loop, i.e. a ".", return 9 "."-tiles
    if !tile.pipe_loop
      expanded_rows.each do |row|
        expanded_columns.each do |column|
          new_tile = Tile.new(".", row, column)
          self.expanded_tiles[new_tile.position] = new_tile
        end
      end
    # If part of the loop, check what pipe it is
    else
      if tile.pipe == "-"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      elsif tile.pipe == "|"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      elsif tile.pipe == "F"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("F", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      elsif tile.pipe == "7"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("7", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      elsif tile.pipe == "L"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("L", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      elsif tile.pipe == "J"
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("|", expanded_rows[0], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[0], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("-", expanded_rows[1], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new("J", expanded_rows[1], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[1], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[0])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[1])
        self.expanded_tiles[new_tile.position] = new_tile
        new_tile = Tile.new(".", expanded_rows[2], expanded_columns[2])
        self.expanded_tiles[new_tile.position] = new_tile
      end
    end
  end

  def draw_tiles(input)
    @tiles = []

    input.each_with_index do |pipes, row|
      pipes.each_with_index do |pipe, column|
        self.tiles << Tile.new(pipe, row, column)
      end
    end
  end

  def replace_start_with_pipe
    idx = tiles.find_index(start_tile)
    tiles[idx].pipe = "|"
  end

  def remove_disconnected_pipes
    trace_loop
    tiles.each do |tile|
      tile.pipe = "." if !tile.pipe_loop
    end
  end

  def trace_loop
    start_tile.pipe_loop = true

    current_tile = find_connecting_tile
    previous_position = start_tile.position
    counter = 1

    loop do
      current_tile.pipe_loop = true
      current_tile.find_connecting_positions
      # puts "Current position: #{current_tile.position}  Connecting: #{current_tile.connecting_positions}"
      next_position = current_tile.connecting_positions.select { |position| position != previous_position }.first

      # puts "Next position: #{next_position}"
      previous_position = current_tile.position
      current_tile = tiles.select { |tile| tile.position == next_position }.first
      counter += 1

      break if current_tile == start_tile
    end

    puts "The result is: #{counter / 2}"
  end

  def find_connecting_tile
    surrounding_tiles = []

    number_of_rows = tiles.last.row
    number_of_columns = tiles.last.column

    if start_tile.row > 0
      tile = tiles.select { |tile| tile.row == (start_tile.row - 1) && tile.column == start_tile.column }.first
      surrounding_tiles << tile
    end

    if start_tile.row < number_of_rows
      tile = tiles.select { |tile| tile.row == (start_tile.row + 1) && tile.column == start_tile.column }.first
      surrounding_tiles << tile
    end

    if start_tile.column > 0
      tile = tiles.select { |tile| tile.row == start_tile.row && tile.column == (start_tile.column - 1) }.first
      surrounding_tiles << tile
    end

    if start_tile.column < number_of_columns
      tile = tiles.select { |tile| tile.row == start_tile.row && tile.column == (start_tile.column + 1) }.first
      surrounding_tiles << tile
    end

    surrounding_tiles.each { |tile| tile.find_connecting_positions }
    start_tile_connections = surrounding_tiles.select { |tile| tile.connecting_positions.include?(start_tile.position)}
    start_tile.connecting_positions = start_tile_connections.map { |tile| tile.position }
    start_tile_connections.first
  end

  def print_tiles
    number_of_columns = tiles.last.column

    # puts "Start tile: #{start_tile.position}"
    # puts "Connecting: #{start_tile.connecting_positions}"
    puts
    tiles.each do |tile|
      print tile.pipe
      if tile.column == number_of_columns
        puts
      end
    end
  end
end

# Main
map = Map.new(input)
map.remove_disconnected_pipes
map.replace_start_with_pipe
map.expand_tiles
map.flood
map.print_tiles
map.count_enclosed_tiles
