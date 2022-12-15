import Foundation

let day12 = Day { part, input in 
  switch part {
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private func part1(_ input: String) -> Int {
  let graph = createGraph(input)
  let (distance, _) = graph.findShortestGoalPath() ?? (-1, [])
  return distance
}

private func part2(_ input: String) -> Int {
  let graph = createGraph(input)
  let possibleStarts = graph.allNodes.filter { $0.value == "a" }
  let paths = possibleStarts.compactMap(graph.findShortestGoalPath(from:))
  let shortestPath = paths.reduce(Int.max) { Swift.min($0, $1.0) }
  return shortestPath
}

private func createGraph(_ input: String) -> Graph {
  let nodes = input
    .components(separatedBy: "\n")
    .map(Array.init)
    .enumerated()
    .map { rowIndex, row in
      let rowCount = row.count
      return row.enumerated().map { columnIndex, letter in
        Node(String(letter), rowIndex * rowCount + columnIndex)
      }
    }
  
  let allNodes = nodes.flatMap { $0 }
  let root = allNodes.filter { $0.value == "S" }[0]
  let goal = allNodes.filter { $0.value == "E" }[0]
  
  root.value = "a"
  goal.value = "z"
  
  for rowIndex in 0 ..< nodes.count {
    for columnIndex in 0 ..< nodes[0].count {
      let currentNode = nodes[rowIndex][columnIndex]
      
      // up
      if let up = nodes.upFrom(row: rowIndex, column: columnIndex), up.value <= currentNode.maxNextValue {
        currentNode.edges.append(up)
      }
      
      // down
      if let down = nodes.downFrom(row: rowIndex, column: columnIndex), down.value <= currentNode.maxNextValue {
        currentNode.edges.append(down)
      }
      
      // left
      if let left = nodes.leftFrom(row: rowIndex, column: columnIndex), left.value <= currentNode.maxNextValue {
        currentNode.edges.append(left)
      }
      
      // right
      if let right = nodes.rightFrom(row: rowIndex, column: columnIndex), right.value <= currentNode.maxNextValue {
        currentNode.edges.append(right)
      }
    }
  }
  
  return .init(root: root, goal: goal, allNodes: allNodes)
}

private class Node: Hashable, Equatable, CustomDebugStringConvertible {
  static func == (lhs: Node, rhs: Node) -> Bool {
    lhs.value == rhs.value && lhs.position == rhs.position
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(value)
    hasher.combine(position)
  }
  
  var value: String
  let position: Int
  var edges: [Node] = []
  
  init(_ value: String, _ position: Int) {
    self.value = value
    self.position = position
  }
  
  var debugDescription: String { "\(position): \(value), edges: \(edges.map(\.value))" }
}

private class Graph {
  let root: Node
  let goal: Node
  let allNodes: [Node]
  
  init(root: Node, goal: Node, allNodes: [Node]) {
    self.root = root
    self.goal = goal
    self.allNodes = allNodes
  }
}

private extension Graph {
  func findShortestGoalPath() -> (Int, [Node])? {
    findShortestGoalPath(from: self.root)
  }
  
  func findShortestGoalPath(from start: Node) -> (Int, [Node])? {
    var visited: [Node: Int] = [:]
    var queue = [(start, 0, [Node]())]
    
    while !queue.isEmpty {
      let (node, distance, path) = queue.removeFirst()
      guard node != self.goal else {
        return (distance, path + [start])
      }
      visited[node] = distance
      let nextNodes = node.edges
        .filter { nextNode in
          (visited[nextNode] ?? Int.max) > distance && !queue.contains(where: { $0.0 == node })
        }
        .map { ($0, distance + 1, path + [node]) }
      
      queue.append(contentsOf: nextNodes)
    }
    
    return nil
  }
}

private extension Array where Element == [Node] {
  func upFrom(row rowIndex: Int, column columnIndex: Int) -> Node? {
    guard rowIndex > 0 else { return nil }
    return self[rowIndex - 1][columnIndex]
  }
  
  func downFrom(row rowIndex: Int, column columnIndex: Int) -> Node? {
    guard rowIndex < self.count - 1 else { return nil }
    return self[rowIndex + 1][columnIndex]
  }
  
  func leftFrom(row rowIndex: Int, column columnIndex: Int) -> Node? {
    guard columnIndex > 0 else { return nil }
    return self[rowIndex][columnIndex - 1]
  }
  
  func rightFrom(row rowIndex: Int, column columnIndex: Int) -> Node? {
    guard columnIndex < self[rowIndex].count - 1 else { return nil }
    return self[rowIndex][columnIndex + 1]
  }
}

private extension Node {
  var maxNextValue: String { String(UnicodeScalar(self.value[self.value.startIndex].asciiValue! + 1)) }
}
