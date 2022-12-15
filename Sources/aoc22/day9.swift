import Foundation

let day9 = Day { part, input in
  switch part {
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private struct Instruction {
  enum Direction: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
  }
  
  let direction: Direction
  let steps: Int
}

private struct Location: Hashable {
  var x = 0
  var y = 0
  
  func newTailLocation(previousLocation: Location) -> Location {
    let xDiff = self.x - previousLocation.x
    let yDiff = self.y - previousLocation.y
    guard abs(xDiff) > 1 || abs(yDiff) > 1 else { return self }
    let newX: Int
    let newY: Int
    if xDiff == 0 {
      newX = self.x
      newY = yDiff > 0 ? self.y - 1 : self.y + 1
    } else if yDiff == 0 {
      newX = xDiff > 0 ? self.x - 1 : self.x + 1
      newY = self.y
    } else {
      newX = xDiff > 0 ? self.x - 1 : self.x + 1
      newY = yDiff > 0 ? self.y - 1 : self.y + 1
    }
    
    return Location(x: newX, y: newY)
  }
}

private struct Step: Hashable {
  var knots: [Location]
  var head: Location { knots[0] }
  var tail: Location { knots[knots.count - 1] }
  var tails: [Location] { Array(knots[1...]) }
  
  func followingInstruction(_ instruction: Instruction) -> [Step] {
    Array(repeating: instruction.direction, count: instruction.steps)
      .reduce((self, [Step]())) { result, direction in
        var (currentStep, steps) = result
        let newHead: Location
        switch direction {
        case .up:
          newHead = .init(x: currentStep.head.x, y: currentStep.head.y + 1)
        case .down:
          newHead = .init(x: currentStep.head.x, y: currentStep.head.y - 1)
        case .left:
          newHead = .init(x: currentStep.head.x - 1, y: currentStep.head.y)
        case .right:
          newHead = .init(x: currentStep.head.x + 1, y: currentStep.head.y)
        }
        
        var previous = newHead
        var newTails = currentStep.tails
        for i in 0 ..< newTails.count {
          let newTail = newTails[i].newTailLocation(previousLocation: previous)
          guard newTail != newTails[i] else { break }
          newTails[i] = newTail
          previous = newTail
        }
        
        let newStep = Step(head: newHead, tails: Array(newTails))
        steps.append(newStep)
        return (newStep, steps)
      }
      .1
  }
}

private extension Step {
  init(head: Location = .init(), tail: Location = .init()) {
    self.knots = [head, tail]
  }
  
  init(head: Location = .init(), numTails: Int) {
    self.knots = [head] + Array(repeating: Location(), count: numTails)
  }
  
  init(head: Location, tails: [Location]) {
    self.knots = [head] + tails
  }
}

private func part1(_ input: String) -> Int {
  let instructions = input
    .components(separatedBy: "\n")
    .compactMap { line -> Instruction? in
      let parts = line.components(separatedBy: " ")
      guard let direction = Instruction.Direction(rawValue: parts[0]), let count = Int(parts[1]) else { return nil }
      return Instruction(direction: direction, steps: count)
    }
  
  let steps = instructions.reduce((Step(), Set<Step>())) { result, instruction in
    var (currentStep, steps) = result
    steps.insert(currentStep)
    let newSteps = currentStep.followingInstruction(instruction)
    let newStep = newSteps.last!
    steps = steps.union(newSteps)
    return (newStep, steps)
  }
  
  return Set(steps.1.map(\.tail)).count
}

private func part2(_ input: String) -> Int {
  let instructions = input
    .components(separatedBy: "\n")
    .compactMap { line -> Instruction? in
      let parts = line.components(separatedBy: " ")
      guard let direction = Instruction.Direction(rawValue: parts[0]), let count = Int(parts[1]) else { return nil }
      return Instruction(direction: direction, steps: count)
    }
  
  let steps = instructions.reduce((Step(head: Location(), numTails: 9), Set<Step>())) { result, instruction in
    var (currentStep, steps) = result
    steps.insert(currentStep)
    let newSteps = currentStep.followingInstruction(instruction)
    let newStep = newSteps.last!
    steps = steps.union(newSteps)
    return (newStep, steps)
  }
  
  return Set(steps.1.map(\.tail)).count
}
