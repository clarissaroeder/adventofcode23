require 'set'

# Load file
# path = "example.txt"
path = "wires.txt"
input = File.readlines(path, chomp: true)

Wire = Struct.new(:connects)

class Advent
  attr_accessor :graph, :connections

  def initialize(input)
    @graph = Hash.new
    @connections = Array.new
    setup(input)

    # graph.each { |pair| p pair }
    # puts
    # p connections.size
  end

  def solve
    combinations = []
    connections.combination(3) do |combo|
      combinations << combo if combo.flatten.uniq.size == 6
    end

    # for each combination, check if the graph is one or two clusters if the connections are removed
    combinations.each do |combo|
      combo.each { |node1, node2| remove_edge(node1, node2) }

      components = find_components
      if components.size > 1
        puts "edges to remove: #{combo}"
        result = components.reduce(1) { |product, component| product * component.size }
        puts "The result is: #{result}"
        break
      end

      combo.each { |node1, node2| add_edge(node1, node2) }
    end

  end

  def find_components
    components = []
    visited = Set.new

    graph.keys.each do |node|
      unless visited.include?(node)
        component = []
        dfs(node, visited, component)
        components << component
      end
    end

    components
  end

  def dfs(node, visited, component)
    visited.add(node)
    component << node

    graph[node].each do |neighbour|
      unless visited.include?(neighbour)
        dfs(neighbour, visited, component)
      end
    end
  end

  def add_edge(node1, node2)
    graph[node1] << node2
    graph[node2] << node1
  end

  def remove_edge(node1, node2)
    graph[node1].delete(node2)
    graph[node2].delete(node1)
  end

  def setup(input)
    # populate graph
    input.each do |line|
      key, values = line.split(": ")
      values = values.split

      if graph.key?(key)
        values.each { |value| graph[key] << value unless graph[key].include?(value) }
      else
        graph[key] = values
      end


      values.each do |value|
        # save all uniqe node pairs in connections array
        connections << [key, value]

        # add reverse connections to graph
        if graph.key?(value)
          graph[value] << key
        else
          graph[value] = [key]
        end
      end
    end
  end
end

advent = Advent.new(input)
advent.solve
