import Foundation

struct IntComparator: SortComparator {
    typealias Compared = Int
    
    var order: SortOrder = .forward
    
    func compare(_ lhs: Int, _ rhs: Int) -> ComparisonResult {
        if lhs < rhs {
            return (order == .forward) ? .orderedAscending : .orderedDescending
        } else if lhs > rhs {
            return (order == .forward) ? .orderedDescending : .orderedAscending
        } else {
            return .orderedSame
        }
    }
}
