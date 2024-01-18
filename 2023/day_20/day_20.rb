# Load file
# path = "example.txt"
path = "pulses.txt"
input = File.readlines(path, chomp: true).map { |str| str.split(" -> ") }.to_h

class Module
  attr_reader :destinations, :name

  def initialize(name, destinations)
    @name = name
    @destinations = destinations
  end

  def self.new_object(prefix, name, destinations)
    case prefix
    when "b" then Broadcaster.new(name, destinations)
    when "%" then FlipFlop.new(name, destinations)
    when "&" then Conjunction.new(name, destinations)
    end
  end
end

class Broadcaster < Module
  def receive(pulse)
    outgoing = []
    destinations.each { |destination| outgoing << Pulse.new(name, pulse.type, destination) }
    outgoing
  end
end

class FlipFlop < Module
  attr_accessor :switch

  def initialize(name, destinations)
    super
    @switch = :off
  end

  def receive(pulse)
    outgoing = []

    return outgoing if pulse.type == :high

    flip_switch
    outgoing_type = switch == :off ? :low : :high

    destinations.each { |destination| outgoing << Pulse.new(name, outgoing_type, destination) }
    outgoing
  end

  def flip_switch
    self.switch = switch == :off ? :on : :off
  end
end

class Conjunction < Module
  attr_accessor :origins

  def initialize(name, destinations)
    super
    @origins = {}
  end

  def receive(pulse)
    outgoing = []

    origins[pulse.origin] = pulse.type

    outgoing_type = origins.values.all? { |last_pulse| last_pulse == :high } ? :low : :high

    destinations.each { |destination| outgoing << Pulse.new(name, outgoing_type, destination) }

    outgoing
  end
end

class Pulse
  attr_reader :origin, :type, :destination

  @@low = 0
  @@high = 0

  def initialize(origin, type, destination)
    @origin = origin
    @type = type
    @destination = destination

    @@low += 1 if type == :low
    @@high += 1 if type == :high
  end

  def to_s
    "origin: #{origin}  type: #{type}   destination: #{destination}"
  end

  def self.counter
    [@@low, @@high]
  end
end

class Advent
  attr_accessor :modules, :queue, :initial_state, :states

  def initialize(input)
    module_setup(input)
    @queue = []
  end

  def calculate_minimum_button_presses
    target_modules = {}
    modules[:hp].origins.keys.each { |key| target_modules[key] = nil }

    button_counter = 0

    loop do
      start_pulse = Pulse.new(:button, :low, :broadcaster)
      queue << start_pulse

      button_counter += 1

      while !queue.empty?
        current = queue.shift

        next unless modules.key?(current.destination)
        outgoing = modules[current.destination].receive(current)
        outgoing.each do |pulse|
          if pulse.type == :high && pulse.destination == :hp
            if target_modules[pulse.origin].nil?
              target_modules[pulse.origin] = button_counter
            end
          end
          queue << pulse
        end
      end

      break if target_modules.values.all?
    end

    result = target_modules.values.reduce { |acc, value| acc.lcm(value) }
    puts "Minimum button presses: #{result}"
  end

  def push_button(n)
    n.times do
      start_pulse = Pulse.new(:button, :low, :broadcaster)
      queue << start_pulse

      while !queue.empty?
        current = queue.shift

        next unless modules.key?(current.destination)
        outgoing = modules[current.destination].receive(current)
        outgoing.each { |pulse| queue << pulse }
      end
    end

    low, high = Pulse.counter
    puts "The result is: #{low * high}"
  end

  def module_setup(input)
    @modules = {}

    input.each do |type, destinations|
      prefix = type[0]
      name = type == "broadcaster" ? :broadcaster : type[1..-1].to_sym
      modules[name] = Module.new_object(prefix, name, destinations.split(", ").map(&:to_sym))
    end

    initialize_conjunction_memory
  end

  def initialize_conjunction_memory
    modules.each do |name, current_module|
      if current_module.is_a?(Conjunction)
        modules.each do |other_name, other_module|
          current_module.origins[other_name] = :low if other_module.destinations.include?(name)
        end
      end
    end
  end
end

advent = Advent.new(input)
# advent.push_button(1000)
advent.calculate_minimum_button_presses
