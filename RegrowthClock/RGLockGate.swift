import SwiftUI
import LocalAuthentication

/// Optional privacy lock. Off by default. If the device cannot evaluate any
/// authentication policy at all, the app unlocks rather than trapping someone
/// out of their own log.
struct RGLockGate: View {
    @StateObject private var store = RGStore()

    @State private var unlocked: Bool = false
    @State private var attempting: Bool = false
    @State private var failureNote: String? = nil
    @State private var hasTriedOnce: Bool = false

    var body: some View {
        ZStack {
            if unlocked || !store.settings.privacyLockEnabled {
                RGRootView(store: store)
            } else {
                lockScreen
            }
        }
        .onAppear {
            if store.settings.privacyLockEnabled && !unlocked && !hasTriedOnce {
                hasTriedOnce = true
                attemptUnlock()
            }
        }
        // Turning the lock on from inside Settings must not eject the user to the
        // lock screen mid-session: this session stays unlocked and the lock takes
        // effect at the next launch.
        .onChange(of: store.settings.privacyLockEnabled) { nowOn in
            if nowOn {
                unlocked = true
                hasTriedOnce = true
                failureNote = nil
            }
        }
    }

    private var lockScreen: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                RGIconView(glyph: .lock, side: 44, color: RGTheme.sageDeep, lineWidth: 2)

                Text("Regrowth Clock is locked")
                    .font(RGFont.title(20))
                    .foregroundColor(RGTheme.ink)
                    .multilineTextAlignment(.center)

                Text("Your grooming log stays on this device. Unlock with the same method you use to unlock the phone.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)

                if let note = failureNote {
                    Text(note)
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.coral)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 30)
                }

                RGPrimaryButton(title: attempting ? "Checking\u{2026}" : "Unlock",
                                color: RGTheme.sageDeep,
                                enabled: !attempting) {
                    attemptUnlock()
                }
                .frame(maxWidth: 240)
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
        }
    }

    private func attemptUnlock() {
        guard !attempting else { return }
        attempting = true
        failureNote = nil

        let context = LAContext()
        context.localizedFallbackTitle = ""
        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication

        guard context.canEvaluatePolicy(policy, error: &error) else {
            // No biometrics and no passcode configured: unlocking is the safe
            // failure mode, never a permanent lockout.
            attempting = false
            unlocked = true
            return
        }

        context.evaluatePolicy(policy,
                               localizedReason: "Unlock your Regrowth Clock log") { success, evalError in
            DispatchQueue.main.async {
                attempting = false
                if success {
                    unlocked = true
                    failureNote = nil
                    return
                }
                if let code = (evalError as NSError?)?.code,
                   code == LAError.biometryNotAvailable.rawValue
                    || code == LAError.biometryNotEnrolled.rawValue
                    || code == LAError.passcodeNotSet.rawValue {
                    unlocked = true
                    return
                }
                failureNote = "That did not go through. Try again, or turn the privacy lock off in Settings once you are in."
            }
        }
    }
}
