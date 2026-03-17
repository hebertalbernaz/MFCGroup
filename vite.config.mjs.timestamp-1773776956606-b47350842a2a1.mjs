// vite.config.mjs
import { defineConfig } from "file:///home/project/node_modules/vite/dist/node/index.js";
import { extensions, classicEmberSupport, ember } from "file:///home/project/node_modules/@embroider/vite/dist/index.js";
import { babel } from "file:///home/project/node_modules/@rollup/plugin-babel/dist/es/index.js";
import { fileURLToPath } from "node:url";
import { resolve, dirname } from "node:path";
var __vite_injected_original_import_meta_url = "file:///home/project/vite.config.mjs";
var __dirname = dirname(fileURLToPath(__vite_injected_original_import_meta_url));
var vite_config_default = defineConfig({
  resolve: {
    alias: {
      "my-app/config/environment": resolve(__dirname, "app/environment.js"),
      "my-app/": resolve(__dirname, "app") + "/"
    }
  },
  plugins: [
    classicEmberSupport(),
    ember(),
    babel({
      babelHelpers: "runtime",
      extensions
    })
  ]
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcubWpzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZGlybmFtZSA9IFwiL2hvbWUvcHJvamVjdFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL2hvbWUvcHJvamVjdC92aXRlLmNvbmZpZy5tanNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL2hvbWUvcHJvamVjdC92aXRlLmNvbmZpZy5tanNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJztcbmltcG9ydCB7IGV4dGVuc2lvbnMsIGNsYXNzaWNFbWJlclN1cHBvcnQsIGVtYmVyIH0gZnJvbSAnQGVtYnJvaWRlci92aXRlJztcbmltcG9ydCB7IGJhYmVsIH0gZnJvbSAnQHJvbGx1cC9wbHVnaW4tYmFiZWwnO1xuaW1wb3J0IHsgZmlsZVVSTFRvUGF0aCB9IGZyb20gJ25vZGU6dXJsJztcbmltcG9ydCB7IHJlc29sdmUsIGRpcm5hbWUgfSBmcm9tICdub2RlOnBhdGgnO1xuXG5jb25zdCBfX2Rpcm5hbWUgPSBkaXJuYW1lKGZpbGVVUkxUb1BhdGgoaW1wb3J0Lm1ldGEudXJsKSk7XG5cbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZyh7XG4gIHJlc29sdmU6IHtcbiAgICBhbGlhczoge1xuICAgICAgJ215LWFwcC9jb25maWcvZW52aXJvbm1lbnQnOiByZXNvbHZlKF9fZGlybmFtZSwgJ2FwcC9lbnZpcm9ubWVudC5qcycpLFxuICAgICAgJ215LWFwcC8nOiByZXNvbHZlKF9fZGlybmFtZSwgJ2FwcCcpICsgJy8nLFxuICAgIH0sXG4gIH0sXG4gIHBsdWdpbnM6IFtcbiAgICBjbGFzc2ljRW1iZXJTdXBwb3J0KCksXG4gICAgZW1iZXIoKSxcbiAgICBiYWJlbCh7XG4gICAgICBiYWJlbEhlbHBlcnM6ICdydW50aW1lJyxcbiAgICAgIGV4dGVuc2lvbnMsXG4gICAgfSksXG4gIF0sXG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBMk4sU0FBUyxvQkFBb0I7QUFDeFAsU0FBUyxZQUFZLHFCQUFxQixhQUFhO0FBQ3ZELFNBQVMsYUFBYTtBQUN0QixTQUFTLHFCQUFxQjtBQUM5QixTQUFTLFNBQVMsZUFBZTtBQUprRyxJQUFNLDJDQUEyQztBQU1wTCxJQUFNLFlBQVksUUFBUSxjQUFjLHdDQUFlLENBQUM7QUFFeEQsSUFBTyxzQkFBUSxhQUFhO0FBQUEsRUFDMUIsU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsNkJBQTZCLFFBQVEsV0FBVyxvQkFBb0I7QUFBQSxNQUNwRSxXQUFXLFFBQVEsV0FBVyxLQUFLLElBQUk7QUFBQSxJQUN6QztBQUFBLEVBQ0Y7QUFBQSxFQUNBLFNBQVM7QUFBQSxJQUNQLG9CQUFvQjtBQUFBLElBQ3BCLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQSxNQUNKLGNBQWM7QUFBQSxNQUNkO0FBQUEsSUFDRixDQUFDO0FBQUEsRUFDSDtBQUNGLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
