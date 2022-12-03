import ArgumentParser
import Foundation

private let days = [1: day1, 2: day2, 3: day3]

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
    guard let dayPuzzle = days[day], let partToRun = Part(rawValue: part) else {
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
      let timeInMs = measureInMilliseconds {
        _ = dayPuzzle.run(partToRun, input)
      }
      print("Completed in \(timeInMs)ms")
#endif
    } else {
      let result = dayPuzzle.run(partToRun, input)
      print(result)
    }
  }
}

AOC22.main()
