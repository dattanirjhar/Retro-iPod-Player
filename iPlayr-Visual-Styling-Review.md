# iPlayr Visual Styling Review

Oct 15, 2026 · @Manpreet Singh

iPlayr renders a simulated iPod (body, bezel, click wheel) in recognisable hardware colours around a restrained, mostly achromatic screen, driven by six independent user settings and twenty presets; this page lays out every visual rule, token and option so the design team can review the system end to end. Nothing here is compiled or screenshot-verified yet: the values are what the code computes, validated with a mirror of the same maths.

## Design direction

The hardware is nostalgic and coloured, the screen is modern and nearly colourless, and one accent per theme does all the highlighting.

- The simulated body, bezel and click wheel use flat hardware colours. Every hex in this document is a design token, not a measurement of an Apple finish.
- Screen surfaces are a stable charcoal (Dark), paper (Light), or one of two period looks (Retro Color, Retro LCD). Menus, lists and settings never take colour from album artwork.
- Exactly one accent per theme. It appears in three places only: the selected row, the progress fill, and the active Volume/Seek toggle on Now Playing.
- Album artwork may tint the background of Now Playing, and nowhere else. It is off in both retro appearances and under Increase Contrast.
- Every colour the user does not pick directly is derived at render time by contrast rules. The user's body, wheel and accent choices are never rewritten by those rules; only the derived values move.

## What the user sees

The whole phone is the iPod: a coloured chassis fills the display, a 300pt screen sits in its upper half (portrait) or left half (landscape), and the click wheel sits below or beside it.

| Element | What it is | Where its colour comes from |
| --- | --- | --- |
| Chassis | Full-screen body with 40pt rounded corners | Body Color, lightened and darkened into a vertical gradient, plus a 1px inner edge |
| Screen bezel | 6pt stroke around the 8pt-radius screen | #0B0D10 on dark bodies, #1A1D22 on light bodies |
| Screen | 300pt panel; left half menu, right half album-art slideshow; library, player and Cover Flow slide over both halves | Interface appearance tokens |
| Status bar | 26pt header at the top of every screen with title, play state, shuffle, repeat and battery | panelBackground with a 1px divider; Retro Color uses a gradient header |
| Menu rows | Text rows (17pt) and artwork rows (44pt cover, title, subtitle) | screenBackground; the highlighted row uses the derived selection colour |
| Click wheel | Ring, centre button and four labels; 62% of body width, 68% on mini/nano bodies | Ring Color, Ring Style, and a glyph colour measured for contrast |
| Now Playing | Artwork, title block, progress bar, Volume/Seek toggle, transport | screenBackground, or the artwork atmosphere when enabled |
| Immersive Cover Flow | Full-phone carousel that replaces the chassis | Black backdrop with the selected cover blurred beneath; unchanged by theme |

Typography is the system font throughout.

| Text | Size and weight |
| --- | --- |
| Menu rows and picker rows | 17pt regular |
| Status bar title | 13pt semibold |
| Now Playing title | 17pt semibold, two lines maximum |
| Now Playing artist and album | 14pt regular, secondary colour |
| Queue position ("3 of 12") | 12pt, muted colour |
| Time labels | 12pt medium, monospaced digits |
| MENU label on the wheel | 11pt semibold, 0.06em tracking |
| Wheel icons (previous, next, play/pause) | 14pt semibold SF Symbols |
| Wheel mode labels ("Wheel", Volume, Seek) | 11pt semibold |

## User controls and presets

Six settings are stored independently; changing one never changes another, and a preset is simply a batch write of all six.

| Control | Values | Default (Silver Classic) | What it drives |
| --- | --- | --- | --- |
| Body Color | any hex | #C9CED4 | Chassis gradient, edge, bezel tone, Minimal-style glyph contrast |
| Ring Style | Classic, Minimal + Icons | Classic | How the wheel is painted; touch handling is identical in both |
| Ring Color | any hex | #F3F5F7 | Ring fill or outline, ring edge, centre-button stroke, pressed tint |
| Interface | Dark, Light, Retro Color, Retro LCD | Dark | Every screen surface and text token |
| Accent | any hex | #2B6FC8 | Selected row, progress fill, active toggle (Dark and Light only) |
| Atmosphere | Off, Subtle, Rich | Off | Artwork tint on Now Playing |

