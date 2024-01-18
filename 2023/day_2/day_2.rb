=begin
P
  - Red, green, or blue cubes in a bag, unknown number of each
  - A handful of cubes are drawn and shown, and then put *back* into the bag, several times per game
  - Several games are played and the information from every game is stored and provided as input

  - The goal: which games would have been possible if the bag contained only
    12 red cubes, 13 green cubes, and 14 blue cubes?
  - What is the sum ID of these games?

E
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

  - Game 1, 2, 5 would be possible
  - Game 3 and 5 impossible, because at one point the elf shows you 20 red/15 blue at once respectively

D
  - Hash of games: { Game 1: {3 => blue, 4 => red}, Game 2: {1 => blue, 2 => green } } ? Maybe flip key/values,
    maybe array of hashes and use index to find game numbers (+ 1)

  - Result array that stores the game number?

A
  - Read file line by line
  - Create a games hash
  - For each line, extract the information into the games hash

    - Helper:
    - Extract the first number from the string as the game number: traverse through the string
    - and if the char is a number, break

    - Split the second string into the different sets: split(";")

-----------
NOTES
- Just need the largest draw of each game to check if it was possible!

=end

# --- PART 1 --- #
MAX_RED = 12
MAX_GREEN = 13
MAX_BLUE = 14

# Helpers
def find_game_number(game)
  game.split[1].to_i
end

def find_game_sets(game)
  game.split(":").last.split(/[,;]/)
end

def find_largest_game_set(game)
  sets = find_game_sets(game)

  sets.each_with_object({}) do |draw, result|
    number, colour = draw.split
    number = number.to_i

    if !result.key?(colour) || number > result[colour]
      result[colour] = number
    end
  end
end

# Main
path = "cube_games.txt"
# path = "example_games.txt"

games = {}
File.readlines(path, chomp: true).each do |game|
  games[find_game_number(game)] = find_largest_game_set(game)
end

possible_games = games.select do |_, draws|
  draws["red"] <= MAX_RED && draws["green"] <= MAX_GREEN && draws["blue"] <= MAX_BLUE
end.keys

p possible_games.sum

# --- PART 2 --- #
# Reuses helpers from part 1

def calculate_power(draw)
  draw.values.reduce(:*)
end

powers = games.map do |_, draw|
  calculate_power(draw)
end

p powers.sum
