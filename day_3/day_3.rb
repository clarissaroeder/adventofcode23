=begin
  ------------- PART 1 -------------
  P
    - Engine schematic has numbers, symbols, and periods
      - A period does not count as a symbol
    - A number is any sequence of digits
      - A number starts/ends after/before a symbol/period

    - A number is a part number of a part of the engine if any of it's digits is
    - horizontally, vertically, or diagonally adjacent to a symbol
    - Goal: sum up all the part numbers

  E
    467..114..      # 114 is not a part
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.      # 58 is not a part
    ..592.....
    ......755.
    ...$.*....
    .664.598..

    - Everthing else is a part number, the sum of which is: 4361

  D
    - Array of strings -> work with the indeces
    - Nested array?

  A
    - Read file into an array of strings, break into a nested array of chars

    - Define a method that computes the sum of all engine parts
      - Input: nested array [rows][columns]
      - Define sum variable and set to 0
      - Iterate over the rows:
        - Define a empty number string
        - Iterate over the columns
          - If the current char is a digit, add it to the number string
          - Else if current char is not a a digit and if number string is not empty, check for adjacent symbols
            - If adjacent symbols are found, add the number string to_i to the sum
            - Reset the number string

          - Edge case last column: if current char is a digit || if the current_number is not empty
          - and the index is the last, check for adjacent symbols
            - If adjacent symbols are found, add the number string to_i to the sum


    Define a helper method that checks if a number is an engine part number (if there are adjacent symbols):
      - Input: input array, row, last index of number, and current number
      - Consider edge cases: first and last row, first column
      - Determine start column: last index of number - (length of number + 1)
        - Edge case: first column: || 0 if that calculation is less than 0

      - Determine the last column: last index of number + 1
        - Edge case last column: || length of row - 1 if that calculation is larger than the row length
      - Loop around the number and check whether a char is a symbol:
        - If it's a symbol, return true

      - Same logic for first and last rows

      - Loop from start row to end row, over start index to last index:
        - If a char is a symbol, return true

      - Return false if no symbol has been found


    Other helpers:
    - A method that checks whether a char is a digit
    - A method that checks whether a char is a symbol

  ---------- PART 2 -------------------
  P
    - A gear is any * that is adjacent to two numbers

  A
    Reuse some of the logic of find_part_sum:
    - Iterate over the input to identify numbers
    - When a number is complete, check if that number has surrounding asterisks and get their coordinates -> helper
    - Store the asterisk coordinates in a hash:
      - For each asterisk coordinate returned for a number:
        - If the current coordinates are not yet a key in the hash, add the coords as key and
          the current number in an array as value
        - If the current coordinates are already a key in the hash, append the current number to the value array

    - When finished identifying numbers, I have a hash that the coordinates of all asterisks as keys, and an array
      of all numbers adjacent to that asterisk as value: potential_gears = {[row, col] => [num1, num2], ... }
    - Filter so only gears are left: select those key-value pairs where the value length is equal to 2
    - Extract the gear ratios -> helper
    - Sum up gear ratios and return

    Helpers:
    - Get asterisk coordinates: reuse some engine_part? logic
      - Identify the bounds of the area to check with edge cases (first and last row and column)
      - For first_row..last_row and for first_index..last_index check whether input[row][col] is an asterisk
      - If yes, add the coordinates to an array
      - Return the coordinates array

    - Get gear ratioas
      - Map over the gears hash
        - For each value, loop over the numbers array:
          - Map each number into an int, then reduce the numbers with *
      - Returns an array with the gear ratios
=end

# Load file
# path = "example_engine.txt"
path = "engine.txt"
engine_schematic = File.readlines(path, chomp: true).map { |line| line.chars }

# --- PART 1 --- #
# Helpers
def is_digit?(char)
  char.match?(/\d/)
end

def is_symbol?(char)
  char.match?(/[^0-9.]/)
end

# Checks for adjacent symbols
def engine_part?(input, row, last_number_index, current_number)
  first_index = [0, (last_number_index - (current_number.size))].max
  last_index = [(input[row].length - 1), (last_number_index + 1)].min

  first_row = [0, (row - 1)].max
  last_row = [(input.length - 1), (row + 1)].min

  input[first_row..last_row].each do |current_row|
    current_row[first_index..last_index].each do |char|
      return true if is_symbol?(char)
    end
  end

  false
end

def find_part_sum(input)
  sum = 0
  numbers = []

  input.each_with_index do |line, row|
    current_number = ""

    line.each_with_index do |char, column|
      if is_digit?(char)
        current_number << char

        if column == (line.length - 1)
          if engine_part?(input, row, column, current_number)
            sum += current_number.to_i
            numbers << current_number.to_i
          end
        end
      elsif !current_number.empty?
        if engine_part?(input, row, column - 1, current_number)
          sum += current_number.to_i
          numbers << current_number.to_i
        end
        current_number = ""
      end
    end
  end

  sum
end

# MAIN
p find_part_sum(engine_schematic)

# --- PART 2 --- #
# Helpers
def get_gear_ratios(gears)
  gears.map do |coords, numbers|
    numbers.map { |num| num.to_i }.reduce(&:*)
  end
end

def get_adjacent_asterisk_coords(input, row, last_number_index, current_number)
  first_index = [0, (last_number_index - (current_number.size))].max
  last_index = [(input[row].length - 1), (last_number_index + 1)].min

  first_row = [0, (row - 1)].max
  last_row = [(input.length - 1), (row + 1)].min

  asterisk_coords = []

  (first_row..last_row).each do |row_number|
    (first_index..last_index).each do |column_number|
      if input[row_number][column_number] == "*"
        asterisk_coords << [row_number, column_number]
      end
    end
  end

  asterisk_coords
end

def add_to_potential_gears(asterisk_coords, potential_gears, current_number)
  if !asterisk_coords.empty?
    asterisk_coords.each do |coords|
      if potential_gears.key?(coords)
        potential_gears[coords] << current_number
      else
        potential_gears[coords] = [current_number]
      end
    end
  end
end

def find_gear_ratio_sum(input)
  numbers = []

  potential_gears = {}

  input.each_with_index do |line, row|
    current_number = ""

    line.each_with_index do |char, column|
      if is_digit?(char)
        current_number << char

        if column == (line.length - 1)
          asterisk_coords = get_adjacent_asterisk_coords(input, row, column, current_number)
          add_to_potential_gears(asterisk_coords, potential_gears, current_number)
        end
      elsif !current_number.empty?
        asterisk_coords = get_adjacent_asterisk_coords(input, row, column - 1, current_number)
        add_to_potential_gears(asterisk_coords, potential_gears, current_number)
        current_number = ""
      end
    end
  end

  gears = potential_gears.select { |coords, numbers| numbers.size == 2 }
  gear_ratios = get_gear_ratios(gears)
  gear_ratios.sum
end

# Main
p find_gear_ratio_sum(engine_schematic)
