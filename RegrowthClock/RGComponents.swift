import SwiftUI

// MARK: - Screen scaffold
//
// The content column respects the top safe area, so nothing is ever drawn under
// the clock, and the cream ground fills the whole window including the status
// bar strip.

struct RGScreen<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(RGFont.display(RGScreen_Metrics.titleSize))
                            .foregroundColor(RGTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        if let sub = subtitle, !sub.isEmpty {
                            Text(sub)
                                .font(RGFont.body(12))
                                .foregroundColor(RGTheme.inkSoft)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer(minLength: 6)
                    if let t = trailing { t }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(
                    RGTheme.cream
                        .overlay(Rectangle().fill(RGTheme.hairline).frame(height: 1), alignment: .bottom)
                )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        content()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 34)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        // Tab roots draw their own header, so the empty system bar is hidden.
        // Pushed screens turn it back on so the back button is there.
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

enum RGScreen_Metrics {
    static var titleSize: CGFloat { RGDevice.isCompact ? 23 : 26 }
}

// MARK: - Pushed sub-screen scaffold (inside a NavigationView)

struct RGSubScreen<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(RGFont.display(RGScreen_Metrics.titleSize))
                            .foregroundColor(RGTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        if let sub = subtitle, !sub.isEmpty {
                            Text(sub)
                                .font(RGFont.body(13))
                                .foregroundColor(RGTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.bottom, 2)

                    content()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
    }
}

// MARK: - Card

struct RGCard<Content: View>: View {
    var padding: CGFloat = 14
    var accent: Color? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(RGTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent?.opacity(0.35) ?? RGTheme.cardEdge, lineWidth: 1)
        )
    }
}

// MARK: - Section header

