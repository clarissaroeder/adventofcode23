# --- HELPERS --- #
def is_digit?(char)
  char.match?(/\d/)
end

def get_symbols(input)
  symbols = []
  input.each do |line|
    line.each_char do |char|
      next if symbols.include?(char)
      symbols << char if char.match?(/[^0-9.]/)
    end
  end
  symbols
end

def get_numbers(input)
  numbers = []
  number = ""
  input.each do |line|
    line.chars.each do |char|
      number << char if is_digit?(char)

      if !is_digit?(char)
        numbers << number if number.size > 0
        number = ""
      end
    end
  end
  numbers
end

def gear?(slice)
  digits = []
  slice.each do |char|
    digits << char if is_digit?(char)
  end

  digits.count >= 2
end


# --- MAIN --- #
path = "example_engine.txt"
# path = "engine.txt"

input = File.readlines(path, chomp: true)

LINE_LENGTH = input[0].size
INPUT_LENGTH = input.size
SYMBOLS = get_symbols(input)
NUMBERS = get_numbers(input)

input.each_with_index do |line, line_number|
  line.chars.each_with_index do |char, index|
    if char == "*"
      start_index = [0, index - 1].max
      end_index = [LINE_LENGTH - 1, index + 1].min

      start_line = [0, (line_number - 1)].max
      end_line = [INPUT_LENGTH - 1, (line_number + 1)].min

      slice_to_check = input[start_line][start_index..end_index] + input[line_number][start_index..end_index] + input[end_line][start_index..end_index]

      if gear?(slice_to_check)

        if is_digit?(line[start_index])
          # if the number before the * is a digit, traverse backwards to find the number
        end


      end
    end
  end
end
