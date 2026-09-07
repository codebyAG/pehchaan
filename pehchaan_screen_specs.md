# GROWLIO — Complete Screen Flow & Layout Spec (V1 MVP)

Companion to `growlio-ui-context.md` (colours, type, components). This file is the full screen list **in order**, with each screen's layout, copy and where it goes next. Build exactly this for the Play Store MVP.

Android phone, portrait only. Hinglish UI, English labels. White surface, 20 dp side padding, one primary action per screen pinned at the bottom (56 dp tall).

---

## FULL SCREEN ORDER (32 screens + 8 system dialogs)

**First run:** 1 Splash → 2 Language → 3 Intro slides → 4 Login → 5 OTP → 6 Setup step 1 → 7 Setup step 2 → 8 Setup step 3 → 9 Notification permission → 10 Home
**Returning user:** 1 Splash → 10 Home

**Creative flow:** 10 Home → 11 Type picker → 12 Creative input → 13 Photo picker → 14 Crop → 15 Generating → 16 Result → 17 Edit text → 18 Format & download → 19 Share handoff → 20 Success
**Library:** 21 My creatives → 22 Search → 23 Creative detail
**Account:** 24 Profile → 25 Edit business → 26 Manage photos → 27 Settings → 28 Language change → 29 Plans → 30 Help & FAQ → 31 Contact support → 32 About
**Utility states:** No internet · Update required · Generation failed · Empty states · Delete confirm · Logout confirm · Rate prompt · Permission denied

---

