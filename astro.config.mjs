// @ts-check
import { defineConfig } from "astro/config";

// Set SITE / BASE_PATH when deploying to a GitHub Pages project site, e.g.
//   SITE=https://t-walker.github.io BASE_PATH=/tacoma-photo-club npm run build
// A custom domain needs only SITE.
export default defineConfig({
  site: process.env.SITE ?? "https://tacomaphoto.club",
  base: process.env.BASE_PATH ?? "/",
  trailingSlash: "always",
  build: {
    format: "directory",
  },
});
