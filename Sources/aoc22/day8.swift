import Foundation

let day8 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> Int {
  let rows = input
    .components(separatedBy: "\n")
    .map { Array($0).map { (Int(String($0))!, Bool?.none) } }
  
  var lookingLeft = Array(repeating: Array(repeating: false, count: rows.count), count: rows.count)
  var lookingRight = Array(repeating: Array(repeating: false, count: rows.count), count: rows.count)
  var lookingUp = Array(repeating: Array(repeating: false, count: rows.count), count: rows.count)
  var lookingDown = Array(repeating: Array(repeating: false, count: rows.count), count: rows.count)
  
  for rowIndex in 0 ..< rows.count {
    let row = rows[rowIndex]
    var rowMax = -1
    for columnIndex in 0 ..< row.count {
      let tree = rows[rowIndex][columnIndex]
      lookingLeft[rowIndex][columnIndex] = tree.0 > rowMax ? true : false
      rowMax = max(rowMax, tree.0)
    }
  }
  
  for r in 0 ..< rows.count {
    let rowIndex = rows.count - 1 - r
    let row = rows[rowIndex]
    var rowMax = -1
    for c in 0 ..< row.count {
      let columnIndex = row.count - 1 - c
      let tree = rows[rowIndex][columnIndex]
      lookingRight[rowIndex][columnIndex] = tree.0 > rowMax ? true : false
      rowMax = max(rowMax, tree.0)
    }
  }
  
  for columnIndex in 0 ..< rows[0].count {
    var columnMax = -1
    for rowIndex in 0 ..< rows.count {
      let tree = rows[rowIndex][columnIndex]
      lookingUp[rowIndex][columnIndex] = tree.0 > columnMax ? true : false
      columnMax = max(columnMax, tree.0)
    }
  }
  
  for c in 0 ..< rows[0].count {
    let columnIndex = rows[0].count - 1 - c
    var columnMax = -1
    for r in 0 ..< rows.count {
      let rowIndex = rows.count - 1 - r
      let tree = rows[rowIndex][columnIndex]
      lookingDown[rowIndex][columnIndex] = tree.0 > columnMax ? true : false
      columnMax = max(columnMax, tree.0)
    }
  }
  
  let numVisible = rows.enumerated().flatMap { rowIndex, row in
    row.enumerated().map { columnIndex, _ in
      lookingLeft[rowIndex][columnIndex] || lookingRight[rowIndex][columnIndex] ||
      lookingUp[rowIndex][columnIndex] || lookingDown[rowIndex][columnIndex]
    }
  }
    .reduce(0) { $0 + ($1 ? 1 : 0)}
  
  return numVisible
}

typealias ScenicView = (numVisible: Int, blockedByIndex: Int)

private func part2(_ input: String) -> Int {
  let rows = input
    .components(separatedBy: "\n")
    .map { Array($0).compactMap { Int(String($0)) } }
  
  
  let lookingLeft = part2LookingLeft(rows: rows)
  let lookingRight = part2LookingRight(rows: rows)
  let lookingUp = part2LookingUp(rows: rows)
  let lookingDown = part2LookingDown(rows: rows)
  
  var maxScenicScore = 0
  for rowIndex in 0 ..< rows.count {
    for columnIndex in 0 ..< rows[rowIndex].count {
      let score = lookingLeft[rowIndex][columnIndex].numVisible * lookingRight[rowIndex][columnIndex].numVisible *
        lookingUp[rowIndex][columnIndex].numVisible * lookingDown[rowIndex][columnIndex].numVisible
      maxScenicScore = max(maxScenicScore, score)
    }
  }
  
  return maxScenicScore
}

