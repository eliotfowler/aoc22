enum Part: Int {
    case one = 1
    case two = 2
}

struct Day {
    let run: (Part, String) -> Any
}