Three more values are stored alongside them: the preset id (or "custom"), a wheel-glyph override ("auto" or a hex), and a Tinted Glyphs switch for the mini presets. Applying a preset writes everything at once and resets the glyph override to auto. Editing any single control afterwards sets the preset to Custom and leaves every other value exactly as it was.

The twenty presets. Glyph columns give the label colour on the wheel (Classic) and on the body (Minimal). "Compact" bodies draw the wheel at 68% instead of 62%.

| # | Preset | Body | Wheel | Glyph on wheel | Glyph on body | Accent | Finish | Default style | Default interface | Atmosphere | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Silver Classic | #C9CED4 | #F3F5F7 | #58616B | #1D2228 | #2B6FC8 | satin | Classic | Dark | Off | app default |
| 2 | Black Classic | #17191D | #252A31 | #E2E6EB | #E2E6EB | #2B6FC8 | gloss | Classic | Dark | Off | keyline fires |
| 3 | Signature White | #F2F2EF | #FFFFFF | #6B737D | #1D2228 | #2B6FC8 | gloss | Classic | Dark | Off | keyline fires |
| 4 | Graphite Classic | #43474D | #16181B | #C9CED4 | #C9CED4 | #2B6FC8 | satin | Classic | Dark | Off |  |
| 5 | U2 Red Wheel | #111215 | #B93248 | #FFFFFF | #FFFFFF | #B93248 | gloss | Classic | Dark | Off |  |
| 6 | Product Red Body | #A7193F | #F3F5F7 | #58616B | #FFFFFF | #2B6FC8 | satin | Classic | Dark | Off |  |
| 7 | Mini Gold | #D9C38E | #ECEEF0 | #7A6330 | #1D2228 | #8A6A1F | satin | Classic | Dark | Off | compact, tinted glyphs |
| 8 | Mini Pink | #E9A9C3 | #ECEEF0 | #9C4870 | #1D2228 | #A3406E | satin | Classic | Dark | Off | compact, tinted glyphs |
| 9 | Mini Blue | #8FBBDB | #ECEEF0 | #2F6A94 | #1D2228 | #2C6A99 | satin | Classic | Dark | Off | compact, tinted glyphs |
| 10 | Mini Green | #A8D08F | #ECEEF0 | #387028 | #1D2228 | #3B7A2C | satin | Classic | Dark | Off | compact, tinted glyphs |
| 11 | Nano Blue | #287EB8 | #F3F5F7 | #4D5A66 | #FFFFFF | #235D92 | satin | Classic | Dark | Off | compact; Minimal glyph 4.41:1 |
| 12 | Nano Pink | #D66F97 | #F3F5F7 | #4D5A66 | #1D2228 | #934066 | satin | Classic | Dark | Off | compact |
| 13 | Nano Green | #56A779 | #F3F5F7 | #4D5A66 | #1D2228 | #235D48 | satin | Classic | Dark | Off | compact |
| 14 | Nano Purple | #6E4BA8 | #F3F5F7 | #4D5A66 | #FFFFFF | #6E4BA8 | satin | Classic | Dark | Off | compact |
| 15 | Nano Orange | #E7792B | #F3F5F7 | #4D5A66 | #1D2228 | #B4541A | satin | Classic | Dark | Off | compact |
| 16 | Nano Yellow | #E9C63C | #F3F5F7 | #4D5A66 | #1D2228 | #8A6D00 | satin | Classic | Dark | Off | compact |
| 17 | Modern Album Glow | #1B1B23 | #C9C7FF | #1D2228 | #F1F0FA | #6A58E0 | satin | Minimal + Icons | Dark | Subtle |  |
| 18 | Midnight Studio | #121212 | #2A2A2A | #FFFFFF | #FFFFFF | #1ED760 | satin | Classic | Dark | Subtle | black selection text |
| 19 | Porcelain | #E7E5E0 | #F8F7F4 | #2B2B2B | #2B2B2B | #E5531A | matte | Minimal + Icons | Light | Off | fixed #D3D0C9 edge, no gloss |
| 20 | Liquid Glass | #22262E | #8E96A3 | #1D2228 | #FFFFFF | #0A84FF | satin | Minimal + Icons | Dark | Rich | Classic ring is translucent white over blur |

