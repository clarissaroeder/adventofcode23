# Load file
# path = "example.txt"
path = "galaxies.txt"
input = File.readlines(path, chomp: true).map(&:chars)

class GalaxyGraph
  attr_accessor :space_map, :transposed_map, :galaxies, :expansion_factor, :empty_rows, :empty_columns

  GALAXY = "#"

  def initialize(input, expansion_factor)
    @space_map = input
    @transposed_map = space_map.transpose
    @expansion_factor = expansion_factor - 1
    find_empty_rows_and_columns
    assign_numbers_to_galaxies
    construct_galaxy_hash
    expand_galaxy_coordinates
  end

  def sum_shortest_paths
    pairs = []
    galaxies.keys[0..-2].each_with_index do |num1, index|
      galaxies.keys[index + 1..-1].each do |num2|
        pairs <<[num1, num2]
      end
    end

    sum = 0
    pairs.each do |pair|
      sum += find_shortest_path(pair)
    end

    puts "The result is: #{sum}"
  end

  def find_shortest_path(pair)
    # puts "Current pair: #{pair}"

    milky_way_coords = galaxies[pair[0]]
    andromeda_coords = galaxies[pair[1]]

    row_difference = andromeda_coords[0] - milky_way_coords[0]
    column_difference = (andromeda_coords[1] - milky_way_coords[1]).abs
    shortest_path = row_difference + column_difference
  end

  def find_empty_rows_and_columns
    self.empty_rows = []
    space_map.each_with_index do |row, index|
      if !row.include?(GALAXY)
        self.empty_rows << index
      end
    end

    self.empty_columns = []
    transposed_map.each_with_index do |row, index|
      if !row.include?(GALAXY)
        self.empty_columns << index
      end
    end
  end

  def assign_numbers_to_galaxies
    number = 0
    space_map.map! do |row|
      row.map! do |node|
        if node == GALAXY
          number += 1
          number
        else
          node
        end
      end
    end
  end

  def construct_galaxy_hash
    self.galaxies = {}
    space_map.each_with_index do |row, row_index|
      row.each_with_index do |node, column_index|
        if node != "."
          self.galaxies[node] = [row_index, column_index]
        end
      end
    end
  end

  def expand_galaxy_coordinates
    galaxies_copy = galaxies.dup
    galaxies_copy.each do |number, coords|
      empty_rows_before = empty_rows.count { |row| row < coords[0] }
      empty_columns_before = empty_columns.count { |column| column < coords[1] }

      expanded_coords = [coords[0] + empty_rows_before * expansion_factor, coords[1] + empty_columns_before * expansion_factor]
      galaxies[number] = expanded_coords
    end
  end
end

galaxies = GalaxyGraph.new(input, 1000000)
galaxies.sum_shortest_paths
