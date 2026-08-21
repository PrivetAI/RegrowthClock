import SwiftUI

/// 37 authored reference cards. Information only: nothing here diagnoses,
/// prescribes or promises a result, and several cards exist specifically to
/// point the reader at a qualified clinician instead of at a technique.
enum RGCareLibrary {

    static let all: [RGCareCard] = [
        RGCareCard(
            id: "ingrown-prevent",
            title: "Why hairs curl back in, and what reduces it",
            category: .ingrown,
            summary: "Ingrown hairs come from a blunt tip meeting a blocked follicle. Both halves are worth attacking.",
            body: "An ingrown hair is one that grows sideways or turns back into the skin instead of out of it. Two things make that likely: a hair cut at a sharp angle, which is what a stretched-then-released blade pass produces, and a follicle opening blocked by dead skin. So the useful habits are the boring ones. Do not stretch the skin to breaking point while shaving, because the hair retracts below the surface and is then cut under the skin line. Do not go over the same strip repeatedly. Exfoliate gently on the days between sessions rather than immediately before one. Keep the area unoccluded for a day afterwards, which mostly means loose cotton rather than a product. If a single spot is painful, growing or not settling after a week or two, leave it alone and ask a pharmacist or a doctor rather than digging at it with tweezers.",
            tags: ["ingrown", "bumps", "razor", "shaving", "exfoliation", "follicle"]
        ),
        RGCareCard(
            id: "exfoliate-timing",
            title: "Exfoliate between sessions, not right before one",
            category: .prep,
            summary: "Scrubbing an hour before wax or a blade is the most common self-inflicted irritation.",
            body: "Exfoliation helps because it clears the dead cells that trap a regrowing hair. The timing is what people get wrong. Skin that has just been scrubbed or acid-treated is already slightly raw, and putting hot wax, an alkaline cream or a blade on top of it stacks two insults on the same surface. A reasonable rhythm is to exfoliate two or three days after a session and again two or three days before the next one, then leave the skin alone in the final twenty-four hours. Gentle means gentle: a soft cloth or a mild chemical exfoliant, not a coarse salt scrub used with pressure. If the skin stays pink for hours after exfoliating, you are using too much or too often.",
            tags: ["exfoliation", "prep", "scrub", "timing", "ingrown"]
        ),
        RGCareCard(
            id: "shaving-thickness-myth",
            title: "Shaving does not make hair grow back thicker",
            category: .myths,
            summary: "It changes the tip, not the follicle. The follicle is what decides thickness.",
            body: "This is probably the most repeated claim in the whole subject, and it is not supported. A blade cuts the hair at the surface. It does not touch the follicle, which is where the diameter, color and growth rate of a hair are determined, and it cannot alter how many follicles are active. What actually changes is the tip. An untouched hair tapers to a fine point; a cut hair has a blunt, flat end, which feels coarser against your hand and looks darker because more of the pigmented cross-section faces you. Regrowth also appears against a bare background rather than emerging gradually, which reads as sudden. Genuine changes in hair thickness or density over months come from hormones, medication or age, not from a razor.",
            tags: ["myth", "shaving", "thickness", "regrowth", "razor"]
        ),
        RGCareCard(
            id: "patch-test-cream",
            title: "Patch-testing a depilatory cream",
            category: .prep,
            summary: "One small square, a full twenty-four hours, every new formula.",
            body: "Depilatory creams work by breaking the bonds that hold hair together, and the chemistry that does that to a hair is also capable of irritating skin. A patch test is not a formality. Apply a small amount to a coin-sized area on the inner forearm, leave it for the time stated on the label, remove it exactly as instructed, and then wait a full twenty-four hours before deciding. You are looking for burning during the test and for delayed redness, itching or a rash afterwards. Repeat the test whenever you buy a different formula, including a different variant from the same brand, and whenever you return to a product after a long gap. Never test on the face first. If a reaction appears, rinse with cool water and do not reach for another active product on the same skin.",
            tags: ["cream", "depilatory", "patch test", "allergy", "safety", "prep"]
        ),
        RGCareCard(
            id: "sun-after-wax",
            title: "Sun exposure after removal at the root",
            category: .aftercare,
            summary: "Freshly waxed or sugared skin has lost a layer. Treat it as new skin for a day or two.",
            body: "Waxing and sugaring take surface skin cells along with the hair, which leaves the area more reactive to ultraviolet light than it usually is. Direct sun in the following twenty-four to forty-eight hours can produce a stronger burn than the same exposure would normally cause, and on some people it leaves temporary darker patches that take weeks to fade. The practical version is simple: schedule sessions for the evening, cover the area with clothing the next day where you can, and use a broad-spectrum sunscreen on the parts you cannot cover once the skin is no longer tender. The same caution applies to sunbeds, saunas, steam rooms and hot tubs, which add heat and, in the case of the last one, shared water on freshly opened follicles.",
            tags: ["sun", "wax", "sugaring", "aftercare", "uv", "pigmentation"]
        ),
        RGCareCard(
            id: "epilator-hygiene",
            title: "Cleaning an epilator between uses",
            category: .hygiene,
            summary: "The head holds skin cells and hair fragments. Alcohol, a brush and dry storage.",
            body: "An epilator pulls hair from the root, so its tweezer discs collect hair fragments, sebum and skin cells in a warm, enclosed head. Left alone, that is a poor thing to press against opened follicles a week later. After every session, switch the device off, remove the head if it detaches, brush out the debris with the supplied brush, and wipe the discs with isopropyl alcohol on a cotton pad. Let it dry completely in the open air before reassembling, because trapped moisture is the other half of the problem. Wet-and-dry models can be rinsed under running water if the manual says so, but they still need to dry fully. Replace the head on the maker's schedule; worn discs grip badly and pull skin rather than hair.",
            tags: ["epilator", "hygiene", "cleaning", "alcohol", "kit"]
        ),
        RGCareCard(
            id: "folliculitis-derm",
            title: "Bumps that keep coming back",
            category: .whenToAsk,
            summary: "Recurring inflamed spots around follicles are worth a professional opinion rather than a harder scrub.",
            body: "Small raised spots around hair follicles after a session are common and usually settle in a day or two. What is worth attention is the pattern that does not settle: spots that recur in the same area every cycle, that are painful, that spread, that contain pus, or that come with a fever. Folliculitis has several causes, some of which respond to changing your method and some of which do not, and the ones that do not are exactly the ones where scrubbing harder makes things worse. This app is not able to tell you which is which and does not try to. If bumps persist beyond a couple of weeks, keep returning, or spread beyond the area you treated, book time with a doctor or dermatologist and bring your log with you, because the zone and method history is genuinely useful information for them.",
            tags: ["folliculitis", "bumps", "dermatologist", "infection", "medical", "help"]
        ),
        RGCareCard(
            id: "pcos-growth",
            title: "When growth itself changes",
            category: .whenToAsk,
            summary: "A noticeable change in where or how fast hair grows is a question for a clinician, not a scheduling problem.",
            body: "This app is built around the assumption that your growth pattern is roughly stable and that the useful thing to learn is its timing. Sometimes that assumption breaks. Hair appearing in a new area, growing noticeably faster or coarser over a few months, or changing alongside other things such as cycle changes, weight changes or skin changes, is worth raising with a doctor. There are several ordinary explanations, including hormonal conditions such as polycystic ovary syndrome, thyroid conditions and some medications, and a clinician can look into them properly. Nothing here can identify a cause and nothing here should be read as saying you have one. If your logged intervals for a zone are steadily shortening and you have not changed your method, that is a fact worth mentioning in the appointment rather than a reason to buy a different razor.",
            tags: ["hormones", "pcos", "change", "doctor", "medical", "growth"]
        ),
        RGCareCard(
            id: "blade-life",
            title: "Blade life and where the razor lives",
            category: .hygiene,
            summary: "Most blades die of corrosion in the shower, not of use on your skin.",
            body: "A cartridge is usually good for somewhere around five to seven comfortable shaves, but that number varies enormously with hair coarseness, area covered and how the blade is stored. Storage is the part people control and ignore. A razor left standing in the shower stays wet, and the edge corrodes and micro-chips long before the same blade would go blunt from cutting. Rinse the head thoroughly, shake the water out rather than tapping it against the sink, and keep it dry, upright and out of the spray. Do not wipe the edge on a towel, which rolls it. When shaving starts to require a second pass or leaves a burning feeling it did not before, the blade is telling you it is finished, and this app's product tracker exists so you notice that from the count rather than from your skin.",
            tags: ["razor", "blade", "storage", "kit", "replacement", "corrosion"]
        ),
        RGCareCard(
            id: "grain-direction",
            title: "Finding the grain before the first pass",
            category: .technique,
            summary: "Run a dry hand over the area. Whichever way feels smooth is the direction of growth.",
            body: "Almost every technique instruction depends on knowing which way the hair grows, and almost nobody checks. Run a dry palm lightly over the dry area: the direction that feels smooth is with the grain, and the direction that feels rough is against it. Grain is not uniform. Necks commonly reverse halfway down, chests grow in whorls, and thighs change direction around the curve. For blades, the first pass should go with the grain, and a second pass across it should only happen if the skin tolerates it; against the grain is the closest result and the most irritation. For wax, apply with the grain and pull against it. For sugaring, apply against and flick with. For epilators, move against the grain. Getting this backwards is the single most common cause of broken hairs and ingrowns.",
            tags: ["grain", "direction", "technique", "shaving", "wax", "epilator"]
        ),
        RGCareCard(
            id: "wax-hair-length",
            title: "How long the hair needs to be",
            category: .prep,
            summary: "Too short and it does not grip; too long and every pull hurts more than it needs to.",
            body: "Removal at the root only works if the method can hold the hair. Hot wax generally wants around five millimeters, roughly two weeks of regrowth for most body hair. Sugar paste manages a little shorter, around three millimeters. An epilator needs about three to five millimeters for the discs to catch. Threading works on very short hair, which is why it is the usual choice for the face. Going in too early produces broken hairs at the surface, which both wastes the session and raises the chance of ingrowns. Going in far too long is not dangerous but it is more painful, and trimming down to roughly the right length first makes the session quicker and kinder. If you are between lengths, waiting three days almost always beats forcing it.",
            tags: ["wax", "length", "prep", "epilator", "sugaring", "timing"]
        ),
        RGCareCard(
            id: "sugaring-vs-wax",
            title: "Sugaring compared with hot wax",
            category: .technique,
            summary: "Same family, different physics: temperature, direction of pull and what it sticks to.",
            body: "Both remove hair from the root and both give you weeks rather than days. The differences are practical. Sugar paste is applied at close to body temperature, so there is no burn risk from heat, while hot wax has to be temperature tested every time. Sugar is pulled in the direction of growth after being applied against it, which many people report as less traumatic to the follicle than a strip pull against the grain. Sugar is water soluble and rinses off skin and fabric; wax needs oil or a remover. Wax adheres strongly to skin as well as hair, which is what makes it efficient and also what makes it strip more surface cells. Neither is universally better. This app is set up to let you compare them on your own irritation numbers per zone, which is a far more useful answer than any general claim.",
            tags: ["sugaring", "wax", "comparison", "technique", "irritation"]
        ),
        RGCareCard(
            id: "shave-prep-warm",
            title: "Three minutes of warm water",
            category: .prep,
            summary: "Hydrated hair cuts at a fraction of the force of dry hair.",
            body: "Hair absorbs water, and hydrated hair is markedly softer and easier to cut than dry hair. That is the entire reason shaving at the end of a shower is more comfortable than shaving at the start. Give the area two to three minutes of warm, not hot, water before the first pass. A shaving product on top of that serves two purposes: it keeps the water in the hair and it lets the head glide instead of dragging. Soap bars are poor at both. Water that is genuinely hot strips lipids and leaves the skin tight and reactive afterwards, so warm is the target. If you shave dry by necessity, an electric shaver is a better tool for it than a blade.",
            tags: ["prep", "shaving", "water", "hydration", "razor", "technique"]
        ),
        RGCareCard(
            id: "razor-burn-calm",
            title: "Calming razor burn",
            category: .aftercare,
            summary: "Cool, plain and nothing active. The urge to treat it is what prolongs it.",
            body: "Razor burn is surface irritation from friction, pressure and repeated passes, and it usually settles on its own within a day if you stop adding to it. Rinse the area cool, pat it dry without rubbing, and leave it exposed to air where that is practical. A plain, fragrance-free moisturizer is fine; alcohol-based aftershaves, exfoliating acids, retinoids and anything with fragrance or menthol will sting and slow things down. Skip the next session in that zone until the skin looks normal again, and when you go back, use a fresh blade, fewer passes and less pressure. If burning turns into blistering, weeping or spreading redness, or if it keeps happening on the same zone despite a lighter technique, that is a reason to ask a professional rather than to try a stronger product.",
            tags: ["razor burn", "aftercare", "irritation", "soothing", "recovery"]
        ),
        RGCareCard(
            id: "underarm-care",
            title: "Underarms: direction, timing and deodorant",
            category: .technique,
            summary: "Multi-directional growth, thin folded skin, and a product waiting to go straight back on.",
            body: "Underarm hair grows outward from the center in several directions at once, so a single long stroke will always be working against part of it. Raise the arm fully to flatten the hollow, and work in short passes, changing direction as you go rather than fighting through. The skin here is thin and folds constantly, so pressure that would be fine on a shin is too much. Afterwards, give it a few hours before an antiperspirant goes back on, because freshly opened follicles plus alcohol and aluminum salts is the classic recipe for stinging and bumps. Evening sessions solve this neatly. If you are prone to bumps here, a root-removal method that buys two weeks may be gentler over a month than four blade passes.",
            tags: ["underarms", "technique", "deodorant", "irritation", "timing"]
        ),
        RGCareCard(
            id: "bikini-care",
            title: "Bikini line: trim, tension, fabric",
            category: .technique,
            summary: "Three habits do most of the work, and one of them is what you wear afterwards.",
            body: "Trim longer hair down before any method, because dragging is what causes both pulling and broken hairs. Hold the skin taut with your free hand, since this area creases and a crease is where a blade catches. Work in the direction of growth on the first pass and resist the second one. Afterwards, the biggest single factor is fabric: loose cotton for a day lets follicles close without friction, while tight synthetics plus sweat is the environment bumps like best. Skip the gym, the pool and the sauna for twenty-four hours after removal at the root. If this zone consistently shows a high irritation rate in your log for one method, that is exactly the signal the app is built to surface, and switching method here is usually more effective than adding a product.",
            tags: ["bikini", "technique", "fabric", "ingrown", "irritation"]
        ),
        RGCareCard(
            id: "leg-care",
            title: "Legs: coverage without over-passing",
            category: .technique,
            summary: "Map the leg into strips and cover each one once.",
            body: "Legs are the zone where people do the most damage through repetition, because the surface is large and easy and it is tempting to keep going until it feels perfect. A better approach is deliberate coverage: divide each lower leg into a few strips, cover each strip once with a sharp blade, then stop and check by touch rather than by shaving again. Knees and ankles are bone under thin skin, so go slower and use less pressure there; bending the knee flattens the skin over it. The back of the calf usually grows in a different direction from the front. If you are finding you need a second full pass every time, the blade is old rather than the technique wrong.",
            tags: ["legs", "technique", "shaving", "coverage", "knees"]
        ),
        RGCareCard(
            id: "face-care",
            title: "Upper lip and chin: small strokes, light hand",
            category: .technique,
            summary: "Small area, thin skin, high visibility. Precision beats speed here more than anywhere.",
            body: "Facial skin is thinner than body skin and the results are on display, so the cost of an over-aggressive session is higher. Whatever method you use, work in short, deliberate movements and stretch the skin flat first. Do not go back over the same patch to catch one hair; take that hair individually or leave it for the next session. Redness for an hour or two afterwards is normal and does not need a product. Avoid exfoliating acids and retinoids on the same evening as a facial session, since both leave the skin more reactive. If you use a depilatory cream on the face, use one specifically labelled for facial use and patch test it first.",
            tags: ["face", "upper lip", "chin", "technique", "sensitive"]
        ),
        RGCareCard(
            id: "eyebrow-restraint",
            title: "Brows: the one-session rule",
            category: .technique,
            summary: "The shape is made of the hair you leave. Removed hair takes weeks to come back.",
            body: "Brow hair grows slowly, so a mistake here lives on your face for six to eight weeks. The single most useful discipline is to stop early. Work in good daylight with a mirror at arm's length rather than a magnifying one, which distorts your sense of proportion. Take a few hairs, put the tweezers down, step back and look at both brows together, and only then decide whether to continue. Never chase symmetry within one session, because correcting the left to match the right and then the right to match the left is how brows get thin. If you want a shape change rather than maintenance, a professional threading or waxing appointment costs less than two months of regret.",
            tags: ["eyebrows", "brows", "tweezers", "shape", "restraint", "technique"]
        ),
        RGCareCard(
            id: "threading-basics",
            title: "What threading actually does",
            category: .technique,
            summary: "A twisted cotton thread rolls across the skin and lifts rows of hair out at the root.",
            body: "Threading uses a length of cotton thread twisted into a loop. As the practitioner opens and closes the twist, the crossing point rolls across the skin and catches hairs, pulling them out at the root in a row. There are no chemicals, no heat and nothing applied to the skin, which is why it suits sensitive facial skin and people using products that make waxing inadvisable. It works on very short hair, so the interval is not gated by growing hair out first. It does pull, so watering eyes on the brow line are ordinary, and small red dots for an hour afterwards are expected. Because everything depends on the practitioner's hands, results vary between people far more than with a machine.",
            tags: ["threading", "face", "brows", "technique", "sensitive"]
        ),
        RGCareCard(
            id: "electric-dry",
            title: "Electric shavers prefer dry skin",
            category: .technique,
            summary: "Unless the manual says wet, dry is where a foil or rotary head performs.",
            body: "Most foil and rotary shavers are designed to work on dry, clean skin, and they cut noticeably better before a shower than after one, which is the opposite of blade advice. Damp hair flattens against the skin and slides under the guard instead of standing up into it. Some models are explicitly wet-and-dry and can be used with a gel, and their manuals will say so. Whichever you have, keep the head flat against the skin rather than tilted into a corner, use small circles for rotary heads and straight strokes for foil heads, and go against the direction of growth. An electric shaver never gets as close as a blade, which is exactly why it irritates less and why the comfortable interval is a little shorter.",
            tags: ["electric", "shaver", "dry", "foil", "rotary", "technique"]
        ),
        RGCareCard(
            id: "laser-expectations",
            title: "What a light-based course can and cannot do",
            category: .whenToAsk,
            summary: "Reduction over a course, not a single permanent event, and results depend on hair and skin.",
            body: "Laser and intense pulsed light work by having pigment in the hair absorb light energy. That means results depend on the contrast and characteristics of your own hair and skin, and that gray, very fair and very fine hair respond poorly because there is little pigment to absorb anything. It is a course rather than a treatment: hair is only vulnerable during its growing phase and only some follicles are in that phase at any moment, which is why sessions are spaced weeks apart and why six to ten of them are typical. Outcomes are usually described as long-term reduction rather than removal, and many people have occasional maintenance sessions afterwards. Anyone offering a guaranteed permanent result from one visit is overselling. Discuss suitability with a qualified provider, especially if you are pregnant, taking photosensitising medication or have a skin condition in the area.",
            tags: ["laser", "ipl", "course", "expectations", "professional", "reduction"]
        ),
        RGCareCard(
            id: "laser-prep",
            title: "Preparing for a light-based session",
            category: .prep,
            summary: "Shave the day before, avoid sun and self-tan, and never wax or pluck in between.",
            body: "A light-based session needs the follicle to still contain a pigmented hair, so waxing, sugaring, epilating or plucking in the weeks before an appointment removes the target and wastes the session. Shaving is the right preparation, usually the day before, so the hair below the surface is intact while the hair above it is not there to burn. Sun exposure and self-tanning products both change how the skin absorbs light and generally mean an appointment gets postponed, so plan around holidays. Arrive with clean skin and no lotion, deodorant or makeup on the area. Tell the provider about any medication you are taking, since several common ones increase light sensitivity. Their aftercare instructions take precedence over anything in this app.",
            tags: ["laser", "ipl", "prep", "shaving", "sun", "professional"]
        ),
        RGCareCard(
            id: "cream-timing",
            title: "With a depilatory cream, the timer is the technique",
            category: .technique,
            summary: "Shortest time on the label, an actual timer, and never a top-up.",
            body: "Depilatory creams are alkaline and work by breaking the disulfide bonds that give hair its structure. Given more time they will start doing the same thing to the surface of your skin, which is why the label times are limits rather than suggestions. Start with the shortest recommended time, set a real timer rather than estimating, and check a small area at that point. If some hairs remain, remove what has worked and deal with the rest another day; do not reapply to the same skin. Never use these products on broken, sunburnt, freshly exfoliated or recently shaved skin, and never on an area not listed on the packaging. Rinse thoroughly with lukewarm water, since residue left in a skin fold keeps working. If it burns at any point, remove it immediately and rinse.",
            tags: ["cream", "depilatory", "timer", "safety", "technique", "chemical"]
        ),
        RGCareCard(
            id: "moisturizer-choice",
            title: "Choosing something to put on afterwards",
            category: .aftercare,
            summary: "Plain, fragrance-free and boring. This is not the moment for actives.",
            body: "The job of an aftercare product is to reduce water loss from skin that has just been scraped, stripped or heated. That means a plain emollient does it: something fragrance-free with an ingredient list you could read aloud without stumbling. What to avoid for the first day is easier to specify than what to choose. Skip fragrance and essential oils, alcohol-heavy toners, exfoliating acids, retinoids and anything marketed as tingling, warming or brightening, because they all add irritation to skin that already has some. Heavy occlusive balms on a zone that will be under tight fabric can trap sweat, so prefer a light lotion there. On very reactive zones, nothing at all for a few hours and then a plain lotion is a perfectly good routine.",
            tags: ["moisturizer", "aftercare", "fragrance", "lotion", "products"]
        ),
        RGCareCard(
            id: "fragrance-avoid",
            title: "Fragrance and alcohol right after a session",
            category: .aftercare,
            summary: "Opened follicles plus a scented product is the sting people blame on the method.",
            body: "Any method that removes hair at the root leaves follicle openings temporarily open, and blades leave micro-abrasions across the surface. Fragrance compounds and denatured alcohol are both common irritants on intact skin and considerably more so on skin in that state. That includes body sprays, perfumed lotions, most antiperspirants, aftershave splashes and scented soaps. Give the area a few hours, and preferably overnight, before anything scented goes near it. The practical consequence is that evening sessions are easier to manage than morning ones. If you find a particular zone stings every time regardless of method, look at what goes on the skin afterwards before you change the method.",
            tags: ["fragrance", "alcohol", "aftercare", "deodorant", "irritation"]
        ),
        RGCareCard(
            id: "gym-after",
            title: "Sweat and friction in the first day",
            category: .aftercare,
            summary: "Twenty-four hours of low friction does more than any product.",
            body: "Freshly treated skin plus sweat plus a tight waistband is the environment that produces the bumps people then try to treat. Sweat is salty and sits in open follicles; friction from fabric or equipment keeps reopening the surface; heat encourages both. Giving a zone a day off from the gym, the sauna, cycling and tight synthetic clothing prevents more irritation than any post-treatment product resolves. If a session and a workout genuinely have to share a day, do the workout first and the session afterwards, and shower in between. For zones under clothing all day, choose loose cotton rather than compression fabric for the following day.",
            tags: ["gym", "sweat", "friction", "aftercare", "clothing", "exercise"]
        ),
        RGCareCard(
            id: "pool-chlorine",
            title: "Swimming after a session",
            category: .aftercare,
            summary: "Chlorinated water on freshly opened skin stings, dries and occasionally does worse.",
            body: "Pools, hot tubs and the sea all put treated skin in contact with water that is either chemically treated or biologically busy, at a moment when follicle openings are still settling. Chlorine is drying and will sting on any area with micro-abrasions; hot tubs add heat and shared water, which is a known route to a bumpy folliculitis. Twenty-four hours is a reasonable gap after a blade and closer to forty-eight after removal at the root. If you swim regularly, plan sessions for the evening after a swim rather than the morning before one. Rinse with fresh water and apply a plain moisturizer after any swim, treated skin or not, because chlorine dries the skin that regrowth then has to push through.",
            tags: ["swimming", "chlorine", "pool", "aftercare", "hot tub"]
        ),
        RGCareCard(
            id: "shave-frequency",
            title: "How often is too often",
            category: .technique,
            summary: "If the skin has not fully recovered from the last session, the interval is too short.",
            body: "There is no universal correct frequency, which is the reason this app learns yours instead of asserting one. What there is, is a signal: if a zone still looks pink, feels tight or has active bumps from the last session, then doing it again today stacks irritation rather than resolving it. Shaving every day is fine for some people on some zones and clearly not fine for others on others, and your own logged irritation rate per zone and method will tell you which case you are in far better than a magazine will. If you need a very short interval on a zone that reacts badly, the productive move is usually to change method on that zone rather than to shorten the interval further or press harder.",
            tags: ["frequency", "interval", "irritation", "recovery", "cadence"]
        ),
        RGCareCard(
            id: "cold-vs-hot",
            title: "Finish cool",
            category: .aftercare,
            summary: "A cool rinse settles flushing and stops the session cleanly.",
            body: "Warm water before a session helps because it softens hair. Warm water after a session does the opposite of what you want: it keeps the surface flushed and adds to the drying effect of the whole process. Finish with a cool, not icy, rinse over the area, then pat dry with a clean towel rather than rubbing. Rubbing a towel over freshly shaved or waxed skin reintroduces exactly the friction you have just spent ten minutes trying to minimise, and towels are not sterile, which matters more on a zone where follicles are open. Use a clean towel and use it gently. Cold water does not close pores, a claim you will see everywhere; it just reduces flushing, which is worth having on its own terms.",
            tags: ["cool", "rinse", "aftercare", "towel", "flushing"]
        ),
        RGCareCard(
            id: "mole-avoid",
            title: "Moles, tattoos and broken skin",
            category: .whenToAsk,
            summary: "Work around them, and get anything that is changing looked at before treating the area.",
            body: "Do not run a blade over a raised mole, do not wax over one, and do not apply a depilatory cream to it. Light-based methods target pigment, which is why providers cover moles and generally decline to treat over tattoos. If a mole is catching on a razor regularly, that is a good reason to have it looked at by a doctor, both for comfort and because a mole that has changed in size, shape, color or border deserves a professional eye regardless of hair. The same restraint applies to cuts, active spots, eczema patches, sunburn and any area of broken skin: treat around it and come back when the skin is intact. This app does not assess skin lesions and cannot; that question belongs with a clinician.",
            tags: ["mole", "tattoo", "broken skin", "safety", "doctor", "medical"]
        ),
        RGCareCard(
            id: "shared-tools",
            title: "Do not share blades, heads or pots",
            category: .hygiene,
            summary: "Anything that touches an opened follicle is personal equipment.",
            body: "Razors, epilator heads and tweezers all make contact with skin that is or is about to be broken, and they retain traces of blood and skin cells even when they look clean. Sharing them passes bacteria and, in the case of blood contact, carries a real if small risk of transmitting blood-borne infections. Wax should never be double-dipped from a pot that has already touched skin, which is the standard rule in professional settings and worth keeping at home. If you use a salon, it is entirely reasonable to look for single-use spatulas and fresh strips, and to ask about how equipment is cleaned. At home, label your own tools if a household shares a bathroom, and replace anything that has been used by someone else rather than cleaning it and hoping.",
            tags: ["hygiene", "sharing", "razor", "salon", "safety", "infection"]
        ),
        RGCareCard(
            id: "period-sensitivity",
            title: "Cycle-related skin sensitivity",
            category: .prep,
            summary: "Many people find the same session hurts more at certain points in their cycle.",
            body: "Pain thresholds and skin reactivity are not constant. A number of people report that waxing, sugaring and epilating are noticeably more uncomfortable in the days immediately before and during a period, and that the same session in the middle of the cycle is easier. This is a well-known scheduling consideration in salons rather than a rule about your body, and it may or may not apply to you. If it does, and if your logged interval allows any flexibility, shifting a session by a few days is a free improvement. The app's notes field is a reasonable place to record that a session was unusually uncomfortable, so that a pattern can become visible to you over a few months.",
            tags: ["cycle", "sensitivity", "pain", "timing", "scheduling"]
        ),
        RGCareCard(
            id: "travel-kit",
            title: "A travel kit that does not wreck your skin",
            category: .hygiene,
            summary: "Hotel razors, hard water and a rushed session are a bad combination.",
            body: "Most travel irritation comes from three things at once: a disposable razor that was never sharp, water that is harder or softer than you are used to, and doing the whole thing in five minutes before leaving. Pack your own handle and one fresh cartridge, a small tube of plain fragrance-free lotion, and something to lubricate the pass, which can be a solid conditioner bar if liquids are a problem. Keep the razor dry in a case rather than loose in a wash bag, where it will blunt against everything else. If your trip involves sun, plan removal at the root for the evening before you travel rather than the morning you arrive, and give the skin its day of cover.",
            tags: ["travel", "kit", "razor", "packing", "hotel"]
        ),
        RGCareCard(
            id: "cost-of-cadence",
            title: "What a cadence actually costs",
            category: .myths,
            summary: "The per-session price is the small number. Frequency is what makes the total.",
            body: "People compare methods by their sticker price, which is why a cartridge razor feels cheap and a salon appointment feels expensive. The honest comparison is annual: a method used every three days runs roughly a hundred and twenty times a year, while one used every three weeks runs about seventeen. That reverses the answer surprisingly often once blades, creams and time are counted, and it reverses again if a cheap method produces enough irritation that you skip other things. The Insights tab does this arithmetic from your own logged cadence and your own logged costs rather than from any assumed average, and falls back to the authored per-method defaults only where you have not entered a price. Treat those projections as an order-of-magnitude comparison, not a quotation.",
            tags: ["cost", "cadence", "annual", "comparison", "budget", "myth"]
        ),
        RGCareCard(
            id: "medication-photosensitivity",
            title: "Medicines that change how skin reacts",
            category: .whenToAsk,
            summary: "Several common prescriptions make skin more light-sensitive or more fragile.",
            body: "Some widely prescribed medicines, including certain antibiotics, acne treatments, diuretics and others, increase sensitivity to light or thin the skin, and some topical treatments such as retinoids make waxing inadvisable because the surface layer lifts too easily. That is not a complete list and this app cannot give you one. What it can usefully say is: if you have started a new medication and a method that was previously comfortable has become irritating, or if you are considering a light-based course, ask the prescriber or a pharmacist specifically about hair removal and sun exposure. Bring the name of the method. It is a short question with a clear answer, and it is a much better use of five minutes than working it out from your own skin.",
            tags: ["medication", "photosensitivity", "retinoid", "pharmacist", "medical", "safety"]
        ),
        RGCareCard(
            id: "log-honestly",
            title: "The log only works if it is honest",
            category: .myths,
            summary: "A skipped bad session is the one the learner most needed.",
            body: "The interval learner in this app builds its prediction from the gaps between the sessions you record, and it weights recent gaps most heavily. That makes it responsive, and it also makes it easy to mislead. If you log the sessions that went well and skip the ones you would rather forget, the irritation rate for that zone and method will look better than it is, and the predicted interval will drift toward whatever cadence you feel good about rather than the one you actually keep. Logging a session with a reaction is not a failure to record; it is the single most valuable entry you can make, because comparing methods on one zone is the thing this app can do that a fixed reminder cannot.",
            tags: ["logging", "honesty", "data", "learner", "accuracy"]
        )
    ]