Mini presets ship with Tinted Glyphs on, so the wheel labels take the body-tinted colour in the table. With Tinted Glyphs off they use #58616B instead. The default style, interface and atmosphere for presets 1 to 16 were not specified and are a proposed default.

## Interface appearances

Four fixed palettes drive every screen surface; Dark and Light derive their selection and progress colours from the accent, while the two retro looks are period-fixed and ignore the accent.

| Token | Dark (default) | Light | Retro Color | Retro LCD |
| --- | --- | --- | --- | --- |
| screenBackground | #101317 | #F6F7F9 | #FFFFFF | #A9C1D3 |
| panelBackground (status bar) | #202630 | #FFFFFF | #FFFFFF | #A9C1D3 |
| raisedPanel (platter, song-list header) | #293341 | #EEF1F4 | #F2F4F6 | #9DB5C7 |
| divider | #394451 | #D5DBE2 | #E3E6EA | #7F97A9 |
| primaryText | #F5F7FA | #12161B | #000000 | #1C2A36 (ink) |
| secondaryText | #BBC4CF | #46505C | #5E6670 | #2E4252 |
| mutedText | #8E99A8 | #5F6A78 | #7A828C | #35485A |
| progressTrack | #2E3641 | #D5DBE2 | #D5DBE2 | #9DB5C7 |
| Status bar header | flat panelBackground | flat panelBackground | gradient #F3F5F7 to #C9CED4 | flat panelBackground |
| Selected row | derived from accent | derived from accent | gradient #356FCC to #1F57B0, white text | inverted: #1C2A36 row, #A9C1D3 text |
| progressFill | derived from accent | derived from accent | #2463C4 | #1C2A36 (ink) |
| System colour scheme | dark | light | light | light |
| Artwork atmosphere allowed | yes | yes | no | no |

The dark progress track is #2E3641 on purpose: the previously proposed #657181 gives a 1.01:1 contrast against the accent fill and is unreadable. Under Increase Contrast, mutedText is replaced by secondaryText in every palette.

## Derived colours: selection and progress

In Dark and Light the selection row and the progress fill are computed from the accent at render time by three rules, and the results match the specification's fixture table in all 64 cases.

1. Selection row. If white text on the accent reaches 4.5:1, use the accent with white text. Otherwise, if the accent's HSL hue is between 60° and 160° (yellows and greens) and black text reaches 4.5:1, use black text. Otherwise darken the accent in 1% lightness steps until white text passes.
2. Progress fill. The fill must reach 3:1 against both the track and the screen. On dark screens the accent is lightened 1% at a time until it does; on light screens it is darkened.
3. Stepping model. Lightness steps are HSL lightness, re-quantised to 8-bit after every step. This is the model that reproduces the fixtures exactly; OKLCH and single-shot HSL both drift by one or two units per channel.

