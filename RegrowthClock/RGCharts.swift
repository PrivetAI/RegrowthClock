import SwiftUI

/// Layout widths are computed once, from the screen, and every nested inset is
/// subtracted explicitly (pitfall 7): screen padding 16 on each side, card
/// padding 14 on each side.
enum RGLayout {
    static var screenWidth: CGFloat { RGDevice.width }
    static var contentWidth: CGFloat { max(screenWidth - 32, 200) }
    static var cardInnerWidth: CGFloat { max(contentWidth - 28, 180) }
}

// MARK: - Monthly bar chart

struct RGBarChart: View {
    struct Bar: Identifiable {
        let id: Int
        let label: String
        let value: Double
        var highlighted: Bool = false
    }

    let bars: [Bar]
    let width: CGFloat
    var height: CGFloat = 132
    var color: Color = RGTheme.sage
    var valueFormatter: (Double) -> String = { RGFormat.oneDecimal($0) }

    private var maxValue: Double {
        let m = bars.map { $0.value }.filter { $0.isFinite }.max() ?? 0
        return m > 0 ? m : 1
    }

    /// `maxValue` falls back to 1 so the bar heights never divide by zero. That
    /// sentinel must not reach the label, or an empty window prints "Peak $1".
    private var peakText: String {
        let anySpend = bars.contains { $0.value.isFinite && $0.value > 0 }
        return "Peak " + (anySpend ? valueFormatter(maxValue) : RGFormat.dash)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Canvas { ctx, _ in
                let w = max(width, 40)
                let h = max(height, 40)
                let plotH = h - 18
                let n = max(bars.count, 1)
                let gap: CGFloat = n > 8 ? 3 : 6
                let barW = max((w - gap * CGFloat(n - 1)) / CGFloat(n), 3)

                var base = Path()
                base.move(to: CGPoint(x: 0, y: plotH))
                base.addLine(to: CGPoint(x: w, y: plotH))
                ctx.stroke(base, with: .color(RGTheme.hairline),
                           style: StrokeStyle(lineWidth: 1))

                for (i, bar) in bars.enumerated() {
                    let x = CGFloat(i) * (barW + gap)
                    let raw = bar.value.isFinite && bar.value > 0 ? bar.value : 0
                    let frac = RGMath.clamp(raw / maxValue, 0, 1)
                    let bh = max(CGFloat(frac) * (plotH - 6), raw > 0 ? 3 : 1.5)
                    var p = Path()
                    p.addRoundedRect(in: CGRect(x: x, y: plotH - bh, width: barW, height: bh),
                                     cornerSize: CGSize(width: min(barW / 2, 4), height: min(barW / 2, 4)))
                    let fill = raw > 0
                        ? (bar.highlighted ? color : color.opacity(0.55))
                        : RGTheme.inkGhost.opacity(0.5)
                    ctx.fill(p, with: .color(fill))

                    let text = Text(bar.label)
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                    ctx.draw(text, at: CGPoint(x: x + barW / 2, y: plotH + 9), anchor: .center)
                }
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)

            HStack {
                Text(peakText)
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
                Spacer(minLength: 4)
                Text("\(bars.count) months")
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
            }
            .frame(width: width, alignment: .leading)
        }
    }
}

// MARK: - Horizontal share bars

struct RGShareBars: View {
    struct Row: Identifiable {
        let id: String
        let label: String
        let value: Double
        let detail: String
        let color: Color
    }

    let rows: [Row]
    let width: CGFloat
    var valueText: (Double) -> String = { RGFormat.oneDecimal($0) }

    private var maxValue: Double {
        let m = rows.map { $0.value }.filter { $0.isFinite }.max() ?? 0
        return m > 0 ? m : 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(row.label)
                            .font(RGFont.body(12))
                            .foregroundColor(RGTheme.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(valueText(row.value))
                            .font(RGFont.mono(12))
                            .foregroundColor(RGTheme.ink)
                        Text(row.detail)
                            .font(RGFont.label(9))
                            .foregroundColor(RGTheme.inkFaint)
                    }
                    RGProgressBar(fraction: RGMath.clamp(row.value / maxValue, 0, 1),
                                  width: width,
                                  height: 7,
                                  color: row.color,
                                  trackColor: RGTheme.creamDeep)
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }
}

// MARK: - Irritation heat grid (zone x method)

struct RGHeatGrid: View {
    let rows: [(zoneID: String, cells: [(methodID: String, rate: Double?, n: Int)])]
    let width: CGFloat

    private let labelWidth: CGFloat = 92

