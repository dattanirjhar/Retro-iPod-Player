# Memo: finding things fast on the wheel

To: iPlayr UI/UX team. Re: search and navigation for large libraries. Produced 2026-10-16 by a UX
ideation agent from the product brief alone (it did not read the codebase). For the team to react to;
nothing here is decided.

Assumptions: about 3,000 songs; one wheel detent per 30° (12 per rotation); a 26pt title bar and
about ten 27pt rows; search covers the user's own library; test case is a known song title.

## 1. Three concepts

**A. Search with a letter strip (the 5.5G iPod design).** A "Search" item at the bottom of the Music
menu. Rotate along a horizontal strip (A–Z, 0–9, space, Delete, Done); SELECT adds the highlighted
letter; results filter live; Done (or rotating past the end) moves the highlight into the results and
MENU from the results returns to the strip; on the strip MENU deletes the last letter, and with an
empty query MENU leaves Search. Screen: title "Search" plus a result count; row 1 the query with a
cursor; row 2 the strip, scrolling sideways so the highlighted letter stays centred (about 15
characters visible); eight rows of results; full width, no album-art half. Cost: about three letters
at about eight detents each plus three SELECTs, then about three detents and one SELECT in the
results: roughly 30 detents (2.5 rotations) and 5 presses, flat as the library grows. Risk: two
focus areas with MENU meaning "delete" in one and "back" in the other.

**B. Quick-scroll letter badge (iPod classic behaviour).** Inside every long list, no new menu item.
Rotate fast; past a speed threshold a large letter badge (about 80pt, centred) appears and each
detent jumps to the next starting letter; slowing down fades the badge and resumes row scrolling.
Cost: 1–2 rotations to the letter, then about 58 detents within an average letter: about six
rotations, versus about 125 today. Risk: overshoot and an opaque speed threshold; no help in
crowded letters.

**C. "Jump to letter" row at the top of lists.** First row "A–Z…" opens a 5 × 6 letter grid; SELECT a
letter to open the list there; optional second level (Ba, Be, Bi…) when a letter holds more than
60 items. Cost: about 25 detents and 4 presses with the second level. Risk: overlaps A and B, adds a
modal to every list, and the real iPod never had it.

## 2. Recommendation

Ship A first: it searches songs, albums and artists at once, matches words inside titles, keeps
cost flat with library size, and is real iPod behaviour. Add B next for browsing; it costs no
screen space and no menu item. Skip C.

## 3. Edge cases for engineering

- Matching: start of any word ("nec" finds "Bear Necessities"); ignore case and accents ("beyo"
  finds "Beyoncé", "o" matches "ø/ö"); leading "The" / "A" still count as words; build a normalised
  index ahead of time; update results within about 100ms; never move the strip highlight while
  results reload.
- Numbers and punctuation: digits on the strip; punctuation ignored ("acdc" finds "AC/DC"); titles
  starting with a symbol sort under "#".
- Empty results: one non-selectable "No matches" row with the strip still in focus; don't clear
  the query automatically.
- Very long results: count in the title; group results, cap each group at 5 rows, then an
  "All 214 Songs >" row opening the full list with quick scroll.
- Mixed types: fixed group order (Artists, Albums, Songs, Playlists) with small grey header rows;
  song rows show the artist as a second line or at the right; artist/album results open their
  normal screens; a song result plays and opens Now Playing.
- Returning: MENU from a result returns to Search with query, scroll position and highlight kept;
  hold MENU still means main menu everywhere; keep the query until the user leaves Search from an
  empty query or the app closes.
- VoiceOver: the strip is one adjustable element ("B, 2 of 40"); SELECT announces "Query B E A,
  12 results"; Delete announces "Deleted A"; announce counts after a short typing pause; results
  read with their type ("Song, Bear Necessities, Phil Harris"); group headers are headings; focus
  moves are announced ("Results" / "Letters").

## 4. Questions for the product owner

1. Library-only search, or also the Apple Music catalogue (network delay, network-dependent
   empty states)?
2. Should Search be reachable from anywhere through a shortcut gesture, or only from the Music
   menu as on the original?
3. Should composers, genres and podcast titles appear in results, or keep to the original three
   types?

Usability test to run on prototype A: can a first-time user, with no instructions, tell where the
wheel is acting (strip or results) and recover from a typo? If not, the focus cue isn't strong enough.
