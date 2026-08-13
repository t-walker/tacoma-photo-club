import { getImage } from "astro:assets";
import heroCredits from "../data/hero-credits.json";

type ImageModule = { default: ImageMetadata };

/**
 * Hero photos are sourced straight from `src/images/hero/`. Drop a file in and it
 * joins the rotation — no code change, no manifest to update.
 */
const heroModules = import.meta.glob<ImageModule>(
  "../images/hero/*.{jpg,jpeg,png,webp,avif}",
  { eager: true },
);

const eventModules = import.meta.glob<ImageModule>(
  "../images/events/*.{jpg,jpeg,png,webp,avif}",
  { eager: true },
);

const shopModules = import.meta.glob<ImageModule>(
  "../images/shop/*.{jpg,jpeg,png,webp,avif}",
  { eager: true },
);

/**
 * Vertical member photos for the classified ad on inner pages. The hero plates
 * only suit landscape frames, so portrait work lives here instead.
 */
const memberModules = import.meta.glob<ImageModule>(
  "../images/members/*.{jpg,jpeg,png,webp,avif}",
  { eager: true },
);

function fileName(path: string): string {
  return path.split("/").pop() ?? path;
}

export type Credit = {
  name: string;
  handle: string;
  instagram?: string;
};

export type HeroSource = {
  src: string;
  width: number;
  height: number;
  name: string;
  credit: Credit;
};

type CreditFile = {
  default: Credit;
  byImage: Record<string, Credit>;
};

const credits = heroCredits as CreditFile;

/** Per-file credit if one is listed, otherwise the club default. */
function creditFor(file: string): Credit {
  return credits.byImage?.[file] ?? credits.default;
}

/** Build-time optimised hero sources, ready to hand to the client picker. */
export async function getHeroSources(width = 1600): Promise<HeroSource[]> {
  const entries = Object.entries(heroModules).sort(([a], [b]) => a.localeCompare(b));

  return Promise.all(
    entries.map(async ([path, mod]) => {
      const optimised = await getImage({ src: mod.default, width, format: "webp" });
      const file = fileName(path);
      return {
        src: optimised.src,
        width: Number(optimised.attributes.width ?? width),
        height: Number(optimised.attributes.height ?? Math.round(width * 0.625)),
        name: file,
        credit: creditFor(file),
      };
    }),
  );
}

/**
 * Vertical member photos, credited from the same file as the heroes. Returns an
 * empty list until someone drops a portrait frame into `src/images/members/`,
 * so the classified ad can simply go text-only in the meantime.
 */
export async function getMemberPhotos(width = 640): Promise<HeroSource[]> {
  const entries = Object.entries(memberModules).sort(([a], [b]) => a.localeCompare(b));

  return Promise.all(
    entries.map(async ([path, mod]) => {
      const optimised = await getImage({ src: mod.default, width, format: "webp" });
      const file = fileName(path);
      return {
        src: optimised.src,
        width: Number(optimised.attributes.width ?? width),
        height: Number(optimised.attributes.height ?? Math.round(width * 1.25)),
        name: file,
        credit: creditFor(file),
      };
    }),
  );
}

/** Look up an event flier by its file name as written in `events.json`. */
export function getEventFlier(flier: string | undefined): ImageMetadata | undefined {
  if (!flier) return undefined;
  const match = Object.entries(eventModules).find(([path]) => fileName(path) === flier);
  return match?.[1].default;
}

/**
 * Look up a shop photo by its file name as written in `shop.json`. Items
 * without a matching file fall back to a typographic tile, so listings can go
 * up before the product shots do.
 */
export function getShopImage(image: string | undefined): ImageMetadata | undefined {
  if (!image) return undefined;
  const match = Object.entries(shopModules).find(([path]) => fileName(path) === image);
  return match?.[1].default;
}
