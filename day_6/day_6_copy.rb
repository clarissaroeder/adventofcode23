# Load file
# path = "example.txt"
path = "racetimes.txt"
input = File.readlines(path, chomp: true)

class Race
  attr_reader :time, :record_distance, :speed
  attr_writer :speed

  def initialize(time, distance)
    @time = time
    @record_distance = distance
    @speed = 0
  end

  def winning_distances
    distances = [get_possible_distances]
    distances.select { |distance| distance > record_distance }
  end

  def get_possible_distances
    distances = []

    time.times do
      distances << max_distance
      self.speed += 1
    end
  end

  def max_distance
    time_left = time - speed
    time_left * speed
  end
end

# def parse_input(input)
#   data = []
#   input.each do |string|
#     data << string.split[1..-1].map(&:to_i)
#   end
#   data
# end

def parse_input(input)
  data = []
  input.each do |string|
    data << string.split[1..-1].join.to_i

  end
  data
end

# Main
times, distances = parse_input(input)

races = []



# races = []
# times.each_with_index do |time, idx|
#   race = Race.new(time, distances[idx])
#   races << race
# end

race = Race.new(times, distances)

winning_ways = []
# races.each do |race|
#   winning_ways << race.winning_distances.count
# end

winning_ways << race.winning_distances.count

p winning_ways.reduce(:*)
