import Foundation

let day4 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> Int {
  input
    .components(separatedBy: "\n")
    .map { pair -> Bool in
      let ranges = pair
        .components(separatedBy: ",")
        .map(ClosedRange<Int>.init(rangeString:))
      
      return ranges[0].partlyOverlaps(ranges[1])
    }
    .reduce(0) { $0 + ($1 ? 1 : 0) }
}

private func part2(_ input: String) -> Int {
  input
    .components(separatedBy: "\n")
    .map { pair -> Bool in
      let ranges = pair
        .components(separatedBy: ",")
        .map(ClosedRange<Int>.init(rangeString:))
      
      return ranges[0].overlaps(ranges[1])
    }
    .reduce(0) { $0 + ($1 ? 1 : 0) }
}

private extension ClosedRange<Int> {
  init(rangeString: String) {
    let rangeParts = rangeString.components(separatedBy: "-")
      .compactMap(Int.init)
    self = rangeParts[0] ... rangeParts[1]
  }
  
  func partlyOverlaps(_ other: Self) -> Bool {
    self.clamped(to: other) == self || other.clamped(to: self) == other
  }
}