private func part2LookingLeft(rows: [[Int]]) -> [[ScenicView]] {
  var lookingLeft: [[ScenicView]] = Array(repeating: Array(repeating: (0, 0), count: rows.count), count: rows.count)
  for rowIndex in 0 ..< rows.count {
    let row = rows[rowIndex]
    for columnIndex in 0 ..< row.count {
      if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
        lookingLeft[rowIndex][columnIndex] = (numVisible: 0, blockedByIndex: 0)
      } else {
        let treeHeight = rows[rowIndex][columnIndex]
        var prevColumnIndex = columnIndex - 1
        var numVisible = 1
        while treeHeight > rows[rowIndex][prevColumnIndex], prevColumnIndex > 0 {
          let prevItem = lookingLeft[rowIndex][prevColumnIndex]
          numVisible += prevItem.numVisible
          prevColumnIndex = prevItem.blockedByIndex
        }
        lookingLeft[rowIndex][columnIndex] = (numVisible: numVisible, blockedByIndex: prevColumnIndex)
      }
    }
  }
  
  return lookingLeft
}

private func part2LookingRight(rows: [[Int]]) -> [[ScenicView]] {
  var lookingRight: [[ScenicView]] = Array(repeating: Array(repeating: (0, 0), count: rows.count), count: rows.count)
  for r in 0 ..< rows.count {
    let rowIndex = rows.count - 1 - r
    let row = rows[rowIndex]
    for c in 0 ..< row.count {
      let columnIndex = row.count - 1 - c
      if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
        lookingRight[rowIndex][columnIndex] = (numVisible: 0, blockedByIndex: 0)
      } else {
        let treeHeight = rows[rowIndex][columnIndex]
        var prevColumnIndex = columnIndex + 1
        var numVisible = 1
        while treeHeight > rows[rowIndex][prevColumnIndex], prevColumnIndex < row.count - 1 {
          let prevItem = lookingRight[rowIndex][prevColumnIndex]
          numVisible += prevItem.numVisible
          prevColumnIndex = prevItem.blockedByIndex
        }
        lookingRight[rowIndex][columnIndex] = (numVisible: numVisible, blockedByIndex: prevColumnIndex)
      }
    }
  }
  
  return lookingRight
}

private func part2LookingUp(rows: [[Int]]) -> [[ScenicView]] {
  var lookingUp: [[ScenicView]] = Array(repeating: Array(repeating: (0, 0), count: rows.count), count: rows.count)
  for columnIndex in 0 ..< rows[0].count {
    for rowIndex in 0 ..< rows.count {
      if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
        lookingUp[rowIndex][columnIndex] = (numVisible: 0, blockedByIndex: 0)
      } else {
        let treeHeight = rows[rowIndex][columnIndex]
        var prevRowIndex = rowIndex - 1
        var numVisible = 1
        while treeHeight > rows[prevRowIndex][columnIndex], prevRowIndex > 0 {
          let prevItem = lookingUp[prevRowIndex][columnIndex]
          numVisible += prevItem.numVisible
          prevRowIndex = prevItem.blockedByIndex
        }
        lookingUp[rowIndex][columnIndex] = (numVisible: numVisible, blockedByIndex: prevRowIndex)
      }
    }
  }
  
  return lookingUp
}

private func part2LookingDown(rows: [[Int]]) -> [[ScenicView]] {
  var lookingDown: [[ScenicView]] = Array(repeating: Array(repeating: (0, 0), count: rows.count), count: rows.count)
  for c in 0 ..< rows[0].count {
    let columnIndex = rows[0].count - 1 - c
    for r in 0 ..< rows.count {
      let rowIndex = rows.count - 1 - r
      if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
        lookingDown[rowIndex][columnIndex] = (numVisible: 0, blockedByIndex: 0)
      } else {
        let treeHeight = rows[rowIndex][columnIndex]
        var prevRowIndex = rowIndex + 1
        var numVisible = 1
        while treeHeight > rows[prevRowIndex][columnIndex], prevRowIndex < rows[0].count - 1 {
          let prevItem = lookingDown[prevRowIndex][columnIndex]
          numVisible += prevItem.numVisible
          prevRowIndex = prevItem.blockedByIndex
        }
        lookingDown[rowIndex][columnIndex] = (numVisible: numVisible, blockedByIndex: prevRowIndex)
      }
    }
  }
  
  return lookingDown
}

extension Array where Element == Array<Int> {
  func isElementOnEdge(row: Int, column: Int) -> Bool {
    row == 0 || column == 0 || row == self.count - 1 || column == self[0].count - 1
  }
}
