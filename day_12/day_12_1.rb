# Load file
# path = "example.txt"
path = "springs.txt"
input = File.readlines(path, chomp: true)
condition_report = input.map do |line|
  line = line.split
  line[1] = line[1].split(",").map(&:to_i)
  line
end

=begin
P
  - Problem: For each row of springs, find the number of possible arrangements of operational and
    broken springs given the criteria of contiguous groups of damaged springs in order that is supplied for each row.

  - Input: Array of strings
  - Output: A number

E

  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1

  - ? signifies unknown
  - . signifies operational
  - # signifies broken
  - The numbers signify the size of contiguous groups of broken springs in the order they are occurring
    - This list of numbers always accounts for all damaged springs
    - Each number is the entire size of the group (#### will never be (2,2) but always 4)

  - In this example, row 2 has 4 possible configurations

D
  - Array of strings (or nested array of chars?) signifying the rows
  - Nested array of group numbers
  -> The indices will correspond

  Now: [["symbolstring", [1, 2, 3]], ["symbolstring", [1, 2, 3]], ...]

A
  General:
  - Identify which ? certainly have to be .
  - Then, try every possible # placement, starting at the first
    - Explore down each "subproblem" (ie different starting #) and its subproblems
    - If a subproblem proves invalid, backtrack to the previous decision point and try another subproblem
    - If a subproblem proves valid, store and increase counter


  Find possible configurations:
  - Given one configuration
  - If valid solution:
    - store the solution
    - return
  - If invalid solution:

=end

DAMAGED = "#"
OPERATIONAL = "."
UNKNOWN = "?"

def parse(input)
  input.map do |line|
    line = line.split
    line[1] = line[1].split(",").map(&:to_i)
    line
  end
end

def unfold(condition_report)
  condition_report.map do |springs|
    row, groups = springs

    row_temp = "?" + row
    group_temp = groups

    4.times do
      row += row_temp
      groups += group_temp
    end

    [row, groups]
  end
end

def permutate_unknowns(row)
  permutations = []
  generate_permutations(row, 0, '', permutations)
  permutations
end

def generate_permutations(row, index, current, permutations)
  if index == row.length
    permutations << current
    return
  end

  if row[index] == UNKNOWN
    generate_permutations(row, index + 1, current + OPERATIONAL, permutations)
    generate_permutations(row, index + 1, current + DAMAGED, permutations)
  else
    generate_permutations(row, index + 1, current + row[index], permutations)
  end
end

def valid?(row, groups)
  current_group_index = 0

  count = 0

  row.each_char do |spring|
    if spring == DAMAGED
      count += 1
    elsif count > 0
      return false if count != groups[current_group_index]
      count = 0
      current_group_index += 1
    end
  end

  if count > 0
    return false if count != groups[current_group_index]
    current_group_index += 1
  end

  current_group_index == groups.length
end

# Main
condition_report = parse(input)
# condition_report = unfold(condition_report)

counter = 0

condition_report.each do |springs|
  row, groups = springs
  permutations = permutate_unknowns(row)
  # puts permutations
  permutations.each do |candidate|
    counter += 1 if valid?(candidate, groups)
  end
end

puts "The result is: #{counter}"
