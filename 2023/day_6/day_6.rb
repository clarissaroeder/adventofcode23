# Load file
# path = "example.txt"
path = "racetimes.txt"
input = File.readlines(path, chomp: true)

def parse(input)
  # # Part 1
  # times = input[0].split[1..-1].map(&:to_i)
  # distances = input[1].split[1..-1].map(&:to_i)

  # [times, distances]

  # Part 2
  time = input[0].split[1..-1].join.to_i
  distance  =input[1].split[1..-1].join.to_i

  [time, distance]
end

def calculate_wins(time, record_distance)
  (0..(time - 1)).each do |i|
    if (i * (time - i)) > record_distance
      return ((time + 1) - (i * 2))
    end
  end
end

# Main
# --- PART 1 --- #
# times, distances = parse(input)

# result = 1
# times.size.times do |i|
#   result *= calculate_wins(times[i], distances[i])
# end
# p result

# --- PART 2 --- #
time, distance = parse(input)
result = calculate_wins(time, distance)
p result
