import Foundation

let day14 = Day { part, input in 
  switch part {
  case .one: return part1(input)
  case .two: return part2(input)
  }
}

private func part1(_ input: String) -> Int {
  let lines = parseLines(input)
  var (grid, sandColumn) = createGrid(lines)
  var numSandDropped = 0
  while dropSand(grid: &grid, sandColumn: sandColumn) { numSandDropped += 1 }
  return numSandDropped
}

private func part2(_ input: String) -> Int {
  let lines = parseLines(input)
  var (grid, sandColumn) = createGrid(lines, addFloor: true)
  var numSandDropped = 0
  while dropSand(grid: &grid, sandColumn: sandColumn, hasFloor: true) {
    numSandDropped += 1
  }
  return numSandDropped
}

// MARK: - Data Structures
private struct Line {
  private enum Orientation {
    case horizontal
    case vertical
  }

  let start: Point
  let end: Point
  
  private var orientation: Orientation {
    start.y == end.y ? .horizontal : .vertical
  }
  
  var points: [Point] {
    switch orientation {
    case .horizontal:
      let range = start.x < end.x ? start.x ... end.x : end.x ... start.x
      return range.map { .init(x: $0, y: start.y) }
    case .vertical:
      let range = start.y < end.y ? start.y ... end.y : end.y ... start.y
      return range.map { .init(x: start.x, y: $0) }
    }
  }
}

private struct Point {
  let x: Int
  let y: Int
}

private enum GridElement: String, Equatable {
  case air = "."
  case rock = "#"
  case sand = "o"
}

// MARK: - Helper Functions
private func printGrid(_ grid: [[GridElement]]) {
  print(
    grid.map { line in line.map(\.rawValue).joined() }.joined(separator: "\n")
  )
}

private func parseLines(_ input: String) -> [Line] {
  input
    .components(separatedBy: "\n")
    .flatMap { line in
      line.components(separatedBy: " -> ")
        .map(Point.init)
        .reduce((previous: Point?.none, lines: [Line]())) { result, current in
          let (previous, lines) = result
          guard let previous else { return (current, lines) }
          return (previous: current, lines: lines + [.init(start: previous, end: current)])
        }
        .lines
    }
}

private func normalizeLines(_ lines: [Line], minX: Int, horizontalPadding: Int) -> [Line] {
  lines.map { line in
    Line(start: .init(x: line.start.x - minX + horizontalPadding, y: line.start.y),
         end: .init(x: line.end.x - minX + horizontalPadding, y: line.end.y))
  }
}

private func createGrid(_ lines: [Line], addFloor: Bool = false) -> ([[GridElement]], Int) {
  let minX = lines.reduce(Int.max) { Swift.min($0, Swift.min($1.start.x, $1.end.x)) }
  let maxX = lines.reduce(0) { max($0, max($1.start.x, $1.end.x)) }
  var maxY = lines.reduce(0) { max($0, max($1.start.y, $1.end.y)) }
  if addFloor { maxY += 2 }
  let horizontalCountForHeight = maxY * 2 + ((500-minX) * 2)
  let minHorizontalCount = maxX - minX + 1
  let horizontalCount = addFloor ? max(minHorizontalCount, horizontalCountForHeight) : minHorizontalCount
  let horizontalPadding = addFloor ? (horizontalCount - minHorizontalCount) / 2 : 0
  let normalizedLines = normalizeLines(lines, minX: minX, horizontalPadding: horizontalPadding)
  let sandColumn = 500 - minX + horizontalPadding
  var grid = Array(repeating: Array(repeating: GridElement.air, count: horizontalCount), count: maxY + 1)
  for line in normalizedLines {
    for point in line.points {
      grid[point.y][point.x] = .rock
    }
  }
  
  if addFloor {
    grid[grid.count - 1] = Array(repeating: GridElement.rock, count: horizontalCount)
  }
  
  return (grid, sandColumn)
}

private func dropSand(grid: inout [[GridElement]], sandColumn: Int, hasFloor: Bool = false) -> Bool {
  guard let nextPoint = nextSandSpot(grid: grid, proposed: Point(x: sandColumn, y: 0), hasFloor: hasFloor)
  else { return false }
  grid[nextPoint.y][nextPoint.x] = .sand
  return true
}

private func nextSandSpot(grid: [[GridElement]], proposed: Point, hasFloor: Bool) -> Point? {
  guard
    let down = proposed.safeDown(grid),
    let left = proposed.safeDownLeft(grid),
    let right = proposed.safeDownRight(grid)
  else {
    if hasFloor && grid[proposed.y][proposed.x] == .air {
      return proposed
    } else {
      return nil
    }
  }
  
  if grid[down.y][down.x] == .air {
    return nextSandSpot(grid: grid, proposed: down, hasFloor: hasFloor)
  } else if grid[left.y][left.x] == .air {
    return nextSandSpot(grid: grid, proposed: left, hasFloor: hasFloor)
  } else if grid[right.y][right.x] == .air {
    return nextSandSpot(grid: grid, proposed: right, hasFloor: hasFloor)
  } else if grid[proposed.y][proposed.x] == .air {
    return proposed
  } else {
    return nil
  }
}

// MARK: - Extensions

private extension Point {
  init(_ input: String) {
    let parts = input.components(separatedBy: ",")
    self.x = Int(parts[0])!
    self.y = Int(parts[1])!
  }
  
  func safeDown(_ grid: [[GridElement]]) -> Point? {
    guard self.y < grid.count - 1 else { return nil }
    return .init(x: self.x, y: self.y + 1)
  }
  
  func safeDownRight(_ grid: [[GridElement]]) -> Point? {
    guard self.x < grid[0].count - 1, self.y < grid.count - 1 else { return nil }
    return .init(x: self.x + 1, y: self.y + 1)
  }
  
  func safeDownLeft(_ grid: [[GridElement]]) -> Point? {
    guard self.x > 0, self.y < grid.count - 1 else { return nil }
    return .init(x: self.x - 1, y: self.y + 1)
  }
}
