# Load file
path = "input.txt"
strings = File.readlines(path, chomp: true)

# Part 1
def three_vowels?(string)
  string.count("aeiou") >= 3
end

def double_letter?(string)
  previous_char = string[0]
  
  1.upto(string.length - 1) do |idx|
    return true if string[idx] == previous_char

    previous_char = string[idx]
  end

  false
end

def no_forbidden_substrings?(string)
  disallowed = ["ab", "cd", "pq", "xy"]

  disallowed.each do |substring|
    return false if string.include?(substring)
  end

  true
end

# def nice?(string)
#   three_vowels?(string) && double_letter?(string) && no_forbidden_substrings?(string)
# end

# Part 2
def two_pair?(string)
  string.chars.each_cons(2) do |pair|
    pair = pair.join

    index = string.index(pair)
    second_index = string.index(pair, index + 2)

    return true if !second_index.nil?
  end

  false
end

def repeated_letter?(string)
  previous_char = string[0]

  2.upto(string.length - 1) do |idx|
    return true if string[idx] == previous_char

    previous_char = string[idx - 1]
  end

  false
end

def nice?(string)
  two_pair?(string) && repeated_letter?(string)
end

def count_nice_strings(strings)
  counter = 0

  strings.each do |string|
    counter += 1 if nice?(string)
  end

  puts "The result is: #{counter}"
end

count_nice_strings(strings)