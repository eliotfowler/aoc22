import Foundation

let day9 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

struct Instruction {
  enum Direction: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
  }
  
  let direction: Direction
  let steps: Int
}

struct Location: Hashable {
  var x = 0
  var y = 0
}

struct Step: Hashable {
  var head = Location()
  var tail = Location()
  
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
        
        let newTail = Self.newTailLocation(currentStep.tail, headLocation: newHead)
        let newStep = Step(head: newHead, tail: newTail)
        steps.append(newStep)
        return (newStep, steps)
      }
      .1
  }
  
  static func newTailLocation(_ currentTailLocation: Location, headLocation: Location) -> Location {
    let xDiff = currentTailLocation.x - headLocation.x
    let yDiff = currentTailLocation.y - headLocation.y
    guard abs(xDiff) > 1 || abs(yDiff) > 1 else { return currentTailLocation }
    let newX: Int
    let newY: Int
    if xDiff == 0 {
      newX = currentTailLocation.x
      newY = yDiff > 0 ? currentTailLocation.y - 1 : currentTailLocation.y + 1
    } else if yDiff == 0 {
      newX = xDiff > 0 ? currentTailLocation.x - 1 : currentTailLocation.x + 1
      newY = currentTailLocation.y
    } else {
      newX = xDiff > 0 ? currentTailLocation.x - 1 : currentTailLocation.x + 1
      newY = yDiff > 0 ? currentTailLocation.y - 1 : currentTailLocation.y + 1
    }
    
    return Location(x: newX, y: newY)
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
    var newSteps = currentStep.followingInstruction(instruction)
    let newStep = newSteps.last!
    steps = steps.union(newSteps)
    return (newStep, steps)
  }
  
  return Set(steps.1.map(\.tail)).count
}

private func part2(_ input: String) -> Int {
  0
}
