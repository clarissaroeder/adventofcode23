# Load file
# path = "example_map.txt"
path = "map.txt"
input = File.readlines(path, chomp: true)

$egg = 0

=begin
P
  - Input: an array of seed numbers, some conversion maps consisting of:
    - Destination start, source start, and range length
    - Destination ports indeces will map to source indeces

  - Objective: find the lowest location number for an input seed -> convert through all the maps

E
  seed-to-soil map:
  50 98 2
  52 50 48

  The destination (soil) start at 50, and 52; The source (seed) start at 98 and 50; The range length is 2 and 48
  Unmapped source numbers have the same number as destination!
  Resulting in the following source to destination map:
  seed  soil
    0     0
    1     1
    ...   ...
    48    48
    49    49
    50    52
    51    53
    ...   ...
    96    98
    97    99
    98    50
    99    51

D
  - Array of seed numbers
  - Array of hashes?
    [{"seed, soil" => [destination, source, range], [destination, source, range], "soil, fertilizer" => [...] }]
  - No key needed, since they're in order... nested array?
                  sets of map 1                     sets of map 2
    [[[destination, source, range], [d, s, r]], [[d, s, r], [d, s, r]]]

  -> Find the lowest destination value at the end of an iteration of mapping

A
  - Given an array of seed numbers: find the smallest location of all the seed locations

  Find smallest location(seeds, maps):
  - Define location variable and set to nil
  - Iterate over the seed numbers
    - For each seed number, calculate the location number -> Helper
    - Store in temp variable
    - If location is nil: set location to temp
    - If location is not nil: set location to temp if temp < location
  - Return location

  Find the location for a seed(seed, maps):
  - Set a variable source to seed
  - Iterate over the maps:
    - For each map, given the source and the current map, find the destination number -> Helper
    - Set source to be that destination
  - At the end of the iteration, source will be the last destination, i.e., location
  - Return source

  Find the destination for a source(source, map):
  - Set a destination variable to nil
  - Iterate over the numsets of the map:
    - If the source is in the current numsets source range:
      - Calculate the destination number and set it to destination -> Helper
      - Break
  - If at the end of the iteration destination still is nil, destination = source
  - Return destination

  Calculate destination number(source, numset):
  - Calculate the offset: source_range_start - source
  - Destination will be: destination_range_start + offset

  PART 2:
  A
    - Get seed ranges: iterate over seeds and slice each pair, storing in new array
      -> The seed ranges each will have the format: [start, length] !!!

    Objective: Given an array of seed ranges: find the smallest location number of all seed locations

    Find smallest location_range of all seed_ranges(seed_ranges, maps):
      - Define location_range variable and set to nil
      - Iterate over the seed ranges: (each seed_range will return several location ranges)
        - For each seed_range, find all location ranges -> HELPER
        - Sort all location ranges by smallest start value, and select the first
          - Store this in a temp variable

        - If location_range is nil, set location_range to temp
        - If location_range is not nil, set location_range to temp if temp[0] < location_range[0]

      - Return location_range.first

    Find location ranges for a seed range(seed_range, maps):
      - Set a variable source_ranges to [seed_range]
      - Iterate over the maps:
        - For each map, given the source ranges and the current map, find the destination ranges -> Helper
          (every source_range will return multiple destination ranges potentially)
        - Set source_ranges to be these destination_ranges

      - At the end of the iteration, source_ranges will be the last destination_ranges, i.e., location ranges
      - Return source ranges


    Find destination_ranges for a number of source_ranges(source_ranges, map):
      - Set a destination_ranges variable to nil



    Find destination range for a source range(source_range, map):
    - Set a destination variable to nil
    - Iterate over the numsets of the map:
      - If the source is in the current numsets source range:
        - Calculate the destination number and set it to destination -> Helper
        - Break
    - If at the end of the iteration destination still is nil, destination = source
    - Return destination



=end

# Part 1
def parse_file(input)
  seeds = input[0].split(":")[1].split.map(&:to_i)
  maps = []

  temp = []

  input.each_with_index do |line, index|
    next if index == 0 || index == 1

    if line.empty?
      temp[1..-1] = temp[1..-1].map do |numset|
        numset = numset.split
        numset.map(&:to_i)
      end

      map = {temp[0] => temp[1..-1]}
      maps << map
      temp.clear
      next
    end

    temp << line
  end

  [seeds, maps]
end

def source_in_range?(source, numset)
  (numset[1]..(numset[1] + numset[2]).pred).cover?(source)
end

def calculate_destination(source, numset)
  diff = source - numset[1]
  numset[0] + diff
end

def find_destination(source, map)
  destination = nil

  numsets = map.values.first
  numsets.each do |numset|
    if source_in_range?(source, numset)
      destination = calculate_destination(source, numset)
      break
    end
  end
  destination = source if destination.nil?

  destination
end

def find_seed_location(seed, maps)
  source = seed

  maps.each do |map|
    source = find_destination(source, map)
  end

  source
end

def find_smallest_location(seeds, maps)
  location = nil
  seeds.each do |seed|
    temp = find_seed_location(seed, maps)
    if location.nil?
      location = temp
    else
      location = temp if temp < location
    end
  end
  location
end

# Part 2
def get_seed_ranges(seeds)
  seed_ranges = []
  seeds.each_slice(2) { |pair| seed_ranges << pair }
  seed_ranges
end

def ranges_overlap?(source_range, conversion_range)
  source_range.cover?(conversion_range.first) || conversion_range.cover?(source_range.first)
end

def is_subrange?(source_range, conversion_range)
  conversion_range.include?(source_range.first) && conversion_range.include?(source_range.last)
end

def calculate(source, conversion_specs)
  converted = []
  unconverted = []

  source_start, source_length = source
  source_end = (source_start + source_length).pred
  source_range = (source_start..source_end)

  destination_start, conversion_start, conversion_length = conversion_specs
  conversion_end = (conversion_start + conversion_length).pred
  conversion_range = (conversion_start..conversion_end)

  offset = destination_start - conversion_start

  if ranges_overlap?(source_range, conversion_range)
    if is_subrange?(source_range, conversion_range)
      destination_range = [(source_start + offset), source_length]

      converted << destination_range

    else
      overlap_start = [source_start, conversion_start].max
      overlap_end = [source_end, conversion_end].min
      overlap_length = overlap_end.next - overlap_start

      destination_range = [(overlap_start + offset), overlap_length]
      converted << destination_range

      if source_start < overlap_start
        length = (overlap_start - source_start)
        range = [source_start, length]
        unconverted << range
      end

      if source_end > overlap_end
        length = (source_end - overlap_end)
        range = [overlap_end.next, length]
        unconverted << range
      end
    end
  else
    unconverted << [source_start, source_length]
  end

  [converted, unconverted]
end

def find_destinations(unconverted_sources, map)
  temp_unconverted = unconverted_sources
  converted = []

  map.each do |conversion_specs|
    sources_to_process = temp_unconverted

    temp_unconverted = []

    sources_to_process.each do |source|
      processed, not_processed = calculate(source, conversion_specs)

      if !not_processed.empty?
        not_processed.each do |r|
          temp_unconverted << r
        end
      end

      if !processed.empty?
        processed.each { |r| converted << r }
      end
    end

  end

  converted + temp_unconverted

end

# Main
seeds, maps = parse_file(input)

# p find_smallest_location(seeds, maps)

seed_ranges = get_seed_ranges(seeds)
maps = maps.map { |map| map.values.first }

unconverted_sources = seed_ranges
maps.each do |map|
  unconverted_sources = find_destinations(unconverted_sources, map)
end

p unconverted_sources.min
