import Foundation

let day13 = Day { part, input in 
  switch part {
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private func parsePacketPairs(_ input: String) -> [[Packet]] {
  input
    .components(separatedBy: "\n\n")
    .map { pair in
      pair
        .components(separatedBy: "\n")
        .map { parseList(Array($0)).0 }
    }
}

private func part1(_ input: String) -> Int {
  parsePacketPairs(input)
    .map { packets in
      compare(left: packets[0], right: packets[1])
    }
    .enumerated()
    .filter { $0.element == .lessThan }
    .map { ($0.offset + 1, $0.element) }
    .map(\.0)
    .reduce(0, +)
}

private func part2(_ input: String) -> Int {
  let divider1 = Packet.list([.list([.value(2)])])
  let divider2 = Packet.list([.list([.value(6)])])
  let allPackets = (parsePacketPairs(input).flatMap { $0 } + [divider1, divider2])
    .sorted()
    
  let decoder1 = (allPackets.firstIndex(of: divider1) ?? -1) + 1
  let decoder2 = (allPackets.firstIndex(of: divider2) ?? -1) + 1
  return decoder1 * decoder2
}

private func parseList(_ line: [Character]) -> (Packet, remaining: [Character]) {
  var line = line
  var items: [Packet] = []
  var digits: [Int] = []
  while !line.isEmpty {
    let next = line[0]
    if let nextInt = Int(String(next)) {
      line.removeFirst()
      digits.append(nextInt)
    } else if !digits.isEmpty {
      let value = digits.reduce(0) { $0 * 10 + $1 }
      items.append(.value(value))
      digits = []
    }
    
    if next == "[" {
      line.removeFirst()
      let (packet, remaining) = parseList(line)
      items.append(packet)
      line = remaining
    } else if next == "," {
      line.removeFirst()
    } else if next == "]" {
      line.removeFirst()
      return (.list(items), line)
    }
  }
  
  return (items[0], remaining: [])
}

private enum ComparisonResult: String, Equatable, CustomDebugStringConvertible {
  case equal = "="
  case lessThan = "<"
  case greaterThan = ">"
  
  var debugDescription: String { rawValue }
}

private func compare(left: Packet, right: Packet) -> ComparisonResult {
  switch (left, right) {
  case let (.value(leftValue), .value(rightValue)):
    return leftValue == rightValue ? .equal :
      leftValue < rightValue ?
      .lessThan : .greaterThan
  case let (.list(leftList), .list(rightList)):
    for (leftPacket, rightPacket) in zip(leftList, rightList) {
      switch compare(left: leftPacket, right: rightPacket) {
      case .greaterThan:
        return .greaterThan
      case .lessThan:
        return .lessThan
      case .equal:
        continue
      }
    }
    
    return leftList.count == rightList.count ? .equal :
      leftList.count < rightList.count ? .lessThan : .greaterThan
    
  case (.list, .value):
    return compare(left: left, right: .list([right]))
  case (.value, .list):
    return compare(left: .list([left]), right: right)
  }
}

private indirect enum Packet: CustomDebugStringConvertible, Comparable {
  static func < (lhs: Packet, rhs: Packet) -> Bool {
    compare(left: lhs, right: rhs) == .lessThan
  }
  
  case value(Int)
  case list([Packet])
  
  var debugDescription: String {
    switch self {
    case .value(let num): return "\(num)"
    case .list(let packets):
      return "[\(packets.map(\.debugDescription).joined(separator: ","))]"
    }
  }
}
