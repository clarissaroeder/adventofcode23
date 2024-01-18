# Load file
# path = "example.txt"
path = "input.txt"
input = File.readlines(path, chomp: true)

Brick = Struct.new(:x1, :y1, :z1, :x2, :y2, :z2)

class Advent
  attr_accessor :bricks, :grid, :bricks_above, :bricks_below

  def initialize(input)
    @input = input
  end

  def solve
    brick_setup
    populate_grid
    settle_bricks
    count_safely_removables
    count_fallen_bricks
  end

  def count_fallen_bricks
    sum = bricks.sum do |brick|
      fallen = [brick]
      queue = bricks_above[brick]

      while !queue.empty?
        current = queue.shift

        next if fallen.include?(current)
        next unless (bricks_below[current].all? { |below| fallen.include?(below) })
        fallen << current

        above_current = bricks_above[current]
        above_current.each { |above| queue << above }
      end

      fallen.size - 1
    end

    puts "The result is: #{sum}"
  end

  def count_safely_removables
    # {brick: [all points above it that are occupied by another brick]}
    @bricks_above = {}
    bricks.each do |brick|
      above = get_all_coordinates(*brick).map do |x, y, z|
        grid[[x, y, z + 1]] if above_occupied?(x, y, z, brick)
      end.compact.uniq # uniq because the same brick might be counted twice or more if more than 1 cube is stacked over the current brick

      bricks_above[brick] = above
    end

    # {brick: [all points below it that are occupied by another brick]}
    @bricks_below = {}
    bricks.each do |brick|
      below = get_all_coordinates(*brick).map do |x, y, z|
        grid[[x, y, z - 1]] if below_occupied?(x, y, z, brick)
      end.compact.uniq

      bricks_below[brick] = below
    end

    # find all bricks which only have bricks above them that have at least 2 below them
    safe_to_remove = bricks.select do |brick|
      bricks_above[brick].all? { |brick_above| bricks_below[brick_above].size > 1 }
    end

    puts "The result is #{safe_to_remove.size}"
  end

  def settle_bricks
    bricks.each do |brick|
      until brick.z1 == 1
        coordinates = get_all_coordinates(*brick)
        break if coordinates.any? { |coord| below_occupied?(*coord, brick) }

        # update coordinate grid
        coordinates.each do |x, y, z|
          grid.delete([x, y, z])
          grid[[x, y, z - 1]] = brick
        end

        # update brick
        brick.z1 -= 1
        brick.z2 -= 1
      end
    end

  end

  def above_occupied?(x, y, z, brick)
    !grid[[x, y, z + 1]].nil? && grid[[x, y, z + 1]] != brick
  end

  def below_occupied?(x, y, z, brick)
    !grid[[x, y, z - 1]].nil? && grid[[x, y, z - 1]] != brick
  end

  def get_all_coordinates(x1, y1, z1, x2, y2, z2)
    coordinates = []

    (x1..x2).each do |x|
      (y1..y2).each do |y|
        (z1..z2).each { |z| coordinates << [x, y, z] }
      end
    end

    coordinates
  end

  def brick_setup
    @bricks = []

    @input.each do |line|
      x1, y1, z1, x2, y2, z2 = line.split(/~|,/).map(&:to_i)
      bricks << Brick.new(x1, y1, z1, x2, y2, z2)
    end

    bricks.sort_by!(&:z1)
  end

  def populate_grid
    @grid = {}

    bricks.each do |brick|
      get_all_coordinates(*brick).each { |coords| grid[coords] = brick }
    end
  end
end

advent = Advent.new(input)
advent.solve
