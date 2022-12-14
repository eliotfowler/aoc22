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
    .map { Array($0).compactMap { Int(String($0)) } }
  
  let leftIndexes = (0 ..< rows.count).flatMap { row in (0 ..< rows.count).map { column in (row, column) } }
  let lookingLeft = scanForVisibleTrees(rows: rows, indexes: leftIndexes)
  
  let rightIndexes = (0 ..< rows.count).flatMap { row in (0 ..< rows.count).reversed().map { column in (row, column) } }
  let lookingRight = scanForVisibleTrees(rows: rows, indexes: rightIndexes)
  
  let upIndexes = (0 ..< rows.count).flatMap { column in (0 ..< rows.count).map { row in (row, column) } }
  let lookingUp = scanForVisibleTrees(rows: rows, indexes: upIndexes)
  
  let downIndexes = (0 ..< rows.count).flatMap { column in (0 ..< rows.count).reversed().map { row in (row, column) } }
  let lookingDown = scanForVisibleTrees(rows: rows, indexes: downIndexes)
  
  return rows.enumerated()
    .flatMap { rowIndex, row in
      row.enumerated().map { columnIndex, _ in
        lookingLeft[rowIndex][columnIndex] || lookingRight[rowIndex][columnIndex] ||
        lookingUp[rowIndex][columnIndex] || lookingDown[rowIndex][columnIndex]
      }
    }
    .reduce(0) { $0 + ($1 ? 1 : 0)}
}

private func scanForVisibleTrees(rows: [[Int]], indexes: [(Int, Int)]) -> [[Bool]] {
  var visibleTrees = Array(repeating: Array(repeating: false, count: rows.count), count: rows.count)
  var runningMax = -1
  for (rowIndex, columnIndex) in indexes {
    let tree = rows[rowIndex][columnIndex]
    if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
      visibleTrees[rowIndex][columnIndex] = true
      runningMax = tree
    } else {
      visibleTrees[rowIndex][columnIndex] = tree > runningMax ? true : false
      runningMax = max(runningMax, tree)
    }
  }
  
  return visibleTrees
}

private func part2(_ input: String) -> Int {
  let rows = input
    .components(separatedBy: "\n")
    .map { Array($0).compactMap { Int(String($0)) } }
  
  let leftIndexes = (0 ..< rows.count - 1).flatMap { row in (0 ..< rows.count).map { column in (row, column) } }
  let lookingLeft = scanForScenicViews(rows: rows, indexes: leftIndexes)
  
  let rightIndexes = (0 ..< rows.count - 1).flatMap { row in (0 ..< rows.count).reversed().map { column in (row, column) } }
  let lookingRight = scanForScenicViews(rows: rows, indexes: rightIndexes)
  
  let upIndexes = (0 ..< rows.count - 1).flatMap { column in (0 ..< rows.count).map { row in (row, column) } }
  let lookingUp = scanForScenicViews(rows: rows, indexes: upIndexes)
  
  let downIndexes = (0 ..< rows.count - 1).flatMap { column in (0 ..< rows.count).reversed().map { row in (row, column) } }
  let lookingDown = scanForScenicViews(rows: rows, indexes: downIndexes)
  
  return rows.enumerated().flatMap { rowIndex, row in
    row.enumerated().map { columnIndex, _ in
      lookingLeft[rowIndex][columnIndex].numVisible * lookingRight[rowIndex][columnIndex].numVisible *
        lookingUp[rowIndex][columnIndex].numVisible * lookingDown[rowIndex][columnIndex].numVisible
    }
  }
  .reduce(0, max)
}

private typealias ScenicView = (numVisible: Int, blockedByIndex: Int)
private func scanForScenicViews(rows: [[Int]], indexes: [(Int, Int)]) -> [[ScenicView]] {
  var scenicViews: [[ScenicView]] = Array(repeating: Array(repeating: (0, 0), count: rows.count), count: rows.count)
  for (index, (rowIndex, columnIndex)) in indexes.enumerated() {
    if rows.isElementOnEdge(row: rowIndex, column: columnIndex) {
      scenicViews[rowIndex][columnIndex] = (numVisible: 0, blockedByIndex: 0)
    } else {
      let treeHeight = rows[rowIndex][columnIndex]
      var prevIndex = index - 1
      var numVisible = 1
      while treeHeight > rows[indexes[prevIndex].0][indexes[prevIndex].1], prevIndex > 0 {
        let prevItem = scenicViews[indexes[prevIndex].0][indexes[prevIndex].1]
        numVisible += prevItem.numVisible
        prevIndex = prevItem.blockedByIndex
      }
      scenicViews[rowIndex][columnIndex] = (numVisible: numVisible, blockedByIndex: prevIndex)
    }
  }
  
  return scenicViews
}

private extension Array where Element == Array<Int> {
  func isElementOnEdge(row: Int, column: Int) -> Bool {
    row == 0 || column == 0 || row == self.count - 1 || column == self[0].count - 1
  }
}
