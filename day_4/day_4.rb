# Load file
# path = "example_cards.txt"
path = "scratchcards.txt"
input = File.readlines(path, chomp: true)

=begin
P
  - Scratchcards have two sets of numbers separated by a |, first a set of winning numbers and
    then your numbers
  - If one of your numbers is also in the set of winning numbers, it's a match and you get 1 point
  - Any additional match will double the current point score
  - Goal: given a number of scratchcards, calculate the sum of all point scores

  - Input: a text file, imported into an array of strings
    - Each string takes the format: "Card XX: <winning numbers> | <your numbers>"
  - Output: an integer

E
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

  - Card 1 has 4 matches (48, 83, 17, and 86), meaning it's worth 8 points
    - 1 point for the first match, then doubled 3 times (2, 4, 8) for every other match
  - In total, this card set has 13 points

D
  - Input: array of strings
  - Transform into nested array

A
  - Extract data into readable format -> nested array of scratchcards
    - Each entry represents a scratchcard, which consists of two arrays, winning (0) and yours (1)

  - Define an points array (maybe just sum immediately?)
  - Iterate over the cards
    - For every card: check how many points that card is worth -> HELPER
    - Add points to points array/sum

  - Return the sum of points

  HELPERS
  Check how many points a card is worth:
  - Input: an array with two array entries [[winning], [yours]]
  - Define points variable and set to 0
  - Iterate over "your" array, i.e. index 1 of input
    - If the current number is also present in winning:
      - If points is still 0, add 1
      - If points is larger then 0, double the current value
  - Return points value
=end

=begin
P
  - Same set of scratch cards
  - For every match a card has, you get a copy of another card
    - These copies are the cards below the current card
    - So if you have 4 matches, you get one copy of each of the 4 cards below the current card
  - Every copy takes the same card number as the card they copied, and is processed in the same manner
  - This process repeats until no copies cause you to win any more cards
  - Cards will never make you copy past the table -> no edge case needed??
  - Goal: count how many scratchcards you end up with

D
  - Save cards in a hash this time: {Card 1: [[winning], [yours]], Card 2}
  - Have a hash that counts the instances: {Card 1: count, Card 2: count}

A
  - Something with recursion!

  - Have a method that recursively copies cards and calls itself until no card incur any further copies
  - Have it update the counts hash with every copy made
  - Iterate over the counts hash and add all values together

  - Populate a counter hash with the card numbers and a value of 1 each
  - Iterate over the cards hash:
    - Get the number of matches for the current card
    - Find how many copies this card wins, plus how my copies the copies win until no more copies are won -> Helper
  - Sum the values of the counter hash

  Helper: win copies
  - Input: set of cards, current card_number, matches, counter
  - Define the base case: return if matches i zero
  - For 1..matches |i|:
    - Calculate the number of the card below, i.e. card_number + 1, that will be copied
    - Check that that number is already in the counter hash -> if not, it's out of bounds of the table
    - Add 1 to the counter value of that card number
    - Find the matches for that new card
    - Call the win copies function recursively on the new card
=end

# --- PART 1 --- #
# cards = input.map do |card|
#   card.split(/:|\|/)[1..2].map do |numset|
#     numset.split.map { |num| num.to_i }
#   end
# end

def get_points(card)
  winning, candidates = card
  points = 0

  candidates.each do |num|
    if winning.include?(num)
      if points == 0
        points = 1
      else
        points *= 2
      end
    end
  end

  points
end

def get_points_sum(cards)
  sum = 0

  cards.each do |card|
    sum += get_points(card)
  end

  sum
end

# p get_points_sum(cards)

# --- PART 2 --- #
# Parse input
cards = {}
input.each do |card|
  card_number = card.split(":")[0].split[1].to_i
  numset = card.split(/:|\|/)[1..2].map do |nums|
        nums.split.map { |num| num.to_i }
      end

  cards[card_number] = numset
end

# Helpers
def get_matches(card)
  winning, candidates = card
  (winning & candidates).count
end

def win_copies(cards, card_number, counter)
  sum = 1
  matches = get_matches(cards[card_number])

  if counter[card_number]
    sum = counter[card_number]
    return sum
  end

  (1..matches).each do |i|
    new_card_number = card_number + i
    sum = sum + win_copies(cards, new_card_number, counter)
  end

  if counter[card_number].nil?
    counter[card_number] = sum
  end

  return sum
end

# def get_total_generations(cards, card_number, matches, counter)
#   return if matches.zero?
#   # if the card_number is in counter, return the value

#   # if the card_number is not yet in counter:
#   (1..matches).each do |i|
#     new_card_number = card_number + i
#     matches = get_matches(cards[new_card_number])
#     sum = get_total_generations(cards, new_card_number, matches, counter)
#     # add to storage
#   end

# end

# Main
counter = {}

sum = 0
cards.each do |card_number, card|
  sum = sum + win_copies(cards, card_number, counter)
end

# p storage
# p counter
# p counter.values.sum
p sum


=begin

- How many copies does a card generate? I.e. how many matches does a card have?
- Which cards get copied by which card?

{ 1 => {winning: [], yours: [], instances: int }

- Card 1: has 4 matches -> number of instances times do: copy card 2, 3, 4, and 5 --> increase their instances by 1
- Card 2: has 2 matches -> copies card 3 and 4
  etc.



=end

# def parse(input)
#   cards = {}
#   input.each do |card|
#     card = card.split(/:|\|/)
#     card_number = card[0].split[1].to_i
#     winning = card[1].split.map(&:to_i)
#     yours = card[2].split.map(&:to_i)
#     cards[card_number] = {winning: winning, yours: yours, count: 1}
#   end
#   cards
# end

# def get_matches(card)
#   winning = card[1][:winning]
#   yours = card[1][:yours]
#   (winning & yours).count
# end

# def find_copies(card_number, matches)
#   copies = []
#   (1..matches).each do |i|
#     copies << card_number + i
#   end
#   copies
# end

# def process_wins(cards)
#   cards.each do |card|
#     # p card
#     card_number = card[0]
#     count = card[1][:count]

#     count.times do
#       matches = get_matches(card)
#       copied_cards = find_copies(card_number, matches)
#       copied_cards.each do |copied_card_number|
#        # p cards[copied_card_number]
#        cards[copied_card_number][:count] += 1
#       end
#     end
#   end
# end

# def get_total_number(cards)
#   sum = 0
#   cards.each do |_, card|
#     sum += card[:count]
#   end
#   sum
# end

# cards = parse(input)
# process_wins(cards)

# p get_total_number(cards)
