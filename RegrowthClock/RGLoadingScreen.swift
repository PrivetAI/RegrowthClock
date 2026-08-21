import SwiftUI

/// Shown while the launch check runs. Deliberately quiet: a mark, a title and a
/// slow sage sweep drawn in Canvas.
struct RGLoadingScreen: View {
    @State private var sweep: Double = 0

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 18) {
                RGBrandMark(side: 96)

                Text("Regrowth Clock")
                    .font(RGFont.display(24))
                    .foregroundColor(RGTheme.ink)

                Text("Learning your own intervals, one session at a time.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)

                RGLoadingSweep(phase: sweep, width: min(RGDevice.width - 120, 200))
                    .padding(.top, 6)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                sweep = 1
            }
        }
    }
}

struct RGLoadingSweep: View {
    let phase: Double
    let width: CGFloat

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 40)
            let h: CGFloat = 6
            var track = Path()
            track.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h),
                                 cornerSize: CGSize(width: h / 2, height: h / 2))
            ctx.fill(track, with: .color(RGTheme.sageMist))

            let headW = w * 0.34
            let travel = (w + headW) * CGFloat(RGMath.clamp(phase, 0, 1)) - headW
            var head = Path()
            head.addRoundedRect(in: CGRect(x: max(travel, 0),
                                           y: 0,
                                           width: min(headW, w - max(travel, 0)),
                                           height: h),
                                cornerSize: CGSize(width: h / 2, height: h / 2))
            ctx.fill(head, with: .color(RGTheme.sage))
        }
        .frame(width: width, height: 6)
        .allowsHitTesting(false)
    }
}