    var body: some View {
        let methodCount = max(RGMethodCatalog.all.count, 1)
        let gridWidth = max(width - labelWidth, 60)
        let cellW = gridWidth / CGFloat(methodCount)
        let cellH: CGFloat = 30

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("")
                    .frame(width: labelWidth, alignment: .leading)
                ForEach(RGMethodCatalog.all) { m in
                    Text(RGHeatGrid.abbrev(m.shortName))
                        .font(RGFont.label(8))
                        .foregroundColor(RGTheme.inkFaint)
                        .frame(width: cellW, height: 16)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            ForEach(rows, id: \.zoneID) { row in
                HStack(spacing: 0) {
                    Text(RGZoneCatalog.name(row.zoneID))
                        .font(RGFont.body(11))
                        .foregroundColor(RGTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(width: labelWidth, height: cellH, alignment: .leading)
                    ForEach(row.cells, id: \.methodID) { cell in
                        RGHeatCell(rate: cell.rate, n: cell.n, width: cellW, height: cellH)
                    }
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }

    static func abbrev(_ s: String) -> String {
        if s.count <= 6 { return s }
        return String(s.prefix(5)) + "."
    }
}

struct RGHeatCell: View {
    let rate: Double?
    let n: Int
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 8)
            let h = max(height, 8)
            let inset: CGFloat = 1.5
            var rect = Path()
            rect.addRoundedRect(in: CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2),
                                cornerSize: CGSize(width: 3, height: 3))
            if let r = rate, n > 0 {
                ctx.fill(rect, with: .color(RGTheme.heat(r)))
                let label = Text("\(n)")
                    .font(RGFont.label(8))
                    .foregroundColor(r > 0.55 ? RGTheme.cream : RGTheme.ink.opacity(0.75))
                ctx.draw(label, at: CGPoint(x: w / 2, y: h / 2), anchor: .center)
            } else {
                ctx.fill(rect, with: .color(RGTheme.creamDeep.opacity(0.6)))
                let label = Text(RGFormat.dash)
                    .font(RGFont.label(8))
                    .foregroundColor(RGTheme.inkFaint.opacity(0.7))
                ctx.draw(label, at: CGPoint(x: w / 2, y: h / 2), anchor: .center)
            }
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}

// MARK: - Zone timeline over the last six months

struct RGZoneTimeline: View {
    let sessions: [RGSession]
    let width: CGFloat
    var height: CGFloat = 74
    var months: Int = 6

    var body: some View {
        let todayKey = RGCal.todayKey
        let startKey = RGCal.addingDays(todayKey, -(months * 30))
        let span = max(Double(RGCal.daysBetween(startKey, todayKey)), 1)

        return VStack(alignment: .leading, spacing: 6) {
            Canvas { ctx, _ in
                let w = max(width, 40)
                let h = max(height, 40)
                let axisY = h - 20

                let monthKeys = RGCal.recentMonthKeys(months)
                for mk in monthKeys {
                    let firstDay = mk * 100 + 1
                    let offset = Double(RGCal.daysBetween(startKey, firstDay))
                    guard offset >= 0, offset <= span else { continue }
                    let x = w * CGFloat(offset / span)
                    var tick = Path()
                    tick.move(to: CGPoint(x: x, y: 8))
                    tick.addLine(to: CGPoint(x: x, y: axisY))
                    ctx.stroke(tick, with: .color(RGTheme.hairline),
                               style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                    let label = Text(RGCal.monthLabel(mk))
                        .font(RGFont.label(8))
                        .foregroundColor(RGTheme.inkFaint)
                    ctx.draw(label, at: CGPoint(x: x + 12, y: axisY + 10), anchor: .center)
                }

                var axis = Path()
                axis.move(to: CGPoint(x: 0, y: axisY))
                axis.addLine(to: CGPoint(x: w, y: axisY))
                ctx.stroke(axis, with: .color(RGTheme.inkGhost),
                           style: StrokeStyle(lineWidth: 1))

                for s in sessions {
                    let offset = Double(RGCal.daysBetween(startKey, s.dayKey))
                    guard offset >= 0, offset <= span else { continue }
                    let x = w * CGFloat(offset / span)
                    let colour = RGMethodCatalog.color(s.methodID)
                    var stem = Path()
                    let topY: CGFloat = s.reaction.countsAsIrritation ? 16 : 30
                    stem.move(to: CGPoint(x: x, y: axisY))
                    stem.addLine(to: CGPoint(x: x, y: topY))
                    ctx.stroke(stem, with: .color(colour.opacity(0.75)),
                               style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: x - 3, y: topY - 3, width: 6, height: 6))
                    ctx.fill(dot, with: .color(s.reaction.countsAsIrritation ? RGTheme.coral : colour))
                }

                if sessions.isEmpty {
                    let label = Text("No sessions in this window")
                        .font(RGFont.label(10))
                        .foregroundColor(RGTheme.inkFaint)
                    ctx.draw(label, at: CGPoint(x: w / 2, y: axisY / 2), anchor: .center)
                }
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)

            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Circle().fill(RGTheme.coral).frame(width: 6, height: 6)
                    Text("with a reaction")
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                }
                HStack(spacing: 4) {
                    Circle().fill(RGTheme.sage).frame(width: 6, height: 6)
                    Text("clear")
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                }
                Spacer(minLength: 0)
            }
            .frame(width: width, alignment: .leading)
        }
    }
}

