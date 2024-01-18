require 'digest'

def md5_hash(input)
  md5 = Digest::MD5.new
  md5.update(input)
  md5.hexdigest
end

def five_zeros?(hash)
  hash[0, 6] == "000000"
end

def find_lowest_number
  key = "iwrupvqb"
  i = 1

  hashed_result = nil

  loop do
    input = key + i.to_s 
    hashed_result = md5_hash(input)

    break if five_zeros?(hashed_result)
    i += 1
  end

  puts "MD5 Hash: #{hashed_result}"
  puts "The result is: #{i}"
end

find_lowest_number