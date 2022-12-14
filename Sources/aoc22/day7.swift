import Foundation

let day7 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> UInt {
  let commands = parseCommands(input)
  let root = createNodes(commands)
  let sumOfSmallDirectories = root.allSubdirectories
    .map(\.size)
    .filter { $0 <= 100_000 }
    .reduce(0, +)
  
  return sumOfSmallDirectories
}

private func part2(_ input: String) -> UInt {
  let totalSpace: UInt = 70_000_000
  let neededSpace: UInt = 30_000_000
  let commands = parseCommands(input)
  let root = createNodes(commands)
  let usedSpace = root.size
  let remainingSpaceNeeded = neededSpace - (totalSpace - usedSpace)
  let dirToDelete = ([root] + root.allSubdirectories)
    .sorted(by: { $0.size < $1.size })
    .first(where: { $0.size >= remainingSpaceNeeded })
  return dirToDelete?.size ?? 0
}

private func parseCommands(_ input: String) -> [Command] {
  Array(input
    .components(separatedBy: "$ ")
    .dropFirst()
    .compactMap(Command.init)
    .dropFirst())
}

private func createNodes(_ commands: [Command]) -> Node {
  let root = Node(name: "/", parent: nil, kind: .directory(.init()))
  createNodes(node: root, commands: commands)
  return root
}

private func createNodes(node: Node, commands: [Command]) {
  var currentNode = node
  for command in commands {
    switch command {
    case let .ls(lines):
      currentNode.children = currentNode.children.union(Set(lines.map { Node(parent: currentNode, contents: $0) }))
    case let .cd(dir) where dir == "..":
      guard let parent = currentNode.parent else { continue }
      currentNode = parent
    case let .cd(dir):
      var children = currentNode.children
      let child = children.first(where: { $0.name == dir && $0.parent == currentNode }) ??
        .init(name: dir, parent: currentNode, kind: .directory(.init()))
      children.update(with: child)
      currentNode.children = children
      currentNode = child
    }
  }
}

private enum Command {
  case cd(String)
  case ls([String])
  
  init?(_ input: String) {
    let lines = input.components(separatedBy: "\n")
    let command = lines[0]
    let parts = command.components(separatedBy: " ")
    switch parts[0] {
    case "cd": self = .cd(parts[1])
    case "ls": self = .ls(Array(lines[1...]).filter { !$0.isEmpty })
    default: return nil
    }
  }
}

private class Node: Hashable, CustomDebugStringConvertible {
  enum Kind {
    case directory(Set<Node>)
    case file(UInt)
  }
  
  var kind: Kind
  var name: String
  weak var parent: Node?
  
  var isDirectory: Bool {
    switch kind {
    case .directory:
      return true
    case .file:
      return false
    }
  }
  
  var allSubdirectories: Set<Node> {
    let childDirs = self.children.filter(\.isDirectory)
    return childDirs.union(childDirs.flatMap { $0.allSubdirectories })
  }
  
  var path: String {
    if let parent = parent {
      return "\(parent.path)/\(name)"
    } else {
      return "/"
    }
  }
  
  var children: Set<Node> {
    get {
      switch kind {
      case let .directory(children):
        return children
      case .file:
        return .init()
      }
    }
    
    set {
      self.kind = .directory(newValue)
    }
    
  }
  
  lazy var size: UInt = {
    switch kind {
    case let .directory(children):
      return children.map(\.size).reduce(0, +)
    case let .file(size):
      return size
    }
  }()
  
  init(name: String, parent: Node?, kind: Kind) {
    self.name = name
    self.parent = parent
    self.kind = kind
  }
  
  init(parent: Node?, contents: String) {
    let parts = contents.components(separatedBy: " ")
    self.name = parts[1]
    self.parent = parent
    if let size = UInt(parts[0]) {
      self.kind = .file(size)
    } else {
      self.kind = .directory(.init())
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }

  static func == (lhs: Node, rhs: Node) -> Bool {
    lhs.path == rhs.path
  }
}

private extension Node {
  var depth: Int {
    var depth = 0
    var node: Node? = self
    while node != nil {
      depth += 1
      node = node?.parent
    }
    return depth
  }
  
  var debugDescription: String {
    switch kind {
    case let .file(size):
      let padding = String(repeating: " ", count: 2 * (depth - 1))
      return "\(padding)- \(name) (file, size=\(size))"
    case let .directory(children):
      let padding = String(repeating: " ", count: 2 * (depth - 1))
      let children = children.sorted(by: { $0.name < $1.name }).map(\.debugDescription).joined(separator: "\n")
      return "\(padding)- \(name) (dir)" + (children.count > 0 ? "\n\(children)" : "")
    }
  }
}