# 1. SPLASH
**Purpose:** session check.
- Full-bleed violet-600 (#6614F5).
- Logo mark centred, 96 dp, radius 24.
- Nothing else. No tagline, no spinner (max 1.5 s).
**Next:** first run → 2 Language · returning → 10 Home · no internet → No internet state.

# 2. LANGUAGE SELECT
**Purpose:** set app + creative language before anything else.
- Title (Nunito 800, 25): "Choose your language"
- Sub (14 muted): "Aap ise baad mein badal sakte hain."
- Option rows (height 64, #F1EBFF, radius 14, gap 12, label 17): `हिंदी` · `Hinglish` · `English` · `मराठी (Soon)` · `ગુજરાતી (Soon)`
- Selected row: violet-600 fill, white label, check icon right. Disabled rows: 50% opacity + "Soon" chip.
- Primary: "Continue"
**Next:** 3 Intro.

# 3. INTRO SLIDES (3, swipeable)
**Purpose:** explain the value in 15 seconds.
Each slide: violet-600 ground; top 45% a mock creative card (radius 20, white or yellow); bottom text block.
- Slide 1 — Title white Nunito 800 25: "Business ki post, minutes mein" · Sub #E7DDFF 17: "Designer ke bina professional creatives."
- Slide 2 — "Offer, festival, product — sab" · "Jo promote karna hai, bas likh do."
- Slide 3 — "Download karo, kahin bhi use karo" · "Instagram, WhatsApp, print — aapki choice."
- Dots above the button (yellow active, #8B6BE8 inactive). "Skip" text button top-right.
- Primary: "Next" / on slide 3 "Get started"
**Next:** 4 Login.

# 4. PHONE LOGIN
**Purpose:** account with the lowest friction.
- Title: "Apna number daaliye"
- Row: fixed "+91" box (64 wide, #F1EBFF) + 10-digit numeric field, auto-focus.
- Helper (14 muted): "OTP se verify karenge. Koi password nahi."
- Secondary (optional): "Continue with Google"
- Legal line (13 muted, links): "Continue karke aap hamari Terms aur Privacy Policy accept karte hain."
- Primary: "Send OTP" — disabled until 10 digits.
**Next:** 5 OTP.

# 5. OTP VERIFY
- Back arrow. Title: "OTP daaliye"
- Sub (14 muted): "+91 98765 43210 par bheja gaya · Change"
- 6 boxes (52×60, #F1EBFF, radius 12, gap 10), auto-advance, auto-verify on the 6th digit, SMS autofill.
- Text button: "Dobara bhejein (00:28)" — enabled at 0.
- Error state: boxes get a 2 dp #D94A2B ring + line "Galat OTP. Dobara try karein."
- Primary: "Verify"
**Next:** new user → 6 Setup step 1 · existing → 10 Home.

# 6. BUSINESS SETUP — STEP 1 (details)
- "Step 1 of 3" (14 muted, top-right). Title: "Tell us about your shop"
- Fields (label 14 muted above, box #F1EBFF, radius 14, height 60):
  1. Business name — text
  2. Category — opens a searchable bottom sheet: Tailor · Salon · Barber shop · Boutique · Kirana · Sweet shop · Mechanic · Mobile repair · Beauty parlour · Home business · Food / restaurant · Mehndi artist · Photographer · Retail shop · Other service
  3. Phone to show on creatives — prefilled from login, editable
- Primary: "Continue"
**Next:** 7 Setup step 2.

# 7. BUSINESS SETUP — STEP 2 (location)
- "Step 2 of 3". Title: "Aapki shop kahan hai?"
- Secondary button with pin icon: "Use my location" (asks OS location permission; on deny, fall back to manual)
- Fields: City · Area / market name · Full address (optional, multiline 2 rows)
- Helper (14 muted): "Yeh address creatives ke bottom par aayega."
- Primary: "Continue" · Text button: "Skip"
**Next:** 8 Setup step 3.

# 8. BUSINESS SETUP — STEP 3 (photos & brand)
- "Step 3 of 3". Title: "Shop aur product ki photos"
- Sub (14 muted): "2–3 photos se creative achha banta hai."
- Uploader: 3-across grid of 104 dp squares (radius 16); filled slots show the photo with an × badge; empty slot #F1EBFF + 2 dp dashed #B9A6F0 + violet "+" (opens 13 Photo picker).
- Logo row (optional): 56 dp square slot + "Add your logo (optional)"
- Brand colour row (optional): 5 swatches + default chip "Use Growlio colours"
- Primary: "Finish setup" · Text button: "Skip for now"
**Next:** 9 Notification permission.

# 9. NOTIFICATION PERMISSION (Android 13+)
- Illustration block (#E8DFFF, radius 20, 160 tall).
- Title: "Festival reminders chahiye?"
- Body (17): "Diwali, Holi, Eid se pehle hum aapko creative banane ki yaad dila denge."
- Primary: "Allow notifications" (triggers the OS dialog) · Text button: "Not now"
**Next:** 10 Home.

# 10. HOME  ← main tab
1. Top bar (56): "Growlio" wordmark violet 700 left; bell icon right (badge dot if unread).
2. Business header row: 44 avatar (initial letter, #E8DFFF), name 17/600, "Category · Location" 14 muted.
3. Title (Nunito 800, 22): "Aaj kya promote karna hai?"
4. Category grid — 2 columns, gap 12, radius 16, padding 18×16, label 17/600:
   **Offer** (violet-600 / white) · **Festival** (yellow / ink) · **Product** (#F1EBFF) · **Service** (#F1EBFF) · **New arrival** (#F1EBFF) · **Announcement** (#F1EBFF)
5. Festival nudge card (only if a festival is ≤10 days away): #E8DFFF, radius 16, "Diwali 12 din mein — creative bana lein?" + "Create" text button.
6. "Recent creatives" (14 muted) + horizontal strip of 3 thumbnails (84 dp, radius 14) + "See all" → 21.
7. Primary (dark #1E0A46): "Create creative" → 11.
8. Bottom nav — Home active.
**Empty state (no creatives yet):** replace 6 with a #F1EBFF card: "Pehla creative banaiye — 1 minute lagega."

# 11. TYPE PICKER (bottom sheet)
- Drag handle. Title (Nunito 700, 20): "Kya banana hai?"
- 6 rows (height 64, gap 10, radius 14, #F1EBFF; icon left, label 17/600, chevron right): Offer · Festival · Product · Service · New arrival · Announcement
- Each row has a 14 muted example line: e.g. Offer → "₹999 stitching offer"
**Next:** 12 Creative input.

# 12. CREATIVE INPUT (one screen, fields vary by type)
Header: back arrow + type name ("Create offer"). Fields per type:
- **Offer:** Offer text · Price (half) + Occasion (half) · Valid till (optional)
- **Festival:** Festival picker chips (with dates) · Greeting or offer text · Price (optional)
- **Product:** Product name · Price · Photo picker strip (84 dp thumbs + "Add new")
- **Service:** Service name · Starting price · One benefit line
- **New arrival:** Collection / product name · Photo picker · One line
- **Announcement:** What to announce (multiline, 3 rows) · Date / time (optional)
Then on every type:
- Chip row "Format": Insta post (1:1) · Story (9:16) · Status (9:16) · Poster (A4) — default Insta post
- Chip row "Language": Hinglish · हिंदी · English — default = app language
- Helper (14 muted): "Growlio aapke business ki details khud add kar lega."
- Primary (yellow, ink label): "Generate creative"
**Next:** 15 Generating (or 13 Photo picker if a photo is added).

# 13. PHOTO PICKER
- Title: "Photo choose karein"
- Tabs: "My photos" (already uploaded) · "Gallery" · "Camera"
- Grid 3-across, 4 dp gaps, tap to select (violet ring + check).
- Primary: "Use photo"
**Next:** 14 Crop.

# 14. CROP
- Dark #1E0A46 ground, image with a crop frame in the chosen aspect (1:1 / 9:16 / A4).
- Chip row: aspect options. Text buttons: Rotate · Reset.
- Bottom row: "Cancel" (text) · Primary "Done"
**Next:** back to 12.

# 15. GENERATING
- Full-bleed violet-600. Logo mark 72 dp centred, gentle pulse.
- Line (Nunito 700 white, 20): "Aapka creative ban raha hai…"
- Rotating status (14 #E7DDFF): "Design choose kar rahe hain" → "Text likh rahe hain" → "Final touch"
- Indeterminate yellow bar, 4 dp, width 200.
- Text button (white 60%): "Cancel"
- No percentages, no AI/model names.
**Next:** 16 Result · on failure → Generation failed state.

# 16. YOUR CREATIVE (result)
1. Back arrow + title "Your creative"
2. Creative preview card (radius 18, shadow, chosen aspect) filling most of the screen.
3. Text buttons row: "Edit text" → 17 · "Change format" → 12 prefilled
4. Bottom row: "Regenerate" (secondary #F1EBFF / violet, flex 1) + "Download" (primary violet, flex 1.3) → 18
5. Auto-saves to My creatives; toast: "Saved in My creatives"
- Back press with unsaved changes → Delete confirm dialog.

# 17. EDIT TEXT
- Title: "Text edit karein"
- Live preview at the top (45% height, scaled).
- Editable rows below (each a #F1EBFF field): Headline · Offer / price line · Sub line · Business name · Phone · Address
- Chip row: "Text size": S · M · L
- Primary: "Save changes"
**Next:** 16 Result with the update applied.

# 18. FORMAT & DOWNLOAD
- Title: "Choose the size you need"
- Format tiles in true proportion, horizontal row: Post 1:1 (220 sq) · Story 9:16 (170×302) · Status 9:16 (170×302) · Poster A4 (200×260). Selected: 3 dp violet ring.
- Action rows (height 64, #F1EBFF, radius 16, gap 12): "Save to phone" · "Share on WhatsApp" · "Share on Instagram" · "More apps" → 19
- Helper (14 muted): "Growlio aapki taraf se kuch post nahi karta — control aapke paas rehta hai."
- On save: writes to `Pictures/Growlio`; toast "Gallery mein save ho gaya".
**Next:** 20 Success.

# 19. SHARE HANDOFF
Android system share intent with the exported image. No custom UI. Returns to 18.

# 20. SUCCESS
- Centred: yellow check badge 72 dp.
- Title (Nunito 800, 22): "Ho gaya!"
- Sub (17 muted): "Creative save ho gaya. Ab isse kahin bhi use karein."
- Primary: "Create another" → 11 · Text button: "Go to home" → 10
- Rate prompt appears here after the 3rd successful download.

# 21. MY CREATIVES  ← tab
1. Top bar: title "My creatives" + search icon → 22.
2. Filter chips (scrollable): All · Offers · Festival · Product · Service · New arrival · Announcement
3. Grid 2 columns, gap 12, cards radius 16, aspect 1:1, thumbnail + small type tag; date 13 muted under each.
4. Long-press: selection mode with Delete / Share in the top bar.
5. Empty state: #E8DFFF block, "Abhi koi creative nahi", primary "Create your first creative".
6. Primary: "New creative" → 11. Bottom nav — Saved active.

# 22. SEARCH
- Search field at the top (#F1EBFF, radius 14, auto-focus), placeholder "Offer, festival, product…"
- Recent searches as chips.
- Live results in the same grid as 21.
- Empty result: "Kuch nahi mila" + "Clear search" text button.

# 23. CREATIVE DETAIL
- Full preview, pinch-to-zoom, dark #1E0A46 ground.
- Meta row (white 14): type tag · format · date
- Action row (icons + labels): Download → 18 · Share → 19 · Regenerate → 15 · Delete (confirm dialog)

# 24. PROFILE  ← tab
1. Business card (#F1EBFF, radius 16): avatar 56, name Nunito 700 20, "Category · Location" 14 muted, "Edit" text button → 25.
2. Stat row (3 tiles, radius 16): "Creatives banaye" · "Is mahine" · "Saved" — numbers Nunito 800 24.
3. List rows (height 60, divider #EAE3FA): My creatives → 21 · Manage photos → 26 · Plan → 29 · Language → 28 · Settings → 27 · Help & FAQ → 30 · Contact support → 31 · Rate Growlio · Share Growlio · About → 32
4. Text button: "Log out" (confirm dialog). Version number 13 muted at the bottom.
5. Bottom nav — Profile active.

# 25. EDIT BUSINESS
- One scrollable form: all fields from 6 + 7 (name, category, phone, city, area, address).
- Primary: "Save changes"; toast "Business update ho gaya".

# 26. MANAGE PHOTOS
- Title: "Shop aur product photos"
- Grid of 104 dp squares with × badges + one "+" slot (max 12 photos).
- Logo section: current logo + "Replace" / "Remove".
- Brand colour section: 5 swatches + "Use Growlio colours".
- Primary: "Save"

# 27. SETTINGS
Switch rows: Festival reminders · Offer ideas notification · Save to gallery automatically
List rows: Language → 28 · Clear cache (shows size) · Privacy Policy · Terms of Service
Danger rows (red #D94A2B text): "Delete account" (confirm dialog; Play Store requires an in-app path)

# 28. LANGUAGE CHANGE
Same layout as 2, with the current language pre-selected. Primary "Save" and an immediate UI reload.

# 29. PLANS (ship only if pricing is decided)
- Free card (#F1EBFF): "Free" + "5 creatives per month · all formats · no watermark"
- Paid card (violet-600): price Nunito 800 32 + "Unlimited creatives · priority generation" + primary yellow "Upgrade"
- Row of trust lines (14 #E7DDFF): "Kabhi bhi cancel karein"
- If pricing is undecided: hide the Plan row in 24 and do not ship this screen.

# 30. HELP & FAQ
- Search field. Accordion rows (radius 14, #F1EBFF): "Creative kaise banaye?" · "Photo kaise upload karein?" · "Download kahan jata hai?" · "Instagram par kaise post karein?" · "Language kaise badle?" · "Refund policy"
- Bottom: "Aur madad chahiye?" + primary "Contact support" → 31

# 31. CONTACT SUPPORT
- Rows: WhatsApp support (opens chat) · Email support · Call (10 am–7 pm)
- Feedback field (multiline 4 rows) + primary "Send"

# 32. ABOUT
- Logo 72 dp, "Growlio" Nunito 800 24, tagline "Har Kaam Ko Mile Pehchaan.", version, "Made in India" line, links: Website · Privacy Policy · Terms · Licenses.

---

## SYSTEM STATES & DIALOGS

- **No internet** — full screen, #E8DFFF illustration block, "Internet nahi hai", body "Creative banane ke liye connection chahiye.", primary "Try again". Saved creatives stay viewable.
- **Update required** — blocking screen, "Naya version aa gaya hai", primary "Update now" (Play link).
- **Generation failed** — sheet: "Creative nahi ban paya", body "Ek baar phir try karein.", primary "Try again", text button "Change details". Never show error codes or model names.
- **Delete confirm** — dialog: "Creative delete kar dein?" · "Cancel" / "Delete" (red).
- **Logout confirm** — "Log out karna hai?" · "Cancel" / "Log out".
- **Permission denied** — inline card explaining what breaks + "Open settings".
- **Rate prompt** — after the 3rd download: "Growlio pasand aaya?" · "Rate on Play Store" / "Later".
- **Toast** — #1E0A46 fill, white 15 dp, 2 s, above the bottom nav.

## GLOBAL BUILD RULES

- One primary action per screen, 56 dp tall, 20 dp side margins, 24 dp above the nav / safe area.
- Loading = #F1EBFF skeleton blocks, never spinners over content.
- Bottom sheets: white, radius 28 top only, 36×4 drag handle (#EAE3FA).
- Dialogs: white, radius 20, title Nunito 700 20, body 17, right-aligned violet text buttons.
- Icons: single-stroke line icons, 24 dp, #1E0A46 (violet when active). No emoji.
- Works at 360 dp width without horizontal scroll; text scaling to 130% must not clip.
- Back from any flow screen (12–20) returns to the previous flow step; back on tabs (10/21/24) double-taps to exit.

## DATA MODEL (minimum)

```
User      : id, phone, language, plan, createdAt
Business  : id, userId, name, category, city, area, address, phone, photos[], logo?, brandColors?
Creative  : id, businessId, type, inputs{}, language, format, imageUrl, createdAt, savedAt?
```

## PLAY STORE READINESS

- 6 phone screenshots 1080×1920, feature graphic 1024×500, icon 512×512 — already exported in `playstore/`.
- Short description ≤80 chars, full description ≤4000.
- Privacy Policy URL (app collects phone number + photos) and in-app account deletion (screen 27) plus a web deletion URL.
- Data safety form: phone number, photos, device ID; declare that uploaded photos are processed to generate creatives.
- Content rating questionnaire; signed App Bundle (.aab) with Play App Signing; current target SDK; 64-bit.
- Test on 360 dp and 412 dp widths, Android 9 → 15.
