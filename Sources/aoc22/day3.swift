let day3 = Day { part, input in
    switch part {
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> Int {
  input
    .components(separatedBy: "\n")
    .map(commonLetterPriority(in:))
    .reduce(0, +)
}

private func part2(_ input: String) -> Int {
  let lines = input.components(separatedBy: "\n")
  let groups = stride(from: 0, to: lines.count, by: 3).map { start in
    Array(lines[start ..< min(start + 3, lines.count)])
  }
  
  return groups
    .map { group in commonLetterPriority(among: group.map(Set.init)) }
    .reduce(0, +)
}

private func commonLetterPriority(in str: String) -> Int {
  let firstHalf = Set(str[str.startIndex ..< str.index(str.startIndex, offsetBy: str.count / 2)])
  let secondHalf = Set(str[str.index(str.startIndex, offsetBy: str.count / 2)...])
  
  guard
    let commonCharacter = firstHalf.intersection(secondHalf).first,
    let asciiValue = commonCharacter.asciiValue
  else { return 0 }
  let priority = commonCharacter.isUppercase ? asciiValue - 38 : asciiValue - 96
  return Int(priority)
}

// MARK: Part 2

private func commonLetterPriority(among strs: [Set<Character>]) -> Int {
  let commonCharacters = strs.reduce(strs[0]) { $0.intersection($1) }
  guard
    let commonCharacter = commonCharacters.first,
    let asciiValue = commonCharacter.asciiValue
  else { return 0 }
  let priority = commonCharacter.isUppercase ? asciiValue - 38 : asciiValue - 96
  return Int(priority)
}