struct RGSectionHeader: View {
    let text: String
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text.uppercased())
                .font(RGFont.label(11))
                .foregroundColor(RGTheme.inkFaint)
                .tracking(0.8)
            Spacer(minLength: 6)
            if let d = detail {
                Text(d)
                    .font(RGFont.label(11))
                    .foregroundColor(RGTheme.inkFaint)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Confidence badge

struct RGConfidenceBadge: View {
    let confidence: RGConfidence
    var compact: Bool = false

    private var accent: Color {
        switch confidence {
        case .learning: return RGTheme.inkFaint
        case .low:      return RGTheme.clay
        case .medium:   return RGTheme.slateBlue
        case .high:     return RGTheme.sage
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            RGConfidencePips(level: confidence.rawValue, color: accent)
            Text(confidence.title)
                .font(RGFont.label(compact ? 9 : 10))
                .foregroundColor(accent)
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(
            Capsule().fill(accent.opacity(0.12))
        )
    }
}

struct RGConfidencePips: View {
    let level: Int
    let color: Color

    var body: some View {
        Canvas { ctx, _ in
            let w: CGFloat = 20
            let h: CGFloat = 9
            for i in 0..<3 {
                let filled = i < max(level, 0)
                var bar = Path()
                let bw: CGFloat = 4
                let bh = h * (0.45 + CGFloat(i) * 0.275)
                let x = CGFloat(i) * (bw + 2)
                bar.addRoundedRect(in: CGRect(x: x, y: h - bh, width: bw, height: bh),
                                   cornerSize: CGSize(width: 1.2, height: 1.2))
                ctx.fill(bar, with: .color(filled ? color : color.opacity(0.22)))
            }
            _ = w
        }
        .frame(width: 20, height: 9)
        .allowsHitTesting(false)
    }
}

// MARK: - Pills and chips

struct RGPill: View {
    let text: String
    var color: Color = RGTheme.sage
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(RGFont.label(10))
            .foregroundColor(filled ? RGTheme.card : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(filled ? color : color.opacity(0.13))
            )
            .lineLimit(1)
    }
}

struct RGChoiceChip: View {
    let text: String
    let selected: Bool
    var color: Color = RGTheme.sage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(RGFont.label(12))
                .foregroundColor(selected ? RGTheme.card : RGTheme.ink)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(selected ? color : RGTheme.card)
                )
                .overlay(
                    Capsule().stroke(selected ? color : RGTheme.hairline, lineWidth: 1)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Buttons

struct RGPrimaryButton: View {
    let title: String
    var color: Color = RGTheme.sageDeep
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            Text(title)
                .font(RGFont.heading(15))
                .foregroundColor(RGTheme.card)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(enabled ? color : RGTheme.inkGhost)
                )
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}

struct RGSecondaryButton: View {
    let title: String
    var color: Color = RGTheme.sageDeep
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(RGFont.heading(14))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(color.opacity(0.10))
                )
                .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RGIconButton: View {
    let glyph: RGGlyph
    var side: CGFloat = 20
    var color: Color = RGTheme.ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RGIconView(glyph: glyph, side: side, color: color)
                .frame(width: side + 16, height: side + 16)
                .contentShape(Rectangle())   // pitfall 2: a bare Canvas label has no tap area
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty state

struct RGEmptyState: View {
    let title: String
    let message: String
    var glyph: RGGlyph = .leaf
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            RGIconView(glyph: glyph, side: 34, color: RGTheme.sage.opacity(0.7), lineWidth: 1.6)
            Text(title)
                .font(RGFont.heading(15))
                .foregroundColor(RGTheme.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(RGFont.body(13))
                .foregroundColor(RGTheme.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let t = actionTitle, let a = action {
                Button(action: a) {
                    Text(t)
                        .font(RGFont.heading(13))
                        .foregroundColor(RGTheme.sageDeep)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(RGTheme.sage.opacity(0.14)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(RGTheme.card.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(RGTheme.cardEdge, lineWidth: 1)
        )
    }
}

// MARK: - Inline disclaimer

struct RGDisclaimerNote: View {
    var text: String = "Information and self-tracking only. Regrowth Clock is not a medical device and does not provide medical advice."

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RGIconView(glyph: .info, side: 14, color: RGTheme.inkFaint, lineWidth: 1.4)
                .padding(.top, 1)
            Text(text)
                .font(RGFont.body(11))
                .foregroundColor(RGTheme.inkFaint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }
}

// MARK: - Stat row

struct RGStatRow: View {
    let label: String
    let value: String
    var accent: Color = RGTheme.ink
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(RGFont.body(13))
                .foregroundColor(RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 6)
            VStack(alignment: .trailing, spacing: 1) {
                Text(value)
                    .font(RGFont.mono(13))
                    .foregroundColor(accent)
                if let d = detail {
                    Text(d)
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                }
            }
        }
    }
}

// MARK: - Canvas bars

/// Horizontal urgency bar: the midpoint is the predicted due date, so a marker
/// left of centre is early and right of centre is overdue.
struct RGUrgencyBar: View {
    /// Days remaining. Negative means overdue.
    let daysUntil: Int?
    /// Predicted interval, used to scale the bar.
    let interval: Double?
    var width: CGFloat
    var height: CGFloat = 12

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 20)
            let h = max(height, 6)
            let mid = w * 0.62

            var track = Path()
            track.addRoundedRect(in: CGRect(x: 0, y: h * 0.34, width: w, height: h * 0.32),
                                 cornerSize: CGSize(width: h * 0.16, height: h * 0.16))
            ctx.fill(track, with: .color(RGTheme.sageMist.opacity(0.85)))

            guard let days = daysUntil, let iv = interval, iv.isFinite, iv > 0 else {
                var dash = Path()
                dash.move(to: CGPoint(x: w * 0.44, y: h * 0.5))
                dash.addLine(to: CGPoint(x: w * 0.56, y: h * 0.5))
                ctx.stroke(dash, with: .color(RGTheme.inkFaint),
                           style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                return
            }

            // Fraction of the interval already elapsed.
            let elapsed = iv - Double(days)
            let progress = RGMath.clamp(elapsed / iv, 0, 1)
            let overshoot = days < 0 ? RGMath.clamp(Double(-days) / max(iv, 1), 0, 1) : 0

            var fill = Path()
            let fillW = mid * CGFloat(progress)
            fill.addRoundedRect(in: CGRect(x: 0, y: h * 0.34, width: max(fillW, h * 0.32), height: h * 0.32),
                                cornerSize: CGSize(width: h * 0.16, height: h * 0.16))
            ctx.fill(fill, with: .color(days < 0 ? RGTheme.coral.opacity(0.35) : RGTheme.sage.opacity(0.55)))

            if overshoot > 0 {
                var over = Path()
                let ow = (w - mid) * CGFloat(overshoot)
                over.addRoundedRect(in: CGRect(x: mid, y: h * 0.28, width: max(ow, h * 0.3), height: h * 0.44),
                                    cornerSize: CGSize(width: h * 0.22, height: h * 0.22))
                ctx.fill(over, with: .color(RGTheme.coral.opacity(0.75)))
            }

            // Due marker.
            var marker = Path()
            marker.move(to: CGPoint(x: mid, y: h * 0.12))
            marker.addLine(to: CGPoint(x: mid, y: h * 0.88))
            ctx.stroke(marker, with: .color(RGTheme.ink.opacity(0.45)),
                       style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

            // Head of the progress.
            var head = Path()
            let hx = days < 0 ? RGMath.clamp(mid + (w - mid) * CGFloat(overshoot), mid, w - h * 0.22) : RGMath.clamp(fillW, h * 0.22, mid)
            head.addEllipse(in: CGRect(x: hx - h * 0.22, y: h * 0.28, width: h * 0.44, height: h * 0.44))
            ctx.fill(head, with: .color(days < 0 ? RGTheme.coral : RGTheme.sageDeep))
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}

/// Simple fraction bar used for course progress and consumable wear.
struct RGProgressBar: View {
    let fraction: Double
    var width: CGFloat
    var height: CGFloat = 8
    var color: Color = RGTheme.sage
    var trackColor: Color = RGTheme.sageMist

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 12)
            let h = max(height, 4)
            var track = Path()
            track.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h),
                                 cornerSize: CGSize(width: h / 2, height: h / 2))
            ctx.fill(track, with: .color(trackColor.opacity(0.8)))

            let f = RGMath.clamp(fraction.isFinite ? fraction : 0, 0, 1)
            guard f > 0 else { return }
            var fill = Path()
            fill.addRoundedRect(in: CGRect(x: 0, y: 0, width: max(w * CGFloat(f), h), height: h),
                                cornerSize: CGSize(width: h / 2, height: h / 2))
            ctx.fill(fill, with: .color(color))
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}

// MARK: - Labelled field wrappers used across sheets

struct RGFieldLabel: View {
    let text: String
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(text.uppercased())
                .font(RGFont.label(10))
                .foregroundColor(RGTheme.inkFaint)
                .tracking(0.7)
            if let d = detail {
                Text(d)
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint.opacity(0.8))
            }
            Spacer(minLength: 0)
        }
    }
}

struct RGDivider: View {
    var body: some View {
        Rectangle()
            .fill(RGTheme.hairline)
            .frame(height: 1)
    }
}

// MARK: - Sheet chrome

struct RGSheetHeader: View {
    let title: String
    var subtitle: String? = nil
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(RGFont.title(19))
                    .foregroundColor(RGTheme.ink)
                if let s = subtitle {
                    Text(s)
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 6)
            RGIconButton(glyph: .close, side: 18, color: RGTheme.inkSoft, action: onClose)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 10)
        .background(
            RGTheme.cream
                .overlay(Rectangle().fill(RGTheme.hairline).frame(height: 1), alignment: .bottom)
        )
    }
}
