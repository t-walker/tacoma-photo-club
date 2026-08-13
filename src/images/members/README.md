# Member photos (vertical)

Drop **portrait / vertical** member photographs in this folder. They appear in
the "Classifieds" ad on the home page and beside the title on the inner pages,
picked at random in the browser on every page load.

- Any `.jpg`, `.jpeg`, `.png`, `.webp` or `.avif` is picked up automatically —
  no code change, no manifest to update.
- Credit comes from `src/data/hero-credits.json`. Add an entry under `byImage`
  keyed by the exact file name, or leave it out to use the `default` credit.
- Landscape frames belong in `src/images/hero/` instead — those run full width
  on the home page.

While this folder has no photos in it, both slots show a dashed "member photo
wanted" placeholder instead.
