import ArgumentParser
import Foundation

private let days = [1: day1, 2: day2, 3: day3, 4: day4, 5: day5, 6: day6, 7: day7, 8: day8, 9: day9]

private func measureInMilliseconds(_ block: () -> ()) -> Double {
  let start = DispatchTime.now()
  block()
  let end = DispatchTime.now()
  
  // Difference in nano seconds (UInt64)
  let nanoTime = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
  
  // Technically could overflow for long running tests
  let timeInterval = nanoTime / 1_000_000
  return timeInterval
}

struct AOC22: ParsableCommand { 
  @Option(help: "Day to run")
  var day: Int = days.keys.sorted().last ?? 0
  
  @Option(help: "Part to run")
  var part: Int = 1
  
  @Flag(help: "Use actual input")
  var useActualInput = false
  
  @Flag(help: "Benchmark performance")
  var timing = false
  
  mutating func run() throws {
    guard let dayPuzzle = days[day] else {
      print("That day doesn't exist")
      return
    }
    
    let inputTypeName = useActualInput ? "input" : "test"
    let fileName = "day\(day)-\(inputTypeName)"
    print(fileName)
    guard let fileURL = Bundle.module.url(forResource: fileName, withExtension: "txt", subdirectory: "Resources") else {
      print("File not found.")
      return
    }
    
    let input = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    
    if timing {
#if DEBUG
      print("Must run in release mode to get accurate timing")
      return
#else
      var part1Result: Any?
      let part1TimeInMs = measureInMilliseconds {
        part1Result = dayPuzzle.run(.one, input)
      }
      
      var part2Result: Any?
      let part2TimeInMs = measureInMilliseconds {
        part2Result = dayPuzzle.run(.two, input)
      }
      
      print(
      """
      Part 1: \(part1Result!) (\(part1TimeInMs)ms)
      Part 2: \(part2Result!) (\(part2TimeInMs)ms)
      """
      )
#endif
    } else {
      let partToRun = Part(rawValue: part)!
      let result = dayPuzzle.run(partToRun, input)
      print(result)
    }
  }
}

AOC22.main()
