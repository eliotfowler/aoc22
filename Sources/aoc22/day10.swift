import Foundation

let day10 = Day { part, input in
  switch part {
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private struct Cycle {
  var totalBefore: Int
  var valueToAdd: Int
  
  func isLit(at index: Int) -> Bool {
    (totalBefore - 1 ... totalBefore + 1).contains(index % 40)
  }
}

private func parseCycles(_ input: String) -> [Cycle] {
  input
    .components(separatedBy: "\n")
    .map { line -> Int? in
      let parts = line.components(separatedBy: " ")
      guard parts.count == 2 else { return nil }
      return Int(parts[1])
    }
    .reduce([Cycle]()) { cycles, valueToAdd in
      var runningTotal = 1
      if let lastCycle = cycles.last {
        runningTotal = lastCycle.totalBefore + lastCycle.valueToAdd
      }
      
      var newCycles = [Cycle(totalBefore: runningTotal, valueToAdd: 0)]
      if let value = valueToAdd {
        newCycles.append(Cycle(totalBefore: runningTotal, valueToAdd: value))
      }
      
      return cycles + newCycles
    }
}

private func part1(_ input: String) -> Int {
  parseCycles(input)
    .interestingSignalStrengths
    .reduce(0, +)
}

private func part2(_ input: String) -> String {
  let screen = zip(parseCycles(input), 0 ..< 240).map { cycle, crtIndex in
    cycle.isLit(at: crtIndex) ? "#" : "."
  }
    .chunked(into: 40)
    .map { $0.joined() }
    .joined(separator: "\n")
  
  return "\n" + screen
}

private extension Array where Element == Cycle {
  var interestingSignalStrengths: [Int] {
    stride(from: 19, to: Swift.min(220, self.count - 1), by: 40).map { cycleNum in
      (cycleNum + 1) * self[cycleNum].totalBefore
    }
  }
}

private extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