| Accent | Presets | Selection row | Selection text | Contrast | Fill on Dark | Fill on Light |
| --- | --- | --- | --- | --- | --- | --- |
| #2B6FC8 | Silver, Black, Signature White, Graphite, Product Red | #2B6FC8 | #FFFFFF | 5.0:1 | #3C7FD5 | #2B6FC8 |
| #B93248 | U2 Red Wheel | #B93248 | #FFFFFF | 5.8:1 | #D1566C | #B93248 |
| #8A6A1F | Mini Gold | #8A6A1F | #FFFFFF | 5.0:1 | #9E7924 | #8A6A1F |
| #A3406E | Mini Pink | #A3406E | #FFFFFF | 6.0:1 | #C05F8D | #A3406E |
| #2C6A99 | Mini Blue | #2C6A99 | #FFFFFF | 5.8:1 | #3585BD | #2C6A99 |
| #3B7A2C | Mini Green | #3B7A2C | #FFFFFF | 5.2:1 | #458E31 | #3B7A2C |
| #235D92 | Nano Blue | #235D92 | #FFFFFF | 6.9:1 | #3084C6 | #235D92 |
| #934066 | Nano Pink | #934066 | #FFFFFF | 6.6:1 | #BB6586 | #934066 |
| #235D48 | Nano Green | #235D48 | #FFFFFF | 7.7:1 | #30916F | #235D48 |
| #6E4BA8 | Nano Purple | #6E4BA8 | #FFFFFF | 6.5:1 | #8D73C2 | #6E4BA8 |
| #B4541A | Nano Orange | #B4541A | #FFFFFF | 5.0:1 | #CC6020 | #B4541A |
| #8A6D00 | Nano Yellow | #8A6D00 | #FFFFFF | 4.9:1 | #9E7D00 | #8A6D00 |
| #6A58E0 | Modern Album Glow | #6A58E0 | #FFFFFF | 5.1:1 | #7E6CE5 | #6A58E0 |
| #1ED760 | Midnight Studio | #1ED760 | #000000 | 10.9:1 | #1ED760 | #0F8A40 |
| #E5531A | Porcelain | #CC4916 (darkened) | #FFFFFF | 4.6:1 | #E5531A | #D64D17 |
| #0A84FF | Liquid Glass | #0073EB (darkened) | #FFFFFF | 4.5:1 | #0A84FF | #0078F5 |

Every fill reaches at least 3.0:1 against its track and 3.9:1 against its screen. Modern Album Glow uses #6A58E0 rather than #7868E8 because white text on #7868E8 is only 4.25:1.

## Body and bezel rendering

The chassis is drawn entirely from the body colour and the preset's finish; nothing is a bitmap.

- Body gradient: vertical, from body lightened 6% at the top to body darkened 6% at the bottom (HSL lightness). Matte finishes use 2%.
- Edge: a 1px inner stroke at body darkened 18%, following the 40pt rounded corners. Porcelain uses a fixed #D3D0C9 edge.
- Finish: satin is the gradient alone; gloss adds a sharper white highlight band from the top (22% to 7% to clear over the upper half); matte is the flat 2% gradient with no highlight.
- Bezel: #0B0D10 when the body's HSL lightness is below 0.5, #1A1D22 otherwise.

| Preset | Body top | Body bottom | Edge | Bezel |
| --- | --- | --- | --- | --- |
| Silver Classic | #DADDE2 | #B8BFC6 | #96A0AB | #1A1D22 |
| Black Classic | #25282E | #090A0C | #000000 | #0B0D10 |
| Signature White | #FFFFFF | #E4E4DE | #C9C9BC | #1A1D22 |
| Graphite Classic | #51565D | #35383D | #181A1C | #0B0D10 |
| U2 Red Wheel | #1F2026 | #030404 | #000000 | #0B0D10 |
| Product Red Body | #C21D49 | #8C1535 | #570D21 | #0B0D10 |
| Mini Gold | #E1CFA5 | #D1B777 | #C29F49 | #1A1D22 |
| Mini Pink | #EFC1D4 | #E391B2 | #D66090 | #1A1D22 |
| Mini Blue | #A6C9E2 | #78ADD4 | #4A91C5 | #1A1D22 |
| Mini Green | #B9D9A5 | #97C779 | #76B54E | #1A1D22 |
| Nano Blue | #2D8FD1 | #236D9F | #184A6D | #0B0D10 |
| Nano Pink | #DD87A8 | #CF5786 | #B63466 | #1A1D22 |
| Nano Green | #6AB289 | #4C936A | #376A4D | #0B0D10 |
| Nano Purple | #7E5CB6 | #604293 | #442F69 | #0B0D10 |
| Nano Orange | #EA8A46 | #DB6919 | #A44F13 | #1A1D22 |
| Nano Yellow | #ECCE57 | #E6BE21 | #B59414 | #1A1D22 |
| Modern Album Glow | #282834 | #0E0E12 | #000000 | #0B0D10 |
| Midnight Studio | #212121 | #030303 | #000000 | #0B0D10 |
| Porcelain (matte) | #EBEAE6 | #E3E0DA | #D3D0C9 (fixed) | #1A1D22 |
| Liquid Glass | #2F3540 | #15171C | #000000 | #0B0D10 |

