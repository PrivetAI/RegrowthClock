import SwiftUI

// MARK: - Interface glyphs
//
// Every icon in the app is drawn here in Canvas. No SF Symbols, no emoji, no
// image assets. All drawing is done against the `side` value passed in, never
// against the Canvas closure's own size.

enum RGGlyph {
    case due
    case log
    case zones
    case insights
    case settings
    case plus
    case close
    case check
    case chevronRight
    case chevronDown
    case back
    case trash
    case pencil
    case search
    case filter
    case info
    case warning
    case clock
    case leaf
    case lock
    case shield
    case book
    case timer
}

struct RGIconView: View {
    let glyph: RGGlyph
    var side: CGFloat = 22
    var color: Color = RGTheme.ink
    var lineWidth: CGFloat = 1.7

    var body: some View {
        Canvas { ctx, _ in
            RGIconDraw.draw(glyph, in: ctx, side: side, color: color, lineWidth: lineWidth)
        }
        .frame(width: side, height: side)
        .allowsHitTesting(false)
    }
}

enum RGIconDraw {

    // swiftlint:disable:next cyclomatic_complexity
    static func draw(_ glyph: RGGlyph,
                     in ctx: GraphicsContext,
                     side: CGFloat,
                     color: Color,
                     lineWidth: CGFloat) {
        let s = max(side, 1)
        let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        let c = CGPoint(x: s / 2, y: s / 2)

        switch glyph {
        case .due, .clock, .timer:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: s * 0.12, y: s * 0.12, width: s * 0.76, height: s * 0.76))
            ctx.stroke(ring, with: .color(color), style: stroke)
            var hands = Path()
            hands.move(to: CGPoint(x: c.x, y: s * 0.28))
            hands.addLine(to: c)
            hands.addLine(to: CGPoint(x: s * 0.72, y: s * 0.60))
            ctx.stroke(hands, with: .color(color), style: stroke)
            if glyph == .timer {
                var top = Path()
                top.move(to: CGPoint(x: s * 0.38, y: s * 0.06))
                top.addLine(to: CGPoint(x: s * 0.62, y: s * 0.06))
                ctx.stroke(top, with: .color(color), style: stroke)
            }

        case .log:
            var page = Path()
            page.addRoundedRect(in: CGRect(x: s * 0.20, y: s * 0.12, width: s * 0.52, height: s * 0.76),
                                cornerSize: CGSize(width: s * 0.10, height: s * 0.10))
            ctx.stroke(page, with: .color(color), style: stroke)
            for i in 0..<3 {
                var line = Path()
                let y = s * (0.32 + Double(i) * 0.16)
                line.move(to: CGPoint(x: s * 0.31, y: y))
                line.addLine(to: CGPoint(x: s * 0.61, y: y))
                ctx.stroke(line, with: .color(color.opacity(0.75)), style: stroke)
            }
            var nib = Path()
            nib.move(to: CGPoint(x: s * 0.66, y: s * 0.66))
            nib.addLine(to: CGPoint(x: s * 0.90, y: s * 0.42))
            ctx.stroke(nib, with: .color(color), style: stroke)

        case .zones:
            let cell = s * 0.32
            let gap = s * 0.08
            let originX = (s - (cell * 2 + gap)) / 2
            let originY = originX
            for r in 0..<2 {
                for col in 0..<2 {
                    var rect = Path()
                    rect.addRoundedRect(in: CGRect(x: originX + Double(col) * (cell + gap),
                                                   y: originY + Double(r) * (cell + gap),
                                                   width: cell, height: cell),
                                        cornerSize: CGSize(width: cell * 0.28, height: cell * 0.28))
                    if r == 0 && col == 0 {
                        ctx.fill(rect, with: .color(color))
                    } else {
                        ctx.stroke(rect, with: .color(color), style: stroke)
                    }
                }
            }

        case .insights:
            var axis = Path()
            axis.move(to: CGPoint(x: s * 0.16, y: s * 0.16))
            axis.addLine(to: CGPoint(x: s * 0.16, y: s * 0.84))
            axis.addLine(to: CGPoint(x: s * 0.86, y: s * 0.84))
            ctx.stroke(axis, with: .color(color.opacity(0.7)), style: stroke)
            let heights: [Double] = [0.30, 0.52, 0.40, 0.66]
            for (i, h) in heights.enumerated() {
                let w = s * 0.11
                let x = s * 0.26 + Double(i) * (w + s * 0.055)
                let top = s * 0.84 - s * h
                var bar = Path()
                bar.addRoundedRect(in: CGRect(x: x, y: top, width: w, height: s * h),
                                   cornerSize: CGSize(width: w * 0.4, height: w * 0.4))
                ctx.fill(bar, with: .color(color.opacity(i == 3 ? 1.0 : 0.55)))
            }

