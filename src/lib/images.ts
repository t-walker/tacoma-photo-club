import { getImage } from "astro:assets";

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

function fileName(path: string): string {
  return path.split("/").pop() ?? path;
}

export type HeroSource = {
  src: string;
  width: number;
  height: number;
  name: string;
};

/** Build-time optimised hero sources, ready to hand to the client picker. */
export async function getHeroSources(width = 1600): Promise<HeroSource[]> {
  const entries = Object.entries(heroModules).sort(([a], [b]) => a.localeCompare(b));

  return Promise.all(
    entries.map(async ([path, mod]) => {
      const optimised = await getImage({ src: mod.default, width, format: "webp" });
      return {
        src: optimised.src,
        width: Number(optimised.attributes.width ?? width),
        height: Number(optimised.attributes.height ?? Math.round(width * 0.625)),
        name: fileName(path),
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
