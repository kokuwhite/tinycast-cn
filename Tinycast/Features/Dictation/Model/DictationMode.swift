import Foundation

enum DictationMode: String, CaseIterable, Identifiable, Sendable {
    case pushToTalk
    case toggle

    var id: Self { self }
    var title: String {
        self == .pushToTalk ? "Hold to talk".localizedUI : "Press to start or stop".localizedUI
    }
}
