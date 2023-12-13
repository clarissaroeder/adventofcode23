=begin
P
  - Find the mirror: count number of rows above/to the left of the mirror
    - Mirror will always be between two lines
    - Mirror will never be on the edge (before first line or after last)
    - There will only ever be one valid mirror either horizontally or vertically

A
  - For every pattern block:  "summarize" notes, i.e. count the lines before the mirror
  - Summarize notes (pattern block): first find the mirror horizontally, then vertically (by transposing pattern block)
  - Find the mirror (pattern block):
    - Start at index 1 (mirror between line 0 and 1) up until last index (mirror between last and second to last)
    - Slice the pattern into a top and bottom half:
      - Top: 0..current_index - 1
        - Reverse the top half to be able to compare top and bottom in order
      - Bottom: current_index..-1

    - Truncate the larger half to be the same length as the smaller one

    Part 1:
    - If top and bottom are equal, the mirror is found -> Return the current index
      - The current index will signify the line after the mirror and thus equal the number of lines before

    Part 2:
    - Check for differences in the top and bottom half:
      - Set a counter to 0
      - Iterate over the top half:
        - Iterate over each row:
          - If the current element is unequal to the corresponding element in bottom, increase counter by 1
      - Return counter

    - If there is only 1 difference, -> return the current index
=end

# Load file
# path = "example.txt"
path = "mirrors.txt"
input = File.readlines(path, chomp: true)

def parse(input)
  input = input.slice_before("")
  input.map do |pattern|
    pattern = pattern.reject { |string| string.empty? }
    pattern.map { |row| row.chars }
  end
end

def count_differences(top, bottom)
  counter = 0

  top.each_with_index do |row, row_index|
    row.each_with_index do |node, col_index|
      if node != bottom[row_index][col_index]
        counter += 1
      end
    end
  end

  counter
end

def find_mirror_location(pattern)
  (1..pattern.size - 1).each do |index|
    top = pattern[0..index - 1].reverse
    bottom = pattern[index..-1]

    top = top[0, bottom.length]
    bottom = bottom[0, top.length]

    # Part 1:
    # return index if top == bottom

    # Part 2:
    return index if count_differences(top, bottom) == 1
  end

  return 0
end

def summarize_notes(pattern)
  counter = find_mirror_location(pattern) * 100

  transposed_pattern = pattern.transpose
  counter += find_mirror_location(transposed_pattern)
end

# Main
mirrors = parse(input)

count = mirrors.sum { |pattern| summarize_notes(pattern) }
puts "The result is: #{count}"
