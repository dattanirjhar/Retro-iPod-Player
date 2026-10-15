import Foundation
import UIKit
import AudioToolbox
import Observation

enum ButtonAction: Hashable, Sendable {
    case menu, forwardEndAlt, backwardEndAlt, playPause, select
    case forwardLongPress, backwardLongPress, forwardLongPressEnd, backwardLongPressEnd
}

@MainActor
@Observable
final class iPlayrButtonController {
    private(set) var activeScope: FocusScope?

    @ObservationIgnored private var globalPlaybackHandler: ((ButtonAction) -> Void)?
    @ObservationIgnored var onMenuLongPress: (() -> Void)?

    @ObservationIgnored private let selectionFeedback = UISelectionFeedbackGenerator()
    @ObservationIgnored private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    private var hapticsEnabled: Bool { UserDefaults.standard.object(forKey: UserDefaultsKeys.hapticsEnabled.rawValue) as? Bool ?? true }
    private var soundsEnabled: Bool { UserDefaults.standard.object(forKey: UserDefaultsKeys.soundsEnabled.rawValue) as? Bool ?? true }

    /// Debounce is tracked per button so a quick MENU-then-SELECT (or the reverse)
    /// is not swallowed; only a repeat of the *same* button within the window is.
    @ObservationIgnored private var lastInteractionTimes: [ButtonAction: Date] = [:]
    @ObservationIgnored private let debounceInterval: TimeInterval = 0.3

    init() {
        selectionFeedback.prepare()
        impactFeedback.prepare()
    }

    func activate(_ scope: FocusScope) {
        activeScope = scope
    }

    func setGlobalPlaybackHandler(_ handler: @escaping (ButtonAction) -> Void) {
        self.globalPlaybackHandler = handler
    }

    private func playPressFeedback() {
        if hapticsEnabled {
            impactFeedback.impactOccurred()
            impactFeedback.prepare()
        }
        if soundsEnabled {
            AudioServicesPlaySystemSound(1306)
        }
    }

    private func consumeDebounce(for action: ButtonAction) -> Bool {
        let now = Date()
        if let last = lastInteractionTimes[action], now.timeIntervalSince(last) <= debounceInterval {
            return false
        }
        lastInteractionTimes[action] = now
        return true
    }

    private func handleInput(_ action: ButtonAction) {
        if action == .menu || action == .select {
            guard consumeDebounce(for: action) else { return }
            playPressFeedback()
        }

        activeScope?.onAction?(action)

        switch action {
        case .playPause, .forwardEndAlt, .backwardEndAlt:
            if activeScope?.handledTransportActions.contains(action) != true {
                globalPlaybackHandler?(action)
            }
        default:
            break
        }
    }

    func menuButtonPressed() { handleInput(.menu) }

    func menuLongPressed() {
        guard consumeDebounce(for: .menu) else { return }
        playPressFeedback()
        onMenuLongPress?()
    }

    func selectButtonPressed() { handleInput(.select) }
    func forwardEndAltButtonPressed() { handleInput(.forwardEndAlt) }
    func backwardEndAltButtonPressed() { handleInput(.backwardEndAlt) }
    func playPauseButtonPressed() { handleInput(.playPause) }

    func forwardLongPressStarted() { handleInput(.forwardLongPress) }
    func forwardLongPressEnded() { handleInput(.forwardLongPressEnd) }
    func backwardLongPressStarted() { handleInput(.backwardLongPress) }
    func backwardLongPressEnded() { handleInput(.backwardLongPressEnd) }

    func scrollUp() {
        guard let scope = activeScope, scope.moveUp() else { return }
        if hapticsEnabled {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        }
    }

    func scrollDown() {
        guard let scope = activeScope, scope.moveDown() else { return }
        if hapticsEnabled {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        }
    }
}
