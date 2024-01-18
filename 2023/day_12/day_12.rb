# Load file
# path = "example.txt"
path = "springs.txt"
input = File.readlines(path, chomp: true)
condition_report = input.map do |line|
  line = line.split
  line[1] = line[1].split(",").map(&:to_i)
  line
end

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

def count(row, groups, cache)
  if row == ""
    return groups.empty? ? 1 : 0
  end

  if groups.empty?
    return row.include?(DAMAGED) ? 0 : 1
  end

  key = [row, groups]
  if cache.key?(key)
    return cache[key]
  end

  result = 0

  if row[0] == OPERATIONAL || row[0] == UNKNOWN
    result += count(row[1..-1], groups, cache)
  end

  if row[0] == DAMAGED || row[0] == UNKNOWN
    if valid_group?(row, groups)
      row = row[groups[0] + 1..-1].nil? ? "" : row[groups[0] + 1..-1]
      groups = groups[1..-1].nil? ? [] : groups[1..-1]
      result += count(row, groups, cache)
    end
  end

  cache[key] = result
  return result
end

def valid_group?(row, groups)
  # enough springs in the row left to accomodate all groups?
  return false if row.size < groups.sum

  # current group range includes no functioning springs?
  return false if row[0..(groups[0] - 1)].include?(OPERATIONAL)

  # damaged at end of row OR next one over cannot be damaged
  ((groups[0] == row.length) || (row[groups[0]] != DAMAGED))
end

# Main
condition_report = parse(input)
condition_report = unfold(condition_report)

cache = {}
total = 0

condition_report.each do |springs|
  row, groups = springs
  total += count(row.dup, groups.dup, cache)
end

puts "The result is: #{total}"