// MARK: - Gap series with a fitted trend line

struct RGDriftChart: View {
    let gaps: [Double]
    let width: CGFloat
    var height: CGFloat = 96
    var color: Color = RGTheme.sageDeep

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 40)
            let h = max(height, 40)
            // Five, to match the label, the drift sentence underneath and the
            // intro card. Drawing a series below that is exactly the shape the
            // app promises not to draw out of noise.
            guard gaps.count >= 5 else {
                let label = Text("Needs at least five gaps")
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
                ctx.draw(label, at: CGPoint(x: w / 2, y: h / 2), anchor: .center)
                return
            }
            let lo = gaps.min() ?? 0
            let hi = gaps.max() ?? 1
            let pad = max((hi - lo) * 0.2, 1)
            let minY = max(lo - pad, 0)
            let maxY = hi + pad
            let range = max(maxY - minY, 0.001)

            func point(_ i: Int, _ v: Double) -> CGPoint {
                let x = gaps.count > 1 ? w * CGFloat(Double(i) / Double(gaps.count - 1)) : w / 2
                let y = h - 14 - CGFloat((v - minY) / range) * (h - 26)
                return CGPoint(x: x, y: y)
            }

            var line = Path()
            for (i, v) in gaps.enumerated() {
                let p = point(i, v)
                if i == 0 { line.move(to: p) } else { line.addLine(to: p) }
            }
            ctx.stroke(line, with: .color(color.opacity(0.55)),
                       style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))

            for (i, v) in gaps.enumerated() {
                var dot = Path()
                let p = point(i, v)
                dot.addEllipse(in: CGRect(x: p.x - 2.6, y: p.y - 2.6, width: 5.2, height: 5.2))
                ctx.fill(dot, with: .color(color))
            }

            if gaps.count >= 5, let slope = RGMath.slope(gaps), let mean = RGMath.mean(gaps) {
                let midIndex = Double(gaps.count - 1) / 2
                let startV = mean - slope * midIndex
                let endV = mean + slope * midIndex
                var trend = Path()
                trend.move(to: point(0, startV))
                trend.addLine(to: point(gaps.count - 1, endV))
                ctx.stroke(trend, with: .color(RGTheme.coral.opacity(0.8)),
                           style: StrokeStyle(lineWidth: 1.6, dash: [4, 3]))
            }

            let loLabel = Text(RGFormat.whole(minY) + "d")
                .font(RGFont.label(8))
                .foregroundColor(RGTheme.inkFaint)
            ctx.draw(loLabel, at: CGPoint(x: 14, y: h - 6), anchor: .center)
            let hiLabel = Text(RGFormat.whole(maxY) + "d")
                .font(RGFont.label(8))
                .foregroundColor(RGTheme.inkFaint)
            ctx.draw(hiLabel, at: CGPoint(x: 14, y: 8), anchor: .center)
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}

// MARK: - Course ladder for laser / IPL

struct RGCourseLadder: View {
    let done: Int
    let planned: Int
    let width: CGFloat
    var height: CGFloat = 34

    var body: some View {
        Canvas { ctx, _ in
            let w = max(width, 40)
            let h = max(height, 16)
            let n = max(planned, 1)
            let gap: CGFloat = 5
            let cell = max((w - gap * CGFloat(n - 1)) / CGFloat(n), 6)
            for i in 0..<n {
                let x = CGFloat(i) * (cell + gap)
                var box = Path()
                box.addRoundedRect(in: CGRect(x: x, y: h * 0.2, width: cell, height: h * 0.6),
                                   cornerSize: CGSize(width: 4, height: 4))
                if i < done {
                    ctx.fill(box, with: .color(RGTheme.sage))
                } else if i == done {
                    ctx.fill(box, with: .color(RGTheme.clay.opacity(0.45)))
                    ctx.stroke(box, with: .color(RGTheme.clay), style: StrokeStyle(lineWidth: 1.4))
                } else {
                    ctx.fill(box, with: .color(RGTheme.creamDeep))
                }
            }
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }
}
