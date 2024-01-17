# Load file
# path = "example.txt"
path = "hail.txt"
input = File.readlines(path, chomp: true).map { |line| line.split(/,|@/).map(&:to_i) }

=begin
- Compare each hailstone with each hailstone -> nested loop
- Compute linear equation for each hailstone
- Find intersection
- Is intersection within the defined interval?
- Count intersections that are

- Potential edge case: straight line down

- velocities: changes in x, y, z
- to calculate
=end

Hailstone = Struct.new(:x, :y, :z, :vx, :vy, :vz)

class Advent
  attr_accessor :hailstones

  MIN = 200000000000000
  MAX = 400000000000000

  # MIN = 7
  # MAX = 27

  def initialize(input)
    @hailstones = []

    input.each do |line|
      x, y, z, vx, vy, vz = line

      hailstones << Hailstone.new(x, y, z, vx, vy, vz)
    end
  end

  def count_crossings
    sum = 0

    (0..hailstones.size - 2).each do |i|
      (i + 1..hailstones.size - 1).each do |j|
        cross = xy_cross_point(hailstones[i], hailstones[j])
        sum += 1 if cross_in_area?(cross) && cross_in_future?(cross, hailstones[i], hailstones[j])
      end
    end

    puts "The result is: #{sum}"
  end

  def cross_in_area?(cross)
    (MIN..MAX).include?(cross[0]) && (MIN..MAX).include?(cross[1])
  end

  def cross_in_future?(cross, hailstone1, hailstone2)
    if hailstone1.vx < 0
      return false if hailstone1.x < cross[0]
    elsif hailstone1.vx > 0
      return false if hailstone1.x > cross[0]
    end

    if hailstone2.vx < 0
      return false if hailstone2.x < cross[0]
    elsif hailstone2.vx > 0
      return false if hailstone2.x > cross[0]
    end

    true
  end

  def xy_cross_point(hailstone1, hailstone2)
    m1 = hailstone1.vy.to_f / hailstone1.vx
    c1 = (-m1 * hailstone1.x) + hailstone1.y

    m2 = hailstone2.vy.to_f / hailstone2.vx
    c2 = (-m2 * hailstone2.x) + hailstone2.y

    x = (c2 - c1) / (m1 - m2)
    y = (m1 * x) + c1

    [x, y]
  end
end

advent = Advent.new(input)
advent.count_crossings
