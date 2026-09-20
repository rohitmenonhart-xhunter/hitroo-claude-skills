---
name: codex-imagegen
description: Generate real pictures — illustrations, hero art, icons, logos, textures, transparent PNG cut-outs — with Codex's image generation tool from a written brief, then verify and size them for the web. Use whenever a project needs an actual image rather than hand-coded SVG or CSS art: landing-page illustrations, empty states, avatars, marketing visuals, app icons, background textures. Works on any project; needs only the Codex CLI signed in to ChatGPT.
---

# Image generation with Codex

Codex (OpenAI's coding agent) carries an image-generation tool. Driven non-interactively with `codex exec`,
it turns a written brief into a PNG — with a transparent background when asked — and can save it straight
into the project. This skill is the reliable way to do that from a Claude session.

## 1. Run it

```bash
~/.claude/skills/codex-imagegen/scripts/imagegen.sh <out-dir> <file.png> "<brief>"
```

The script finds a working `codex` (see § 5), runs it in `<out-dir>` with a workspace-write sandbox, tells it
to use its image generation tool and copy the result to `<file.png>`, then verifies the file: mode, pixel
size, share of fully transparent pixels. Expect 1–2 minutes and roughly 20–35 K Codex tokens per image.

Generate several images in parallel by running the script several times at once (separate calls) — each is
independent.

## 2. Write the brief (this is where the quality comes from)

Say all of these, in this order, in plain prose:

1. **What** — the subject, its pose/composition, what it is doing. One scene per image.
2. **Style** — e.g. "editorial hand-inked illustration: loose confident ink outlines, flat colours, small
   hatching for texture", or "flat vector icon, 2 px strokes, rounded corners", or "soft 3D clay render".
   Name a public reference if it helps ("like the whimsical illustrations on the Whereby website").
3. **Palette** — exact hex values for the two to four colours that matter, and what each is used for.
4. **Background** — "transparent background (alpha)" for cut-outs; otherwise the exact colour. Add
   "no ground, no shadow, no text, no border, no watermark".
5. **Size and composition** — the aspect and pixel size (1024×1024, 1536×1024, 1024×1536), and where the
   empty space should be ("scene in the lower-right quadrant, empty transparent space above and to the
   left, so it can sit in a page corner").
6. **The hand-off** — "save it into this directory as `<name>.png`; reply with only the absolute path
   and the pixel size". The script adds this line for you.

Example brief that produced a good result:

> Two graceful geese in flight, one slightly ahead of the other, drawn as an editorial hand-inked
> illustration: loose confident ink outlines, flat warm coral-orange (#E8794E) bodies with a lighter peach
> underside, small dark teal (#1E5C4B) beaks, legs and eye dots, tiny hatching for feather texture.
> Transparent background (alpha), no ground, no shadow, no text, no border. Wide landscape image about
> 1536x1024, birds flying left-to-right across the upper two thirds with generous empty transparent margins.

## 3. After generation

- **Look at it.** Read the PNG (the Read tool renders images). Transparent areas show as black in that
  preview — that is the viewer, not the file. Judge composition, palette, edges.
- **Check the numbers** the script prints: `RGBA` and a high "transparent %" for cut-outs; if the share of
  transparent pixels is 0 %, the model painted a background — regenerate with "transparent background
  (alpha)" earlier and more emphatically in the brief.
- **Edges**: transparent images come with a soft feathered halo of partial alpha. Invisible on pale
  backgrounds, visible on dark ones. For a dark page, ask for "hard clean edges, no glow" or place the
  image on a matching dark colour.
- **Size for the web** with `scripts/png_check.py <file> --max-width 1200` (LANCZOS downscale, keeps
  the original in `src/`). 1–1.7 MB originals become 150–900 KB.
- **Keep the briefs** beside the images (`PROMPTS.md` in the art folder) so the next person can regenerate
  in the same style when the palette changes.
- **Wire it in** with a plain `<img>` (`alt=""`, `aria-hidden` for decoration; `loading="lazy"` below the
  fold) or the framework's image component; position with CSS; check on a screenshot at desktop and phone
  widths.

## 4. Good uses, and limits

Good: decorative illustrations, hero art, empty-state pictures, icons and logos to iterate on, textures,
character vignettes, product-style renders, social cards. Ask for *one* subject per image; compose in CSS.

Limits: text inside images is unreliable — keep words out and set them in HTML; exact brand logos of other
companies will not (and should not) be reproduced; photorealistic people are not for decoration; every run
is a fresh draw, so ask for the same palette and style words each time to keep a set consistent. Do not
generate anything that imitates a real person or organisation.

## 5. Finding a working Codex

The script tries, in order: `codex` on `PATH`, `/Applications/ChatGPT.app/Contents/Resources/codex`,
`~/.codex/plugins/.plugin-appserver/codex`. An npm-global `codex` can be a broken wrapper whose native
binary is missing (`spawn … ENOENT`); the ChatGPT-app copy is complete. Auth is whatever `codex login` set
up (`~/.codex/auth.json`); no API key is needed. Generated files are also kept by Codex under
`~/.codex/generated_images/<session>/`. Override the binary with `CODEX_BIN=/path/to/codex`.

If no Codex is available: say so and offer the alternative (an image-generation API with a key the user
provides), do not silently fall back to hand-drawn SVG.