        case .settings:
            for i in 0..<3 {
                let y = s * (0.26 + Double(i) * 0.24)
                var line = Path()
                line.move(to: CGPoint(x: s * 0.14, y: y))
                line.addLine(to: CGPoint(x: s * 0.86, y: y))
                ctx.stroke(line, with: .color(color.opacity(0.7)), style: stroke)
                var knob = Path()
                let kx = s * (i == 1 ? 0.34 : (i == 0 ? 0.62 : 0.46))
                knob.addEllipse(in: CGRect(x: kx - s * 0.09, y: y - s * 0.09,
                                           width: s * 0.18, height: s * 0.18))
                ctx.fill(knob, with: .color(RGTheme.card))
                ctx.stroke(knob, with: .color(color), style: stroke)
            }

        case .plus:
            var p = Path()
            p.move(to: CGPoint(x: c.x, y: s * 0.20))
            p.addLine(to: CGPoint(x: c.x, y: s * 0.80))
            p.move(to: CGPoint(x: s * 0.20, y: c.y))
            p.addLine(to: CGPoint(x: s * 0.80, y: c.y))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .close:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.26, y: s * 0.26))
            p.addLine(to: CGPoint(x: s * 0.74, y: s * 0.74))
            p.move(to: CGPoint(x: s * 0.74, y: s * 0.26))
            p.addLine(to: CGPoint(x: s * 0.26, y: s * 0.74))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .check:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.22, y: s * 0.53))
            p.addLine(to: CGPoint(x: s * 0.42, y: s * 0.73))
            p.addLine(to: CGPoint(x: s * 0.79, y: s * 0.29))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .chevronRight:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.40, y: s * 0.24))
            p.addLine(to: CGPoint(x: s * 0.66, y: s * 0.50))
            p.addLine(to: CGPoint(x: s * 0.40, y: s * 0.76))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .chevronDown:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.24, y: s * 0.40))
            p.addLine(to: CGPoint(x: s * 0.50, y: s * 0.66))
            p.addLine(to: CGPoint(x: s * 0.76, y: s * 0.40))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .back:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.58, y: s * 0.24))
            p.addLine(to: CGPoint(x: s * 0.32, y: s * 0.50))
            p.addLine(to: CGPoint(x: s * 0.58, y: s * 0.76))
            ctx.stroke(p, with: .color(color), style: stroke)

        case .trash:
            var lid = Path()
            lid.move(to: CGPoint(x: s * 0.20, y: s * 0.28))
            lid.addLine(to: CGPoint(x: s * 0.80, y: s * 0.28))
            lid.move(to: CGPoint(x: s * 0.40, y: s * 0.28))
            lid.addLine(to: CGPoint(x: s * 0.42, y: s * 0.16))
            lid.addLine(to: CGPoint(x: s * 0.58, y: s * 0.16))
            lid.addLine(to: CGPoint(x: s * 0.60, y: s * 0.28))
            ctx.stroke(lid, with: .color(color), style: stroke)
            var body = Path()
            body.move(to: CGPoint(x: s * 0.28, y: s * 0.34))
            body.addLine(to: CGPoint(x: s * 0.33, y: s * 0.84))
            body.addLine(to: CGPoint(x: s * 0.67, y: s * 0.84))
            body.addLine(to: CGPoint(x: s * 0.72, y: s * 0.34))
            ctx.stroke(body, with: .color(color), style: stroke)

        case .pencil:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.22, y: s * 0.78))
            p.addLine(to: CGPoint(x: s * 0.28, y: s * 0.60))
            p.addLine(to: CGPoint(x: s * 0.68, y: s * 0.20))
            p.addLine(to: CGPoint(x: s * 0.80, y: s * 0.32))
            p.addLine(to: CGPoint(x: s * 0.40, y: s * 0.72))
            p.closeSubpath()
            ctx.stroke(p, with: .color(color), style: stroke)

        case .search:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: s * 0.16, y: s * 0.16, width: s * 0.50, height: s * 0.50))
            ctx.stroke(ring, with: .color(color), style: stroke)
            var handle = Path()
            handle.move(to: CGPoint(x: s * 0.62, y: s * 0.62))
            handle.addLine(to: CGPoint(x: s * 0.84, y: s * 0.84))
            ctx.stroke(handle, with: .color(color), style: stroke)

        case .filter:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.16, y: s * 0.26))
            p.addLine(to: CGPoint(x: s * 0.84, y: s * 0.26))
            p.addLine(to: CGPoint(x: s * 0.58, y: s * 0.54))
            p.addLine(to: CGPoint(x: s * 0.58, y: s * 0.82))
            p.addLine(to: CGPoint(x: s * 0.42, y: s * 0.72))
            p.addLine(to: CGPoint(x: s * 0.42, y: s * 0.54))
            p.closeSubpath()
            ctx.stroke(p, with: .color(color), style: stroke)

        case .info:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: s * 0.12, y: s * 0.12, width: s * 0.76, height: s * 0.76))
            ctx.stroke(ring, with: .color(color), style: stroke)
            var dot = Path()
            dot.addEllipse(in: CGRect(x: c.x - s * 0.05, y: s * 0.26, width: s * 0.10, height: s * 0.10))
            ctx.fill(dot, with: .color(color))
            var stem = Path()
            stem.move(to: CGPoint(x: c.x, y: s * 0.46))
            stem.addLine(to: CGPoint(x: c.x, y: s * 0.72))
            ctx.stroke(stem, with: .color(color), style: stroke)

        case .warning:
            var tri = Path()
            tri.move(to: CGPoint(x: c.x, y: s * 0.14))
            tri.addLine(to: CGPoint(x: s * 0.88, y: s * 0.82))
            tri.addLine(to: CGPoint(x: s * 0.12, y: s * 0.82))
            tri.closeSubpath()
            ctx.stroke(tri, with: .color(color), style: stroke)
            var stem = Path()
            stem.move(to: CGPoint(x: c.x, y: s * 0.40))
            stem.addLine(to: CGPoint(x: c.x, y: s * 0.60))
            ctx.stroke(stem, with: .color(color), style: stroke)
            var dot = Path()
            dot.addEllipse(in: CGRect(x: c.x - s * 0.045, y: s * 0.66, width: s * 0.09, height: s * 0.09))
            ctx.fill(dot, with: .color(color))

        case .leaf:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.22, y: s * 0.80))
            p.addCurve(to: CGPoint(x: s * 0.80, y: s * 0.20),
                       control1: CGPoint(x: s * 0.22, y: s * 0.36),
                       control2: CGPoint(x: s * 0.48, y: s * 0.20))
            p.addCurve(to: CGPoint(x: s * 0.22, y: s * 0.80),
                       control1: CGPoint(x: s * 0.80, y: s * 0.62),
                       control2: CGPoint(x: s * 0.62, y: s * 0.80))
            ctx.stroke(p, with: .color(color), style: stroke)
            var vein = Path()
            vein.move(to: CGPoint(x: s * 0.30, y: s * 0.72))
            vein.addLine(to: CGPoint(x: s * 0.70, y: s * 0.32))
            ctx.stroke(vein, with: .color(color.opacity(0.6)), style: stroke)

        case .lock:
            var body = Path()
            body.addRoundedRect(in: CGRect(x: s * 0.22, y: s * 0.44, width: s * 0.56, height: s * 0.40),
                                cornerSize: CGSize(width: s * 0.10, height: s * 0.10))
            ctx.stroke(body, with: .color(color), style: stroke)
            var shackle = Path()
            shackle.addArc(center: CGPoint(x: c.x, y: s * 0.44), radius: s * 0.17,
                           startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            ctx.stroke(shackle, with: .color(color), style: stroke)
            var keyhole = Path()
            keyhole.addEllipse(in: CGRect(x: c.x - s * 0.05, y: s * 0.58, width: s * 0.10, height: s * 0.10))
            ctx.fill(keyhole, with: .color(color))

        case .shield:
            var p = Path()
            p.move(to: CGPoint(x: c.x, y: s * 0.12))
            p.addLine(to: CGPoint(x: s * 0.82, y: s * 0.28))
            p.addCurve(to: CGPoint(x: c.x, y: s * 0.88),
                       control1: CGPoint(x: s * 0.82, y: s * 0.64),
                       control2: CGPoint(x: s * 0.62, y: s * 0.80))
            p.addCurve(to: CGPoint(x: s * 0.18, y: s * 0.28),
                       control1: CGPoint(x: s * 0.38, y: s * 0.80),
                       control2: CGPoint(x: s * 0.18, y: s * 0.64))
            p.closeSubpath()
            ctx.stroke(p, with: .color(color), style: stroke)

        case .book:
            var p = Path()
            p.move(to: CGPoint(x: s * 0.18, y: s * 0.20))
            p.addLine(to: CGPoint(x: s * 0.48, y: s * 0.28))
            p.addLine(to: CGPoint(x: s * 0.48, y: s * 0.84))
            p.addLine(to: CGPoint(x: s * 0.18, y: s * 0.76))
            p.closeSubpath()
            p.move(to: CGPoint(x: s * 0.82, y: s * 0.20))
            p.addLine(to: CGPoint(x: s * 0.52, y: s * 0.28))
            p.addLine(to: CGPoint(x: s * 0.52, y: s * 0.84))
            p.addLine(to: CGPoint(x: s * 0.82, y: s * 0.76))
            p.closeSubpath()
            ctx.stroke(p, with: .color(color), style: stroke)
        }
    }
}

