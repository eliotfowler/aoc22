enum Part { 
    case one
    case two
}

struct Day {
    let run: (Part, String) -> Any
}