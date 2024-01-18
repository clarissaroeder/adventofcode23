# Load file
# path = "example.txt"
path = "workflow.txt"
input = File.readlines(path, chomp: true)

class Advent
  attr_accessor :workflows, :machine_parts, :accepted, :possible_acceptions

  def initialize(input)
    parse(input)
    @accepted = []
    @possible_acceptions = 0
  end

  def solve_part_2
    part = { x: (1..4000), m: (1..4000), a: (1..4000), s: (1..4000) }
    start_action = "in"

    count_acceptions(part, start_action)
    puts "The result is: #{possible_acceptions}"
  end

  def count_combinations(part)
    range_sizes = part.map { |_, value| value.size }
    range_sizes.reduce(&:*)
  end

  def count_acceptions(part, action)
    if action == "A" || action == "R"
      self.possible_acceptions += count_combinations(part) if action == "A"
      return
    end

    current_workflow = workflows[action]

    current_workflow.each do |rule|
      condition, action = parse_rule(rule)

      if condition == ["else"]
        count_acceptions(part, action)
      else
        rating, operator, number = condition

        case operator
        when "<"

          if part[rating].max < number
            count_acceptions(part, action)
            break
          elsif part[rating].min >= number
            next
          elsif part[rating].cover?(number)
            valid = (part[rating].min..number - 1)
            invalid = (number..part[rating].max)

            valid_part = {}
            part.each { |key, value| valid_part[key] = value}
            valid_part[rating] = valid

            count_acceptions(valid_part, action)

            part[rating] = invalid
            next
          end
        when ">"
          if part[rating].min > number
            count_acceptions(part, action)
            break
          elsif part[rating].max <= number
            next
          elsif part[rating].cover?(number)
            valid = (number + 1..part[rating].max)
            invalid = (part[rating].min..number)

            valid_part = {}
            part.each { |key, value| valid_part[key] = value }
            valid_part[rating] = valid

            count_acceptions(valid_part, action)

            part[rating] = invalid
            next
          end
        end
      end
    end
  end

  # --- PART 1 --- #
  def solve_part_1
    sort_parts
    calculate_accepted_sum
  end

  def calculate_accepted_sum
    sum = accepted.sum { |part| part.values.sum }
    puts "The result is: #{sum}"
  end

  def sort_parts
    start_action = "in"

    machine_parts.each do |part|
      check(part, start_action)
    end
  end

  def check(part, action)
    if action == "A" || action == "R"
      accepted << part if action == "A"
      return
    end

    current_workflow = workflows[action]

    current_workflow.each do |rule|
      condition, action = parse_rule(rule)

      if condition == ["else"]
        check(part, action)
      else
        rating, operator, number = condition

        case operator
        when "<"
          next unless part[rating] < number
          check(part, action)
          break
        when ">"
          next unless part[rating] > number
          check(part, action)
          break
        end
      end
    end
  end

  def parse_rule(rule)
    condition = rule.keys.first
    action = rule.values.first

    return [[condition], action] if condition == "else"

    rating = condition[0].to_sym
    operator = condition[1]
    number = condition[2..-1].to_i

    [[rating, operator, number], action]
  end

  def parse(input)
    i = input.index("")
    flows = input[0..i - 1]
    parts = input[i + 1..-1]

    parse_workflows(flows)
    parse_parts(parts)
  end

  def parse_workflows(flows)
    @workflows = {}

    flows.each do |flow|
      i = flow.index("{")
      name = flow[0..i - 1]
      rules = flow[i + 1..-2].split(",").map do |r|
        r = r.split(":")

        if r.size == 1
          { "else" => r[0] }
        else
          { r[0] => r[1] }
        end
      end

      workflows[name] = rules
    end
  end

  def parse_parts(parts)
    @machine_parts = []

    parts.each do |part|
      hash = {}
      part = part[1..-2].split(",")
      part.each { |rating| hash[rating[0].to_sym] = rating[2..-1].to_i }
      machine_parts << hash
    end
  end
end

advent = Advent.new(input)
advent.solve_part_2
