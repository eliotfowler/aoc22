import Foundation

let day1 = Day { part, input in 
  switch part { 
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private func part1(_ input: String) -> Int {
  let mostCalories = input.components(separatedBy: "\n\n")
    .map { elfLines in 
      elfLines
        .components(separatedBy: "\n")
        .compactMap(Int.init)
        .reduce(0, +)
    }
    .sorted()
    .last ?? -1
  
  return mostCalories
}

private func part2(_ input: String) -> Int {
  let mostCalories = input.components(separatedBy: "\n\n")
    .map { elfLines in 
      elfLines
        .components(separatedBy: "\n")
        .compactMap(Int.init)
        .reduce(0, +)
    }
    .sorted(by: >)[0 ... 2]
    .reduce(0, +)
  
  return mostCalories
}