// MARK: - Method glyphs (8)

struct RGMethodGlyph: View {
    let index: Int
    var side: CGFloat = 26
    var color: Color = RGTheme.ink
    var lineWidth: CGFloat = 1.7

    var body: some View {
        Canvas { ctx, _ in
            let s = max(side, 1)
            let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            switch ((index % 8) + 8) % 8 {
            case 0: // cartridge razor: handle plus head with blade lines
                var handle = Path()
                handle.move(to: CGPoint(x: s * 0.50, y: s * 0.44))
                handle.addLine(to: CGPoint(x: s * 0.50, y: s * 0.88))
                ctx.stroke(handle, with: .color(color), style: stroke)
                var head = Path()
                head.addRoundedRect(in: CGRect(x: s * 0.16, y: s * 0.16, width: s * 0.68, height: s * 0.26),
                                    cornerSize: CGSize(width: s * 0.07, height: s * 0.07))
                ctx.stroke(head, with: .color(color), style: stroke)
                for i in 0..<2 {
                    var blade = Path()
                    let y = s * (0.25 + Double(i) * 0.09)
                    blade.move(to: CGPoint(x: s * 0.24, y: y))
                    blade.addLine(to: CGPoint(x: s * 0.76, y: y))
                    ctx.stroke(blade, with: .color(color.opacity(0.55)),
                               style: StrokeStyle(lineWidth: lineWidth * 0.7, lineCap: .round))
                }
            case 1: // electric shaver: body with three rotary rings
                var body = Path()
                body.addRoundedRect(in: CGRect(x: s * 0.28, y: s * 0.38, width: s * 0.44, height: s * 0.48),
                                    cornerSize: CGSize(width: s * 0.12, height: s * 0.12))
                ctx.stroke(body, with: .color(color), style: stroke)
                let centres = [CGPoint(x: s * 0.36, y: s * 0.25),
                               CGPoint(x: s * 0.64, y: s * 0.25),
                               CGPoint(x: s * 0.50, y: s * 0.14)]
                for p in centres {
                    var ring = Path()
                    ring.addEllipse(in: CGRect(x: p.x - s * 0.10, y: p.y - s * 0.10,
                                               width: s * 0.20, height: s * 0.20))
                    ctx.stroke(ring, with: .color(color), style: stroke)
                }
            case 2: // epilator: barrel with tweezer discs
                var barrel = Path()
                barrel.addRoundedRect(in: CGRect(x: s * 0.14, y: s * 0.34, width: s * 0.72, height: s * 0.32),
                                      cornerSize: CGSize(width: s * 0.15, height: s * 0.15))
                ctx.stroke(barrel, with: .color(color), style: stroke)
                for i in 0..<4 {
                    var disc = Path()
                    let x = s * (0.26 + Double(i) * 0.16)
                    disc.move(to: CGPoint(x: x, y: s * 0.30))
                    disc.addLine(to: CGPoint(x: x, y: s * 0.70))
                    ctx.stroke(disc, with: .color(color.opacity(0.6)),
                               style: StrokeStyle(lineWidth: lineWidth * 0.8, lineCap: .round))
                }
            case 3: // hot wax: pot with rising heat lines
                var pot = Path()
                pot.move(to: CGPoint(x: s * 0.22, y: s * 0.50))
                pot.addLine(to: CGPoint(x: s * 0.30, y: s * 0.84))
                pot.addLine(to: CGPoint(x: s * 0.70, y: s * 0.84))
                pot.addLine(to: CGPoint(x: s * 0.78, y: s * 0.50))
                pot.closeSubpath()
                ctx.stroke(pot, with: .color(color), style: stroke)
                for i in 0..<3 {
                    var heat = Path()
                    let x = s * (0.34 + Double(i) * 0.16)
                    heat.move(to: CGPoint(x: x, y: s * 0.38))
                    heat.addQuadCurve(to: CGPoint(x: x, y: s * 0.14),
                                      control: CGPoint(x: x + s * 0.10, y: s * 0.26))
                    ctx.stroke(heat, with: .color(color.opacity(0.6)),
                               style: StrokeStyle(lineWidth: lineWidth * 0.8, lineCap: .round))
                }
            case 4: // sugaring: jar with a spiral of paste
                var jar = Path()
                jar.addRoundedRect(in: CGRect(x: s * 0.26, y: s * 0.34, width: s * 0.48, height: s * 0.50),
                                   cornerSize: CGSize(width: s * 0.10, height: s * 0.10))
                ctx.stroke(jar, with: .color(color), style: stroke)
                var lid = Path()
                lid.move(to: CGPoint(x: s * 0.20, y: s * 0.30))
                lid.addLine(to: CGPoint(x: s * 0.80, y: s * 0.30))
                ctx.stroke(lid, with: .color(color), style: stroke)
                var spiral = Path()
                spiral.move(to: CGPoint(x: s * 0.36, y: s * 0.62))
                spiral.addQuadCurve(to: CGPoint(x: s * 0.64, y: s * 0.62),
                                    control: CGPoint(x: s * 0.50, y: s * 0.44))
                spiral.addQuadCurve(to: CGPoint(x: s * 0.42, y: s * 0.72),
                                    control: CGPoint(x: s * 0.52, y: s * 0.76))
                ctx.stroke(spiral, with: .color(color.opacity(0.7)), style: stroke)
            case 5: // depilatory cream: tube with a cap
                var tube = Path()
                tube.move(to: CGPoint(x: s * 0.34, y: s * 0.30))
                tube.addLine(to: CGPoint(x: s * 0.66, y: s * 0.30))
                tube.addLine(to: CGPoint(x: s * 0.74, y: s * 0.86))
                tube.addLine(to: CGPoint(x: s * 0.26, y: s * 0.86))
                tube.closeSubpath()
                ctx.stroke(tube, with: .color(color), style: stroke)
                var cap = Path()
                cap.addRoundedRect(in: CGRect(x: s * 0.41, y: s * 0.12, width: s * 0.18, height: s * 0.16),
                                   cornerSize: CGSize(width: s * 0.04, height: s * 0.04))
                ctx.stroke(cap, with: .color(color), style: stroke)
                var band = Path()
                band.move(to: CGPoint(x: s * 0.30, y: s * 0.62))
                band.addLine(to: CGPoint(x: s * 0.70, y: s * 0.62))
                ctx.stroke(band, with: .color(color.opacity(0.55)),
                           style: StrokeStyle(lineWidth: lineWidth * 0.8, lineCap: .round))
            case 6: // threading: a twisted loop
                var left = Path()
                left.addEllipse(in: CGRect(x: s * 0.10, y: s * 0.28, width: s * 0.38, height: s * 0.44))
                ctx.stroke(left, with: .color(color), style: stroke)
                var right = Path()
                right.addEllipse(in: CGRect(x: s * 0.52, y: s * 0.28, width: s * 0.38, height: s * 0.44))
                ctx.stroke(right, with: .color(color), style: stroke)
                var twist = Path()
                twist.move(to: CGPoint(x: s * 0.40, y: s * 0.38))
                twist.addLine(to: CGPoint(x: s * 0.60, y: s * 0.62))
                twist.move(to: CGPoint(x: s * 0.60, y: s * 0.38))
                twist.addLine(to: CGPoint(x: s * 0.40, y: s * 0.62))
                ctx.stroke(twist, with: .color(color), style: stroke)
            default: // laser / IPL: emitter with a beam and a burst
                var head = Path()
                head.addRoundedRect(in: CGRect(x: s * 0.18, y: s * 0.12, width: s * 0.64, height: s * 0.24),
                                    cornerSize: CGSize(width: s * 0.08, height: s * 0.08))
                ctx.stroke(head, with: .color(color), style: stroke)
                var beam = Path()
                beam.move(to: CGPoint(x: s * 0.36, y: s * 0.38))
                beam.addLine(to: CGPoint(x: s * 0.50, y: s * 0.74))
                beam.addLine(to: CGPoint(x: s * 0.64, y: s * 0.38))
                ctx.stroke(beam, with: .color(color), style: stroke)
                for i in 0..<3 {
                    var spark = Path()
                    let x = s * (0.30 + Double(i) * 0.20)
                    spark.move(to: CGPoint(x: x, y: s * 0.86))
                    spark.addLine(to: CGPoint(x: x + s * 0.05, y: s * 0.80))
                    ctx.stroke(spark, with: .color(color.opacity(0.65)),
                               style: StrokeStyle(lineWidth: lineWidth * 0.8, lineCap: .round))
                }
            }
        }
        .frame(width: side, height: side)
        .allowsHitTesting(false)
    }
}