On the six near-black bodies the 18% darkening clamps to pure #000000, so the edge reads as a black hairline rather than a tinted one. Whether to floor the edge at a minimum lightness is an open question below.

## Click wheel

The wheel is two stacked layers: a fixed, invisible hit layer that never changes, and a paint layer that Ring Style swaps; switching style changes only what is drawn.

| Geometry (both styles) | Value |
| --- | --- |
| Wheel diameter | 62% of body width; 68% on mini and nano bodies |
| Centre button | 36% of the wheel diameter |
| Label radius | 68% of the outer radius: MENU top, previous left, next right, play/pause bottom |
| Hit regions | Centre circle, then four 90° sectors of the ring centred on top, right, bottom, left, extended 8pt past the outer edge |
| Rotation | Angular drag anywhere on the ring; one step per 30° of travel; clockwise scrolls down |
| Tap | Release within 12pt of the touch-down with no scroll step |
| Long press | 500ms held on MENU (jump to main menu) or previous/next (accelerating seek) |
| Pressed highlight | The touched sector or centre tints for at least 90ms, or until release when held |

| Paint | Classic | Minimal + Icons |
| --- | --- | --- |
| Ring | Solid fill in Ring Color with a 1px edge at Ring Color darkened 10% | 2px stroke in Ring Color; the body shows through the interior |
| Centre button | Ring Color lightened 3% (the body colour on mini/nano presets) with a 1px Ring Color stroke at 40% | Body colour with a 1.5px Ring Color stroke at 60% |
| Pressed tint | Ring Color darkened 8% on light wheels, lightened 8% on dark wheels | Ring Color at 16% opacity |
| Gloss presets | Add an 8% white radial highlight on the upper left of the ring | No change |
| Labels | Coloured against the wheel fill | Coloured against the body |
| Liquid Glass | Ring is white at 14% over a system blur (solid #8E96A3 under Reduce Transparency) | Standard outline |

Contrast keyline. When Ring Color against Body Color falls below 1.5:1 in Classic or 3:1 in Minimal, a 1px ring is added at the outer edge: white at 18% on dark bodies, black at 14% on light bodies. This is what keeps Black Classic and Midnight Studio readable without changing the user's colours. It fires for Silver Classic, Black Classic, Signature White, Mini Gold, Mini Green, Midnight Studio and Porcelain in both styles, and for Graphite, the other minis and most nanos in Minimal only.

| Preset | Ring edge (−10%) | Classic centre | Classic pressed |
| --- | --- | --- | --- |
| Silver Classic | #D4DCE3 | #FCFDFD | #DBE1E7 |
| Black Classic | #0F1114 | #2C313A | #373E48 |
| Signature White | #E6E6E6 | #FFFFFF | #EBEBEB |
| Graphite Classic | #000000 | #1D1F23 | #282C31 |
| U2 Red Wheel | #912738 | #C5354D | #CD475D |
| Product Red Body | #D4DCE3 | #FCFDFD | #DBE1E7 |
| Minis (wheel #ECEEF0) | #D0D4DA | body colour | #D5DADE |
| Nanos (wheel #F3F5F7) | #D4DCE3 | body colour | #DBE1E7 |
| Modern Album Glow | #9894FF | #D8D6FF | #A29EFF |
| Midnight Studio | #101010 | #323232 | #3E3E3E |
| Porcelain | #E4E0D5 | #FEFEFD | #E8E5DB |
| Liquid Glass | #727C8C | #969EAA | #788191 |

## Wheel glyph colour and contrast

Every preset's table glyph colour clears 4.5:1 on its real surface in both styles except one, so the contrast rule never had to override a designed value.

Resolution order for the label colour: the user's Wheel Glyphs override if set; otherwise the preset's table value (wheel column in Classic, body column in Minimal; the #58616B fallback for minis with Tinted Glyphs off); otherwise white or #1D2228 by measurement. The result is then checked against its actual surface (the ring fill in Classic, the body in Minimal). If it falls below 4.5:1 it is replaced by white or #1D2228, whichever contrasts more.

| Preset | Classic glyph | On wheel | Minimal glyph | On body | Keyline Classic / Minimal |
| --- | --- | --- | --- | --- | --- |
| Silver Classic | #58616B | 5.76:1 | #1D2228 | 10.11:1 | yes / yes |
| Black Classic | #E2E6EB | 11.52:1 | #E2E6EB | 14.04:1 | yes / yes |
| Signature White | #6B737D | 4.80:1 | #1D2228 | 14.27:1 | yes / yes |
| Graphite Classic | #C9CED4 | 11.23:1 | #C9CED4 | 5.90:1 | no / yes |
| U2 Red Wheel | #FFFFFF | 5.81:1 | #FFFFFF | 18.73:1 | no / no |
| Product Red Body | #58616B | 5.76:1 | #FFFFFF | 7.36:1 | no / no |
| Mini Gold | #7A6330 (tinted) | 4.94:1 | #1D2228 | 9.26:1 | yes / yes |
| Mini Pink | #9C4870 (tinted) | 5.05:1 | #1D2228 | 8.33:1 | no / yes |
| Mini Blue | #2F6A94 (tinted) | 5.00:1 | #1D2228 | 7.85:1 | no / yes |
| Mini Green | #387028 (tinted) | 5.13:1 | #1D2228 | 9.21:1 | yes / yes |
| Nano Blue | #4D5A66 | 6.47:1 | #FFFFFF | 4.41:1 (exception) | no / no |
| Nano Pink | #4D5A66 | 6.47:1 | #1D2228 | 5.02:1 | no / yes |
| Nano Green | #4D5A66 | 6.47:1 | #1D2228 | 5.49:1 | no / yes |
| Nano Purple | #4D5A66 | 6.47:1 | #FFFFFF | 6.49:1 | no / no |
| Nano Orange | #4D5A66 | 6.47:1 | #1D2228 | 5.46:1 | no / yes |
| Nano Yellow | #4D5A66 | 6.47:1 | #1D2228 | 9.61:1 | no / yes |
| Modern Album Glow | #1D2228 | 9.98:1 | #F1F0FA | 15.14:1 | no / no |
| Midnight Studio | #FFFFFF | 14.35:1 | #FFFFFF | 18.73:1 | yes / yes |
| Porcelain | #2B2B2B | 13.22:1 | #2B2B2B | 11.25:1 | yes / yes |
| Liquid Glass | #1D2228 | 5.37:1 | #FFFFFF | 15.17:1 | no / no |

With Tinted Glyphs off, the four minis use #58616B on the wheel at 5.41:1. Nano Blue in Minimal is the one documented exception: white on #287EB8 reaches 4.41:1 (icons still pass 3:1), and #1D2228 would be worse at 3.7:1, so white stays and the MENU label is rendered semibold like every other label. Liquid Glass's Classic value is measured against the solid fallback colour; over the translucent ring the real surface depends on what is behind it.

## Now Playing and album-art atmosphere

Now Playing is the one screen that may take colour from the artwork, and it does so behind the content, never in the text.

Layout, top to bottom: status bar titled Now Playing; a 120pt cover with 6pt corners and a soft shadow beside the title block (title 17pt semibold, artist and album 14pt, queue position 12pt); a 30pt progress row; the Wheel selector with Volume and Seek capsules; and the previous, play/pause, next transport row. The active capsule uses the selection colour and selection text; the inactive one is outlined in muted text at 50%.

Extraction runs once per artwork, cached, off the main thread:

1. Downsample the cover to 32 by 32.
2. Cluster the pixels in OKLab with k-means, k = 5, 12 iterations.
3. Drop clusters with chroma below 0.03. If none remain (grayscale art), there is no palette.
4. c1 is the cluster with the highest population times chroma.
5. c2 is the next cluster at least 30° away in hue, or c1 with its hue shifted 25°.

| Clamp (OKLCH) | Dark | Light |
| --- | --- | --- |
| Lightness | 0.28 to 0.38 | 0.86 to 0.92 |
| Chroma, Subtle | at most 0.12 | at most 0.08 |
| Chroma, Rich | at most 0.16 | at most 0.08 |

The background is a 160° linear gradient: c1 at 0%, c2 at 45%, screenBackground from 85%. Over it sits screenBackground at 55% opacity (Subtle) or 35% (Rich). Text on atmosphere is pure white (Dark) or pure black (Light), never tinted; secondary text is the same colour at 78% and muted at 62%. Ten points behind the title block and the controls are sampled analytically from the gradient model, and if the lightest of them gives less than 4.5:1 against the text the overlay rises in 0.05 steps until it does. On very light, very saturated and deep-dark test covers the worst case never dropped below 12.8:1, so the default overlays held.

Controls sit on a platter of raisedPanel at 60% over a system blur, or raisedPanel at 85% with no blur under Reduce Transparency. The progress track on atmosphere is white at 24%; the fill is the accent if it reaches 3:1 against the local background behind the bar, otherwise white.

With no artwork, or grayscale artwork, the screen shows screenBackground with an 8% accent radial glow behind the artwork position. On a track change the background cross-fades over 600ms; the gradient is never animated continuously. Atmosphere never appears on menus, lists, settings, the body or the wheel, and it is disabled in Retro Color, Retro LCD and under Increase Contrast.

## Everything selectable in Settings

All appearance controls live under Settings, App Settings, on a screen titled Appearance; every change applies instantly as a live preview and persists across launches.

| Appearance row | What the user sees | Options | Flips preset to Custom |
| --- | --- | --- | --- |
| Preset | Current preset name, or Custom; opens a list with a swatch per preset (body disc, wheel ring, accent dot) and a tick on the current one | 20 presets | no (sets the preset) |
| Body Color | Current hex; opens a swatch list | 20 body colours, named after their presets | yes |
| Ring Style | Current style | Classic, Minimal + Icons | yes |
| Ring Color | Current hex; swatch list | 10 distinct wheel colours from the presets | yes |
| Wheel Glyphs | Auto or the override hex; swatch list | Auto, White, Ink #1D2228, plus 11 distinct glyph colours from the presets | yes |
| Tinted Glyphs | On or Off, toggled in place | On, Off | yes |
| Interface | Current appearance; swatch shows its screen colour | Dark, Light, Retro Color, Retro LCD | yes |
| Accent | Current hex; swatch list | 16 distinct accents from the presets | yes |
| Atmosphere | Current level | Off, Subtle, Rich | yes |
| Language | English | English only | no |
| Immersive Mode | On or Off, toggled in place | On, Off (full-phone Cover Flow versus Cover Flow inside the iPod screen) | no |

The colour pickers offer curated palettes rather than free hex entry because the app is driven by the click wheel and has no keyboard. The stored values are still arbitrary hex, so a future hex field would need no model change.

Other settings on the main Settings screen are functional rather than visual: Shuffle (Off, Songs; Albums via the Shuffle Albums menu), Repeat (Off, All, One), Sort Order (Alphabetical, Date Added), Main Menu and Music Menu customisation (seven library sections with tick toggles and a reset), Brightness (the real screen brightness, adjusted by the wheel), Haptics (On, Off) and Clicker (On, Off).

## Accessibility behaviours

Three system settings change rendering, and the wheel exposes every control to VoiceOver without relying on its painted shapes.

| Setting | Behaviour |
| --- | --- |
| Reduce Motion | The Now Playing atmosphere swaps instantly instead of cross-fading over 600ms |
| Reduce Transparency | Every blur is replaced by solid raisedPanel: the Now Playing platter becomes raisedPanel at 85%, the Liquid Glass ring becomes solid #8E96A3 |
| Increase Contrast | Atmosphere is turned off and mutedText is raised to secondaryText in every palette |
| VoiceOver | The wheel is one element labelled "Click wheel" with an adjustable action for scrolling and named actions for Select, Menu, Main menu, Play or pause, Next track and Previous track; the painted labels are hidden from the accessibility tree |

Touch targets: the centre button is 36% of the wheel diameter (about 87pt in portrait on a 390pt-wide phone, 64pt in landscape), and each of the four sectors spans the full ring width plus 8pt of slop, so no target drops below 44pt in either style. The thin Minimal outline does not shrink any target because the hit layer is independent of the paint.

## Open questions for the design team

These are the judgement calls made while implementing, each reversible, where a designer's decision would be better than mine.

- [ ] Edge on near-black bodies clamps to #000000 (Black Classic, U2, Graphite, Modern Album Glow, Midnight, Liquid Glass). Keep as a black hairline, or floor the edge at a minimum lightness?
- [ ] Presets 1 to 16 default to Classic wheel, Dark interface, atmosphere Off. Should the legacy hardware presets open in Retro Color for period authenticity instead?
- [ ] Porcelain defaults to the Light interface, the only preset that does. Confirm.
- [ ] Atmosphere is disabled in Retro Color as well as Retro LCD. The spec only forbade it in LCD; confirm the Retro Color choice.
- [ ] Colour pickers are curated preset palettes. Is a free hex field wanted, and if so what input UI fits a wheel-driven app?
- [ ] Nano Blue in Minimal is 4.41:1 with white labels. Accept the documented exception, or nudge the body token toward #2678B2 to cross 4.5:1?
- [ ] Blur radii are not controllable with SwiftUI materials; both the platter and the Liquid Glass ring use the system ultra-thin material. Accept the system blur?
- [ ] MENU is rendered as the word in both styles per the spec; an earlier iteration used a three-line icon in Minimal + Icons. Confirm the word.
- [ ] The battery indicator keeps its ten-stop green and red asset gradient, the only chromatic element left in the status bar. Keep it as an iconic exception or flatten it to a token?
- [ ] Cover Flow's own screen still uses a blurred-artwork backdrop (pre-existing). Does that count as an album detail view, where the spec allows atmosphere, or should it be neutral?
- [ ] In immersive Cover Flow the track list is viewable but its rows are not tappable, so Play always starts from track one. Product gap worth a small design.
- [ ] Pressed highlight holds for 90ms minimum. Confirm the feel once it can be tried on device.
- [ ] The asset catalogue still contains the retired gradients (progressFill1 to 6, menuItemBackground1 to 5, statusBar1 to 4, wheelU2 and friends). They can be deleted once the new system is signed off.

## Code map

Each part of the system lives in one file under iPlayr/iPlayr, so a design change maps to a single place.

| Area | File | What it holds |
| --- | --- | --- |
| Colour maths | Core/Theme/ColorMath.swift | sRGB, WCAG contrast, HSL stepping, OKLab and OKLCH |
| Contrast helper | Core/Theme/ColorContrast.swift | White-or-ink foreground chooser |
| Appearance tokens and rules | Core/Theme/ThemeTokens.swift | The four palettes, selection and progress derivation, glyph rule |
| Presets | Core/Theme/ThemePresets.swift | The twenty presets and hardware traits |
| Persisted settings | Core/Theme/Theme.swift | ThemeManager: six controls, preset logic, migration, glyph resolution |
| Artwork atmosphere | Core/Theme/ArtworkAtmosphere.swift | Palette extraction, cache, clamping, gradient and overlay model |
| Chassis | Screens/Main/MainScreen.swift | Body gradient, edge, finish |
| Bezel | Components/iPlayrScreen.swift | Screen frame colour |
| Click wheel | Components/iPodButtons.swift | Geometry, hit layer, paint layer, labels |
| Rows and status bar | Components/MenuItemView.swift, CollectionMenuItem.swift, StatusBar.swift | Token-driven rows and header |
| Progress bars | Screens/Player/NowPlayingControls.swift | Capsule bar, scrubber, volume bar, time labels |
| Now Playing | Screens/Player/PlayerView.swift | Layout, atmosphere, platter, typography |
| Settings screens | Screens/Theme/ThemeView.swift | Appearance hub, presets list, pickers, swatches |
| Fixture tests | iPlayrTests/ThemeDerivationTests.swift | Fixture table, contrast sweep, hit-map and preset-to-custom tests (needs a test target in Xcode) |
