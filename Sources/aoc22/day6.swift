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
  var start = message.startIndex
  var end = message.index(message.startIndex, offsetBy: uniqueNum)
  let lastIndex = message.index(message.endIndex, offsetBy: -uniqueNum)
  while start <= lastIndex {
    let substring = message[start ..< end]
    if Set(substring).count == uniqueNum {
      return message.distance(from: message.startIndex, to: end)
    }
    
    start = message.index(after: start)
    end = message.index(after: end)
  }
  
  return -1
}
