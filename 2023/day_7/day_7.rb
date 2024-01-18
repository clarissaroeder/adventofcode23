# Load file
# path = "example.txt"
path = "hands.txt"
input = File.readlines(path, chomp: true).map { |hand| hand.split }

module Typable
  def five_of_a_kind?
    cards.any? { |c| cards.count(c) == 5 }
  end

  def four_of_a_kind?
    cards.any? { |c| cards.count(c) == 4 }
  end

  def full_house?
    three_of_a_kind? && pair?
  end

  def three_of_a_kind?
    cards.any? { |c| cards.count(c) == 3 }
  end

  def two_pair?
    pairs = cards.select { |c| cards.count(c) == 2 }
    pairs.size == 4
  end

  def pair?
    cards.any? { |c| cards.count(c) == 2 }
  end
end

# --- PART 1 --- #
class Hand
  include Comparable, Typable
  attr_accessor :cards, :bid, :type, :rank, :wins

  def initialize(hand, bid)
    @cards = hand.chars
    @bid = bid.to_i
    find_type
  end

  def find_type
    self.type = case
    when five_of_a_kind? then 7
    when four_of_a_kind? then 6
    when full_house? then 5
    when three_of_a_kind? then 4
    when two_pair? then 3
    when pair? then 2
    else
      1
    end
  end
  end

  def calculate_wins
    self.wins = bid * rank
  end

  def value(card)
    case card
    when 'A' then 14
    when 'K' then 13
    when 'Q' then 12
    when 'J' then 11
    when 'T' then 10
    else
      card.to_i
    end
  end

  def <=>(other)
    return type <=> other.type if type != other.type

    cards.each_with_index do |card, idx|
      result = value(card) <=> value(other.cards[idx])
      return result unless result.zero?
    end
    0
  end

  def to_s
    "cards: #{cards} type: #{type} rank: #{rank} wins: #{wins}"
  end
end

# --- PART 2 ---- #
class Hand
  include Comparable, Typable
  attr_accessor :cards, :bid, :type, :rank, :wins, :tiebreak_cards

  def initialize(hand, bid)
    @cards = hand.chars
    @tiebreak_cards = @cards.dup
    substitute_jokers
    @bid = bid.to_i
    find_type
  end

  def substitute_jokers
    jokers = cards.count('J')

    if jokers == 5
      cards.map! { |c| c == 'J' ? '1' : c }
    else
      other_cards = cards - ['J']
      replacement = other_cards.max_by { |c| other_cards.count(c) }
      cards.map! { |c| c == 'J' ? replacement : c }
    end
  end

  def find_type
    self.type = case
    when five_of_a_kind? then 7
    when four_of_a_kind? then 6
    when full_house? then 5
    when three_of_a_kind? then 4
    when two_pair? then 3
    when pair? then 2
    else
      1
    end
  end

  def calculate_wins
    self.wins = bid * rank
  end

  def value(card)
    case card
    when 'A' then 14
    when 'K' then 13
    when 'Q' then 12
    when 'J' then 1
    when 'T' then 10
    else
      card.to_i
    end
  end

  def <=>(other)
    return type <=> other.type if type != other.type

    tiebreak_cards.each_with_index do |card, idx|
      result = value(card) <=> value(other.tiebreak_cards[idx])
      return result unless result.zero?
    end
    0
  end

  def to_s
    "cards replaced: #{cards} original:#{tiebreak_cards} \
    type: #{type} rank: #{rank} wins: #{wins}"
  end
end

class CamelCards
  attr_accessor :hands

  def initialize(input)
    @hands = []
    get_hands(input)
  end

  def start
    rank_hands
    sum_wins
  end

  def get_hands(input)
    input.each do |hand|
      hands << Hand.new(hand[0], hand[1])
    end
  end

  def rank_hands
    @ranked_hands = hands.sort

    @ranked_hands.each_with_index do |hand, idx|
      hand.rank = idx + 1
    end
  end

  def sum_wins
    hands.each(&:calculate_wins)

    result = 0
    hands.each do |hand|
      result += hand.wins
    end
    puts "The result is: #{result}"
  end
end

game = CamelCards.new(input)
game.start
