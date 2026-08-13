# Tacoma Photo Club

Website for the Tacoma Photo Club. **All cameras welcome!**

Built with [Astro](https://astro.build) as a fully static site. The design is a
deliberate pastiche of a 1970s magazine ad: newsprint stock, a heavy grotesk
headline, handwritten script captions, justified two-column body copy, and a
badge/wordmark lockup at the end of the copy block.

## Running it

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # static output in dist/
npm run preview  # serve dist/
```

## Updating content

Nothing here needs code changes — drop in files and edit JSON.

### Home page photos

Put photos in `src/images/hero/`. Any `.jpg`, `.jpeg`, `.png`, `.webp` or
`.avif` in that folder joins the rotation automatically. Two different ones are
picked at random on **every page load** (the top plate is 16:10, the lower plate
is 16:9 and inset to 88% width, both cropped with `object-fit: cover`).

Landscape images around 1600px wide work best. Astro optimises and hashes them
at build time.

### Member photos — `src/images/members/`

The home page plates only suit landscape frames, so **vertical** member work
goes in `src/images/members/` instead. It shows up in two places, with a fresh
random pick on every page load:

- the "Classifieds" ad below the home page copy, and
- alongside the title on Events, Photo Labs and Shop.

Portrait images around 640px wide are plenty. Credits come from
`src/data/hero-credits.json`, exactly like the hero photos. While the folder is
empty both slots show a dashed "member photo wanted" placeholder, which
disappears as soon as the first photo lands.

### Events — `src/data/events.json`

```jsonc
{
  "id": "darkroom-night",          // unique, kebab-case
  "title": "Darkroom Night",
  "location": "Hilltop Community Darkroom, Tacoma",
  "date": "2026-09-18T18:00:00-07:00", // ISO 8601; keep the -07:00/-08:00 offset
  "description": "Bring exposed black-and-white rolls.",
  "flier": "darkroom-night.jpg",   // file in src/images/events/
  "url": "https://optional-signup-link"
}
```

Fliers are the same 4:5 ratio as an Instagram portrait post — export at
**1080 × 1350**. Drop them in `src/images/events/` and reference the file name.

### Event group shots — `src/images/groups/`

The group photo from an event goes in `src/images/groups/`, named after the
event's `id` — `bowling-meetup.jpg` for the event with `"id": "bowling-meetup"`.
There is no JSON field to update; the name is the link. It gets laid over the
foot of that event's flier, and events without one simply show the flier.

Landscape, around 1600px wide.

Ordering and highlighting are automatic:

| State | Treatment |
| --- | --- |
| Next event | Red outline, red `NEXT UP` stamp, sorted first |
| Later upcoming events | Full color, black `UPCOMING` stamp |
| Past events | Desaturated and faded, returns to full color on hover/focus |

Statuses are computed at build time **and** recomputed in the browser against
the visitor's clock, so the page never shows a stale "upcoming" event even if
the site hasn't been rebuilt.

### Photo labs — `src/data/photo-labs.json`

```jsonc
{
  "name": "Blue Moon Camera & Machine",
  "location": "Portland, OR",
  "capabilities": ["C-41", "B&W", "E-6", "120", "35mm", "Scanning"],
  "priceRange": "$$",              // $, $$ or $$$
  "milesFromTacoma": 145,          // rough driving miles; null/omitted = mail-order, sorts last
  "dropOff": "8417 N Lombard St, Portland", // the shop counter; "" for mail-order-only labs
  "dropBoxes": [],                 // optional: partner shops that host a drop box
  "mailIn": true,
  "turnaround": "2-3 weeks",       // optional
  "url": "https://www.bluemooncamera.com", // optional
  "notes": "Slow but meticulous."  // optional
}
```

Rendered as a ruled spec chart — the 70s equivalent of a product comparison
table in the back pages of a magazine.

### Club details — `src/data/site.json`

Club name, slogan, Discord invite URL, Instagram and contact email. **Replace
the `REPLACE-ME` Discord and Instagram URLs before launch.**

### Logo

`src/components/Logo.astro` is an inline SVG placeholder in the spirit of the
MUSTANG wordmark + Ford oval. Swap the SVG contents for the real club logo when
it's ready; the `.lockup__logo` sizing stays the same.

### Placeholder images

`tools/make-placeholders.ps1` regenerates the stand-in hero and flier JPEGs.
Delete them once real photos are in.

## Layout notes

The page is a single centred "sheet" (`--sheet-width`, 1080px). On a phone it
fills the screen edge to edge; on a large monitor it stretches to that width and
stays centred on a darker desk-colored background, so the ad composition holds
at every size. The two text columns stay two columns at all widths — that's the
point of the format — with type scaling via `clamp()`.

## Deploying

The site is hosted on GitHub Pages at **https://www.tacomaphoto.club**.

`.github/workflows/deploy.yml` builds and publishes on every push to `main`,
plus nightly so event ordering stays current. `public/CNAME` holds the custom
domain and ships with the build output, which keeps the Pages custom-domain
setting pinned to `www.tacomaphoto.club`.

DNS (Squarespace) needs both halves:

| Type | Host | Value |
| --- | --- | --- |
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| CNAME | `www` | `t-walker.github.io` |

The apex A records let `tacomaphoto.club` redirect to the `www` host. Once the
DNS check passes, tick **Enforce HTTPS** in Settings → Pages.

To build for a project-site URL instead, set repository variables
`SITE=https://t-walker.github.io` and `BASE_PATH=/tacoma-photo-club`.
