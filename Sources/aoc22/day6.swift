import Foundation

let day6 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> Int {
  findMarkerLength(uniqueNum: 4, message: input)
}

private func part2(_ input: String) -> Int {
  findMarkerLength(uniqueNum: 14, message: input)
}

private func findMarkerLength(uniqueNum: Int, message: String) -> Int {
  var i = 0
  while i < message.count - uniqueNum {
    let start = message.index(message.startIndex, offsetBy: i)
    let end = message.index(start, offsetBy: uniqueNum)
    let substring = message[start ..< end]
    if Set(substring).count == uniqueNum {
      return i + uniqueNum
    }
    
    i += 1
  }
  
  return -1
}
