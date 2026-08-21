import SwiftUI

/// The 17 tracked zones. Every zone carries a cold-start prior (expressed for a
/// cartridge razor and scaled per method), an authored care note and a set of
/// relevant care cards. Nothing here is generated at runtime.
enum RGZoneCatalog {

    static let all: [RGZone] = [
        RGZone(
            id: "underarms",
            name: "Underarms",
            group: .intimate,
            priorDays: 3,
            regrowthHint: "Underarm hair is coarse and grows from several directions at once, so stubble usually shows within two to four days of a blade pass.",
            careNote: "Underarm skin is thin, folds constantly and sits under fabric all day, so it shows friction faster than almost anywhere else. Work in short passes rather than long ones, because the hair grows in several directions and one long stroke will always fight some of it. Give the skin a few hours before an antiperspirant goes back on, and let it breathe overnight if you can.",
            glyph: 0,
            laserCourseSessions: 8,
            cardIDs: ["underarm-care", "grain-direction", "razor-burn-calm", "fragrance-avoid", "gym-after", "ingrown-prevent"]
        ),
        RGZone(
            id: "lower-legs",
            name: "Lower legs",
            group: .lowerBody,
            priorDays: 4,
            regrowthHint: "The shins and calves are the classic maintenance zone: visible regrowth about three to five days after shaving, two to four weeks after waxing.",
            careNote: "Lower legs are mostly flat and forgiving, which is exactly why they get over-shaved: it is easy to keep passing over the same shin until it is raw. Cover each strip once with a fresh blade rather than three times with a dull one. Shins and ankles dry out quickly, so an unscented moisturizer afterwards does more for the look of the skin than any extra pass.",
            glyph: 1,
            laserCourseSessions: 8,
            cardIDs: ["leg-care", "shave-frequency", "blade-life", "moisturizer-choice", "exfoliate-timing", "pool-chlorine"]
        ),
        RGZone(
            id: "upper-legs",
            name: "Upper legs",
            group: .lowerBody,
            priorDays: 5,
            regrowthHint: "Thigh hair is usually finer and slower than shin hair, so the same method tends to buy you a day or two more here.",
            careNote: "Thighs curve in every direction and the skin moves under the blade, so the hand that is not holding the razor matters as much as the one that is: pull the skin flat first. The back of the thigh is the part people miss and then over-correct on later. Because the hair is often finer here, a gentler method than the one you use on your shins may hold just as long.",
            glyph: 2,
            laserCourseSessions: 8,
            cardIDs: ["leg-care", "grain-direction", "ingrown-prevent", "exfoliate-timing", "moisturizer-choice"]
        ),
        RGZone(
            id: "bikini-line",
            name: "Bikini line",
            group: .intimate,
            priorDays: 4,
            regrowthHint: "The bikini line regrows visibly in three to five days after shaving; wax and sugaring usually hold for three to four weeks.",
            careNote: "This is the zone where irritation statistics change people's minds, because the skin is thin, it creases, and clothing rubs it all day. Trim first if the hair is long, so whatever you use is not dragging. Loose cotton for the first day afterwards prevents far more bumps than any post-treatment product does.",
            glyph: 3,
            laserCourseSessions: 8,
            cardIDs: ["bikini-care", "ingrown-prevent", "gym-after", "fragrance-avoid", "folliculitis-derm", "period-sensitivity"]
        ),
        RGZone(
            id: "full-bikini",
            name: "Full bikini",
            group: .intimate,
            priorDays: 4,
            regrowthHint: "Coarse hair and folded skin: expect a shorter comfortable interval than the bikini line alone, and a longer one from removal at the root.",
            careNote: "A full bikini session covers skin that folds, sweats and rarely gets air, so the aftercare window matters more than the technique. Removal at the root generally holds far longer here than a blade, which is why many people accept a slower session in exchange for three quiet weeks. Skip heat, tight fabric and exercise for a day afterwards.",
            glyph: 4,
            laserCourseSessions: 8,
            cardIDs: ["bikini-care", "ingrown-prevent", "sugaring-vs-wax", "gym-after", "folliculitis-derm", "shared-tools"]
        ),
        RGZone(
            id: "forearms",
            name: "Forearms",
            group: .upperBody,
            priorDays: 7,
            regrowthHint: "Forearm hair is fine and slow. A week or more between sessions is normal even with a blade.",
            careNote: "Forearms are exposed to sun all year, so they are one of the few zones where the aftercare question is mostly about ultraviolet light rather than friction. Hair here is fine enough that many people prefer to reduce it rather than remove it. Whatever you use, do it in the evening so the skin has the night to settle before it goes back out.",
            glyph: 5,
            laserCourseSessions: 6,
            cardIDs: ["sun-after-wax", "grain-direction", "moisturizer-choice", "medication-photosensitivity"]
        ),
        RGZone(
            id: "upper-arms",
            name: "Upper arms",
            group: .upperBody,
            priorDays: 8,
            regrowthHint: "Upper arm hair is usually the finest on the body and the slowest to return.",
            careNote: "The back of the upper arm is often slightly bumpy on its own, unrelated to hair removal, and dragging a blade over it repeatedly will not smooth it. Gentle exfoliation on non-session days does more than pressure during one. Keep passes light and let the method do the work.",
            glyph: 6,
            laserCourseSessions: 6,
            cardIDs: ["exfoliate-timing", "moisturizer-choice", "folliculitis-derm", "grain-direction"]
        ),
        RGZone(
            id: "chest",
            name: "Chest",
            group: .upperBody,
            priorDays: 4,
            regrowthHint: "Chest hair is coarse and grows in swirls, so stubble here feels sharp within a few days.",
            careNote: "Chest hair grows in whorls rather than one direction, so map the grain before the first pass instead of assuming it runs downward. The skin over the sternum is thin and the area around it is not, so pressure that feels fine on one part will be too much on the other. Coarse regrowth against a shirt is the usual complaint, and that argues for removal at the root rather than a closer blade.",
            glyph: 7,
            laserCourseSessions: 8,
            cardIDs: ["grain-direction", "wax-hair-length", "razor-burn-calm", "mole-avoid", "gym-after"]
        ),
        RGZone(
            id: "abdomen",
            name: "Abdomen",
            group: .upperBody,
            priorDays: 5,
            regrowthHint: "Abdominal hair varies enormously between people; the learner is particularly worth trusting here over any published average.",
            careNote: "The abdomen is soft, mobile skin, so stretch it flat with your free hand and keep strokes short. The line below the navel is usually coarser than the rest and often needs a different method from the surrounding area. Waistbands sit directly on this zone, so give it a day of loose clothing after a session at the root.",
            glyph: 8,
            laserCourseSessions: 8,
            cardIDs: ["grain-direction", "ingrown-prevent", "wax-hair-length", "moisturizer-choice", "mole-avoid"]
        ),
        RGZone(
            id: "back",
            name: "Back",
            group: .upperBody,
            priorDays: 6,
            regrowthHint: "Back hair is coarse but slower than facial hair; most people find a cadence of every week or two with a blade.",
            careNote: "You cannot see most of this zone, which is the single biggest reason it gets nicked, so a long-handled tool or another pair of hands beats improvising. The back sweats under clothing and bag straps, which makes it one of the more bump-prone zones after any session. If you notice recurring spots along the shoulder blades, treat that as a reason to talk to a professional rather than to press harder.",
            glyph: 9,
            laserCourseSessions: 8,
            cardIDs: ["folliculitis-derm", "gym-after", "ingrown-prevent", "mole-avoid", "shared-tools"]
        ),
        RGZone(
            id: "shoulders",
            name: "Shoulders",
            group: .upperBody,
            priorDays: 7,
            regrowthHint: "Shoulders sit between the fine arm hair and the coarse back hair, and usually regrow at their own pace.",
            careNote: "Shoulders take direct sun and carry bag straps, so both ultraviolet light and friction are in play after a session. The curve makes it easy to press too hard on the highest point. Work outward from the neck in short passes and stop before the skin turns pink.",
            glyph: 10,
            laserCourseSessions: 6,
            cardIDs: ["sun-after-wax", "grain-direction", "mole-avoid", "moisturizer-choice"]
        ),
        RGZone(
            id: "upper-lip",
            name: "Upper lip",
            group: .face,
            priorDays: 3,
            regrowthHint: "Facial hair is the fastest-returning of all: shadow can show in two to three days, while threading or waxing tends to hold two to four weeks.",
            careNote: "This is a small, highly visible zone on thin skin, and it punishes over-correction more than anywhere else. Whatever you use, one careful pass beats three quick ones. Redness here is normal for an hour or two and is not a reason to add another product to the routine.",
            glyph: 11,
            laserCourseSessions: 8,
            cardIDs: ["face-care", "threading-basics", "patch-test-cream", "sun-after-wax", "medication-photosensitivity"]
        ),
        RGZone(
            id: "chin",
            name: "Chin",
            group: .face,
            priorDays: 2,
            regrowthHint: "Chin hair is typically the coarsest facial hair and returns quickly, which makes it a good candidate for a light-based course.",
            careNote: "The chin curves sharply and the skin over the jaw is thin, so short strokes and a stretched surface matter more than the tool. Coarse individual hairs here often sit on a different clock from the surrounding fine hair, which is why a fixed reminder period rarely fits. If growth in this zone changes noticeably over a few months, that is worth mentioning to a clinician rather than simply removing more often.",
            glyph: 12,
            laserCourseSessions: 8,
            cardIDs: ["face-care", "pcos-growth", "threading-basics", "ingrown-prevent", "laser-expectations"]
        ),
        RGZone(
            id: "eyebrows",
            name: "Eyebrows",
            group: .face,
            priorDays: 5,
            regrowthHint: "Brow hair grows slowly and the shape takes weeks to recover, so a longer interval is almost always the right call.",
            careNote: "Brows are the one zone where the correct interval is usually longer than you think, because the shape is built from hair you did not remove. Work in daylight, take a few hairs, then stop and look before taking any more. Never chase symmetry in a single session; come back in a week instead.",
            glyph: 13,
            laserCourseSessions: 6,
            cardIDs: ["eyebrow-restraint", "threading-basics", "face-care", "mole-avoid"]
        ),
        RGZone(
            id: "neck",
            name: "Neck",
            group: .face,
            priorDays: 2,
            regrowthHint: "Neck hair grows fast and often changes direction sharply, which is why it is the most common site of razor burn.",
            careNote: "The neck combines fast, coarse growth with hair that reverses direction halfway down, so it produces more razor burn than any other zone. Find the grain with a dry hand before you start and accept a slightly less close result in exchange for calm skin. Give it warmth and time before the first pass rather than pressure during it.",
            glyph: 14,
            laserCourseSessions: 8,
            cardIDs: ["grain-direction", "razor-burn-calm", "shave-prep-warm", "cold-vs-hot", "ingrown-prevent"]
        ),
        RGZone(
            id: "hands",
            name: "Hands and fingers",
            group: .lowerBody,
            priorDays: 9,
            regrowthHint: "Hand and finger hair is fine and slow, and rarely needs more than a monthly look.",
            careNote: "Fingers are small, bony and constantly washed, so the skin is drier here than people expect and a blade finds every knuckle. Keep the surface taut over each joint and take your time. Hands are also in the sun year round, which matters after any session at the root.",
            glyph: 15,
            laserCourseSessions: 6,
            cardIDs: ["sun-after-wax", "moisturizer-choice", "grain-direction", "travel-kit"]
        ),
        RGZone(
            id: "feet",
            name: "Feet and toes",
            group: .lowerBody,
            priorDays: 10,
            regrowthHint: "Toe hair is sparse and slow; most people find a two to three week interval is plenty.",
            careNote: "The top of the foot is thin skin over bone and the toes are awkward angles, so this is a zone for patience rather than speed. Socks and shoes create constant friction, so a session right before a long walk is a poor idea. Because the hair is sparse, plucking a few hairs often beats treating the whole area.",
            glyph: 16,
            laserCourseSessions: 6,
            cardIDs: ["moisturizer-choice", "ingrown-prevent", "travel-kit", "pool-chlorine"]
        )
    ]

    static let byID: [String: RGZone] = {
        var d: [String: RGZone] = [:]
        for z in all { d[z.id] = z }
        return d
    }()

    static func zone(_ id: String) -> RGZone? { byID[id] }

    static func name(_ id: String) -> String { byID[id]?.name ?? "Zone" }

    static func grouped() -> [(RGZoneGroup, [RGZone])] {
        RGZoneGroup.allCases.map { g in (g, all.filter { $0.group == g }) }
            .filter { !$0.1.isEmpty }
    }
}
