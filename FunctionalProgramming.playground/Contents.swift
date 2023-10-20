func identity(_ int: Int) -> Int {
    return int
}

// Higher-order function: a function that takes a function as input or returns a function as output

// Filter

let integers = Array(1...10)

func evensImperative(from input: [Int]) -> [Int] {
    var evens: [Int] = []
    for integer in input {
        if integer.isMultiple(of: 2) {
            evens.append(integer)
        }
    }
    return evens
}

evensImperative(from: integers).description

func evensUsingFilter(from input: [Int]) -> [Int] {
    return input.filter({ value in
        return value.isMultiple(of: 2)
    })
}

evensUsingFilter(from: integers).description

func evensUsingFilterMoreConcise(from input: [Int]) -> [Int] {
    input.filter { $0.isMultiple(of: 2) }
}

extension Collection {
    func myFilter(
        _ isIncluded: (Self.Element) throws -> Bool
    ) rethrows -> [Self.Element] {
        var result: [Self.Element] = []
        for element in self {
            if try isIncluded(element) {
                result.append(element)
            }
        }
        return result
    }
}

let words = ["hi", "pen", "reverberated", "lollipop", "stewardesses", "dog"]
let shortWords = words.myFilter { word in word.count <= 5 }
shortWords.description

// Reduce

var sum = 0
for integer in integers {
    sum += integer
}
sum

integers.reduce(0, +)

integers.reduce(0) { partialResult, next in
    return partialResult + next
}

//func reduce<Int>(
//    _ initialResult: Int,
//    _ nextPartialResult: (Int, Int) -> Int
//) -> Int

let plus: (Int, Int) -> Int = (+)

integers.reduce(0, plus)

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element {
        self.reduce(.zero, +)
    }
}

integers.sum()

extension Collection {
    func myReduce<Result>(
        initialResult: Result,
        nextPartialResult: (Result, Self.Element) throws -> Result
    ) rethrows -> Result {
        var partialResult = initialResult
        for element in self {
            partialResult = try nextPartialResult(partialResult, element)
        }
        return partialResult
    }
}

integers.myReduce(initialResult: 0, nextPartialResult: +)

shortWords.myReduce(initialResult: 0, nextPartialResult: { partialResult, word in
    partialResult + word.count
})

// Map

var squares: [Int] = []
for integer in integers {
    let square = integer * integer
    squares.append(square)
}
squares.description

integers.map { integer in integer * integer }.description
integers.map { $0 * $0 }.description
let negated = integers.map(-).description

import Foundation
let spellOutFormatter = NumberFormatter()
spellOutFormatter.numberStyle = .spellOut
integers.map { spellOutFormatter.string(from: $0 as NSNumber)! }.description

extension Collection {
    func myMap<Result>(
        _ transform: (Self.Element) throws -> Result
    ) rethrows -> [Result] {
        var result: [Result] = []
        // result.reserveCapacity(count)
        for element in self {
            let transformed = try transform(element)
            result.append(transformed)
        }
        return result
    }
}

integers.myMap { $0 * $0 }.description

// Map on Optional

let presentInt: Int? = .some(3)

//let squareOfOptionalInt = optionalInt * optionalInt

var squareOfOptionalInt: Int?
if let presentInt {
    squareOfOptionalInt = presentInt * presentInt
}
String(describing: squareOfOptionalInt)

let mappedSquareOfOptionalInt = presentInt
    .map { $0 * $0 }

extension Optional {
    func myMap<Result>(
        _ transform: (Wrapped) throws -> Result
    ) rethrows -> Result? {
        switch self {
        case .none:
            return .none
        case .some(let wrapped):
            return try transform(wrapped)
        }
    }
}

presentInt.myMap { $0 * $0 }
extension Int {
    func squared() -> Int { self * self }
}

presentInt?.squared()

let absentInt: Int? = nil

absentInt.myMap { $0 * $0 }

// FlatMap

var optionalSpelledOut: String?
if let presentInt {
    optionalSpelledOut = spellOutFormatter.string(from: presentInt as NSNumber)
}
String(describing: optionalSpelledOut)

let spelledOutMap = presentInt
    .map { spellOutFormatter.string(from: $0 as NSNumber) }

let spelledOutFlatMap = presentInt
    .flatMap { spellOutFormatter.string(from: $0 as NSNumber) }

extension Optional {
    func myFlatMap<Result>(
        _ transform: (Wrapped) throws -> Result?
    ) rethrows -> Result? {
        switch self {
        case .none:
            return .none
        case .some(let wrapped):
            let transformed = try transform(wrapped)
            return transformed
        }
    }
}

let spelledOutMyFlatMap = presentInt
    .myFlatMap { spellOutFormatter.string(from: $0 as NSNumber) }

absentInt
    .myFlatMap { spellOutFormatter.string(from: $0 as NSNumber) }

// Sorting

integers.sorted().description

integers.sorted(by: >).description

integers.sorted(by: { first, second in
    if first < second {
        return true
    } else {
        return false
    }
})

struct Person: CustomStringConvertible {
    let firstName: String
    let lastName: String
    let age: Int

    var description: String {
        "\(firstName) \(lastName), age \(age)"
    }
}

let people: [Person] = [
    .init(firstName: "Zev", lastName: "Eisenberg", age: 35),
    .init(firstName: "Wolfgang", lastName: "Mozart", age: 22),
    .init(firstName: "Steve", lastName: "Gates", age: 58),
]

people.sorted { lhs, rhs in
    lhs.firstName < rhs.firstName
}.description

let characters = ["汉" /* h */, "字"/* z */, "排"/* p */, "序"/* x */]
characters.sorted().description

let sortedForRealz = characters
    .sorted { lhs, rhs in
        let result = lhs.localizedCaseInsensitiveCompare(rhs)
        switch result {
        case .orderedAscending:
            return true
        case .orderedSame, .orderedDescending:
            return false
        }
    }

sortedForRealz.description


let ageSortDescriptor: (Person, Person) -> Bool = { lhs, rhs in
    lhs.age < rhs.age
}

people.sorted(by: ageSortDescriptor)

let firstNameSortDescriptor: (Person, Person) -> Bool = { lhs, rhs in
    lhs.firstName < rhs.firstName
}

people.sorted(by: firstNameSortDescriptor)

typealias SortDescriptor<Root> = (Root, Root) -> Bool

func makeSortDescriptor<Root, Value: Comparable>(
    of: Root.Type,
    by getter: @escaping (Root) -> Value
) -> SortDescriptor<Root> {
    return { lhs, rhs in
        getter(lhs) < getter(rhs)
    }
}

let firstName = makeSortDescriptor(of: Person.self, by: { $0.firstName })
people.sorted(by: firstName).description

// Key Paths

let x = \Person.age

func makeSortDescriptor<Root, Value: Comparable>(
    by keyPath: KeyPath<Root, Value>
) -> SortDescriptor<Root> {
    return { lhs, rhs in
        lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
    }
}

let lastName = makeSortDescriptor(by: \Person.lastName)
people.sorted(by: lastName)

extension Collection {
    func mySorted<Value: Comparable>(
        by keyPath: KeyPath<Self.Element, Value>
    ) -> [Self.Element] {
        return self.sorted(by: makeSortDescriptor(by: keyPath))
    }
}

people.mySorted(by: \.age)
