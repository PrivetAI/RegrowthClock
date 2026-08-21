import SwiftUI

/// The 8 tracked methods. `intervalMultiplier` scales a zone's razor-baseline
/// prior into a cold-start prior for that (zone, method) pair; once the learner
/// has real gaps it takes over and the multiplier only survives as a fading
/// prior weight.
enum RGMethodCatalog {

    static let all: [RGMethod] = [
        RGMethod(
            id: "razor",
            name: "Safety or cartridge razor",
            shortName: "Razor",
            intervalMultiplier: 1.0,
            typicalCost: 2.20,
            typicalMinutes: 9,
            irritationProfile: "Cuts the hair at the surface, so nothing is removed from the follicle. Irritation shows up as razor burn, nicks and ingrown hairs rather than as inflammation days later.",
            techniqueNote: "Soften the hair with warm water for two or three minutes before the first pass; dry hair blunts a blade almost immediately. Stretch the skin flat with your free hand and let the weight of the handle do the work instead of pressing. Rinse the head after every second stroke so the gap between blades stays clear. Rinse cool at the end, pat rather than rub, and store the razor dry and away from the shower spray, because a wet blade corrodes long before it goes blunt from use.",
            consumableName: "Cartridge or blade",
            consumableLife: 6,
            glyph: 0,
            chipIndex: 0
        ),
        RGMethod(
            id: "electric",
            name: "Electric shaver",
            shortName: "Electric",
            intervalMultiplier: 0.85,
            typicalCost: 0.30,
            typicalMinutes: 7,
            irritationProfile: "Gentler on the skin surface than a blade because the foil or guard never touches skin directly, but it leaves the hair slightly longer, so the comfortable interval is shorter.",
            techniqueNote: "Most foil and rotary shavers work best on dry, clean skin, so save this for before a shower rather than after one. Move against the direction of growth in small circles for rotary heads, and in straight strokes for foil heads. Keep the head flat on the skin instead of tilting it into a corner. Empty and brush out the head after each use, and replace the foil or cutter on the maker's schedule, because a worn cutter pulls hairs rather than cutting them.",
            consumableName: "Foil or cutter head",
            consumableLife: 90,
            glyph: 1,
            chipIndex: 1
        ),
        RGMethod(
            id: "epilator",
            name: "Epilator",
            shortName: "Epilator",
            intervalMultiplier: 3.2,
            typicalCost: 0.45,
            typicalMinutes: 22,
            irritationProfile: "Removes hair from the root mechanically, so regrowth is slow and soft, but the first few sessions commonly leave redness and small bumps for a day.",
            techniqueNote: "Let the hair reach three to five millimeters so the tweezer discs can actually grip it. Hold the device at roughly a right angle to the skin, move slowly against the direction of growth, and keep the skin stretched with your other hand. Going slowly hurts less than going quickly, which is the opposite of what most people assume. Do it in the evening so redness fades overnight, and clean the head with alcohol and let it dry fully between uses.",
            consumableName: "Epilator head",
            consumableLife: 150,
            glyph: 2,
            chipIndex: 2
        ),
        RGMethod(
            id: "hot-wax",
            name: "Hot wax",
            shortName: "Hot wax",
            intervalMultiplier: 3.5,
            typicalCost: 16.00,
            typicalMinutes: 26,
            irritationProfile: "Removes hair at the root and takes a layer of surface skin cells with it, so redness for a few hours is normal. Heat plus stripping means sun and friction are the real risks afterwards.",
            techniqueNote: "Hair needs to be about five millimeters long, and the skin needs to be clean, dry and free of oil or lotion. Test the temperature on your inner wrist every single time, no matter how familiar the pot is. Apply in the direction the hair grows, hold the skin taut, and pull the strip back low and fast, parallel to the skin rather than upward. Never wax the same patch twice in one session, and keep the area out of direct sun, hot tubs and tight clothing for a day.",
            consumableName: "Wax pot or refill",
            consumableLife: 12,
            glyph: 3,
            chipIndex: 3
        ),
        RGMethod(
            id: "sugaring",
            name: "Sugaring",
            shortName: "Sugaring",
            intervalMultiplier: 3.4,
            typicalCost: 19.00,
            typicalMinutes: 26,
            irritationProfile: "Similar hold to wax but applied at closer to body temperature and pulled with the grain, which many people find leaves less surface trauma. Still removal at the root, so redness for a few hours is expected.",
            techniqueNote: "Sugar paste is water soluble, so mistakes rinse off and there is no strip residue to scrub. Warm the paste until it is pliable but not runny, then apply against the direction of growth and flick it off with the grain in a short, low motion. Because it is pulled with the grain it is often kinder to the follicle than a strip pull. Shorter hair works than with wax, around three millimeters, and the same day-after rules apply: no sauna, no sun, no tight fabric.",
            consumableName: "Sugar paste jar",
            consumableLife: 15,
            glyph: 4,
            chipIndex: 4
        ),
        RGMethod(
            id: "cream",
            name: "Depilatory cream",
            shortName: "Cream",
            intervalMultiplier: 1.6,
            typicalCost: 4.50,
            typicalMinutes: 14,
            irritationProfile: "Dissolves the hair chemically just below the surface. No blade trauma, but the active ingredients are alkaline and will burn skin if left beyond the stated time.",
            techniqueNote: "Patch test on a small area a full day before the first use of any new product, and repeat the test if the formula changes. Apply an even layer without rubbing it in, and set an actual timer for the shortest time on the label rather than guessing. Never leave it on longer to catch stubborn hairs, and never use it on broken, sunburnt or freshly exfoliated skin. Remove with the supplied spatula and lukewarm water, not by scrubbing, and skip fragranced products for the rest of the day.",
            consumableName: "Cream tube",
            consumableLife: 6,
            glyph: 5,
            chipIndex: 5
        ),
        RGMethod(
            id: "threading",
            name: "Threading",
            shortName: "Threading",
            intervalMultiplier: 3.0,
            typicalCost: 12.00,
            typicalMinutes: 11,
            irritationProfile: "A twisted cotton thread lifts hair out at the root in rows. No chemicals and no heat, so it suits sensitive facial skin, but it does pull, and watering eyes on the brow line are ordinary.",
            techniqueNote: "Threading works on very short hair, which is why it suits the upper lip, chin and brows where wax would be clumsy. The thread catches whole rows at once, so precision comes from the practitioner's hand rather than from stencils or strips. Keep the skin taut and the area free of makeup and oil beforehand. Expect small red dots for an hour afterwards, and skip heavy foundation until they settle.",
            consumableName: "Thread spool",
            consumableLife: 40,
            glyph: 6,
            chipIndex: 6
        ),
        RGMethod(
            id: "laser",
            name: "Laser or IPL course",
            shortName: "Laser / IPL",
            intervalMultiplier: 8.0,
            typicalCost: 85.00,
            typicalMinutes: 21,
            irritationProfile: "Light energy is absorbed by pigment in the follicle. Warmth and pinkness for a few hours is expected; heat, sun and fragranced products in the following days are what cause trouble.",
            techniqueNote: "This is the one method in the app that does not follow your own learned interval, because it is a course rather than a cadence. Sessions are spaced to catch hair in its growing phase, which is roughly four weeks on the face and six to eight weeks on the body, with the gaps widening as the course progresses. Shave the area the day before rather than waxing or plucking it, because the light needs a follicle with pigment still in it. Avoid sun exposure and self-tan before and after, and follow the operator's own aftercare instructions over anything written here.",
            consumableName: "IPL lamp cartridge",
            consumableLife: 60,
            glyph: 7,
            chipIndex: 7
        )
    ]

    static let byID: [String: RGMethod] = {
        var d: [String: RGMethod] = [:]
        for m in all { d[m.id] = m }
        return d
    }()

    static func method(_ id: String) -> RGMethod? { byID[id] }

    static func name(_ id: String) -> String { byID[id]?.name ?? "Method" }

    static func shortName(_ id: String) -> String { byID[id]?.shortName ?? "Method" }

    static func color(_ id: String) -> Color {
        guard let m = byID[id] else { return RGTheme.sage }
        return RGTheme.chip(m.chipIndex)
    }

    static func glyph(_ id: String) -> Int { byID[id]?.glyph ?? 0 }

    static let defaultMethodID = "razor"
}
