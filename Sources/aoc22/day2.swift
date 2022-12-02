import Foundation

enum NeededResult { 
    case win
    case loss
    case draw
}

enum Material: Int { 
    case rock = 1
    case paper = 2
    case scissors = 3

    func scoreAgainst(_ other: Material) -> Int { 
        switch (self, other) { 
            case (.rock, .paper), (.paper, .scissors), (.scissors, .rock): return 0
            case (.rock, .rock), (.paper, .paper), (.scissors, .scissors): return 3
            case (.rock, .scissors), (.paper, .rock), (.scissors, .paper): return 6
        }
    }

    var beats: Material { 
        switch self { 
            case .rock: return .scissors
            case .paper: return .rock
            case .scissors: return .paper
        }
    }

    var losesTo: Material { 
        switch self { 
            case .rock: return .paper
            case .paper: return .scissors
            case .scissors: return .rock
        }
    }
}

struct RoundPart1 {
    let opponentChoice: Material
    let myChoice: Material

    var score: Int { 
        myChoice.rawValue + myChoice.scoreAgainst(opponentChoice)
    }

    init?(_ line: String) { 
      let opponentLetter = line[line.startIndex]
      let myLetter = line[line.index(line.startIndex, offsetBy: 2)]

        switch opponentLetter { 
            case "A": opponentChoice = .rock
            case "B": opponentChoice = .paper
            case "C": opponentChoice = .scissors
            default: return nil
        }

        switch myLetter {
            case "X": myChoice = .rock
            case "Y": myChoice = .paper
            case "Z": myChoice = .scissors
            default: return nil
        }
    }
}

struct RoundPart2 {
    let opponentChoice: Material
    let result: NeededResult
    let myChoice: Material

    var score: Int { 
        myChoice.rawValue + myChoice.scoreAgainst(opponentChoice)
    }

    init?(_ line: String) { 
      let opponentLetter = line[line.startIndex]
      let resultLetter = line[line.index(line.startIndex, offsetBy: 2)]

        switch opponentLetter { 
            case "A": opponentChoice = .rock
            case "B": opponentChoice = .paper
            case "C": opponentChoice = .scissors
            default: return nil
        }

        switch resultLetter {
            case "X": 
                result = .loss
                myChoice = opponentChoice.beats
            case "Y": 
                result = .draw
                myChoice = opponentChoice
            case "Z": 
                result = .win
                myChoice = opponentChoice.losesTo
            default: return nil
        }
    }
}

let day2 = Day { part, input in 
    switch part { 
        case .one: return part1(input)
        case .two: return part2(input)
    }
}

private func part1(_ input: String) -> Int {
    input
        .components(separatedBy: "\n")
        .compactMap(RoundPart1.init)
        .map(\.score)
        .reduce(0, +)
}

private func part2(_ input: String) -> Int {
    input
        .components(separatedBy: "\n")
        .compactMap(RoundPart2.init)
        .map(\.score)
        .reduce(0, +)
}
