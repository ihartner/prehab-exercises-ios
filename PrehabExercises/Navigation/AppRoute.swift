import Foundation

enum AppRoute: Hashable {
    case session(startIndex: Int)
    case calendar
    case settings
    case breathing
    case breathingSession(id: Int)
}
