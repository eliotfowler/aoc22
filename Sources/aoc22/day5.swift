import Foundation

let day5 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> String {
  let inputParts = input.components(separatedBy: "\n\n")
  let gridLines = Array(inputParts[0]
    .components(separatedBy: "\n")
    .dropLast(1))
  var stacks = createStacks(gridLines)
  let instructions = createInstructions(inputParts[1])
  for move in instructions {
    let item = stacks[move.0 - 1].removeFirst()
    stacks[move.1 - 1].insert(item, at: 0)
  }
  return stacks.compactMap(\.first).joined()
}

private func part2(_ input: String) -> String {
  let inputParts = input.components(separatedBy: "\n\n")
  let gridLines = Array(inputParts[0]
    .components(separatedBy: "\n")
    .dropLast(1))
  var stacks = createStacks(gridLines)
  let instructions = createInstructionsPart2(inputParts[1])
  for move in instructions {
    let items = stacks[move.1 - 1][0 ..< move.0]
    stacks[move.1 - 1].removeFirst(move.0)
    stacks[move.2 - 1].insert(contentsOf: items, at: 0)
  }
  return stacks.compactMap(\.first).joined()
}

///     [D]
/// [N] [C]
/// [Z] [M] [P]
private func createStacks(_ grid: [String]) -> [[String]] {
  let stackLines = grid.map(parseStackLine)
  var stacks = [[String]]()
  for i in 0 ..< stackLines[0].count {
    var stack = [String]()
    stackLines.forEach { if $0[i] != "" { stack.append($0[i]) } }
    stacks.append(stack)
  }
  return stacks
}

/// [N] [C]
///
/// ["N", "C", ""]
private func parseStackLine(_ stackLine: String) -> [String] {
  var currentIndexOffset = 0
  var stack = [String]()
  while currentIndexOffset < stackLine.count {
    let currentIndex = stackLine.index(stackLine.startIndex, offsetBy: currentIndexOffset)
    if stackLine[currentIndex] == "[" {
      stack.append(String(stackLine[stackLine.index(after: currentIndex)]))
    } else {
      stack.append("")
    }
    
    currentIndexOffset += 4
  }
  
  return stack
}

/// move 3 from 1 to 3
/// move 1 from 2 to 1
///
/// -> [(1, 3), (1, 3), (1, 3), (2, 1)]
private func createInstructions(_ instructionList: String) -> [(Int, Int)] {
  instructionList
    .components(separatedBy: "\n")
    .flatMap(parseInstructions)
}

/// move 3 from 1 to 3
///
/// -> [(1, 3), (1, 3), (1, 3), (2, 1)]
private func parseInstructions(_ line: String) -> [(Int, Int)] {
  let intParts = line
    .components(separatedBy: " ")
    .compactMap(Int.init)
  
  return Array(repeating: (intParts[1], intParts[2]), count: intParts[0])
}

// MARK: - Part 2
private func createInstructionsPart2(_ instructionList: String) -> [(Int, Int, Int)] {
  instructionList
    .components(separatedBy: "\n")
    .map(parseInstructionsPart2)
}

private func parseInstructionsPart2(_ line: String) -> (Int, Int, Int) {
  let intParts = line
    .components(separatedBy: " ")
    .compactMap(Int.init)
  
  return (intParts[0], intParts[1], intParts[2])
}
