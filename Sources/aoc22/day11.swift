import Foundation

let day11 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

typealias Value = Int

private extension Decimal {
  func isDivisible(by other: Decimal) -> Bool {
    let result = self / other
    print("\(self) / \(other): \(result), description: \(description)")
    return !result.description.contains(".")
  }
}

private enum Operation: Equatable {
  enum Part: Equatable {
    case old
    case num(Value)
    
    func value(_ old: Value) -> Value {
      switch self {
      case .old: return old
      case .num(let num): return num
      }
    }
    
    init(_ input: String) {
      if let num = Value(input) {
        self = .num(num)
      } else {
        self = .old
      }
    }
  }

  case add(Part, Part)
  case multiply(Part, Part)
  
  func calculate(_ old: Value) -> Value {
    guard self != .multiply(.old, .old) else { return old }
    switch self {
    case let .add(left, right):
      return left.value(old) + right.value(old)
    case let .multiply(left, right):
      return left.value(old) * right.value(old)
    }
  }
  
  init?(_ input: String) {
    guard let rightSide = input.components(separatedBy: "=").dropFirst().first?.components(separatedBy: " ").dropFirst()
    else { return nil }
    let part1 = Part(rightSide[rightSide.startIndex])
    let part2 = Part(rightSide[rightSide.startIndex.advanced(by: 2)])
    if rightSide[rightSide.startIndex.advanced(by: 1)] == "+" {
      self = .add(part1, part2)
    } else if rightSide[rightSide.startIndex.advanced(by: 1)] == "*" {
      self = .multiply(part1, part2)
    } else {
      return nil
    }
  }
}

private struct Monkey {
  var itemWorries: [Value]
  var transform: Operation
  var monkeyToThrow: (Value) -> Int
}

private func parseMonkey(_ input: String) -> Monkey {
  let lines = Array(input.components(separatedBy: "\n").dropFirst())
  let items = Array(lines[0].components(separatedBy: ": ").dropFirst())[0].components(separatedBy: ", ").compactMap { Value($0) }
  let operation = Operation(lines[1])!
  let divisibleBy = lines[2].components(separatedBy: "by ").compactMap({ Value($0) })[0]
  let monkeyIfTrue = lines[3].components(separatedBy: " ").compactMap(Int.init)[0]
  let monkeyIfFalse = lines[4].components(separatedBy: " ").compactMap(Int.init)[0]
  let monkeyToThrow = { (worry: Value) in
    worry % divisibleBy == 0 ? monkeyIfTrue : monkeyIfFalse
  }
  
  return Monkey(itemWorries: items, transform: operation, monkeyToThrow: monkeyToThrow)
}

private func completeRound(_ monkeys: [Monkey], numInspections: ([Int]), shouldDivide: Bool = true) -> ([Monkey], [Int]) {
  var monkeys = monkeys
  var numInspections = numInspections
  
  for i in 0 ..< monkeys.count {
    while monkeys[i].itemWorries.count > 0 {
      numInspections[i] += 1
      let item = monkeys[i].itemWorries.removeFirst()
      let newWorry = monkeys[i].transform.calculate(item)
//      let newWorryManaged = shouldDivide ? Int(Double(newWorry) / 3.0) : newWorry
      let newMonkey = monkeys[i].monkeyToThrow(newWorry)
      monkeys[newMonkey].itemWorries.append(newWorry)
    }
  }
  
  return (monkeys, numInspections)
}

private func part1(_ input: String) -> Int {
  var monkeys = input.components(separatedBy: "\n\n").map(parseMonkey)
  var numInspections = Array(repeating: 0, count: monkeys.count)
  for _ in 0 ..< 20 {
    (monkeys, numInspections) = completeRound(monkeys, numInspections: numInspections)
  }
  
  let sortedInspections = numInspections.sorted { $0 > $1 }
  return sortedInspections[0] * sortedInspections[1]
}

private func part2(_ input: String) -> Int {
  var monkeys = input.components(separatedBy: "\n\n").map(parseMonkey)
  var numInspections = Array(repeating: 0, count: monkeys.count)
  for i in 0 ..< 20 {
    print(i)
    (monkeys, numInspections) = completeRound(monkeys, numInspections: numInspections, shouldDivide: false)
  }
  
  let sortedInspections = numInspections.sorted { $0 > $1 }
  print(numInspections)
  return sortedInspections[0] * sortedInspections[1]
}
