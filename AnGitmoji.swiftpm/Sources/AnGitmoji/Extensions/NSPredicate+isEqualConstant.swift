import Foundation

extension NSPredicate {
    func isEqualConstant(_ other: NSPredicate?) -> Bool {
        guard let other: NSPredicate,
              isKind(of: NSClassFromString("NSComparisonPredicate")!),
              other.isKind(of: NSClassFromString("NSComparisonPredicate")!) else {
            return false
        }
        
        return constantValue.isEqual(other.constantValue)
    }
    
    private var constantValue: AnyObject {
        // NSConstantValueExpression
        let constantValueExpression: NSExpression = value(forKey: "_rhs") as! NSExpression
        let constantValue: AnyObject = constantValueExpression.constantValue as AnyObject
        return constantValue
    }
}