    static let byID: [String: RGCareCard] = {
        var d: [String: RGCareCard] = [:]
        for c in all { d[c.id] = c }
        return d
    }()

    static func card(_ id: String) -> RGCareCard? { byID[id] }

    static func cards(_ ids: [String]) -> [RGCareCard] {
        ids.compactMap { byID[$0] }
    }

    static func search(_ query: String) -> [RGCareCard] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { card in
            if card.title.lowercased().contains(q) { return true }
            if card.summary.lowercased().contains(q) { return true }
            if card.body.lowercased().contains(q) { return true }
            for t in card.tags where t.contains(q) { return true }
            return false
        }
    }

    /// Cards a given method should surface in its own detail screen.
    static func forMethod(_ methodID: String) -> [RGCareCard] {
        let map: [String: [String]] = [
            "razor":     ["shave-prep-warm", "grain-direction", "blade-life", "razor-burn-calm", "shave-frequency", "shaving-thickness-myth"],
            "electric":  ["electric-dry", "grain-direction", "shave-frequency", "moisturizer-choice"],
            "epilator":  ["wax-hair-length", "epilator-hygiene", "ingrown-prevent", "exfoliate-timing", "gym-after"],
            "hot-wax":   ["wax-hair-length", "sun-after-wax", "sugaring-vs-wax", "gym-after", "shared-tools", "medication-photosensitivity"],
            "sugaring":  ["sugaring-vs-wax", "wax-hair-length", "sun-after-wax", "exfoliate-timing", "gym-after"],
            "cream":     ["patch-test-cream", "cream-timing", "moisturizer-choice", "fragrance-avoid"],
            "threading": ["threading-basics", "face-care", "eyebrow-restraint", "fragrance-avoid"],
            "laser":     ["laser-expectations", "laser-prep", "sun-after-wax", "medication-photosensitivity", "mole-avoid"]
        ]
        return cards(map[methodID] ?? [])
    }
}
