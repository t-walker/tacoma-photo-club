// @ts-check
import { defineConfig } from "astro/config";

// Custom domain: https://www.tacomaphoto.club (see public/CNAME).
// SITE / BASE_PATH can be overridden for a GitHub Pages project site, e.g.
//   SITE=https://t-walker.github.io BASE_PATH=/tacoma-photo-club npm run build
export default defineConfig({
  site: process.env.SITE ?? "https://www.tacomaphoto.club",
  base: process.env.BASE_PATH ?? "/",
  trailingSlash: "always",
  build: {
    format: "directory",
  },
});
