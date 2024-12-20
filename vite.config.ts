import { defineConfig } from "vite";

import mkcert from "vite-plugin-mkcert";
import wasm from "vite-plugin-wasm";
import crossOriginIsolation from "vite-plugin-cross-origin-isolation";

export default defineConfig({
  plugins: [wasm(), mkcert(), crossOriginIsolation()],
});