// MARK: - Zone glyphs (17, deliberately geometric rather than anatomical)

struct RGZoneGlyph: View {
    let index: Int
    var side: CGFloat = 40
    var color: Color = RGTheme.sageDeep
    var lineWidth: CGFloat = 1.8

    var body: some View {
        Canvas { ctx, _ in
            let s = max(side, 1)
            let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            let soft = StrokeStyle(lineWidth: lineWidth * 0.75, lineCap: .round, lineJoin: .round)
            let i = ((index % 17) + 17) % 17
            let c = CGPoint(x: s / 2, y: s / 2)

            // Every zone glyph is a distinct abstract mark built from arcs,
            // chevrons and dot fields. No silhouettes, no body outlines.
            switch i {
            case 0: // underarms: an inverted arch over a dot field
                var arch = Path()
                arch.move(to: CGPoint(x: s * 0.22, y: s * 0.22))
                arch.addQuadCurve(to: CGPoint(x: s * 0.78, y: s * 0.22),
                                  control: CGPoint(x: s * 0.50, y: s * 0.66))
                ctx.stroke(arch, with: .color(color), style: stroke)
                dots(ctx, s: s, color: color, rows: 2, cols: 3,
                     rect: CGRect(x: s * 0.30, y: s * 0.60, width: s * 0.40, height: s * 0.22))
            case 1: // lower legs: two parallel tapering columns
                for k in 0..<2 {
                    var col = Path()
                    let x = s * (0.34 + Double(k) * 0.32)
                    col.move(to: CGPoint(x: x - s * 0.07, y: s * 0.16))
                    col.addLine(to: CGPoint(x: x - s * 0.03, y: s * 0.84))
                    col.addLine(to: CGPoint(x: x + s * 0.06, y: s * 0.84))
                    col.addLine(to: CGPoint(x: x + s * 0.09, y: s * 0.16))
                    ctx.stroke(col, with: .color(color), style: stroke)
                }
            case 2: // upper legs: a broad wedge pair
                var wedge = Path()
                wedge.move(to: CGPoint(x: s * 0.18, y: s * 0.18))
                wedge.addLine(to: CGPoint(x: s * 0.40, y: s * 0.82))
                wedge.move(to: CGPoint(x: s * 0.82, y: s * 0.18))
                wedge.addLine(to: CGPoint(x: s * 0.60, y: s * 0.82))
                ctx.stroke(wedge, with: .color(color), style: stroke)
                var bridge = Path()
                bridge.move(to: CGPoint(x: s * 0.22, y: s * 0.30))
                bridge.addLine(to: CGPoint(x: s * 0.78, y: s * 0.30))
                ctx.stroke(bridge, with: .color(color.opacity(0.6)), style: soft)
            case 3: // bikini line: a single diagonal band
                var band = Path()
                band.move(to: CGPoint(x: s * 0.16, y: s * 0.68))
                band.addQuadCurve(to: CGPoint(x: s * 0.84, y: s * 0.30),
                                  control: CGPoint(x: s * 0.50, y: s * 0.34))
                ctx.stroke(band, with: .color(color), style: stroke)
                var under = Path()
                under.move(to: CGPoint(x: s * 0.20, y: s * 0.80))
                under.addQuadCurve(to: CGPoint(x: s * 0.88, y: s * 0.42),
                                   control: CGPoint(x: s * 0.54, y: s * 0.46))
                ctx.stroke(under, with: .color(color.opacity(0.5)), style: soft)
            case 4: // full bikini: a filled triangle field
                var tri = Path()
                tri.move(to: CGPoint(x: s * 0.20, y: s * 0.26))
                tri.addLine(to: CGPoint(x: s * 0.80, y: s * 0.26))
                tri.addLine(to: CGPoint(x: s * 0.50, y: s * 0.80))
                tri.closeSubpath()
                ctx.stroke(tri, with: .color(color), style: stroke)
                dots(ctx, s: s, color: color, rows: 2, cols: 3,
                     rect: CGRect(x: s * 0.33, y: s * 0.36, width: s * 0.34, height: s * 0.24))
            case 5: // forearms: a single slim bar with a cuff
                var bar = Path()
                bar.addRoundedRect(in: CGRect(x: s * 0.38, y: s * 0.14, width: s * 0.24, height: s * 0.72),
                                   cornerSize: CGSize(width: s * 0.11, height: s * 0.11))
                ctx.stroke(bar, with: .color(color), style: stroke)
                var cuff = Path()
                cuff.move(to: CGPoint(x: s * 0.34, y: s * 0.66))
                cuff.addLine(to: CGPoint(x: s * 0.66, y: s * 0.66))
                ctx.stroke(cuff, with: .color(color.opacity(0.6)), style: soft)
            case 6: // upper arms: a thicker bar with a shoulder cap
                var bar = Path()
                bar.addRoundedRect(in: CGRect(x: s * 0.34, y: s * 0.32, width: s * 0.32, height: s * 0.52),
                                   cornerSize: CGSize(width: s * 0.14, height: s * 0.14))
                ctx.stroke(bar, with: .color(color), style: stroke)
                var cap = Path()
                cap.addArc(center: CGPoint(x: c.x, y: s * 0.32), radius: s * 0.22,
                           startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                ctx.stroke(cap, with: .color(color), style: stroke)
            case 7: // chest: two opposed spirals
                for k in 0..<2 {
                    var whorl = Path()
                    let cx = s * (k == 0 ? 0.34 : 0.66)
                    whorl.addArc(center: CGPoint(x: cx, y: c.y), radius: s * 0.18,
                                 startAngle: .degrees(0), endAngle: .degrees(280), clockwise: k == 1)
                    ctx.stroke(whorl, with: .color(color), style: stroke)
                    var inner = Path()
                    inner.addArc(center: CGPoint(x: cx, y: c.y), radius: s * 0.08,
                                 startAngle: .degrees(180), endAngle: .degrees(20), clockwise: k == 1)
                    ctx.stroke(inner, with: .color(color.opacity(0.6)), style: soft)
                }
            case 8: // abdomen: horizontal contour lines around a centre point
                for k in 0..<3 {
                    var line = Path()
                    let y = s * (0.30 + Double(k) * 0.20)
                    let inset = s * (k == 1 ? 0.14 : 0.22)
                    line.move(to: CGPoint(x: inset, y: y))
                    line.addQuadCurve(to: CGPoint(x: s - inset, y: y),
                                      control: CGPoint(x: c.x, y: y + s * 0.07))
                    ctx.stroke(line, with: .color(color.opacity(k == 1 ? 1 : 0.6)),
                               style: k == 1 ? stroke : soft)
                }
                var dot = Path()
                dot.addEllipse(in: CGRect(x: c.x - s * 0.035, y: c.y - s * 0.035,
                                          width: s * 0.07, height: s * 0.07))
                ctx.fill(dot, with: .color(color))
            case 9: // back: a broad panel divided down the middle
                var panel = Path()
                panel.addRoundedRect(in: CGRect(x: s * 0.20, y: s * 0.18, width: s * 0.60, height: s * 0.64),
                                     cornerSize: CGSize(width: s * 0.14, height: s * 0.14))
                ctx.stroke(panel, with: .color(color), style: stroke)
                var spine = Path()
                spine.move(to: CGPoint(x: c.x, y: s * 0.24))
                spine.addLine(to: CGPoint(x: c.x, y: s * 0.76))
                ctx.stroke(spine, with: .color(color.opacity(0.6)), style: soft)
            case 10: // shoulders: a wide flattened arc with end caps
                var arc = Path()
                arc.move(to: CGPoint(x: s * 0.14, y: s * 0.62))
                arc.addQuadCurve(to: CGPoint(x: s * 0.86, y: s * 0.62),
                                 control: CGPoint(x: c.x, y: s * 0.24))
                ctx.stroke(arc, with: .color(color), style: stroke)
                for x in [s * 0.14, s * 0.86] {
                    var cap = Path()
                    cap.addEllipse(in: CGRect(x: x - s * 0.07, y: s * 0.55, width: s * 0.14, height: s * 0.14))
                    ctx.stroke(cap, with: .color(color), style: stroke)
                }
            case 11: // upper lip: a shallow double curve
                var lip = Path()
                lip.move(to: CGPoint(x: s * 0.20, y: s * 0.52))
                lip.addQuadCurve(to: CGPoint(x: s * 0.50, y: s * 0.42),
                                 control: CGPoint(x: s * 0.35, y: s * 0.32))
                lip.addQuadCurve(to: CGPoint(x: s * 0.80, y: s * 0.52),
                                 control: CGPoint(x: s * 0.65, y: s * 0.32))
                ctx.stroke(lip, with: .color(color), style: stroke)
                dots(ctx, s: s, color: color, rows: 1, cols: 4,
                     rect: CGRect(x: s * 0.28, y: s * 0.64, width: s * 0.44, height: s * 0.06))
            case 12: // chin: a rounded base arc with a stem
                var arc = Path()
                arc.addArc(center: CGPoint(x: c.x, y: s * 0.48), radius: s * 0.28,
                           startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
                ctx.stroke(arc, with: .color(color), style: stroke)
                var stem = Path()
                stem.move(to: CGPoint(x: c.x, y: s * 0.22))
                stem.addLine(to: CGPoint(x: c.x, y: s * 0.44))
                ctx.stroke(stem, with: .color(color.opacity(0.6)), style: soft)
            case 13: // eyebrows: two tapered strokes
                for k in 0..<2 {
                    var brow = Path()
                    let y = s * (0.38 + Double(k) * 0.24)
                    brow.move(to: CGPoint(x: s * 0.20, y: y + s * 0.06))
                    brow.addQuadCurve(to: CGPoint(x: s * 0.80, y: y),
                                      control: CGPoint(x: s * 0.50, y: y - s * 0.10))
                    ctx.stroke(brow, with: .color(color.opacity(k == 0 ? 1 : 0.55)),
                               style: k == 0 ? stroke : soft)
                }
            case 14: // neck: a vertical column with two rings
                var col = Path()
                col.move(to: CGPoint(x: s * 0.38, y: s * 0.16))
                col.addLine(to: CGPoint(x: s * 0.38, y: s * 0.84))
                col.move(to: CGPoint(x: s * 0.62, y: s * 0.16))
                col.addLine(to: CGPoint(x: s * 0.62, y: s * 0.84))
                ctx.stroke(col, with: .color(color), style: stroke)
                for k in 0..<2 {
                    var ring = Path()
                    let y = s * (0.38 + Double(k) * 0.24)
                    ring.move(to: CGPoint(x: s * 0.30, y: y))
                    ring.addQuadCurve(to: CGPoint(x: s * 0.70, y: y),
                                      control: CGPoint(x: c.x, y: y + s * 0.08))
                    ctx.stroke(ring, with: .color(color.opacity(0.6)), style: soft)
                }
            case 15: // hands: a fan of four short bars over a base
                for k in 0..<4 {
                    var finger = Path()
                    let x = s * (0.26 + Double(k) * 0.16)
                    finger.move(to: CGPoint(x: x, y: s * 0.56))
                    finger.addLine(to: CGPoint(x: x + Double(k - 2) * s * 0.03, y: s * 0.18))
                    ctx.stroke(finger, with: .color(color), style: soft)
                }
                var base = Path()
                base.addRoundedRect(in: CGRect(x: s * 0.22, y: s * 0.56, width: s * 0.52, height: s * 0.26),
                                    cornerSize: CGSize(width: s * 0.10, height: s * 0.10))
                ctx.stroke(base, with: .color(color), style: stroke)
            default: // feet: a wedge with a row of dots
                var wedge = Path()
                wedge.move(to: CGPoint(x: s * 0.24, y: s * 0.72))
                wedge.addQuadCurve(to: CGPoint(x: s * 0.76, y: s * 0.46),
                                   control: CGPoint(x: s * 0.42, y: s * 0.38))
                wedge.addLine(to: CGPoint(x: s * 0.78, y: s * 0.66))
                wedge.addLine(to: CGPoint(x: s * 0.28, y: s * 0.82))
                wedge.closeSubpath()
                ctx.stroke(wedge, with: .color(color), style: stroke)
                dots(ctx, s: s, color: color, rows: 1, cols: 3,
                     rect: CGRect(x: s * 0.52, y: s * 0.28, width: s * 0.26, height: s * 0.06))
            }
        }
        .frame(width: side, height: side)
        .allowsHitTesting(false)
    }

    private func dots(_ ctx: GraphicsContext, s: CGFloat, color: Color,
                      rows: Int, cols: Int, rect: CGRect) {
        guard rows > 0, cols > 0 else { return }
        let r = s * 0.035
        let stepX = cols > 1 ? rect.width / CGFloat(cols - 1) : 0
        let stepY = rows > 1 ? rect.height / CGFloat(rows - 1) : 0
        for row in 0..<rows {
            for col in 0..<cols {
                var dot = Path()
                let x = rect.minX + CGFloat(col) * stepX
                let y = rect.minY + CGFloat(row) * stepY
                dot.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
                ctx.fill(dot, with: .color(color.opacity(0.7)))
            }
        }
    }
}

// MARK: - The app's own wordmark glyph (leaf over a droplet)

struct RGBrandMark: View {
    var side: CGFloat = 96
    var leafColor: Color = RGTheme.sage
    var dropColor: Color = RGTheme.sageDeep

    var body: some View {
        Canvas { ctx, _ in
            let s = max(side, 1)
            var drop = Path()
            drop.move(to: CGPoint(x: s * 0.50, y: s * 0.34))
            drop.addCurve(to: CGPoint(x: s * 0.74, y: s * 0.68),
                          control1: CGPoint(x: s * 0.62, y: s * 0.46),
                          control2: CGPoint(x: s * 0.74, y: s * 0.58))
            drop.addArc(center: CGPoint(x: s * 0.50, y: s * 0.68), radius: s * 0.24,
                        startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            drop.closeSubpath()
            ctx.fill(drop, with: .color(dropColor.opacity(0.18)))
            ctx.stroke(drop, with: .color(dropColor),
                       style: StrokeStyle(lineWidth: s * 0.035, lineCap: .round, lineJoin: .round))

            var leaf = Path()
            leaf.move(to: CGPoint(x: s * 0.24, y: s * 0.46))
            leaf.addQuadCurve(to: CGPoint(x: s * 0.78, y: s * 0.18),
                              control: CGPoint(x: s * 0.38, y: s * 0.12))
            leaf.addQuadCurve(to: CGPoint(x: s * 0.24, y: s * 0.46),
                              control: CGPoint(x: s * 0.62, y: s * 0.44))
            ctx.fill(leaf, with: .color(leafColor.opacity(0.85)))

            var vein = Path()
            vein.move(to: CGPoint(x: s * 0.28, y: s * 0.44))
            vein.addQuadCurve(to: CGPoint(x: s * 0.74, y: s * 0.20),
                              control: CGPoint(x: s * 0.50, y: s * 0.28))
            ctx.stroke(vein, with: .color(RGTheme.cream.opacity(0.8)),
                       style: StrokeStyle(lineWidth: s * 0.022, lineCap: .round))
        }
        .frame(width: side, height: side)
        .allowsHitTesting(false)
    }
}
