require "matrix"

# Load file
path = "example.txt"
# path = "hail.txt"
input = File.readlines(path, chomp: true).map { |line| line.split(/,|@/).map(&:to_i) }

Hailstone = Struct.new(:x, :y, :z, :vx, :vy, :vz)

class Advent
  attr_accessor :hailstones, :positions, :velocities

  def initialize(input)
    @hailstones = []
    @positions = []
    @velocities = []

    input.each do |line|
      x, y, z, vx, vy, vz = line

      hailstones << Hailstone.new(x, y, z, vx, vy, vz)
      positions << Vector[x, y, z]
      velocities << Vector[vx, vy, vz]
    end
  end

  def find_rock_position
    time = 0

    rock_position = [0, 0, 0]
    rock_velocity = [0, 0, 0]

    collision_counter = 0

    loop do




  end
end

advent = Advent.new(input)
