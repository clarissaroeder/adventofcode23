# --- PART 1 --- #
# path = 'calibration.txt'
## path = 'example_calibration.txt'

# calibration_doc = File.readlines(path, chomp: true)

# calibration_values = calibration_doc.map do |line|
#   numbers = line.scan(/\d/)
#   (numbers.first + numbers.last).to_i
# end

# total_sum = calibration_values.sum

# p total_sum

# --- PART 2 --- #
=begin

-- ALGORITHM --
- Load file into an array of strings (each line is an entry)
- Define a word to number hash: { 'word' => number }

- Map the calibration doc:
  - Find all the matches in each line and store in an array:
    - Scan the line with a regex
      - Use positive lookahead zero-length assertion to make sure to capture overlapping words
      - Use range of digits
  - Iterate over the number hash:
    - If a current key is equal to any of the elements in matches, replace that element with the current value

  - Split remaining string into array of chars

  - Extract first and last number of that line's numbers array
  - Join and convert into integer
  - Add to sum

---------------
NOTES
- Overlapping number-words both count!

=end

path = 'calibration.txt'
# path = 'example_calibration.txt'

calibration_doc = File.readlines(path, chomp: true)

NUMBERS = { 'zero' => '0', 'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4',
            'five' => '5', 'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9' }

calibration_values = calibration_doc.map do |line|
  matches = line.scan(/(?=(zero|one|two|three|four|five|six|seven|eight|nine|[0-9]))/).flatten
  matches.map! { |match| NUMBERS[match] || match }
  [matches.first + matches.last].join.to_i
end

total_sum = calibration_values.sum

p total_sum
