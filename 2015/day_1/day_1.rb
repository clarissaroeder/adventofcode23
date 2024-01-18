# Load file
path = "input.txt"
directions = File.readlines(path, chomp: true)[0].chars

# Part 1
start = 0

directions.each do |direction|
  case direction
  when "(" then start += 1
  when ")" then start -= 1
  end
end

puts "The result is: #{start}"

# Part 2
start = 0

directions.each_with_index do |direction, index|
  case direction
  when "(" then start += 1
  when ")" then start -= 1
  end

  if start < 0
    puts "The result is: #{index + 1}"
    break
  end
end