import AVFoundation
import MediaPlayer
import UIKit

@MainActor
enum SystemVolume {
    private static let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))

    private static var slider: UISlider? {
        if volumeView.superview == nil, let window = hostWindow {
            window.addSubview(volumeView)
        }
        return volumeView.subviews.compactMap { $0 as? UISlider }.first
    }

    /// Prefer the key window of the foreground-active scene. `windows.first` of
    /// the first scene can be nil early in launch or a non-key window, which made
    /// volume changes silently no-op.
    private static var hostWindow: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let active = scenes.first(where: { $0.activationState == .foregroundActive }),
           let key = active.windows.first(where: \.isKeyWindow) ?? active.windows.first {
            return key
        }
        return scenes.first?.windows.first
    }

    static var level: Float {
        AVAudioSession.sharedInstance().outputVolume
    }

    static func adjust(by delta: Float) -> Float? {
        guard let slider else { return nil }
        let target = min(max(slider.value + delta, 0), 1)
        guard target != slider.value else { return nil }
        slider.value = target
        slider.sendActions(for: .valueChanged)
        return target
    }
}
