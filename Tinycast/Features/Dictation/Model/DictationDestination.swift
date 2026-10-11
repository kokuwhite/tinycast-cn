import Foundation

enum DictationDestination: String, CaseIterable, Identifiable, Sendable {
    case paste
    case copy
    case both

    var id: Self { self }
    var title: String {
        switch self {
        case .paste: "Paste in active app".localizedUI
        case .copy: "Copy to clipboard".localizedUI
        case .both: "Paste and copy".localizedUI
        }
    }

    var pastes: Bool { self != .copy }
    var copies: Bool { self != .paste }
}
