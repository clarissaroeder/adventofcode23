# Load file
path = "input.txt"
instructions = File.readlines(path, chomp: true)

class Advent
  attr_accessor :grid, :instructions

  def initialize(instructions)
    setup_grid
    @instructions = instructions
  end

  def solve
    execute_instructions
    print_grid

    result = 0
    grid.each do |row|
      # result += row.count(1)
      result += row.sum
    end
    puts "The result is: #{result}"
  end

  def execute_instructions
    instructions.each do |instruction|
      action, coords = read(instruction)

      case action
      when :on
        turn_on(coords)
      when :off
        turn_off(coords)
      when :toggle
        toggle(coords)
      end
    end
  end

  def turn_on(coords)
    coords1, coords2 = coords

    (coords1[0]..coords2[0]).each do |row|
      (coords1[1]..coords2[1]).each do |col|
        # grid[row][col] = 1
        grid[row][col] += 1
      end
    end
  end

  def turn_off(coords)
    coords1, coords2 = coords

    (coords1[0]..coords2[0]).each do |row|
      (coords1[1]..coords2[1]).each do |col|
        # grid[row][col] = 0
        grid[row][col] = [(grid[row][col] - 1), 0].max
      end
    end
  end

  def toggle(coords)
    coords1, coords2 = coords

    (coords1[0]..coords2[0]).each do |row|
      (coords1[1]..coords2[1]).each do |col|
        # grid[row][col] = grid[row][col] == 0 ? 1 : 0
        grid[row][col] += 2
      end
    end
  end

  def read(instruction)
    action = case
             when instruction.include?("on") then :on
             when instruction.include?("off") then :off
             when instruction.include?("toggle") then :toggle
             end
    
    coords = instruction.scan(/\d+/)
    coords.map!(&:to_i)

    [action, [coords[0, 2], coords[2, 2]]]
  end

  def setup_grid
    row = []
    1000.times { row << 0 }

    @grid = []
    1000.times { @grid << row.dup }
  end

  def print_grid
    output = grid.map { |row| row.join }.join("\n")
    File.open("light_grid.txt", "w") do |file|
      file.write(output)
    end
  end
end

advent = Advent.new(instructions)
advent.solve