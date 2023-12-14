=begin
Part 2
- To find position in the cycle: determine the cycle length
- Then take n % cycle_length to find the position in the cycle

- Determine cycle length:
  - The cycle doesn't start at the first config!!!
  - Store the start configuration in a cache (an array) -> the index will be the number of spins it took to reach that configuration
  - Repeatedly spin:
    - After each spin, check if the cache holds the current configuration
    - If not, add current configuration to cache
    - If yes:
      - Find the index of the current config in the cache (the prior occurrence)
      - The cycle start is that index
        - In the cache there now will be:
          - The configurations produced before the cycle start
          - After the cycle start: each unique configuration before the cycle starts repeating itself
          - The length of the cycle is thus: the total length of the cache minus the number of configurations produced before the cycle start
        - n is the number of total cycles to do: i want the configuration that spinning the thing n times would produce
        - Therefore: remainder of n / cycle length gives me the position in the cycle that n spins would produce
        - however, need to account for the number of spins that weren't part of the cycle in the beginning:
          - subtract that number from n: after the initial spins, now there is n - x spins left to do: take the modulo of that
  - Return the config at the index in the cache the modulo produces
  - Calculate the north load for that config
=end

# Load file
path = "example.txt"
# path = "rocks.txt"
platform = File.readlines(path, chomp: true).map(&:chars)

FREE = "."
ROUND = "O"

def tilt_north(platform)
  platform.each_with_index do |row, row_index|
    row.each_with_index do |node, col_index|
      if node == ROUND
        (0..row_index - 1).reverse_each do |i|
          if platform[i][col_index] == FREE
            platform[i][col_index], platform[i + 1][col_index] = platform[i + 1][col_index], platform[i][col_index]
          else
            break
          end
        end
      end
    end
  end
end

def tilt_south(platform)
  reversed_platform = platform.reverse

  reversed_platform.each_with_index do |row, row_index|
    row.each_with_index do |node, col_index|
      if node == ROUND
        (0..row_index - 1).reverse_each do |i|
          if reversed_platform[i][col_index] == FREE
            reversed_platform[i][col_index], reversed_platform[i + 1][col_index] = reversed_platform[i + 1][col_index], reversed_platform[i][col_index]
          else
            break
          end
        end
      end
    end
  end

  platform = reversed_platform.reverse
end

def tilt_west(platform)
  platform.each do |row|
    row.each_with_index do |node, col_index|
      if node == ROUND
        (0..col_index - 1).reverse_each do |i|
          if row[i] == FREE
            row[i], row[i + 1] = row[i + 1], row[i]
          else
            break
          end
        end
      end
    end
  end

end

def tilt_east(platform)
  platform.each_with_index do |row, row_index|
    row = row.reverse
    row.each_with_index do |node, col_index|
      if node == ROUND
        (0..col_index - 1).reverse_each do |i|
          if row[i] == FREE
            row[i], row[i + 1] = row[i + 1], row[i]
          else
            break
          end
        end
      end
    end
    platform[row_index] = row.reverse
  end
end

def spin(platform)
  tilt_north(platform)
  tilt_west(platform)
  tilt_south(platform)
  tilt_east(platform)
end

def calculate_load(platform)
  length = platform.length

  load = 0

  platform.each_with_index do |row, index|
    counter = row.count { |node| node == ROUND }
    load += counter * (length - index)
  end

  puts "The result is: #{load}"
end

def cycle(platform, n)
  cycle_start = 0

  cache = []
  cache << platform.map(&:join).join("\n")

  loop do
    spin(platform)
    platform_str = platform.map(&:join).join("\n")
    index = cache.index(platform_str)

    if !index.nil?
      cycle_start = index
      break
    end

    cache << platform_str
  end

  cycles_to_do = n - cycle_start
  cycle_length = cache.size - cycle_start
  position_in_cycle = cycle_start + (cycles_to_do % cycle_length)
  cache[position_in_cycle].split("\n").map(&:chars)
end

# Main
platform = cycle(platform, 1000000000)
calculate_load(platform)
