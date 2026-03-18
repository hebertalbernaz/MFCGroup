// vite.config.mjs
import { defineConfig } from "file:///home/project/node_modules/vite/dist/node/index.js";
import { extensions, classicEmberSupport, ember } from "file:///home/project/node_modules/@embroider/vite/dist/index.js";
import { babel } from "file:///home/project/node_modules/@rollup/plugin-babel/dist/es/index.js";
import { fileURLToPath } from "node:url";
import { resolve, dirname, join } from "node:path";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
var __vite_injected_original_import_meta_url = "file:///home/project/vite.config.mjs";
var __dirname = dirname(fileURLToPath(__vite_injected_original_import_meta_url));
var _require = createRequire(__vite_injected_original_import_meta_url);
function ensureEmbroiderCache() {
  return {
    name: "ensure-embroider-cache",
    enforce: "pre",
    configResolved() {
      const embroiderDir = join(__dirname, "node_modules", ".embroider");
      const contentForPath = join(embroiderDir, "content-for.json");
      if (existsSync(contentForPath)) return;
      const getEnvConfig = _require(join(__dirname, "config", "environment.js"));
      const envConfig = getEnvConfig("development");
      const encoded = encodeURIComponent(JSON.stringify(envConfig));
      const metaTag = `<meta name="my-app/config/environment" content="${encoded}" />`;
      const empty = "";
      const contentFor = {
        "/index.html": {
          head: metaTag,
          "test-head": empty,
          "head-footer": empty,
          "test-head-footer": empty,
          body: empty,
          "test-body": empty,
          "body-footer": empty,
          "test-body-footer": empty,
          "config-module": empty,
          "app-boot": empty
        },
        "/tests/index.html": {
          head: empty,
          "test-head": empty,
          "head-footer": empty,
          "test-head-footer": empty,
          body: empty,
          "test-body": empty,
          "body-footer": empty,
          "test-body-footer": empty,
          "config-module": empty,
          "app-boot": empty
        }
      };
      mkdirSync(embroiderDir, { recursive: true });
      writeFileSync(contentForPath, JSON.stringify(contentFor, null, 2));
    }
  };
}
var vite_config_default = defineConfig({
  server: {
    port: 4201,
    hmr: {
      clientPort: 4201
    }
  },
  resolve: {
    alias: {
      "my-app/config/environment": resolve(__dirname, "app/environment.js"),
      "my-app/": resolve(__dirname, "app") + "/"
    }
  },
  plugins: [
    ensureEmbroiderCache(),
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
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcubWpzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZGlybmFtZSA9IFwiL2hvbWUvcHJvamVjdFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL2hvbWUvcHJvamVjdC92aXRlLmNvbmZpZy5tanNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL2hvbWUvcHJvamVjdC92aXRlLmNvbmZpZy5tanNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJztcbmltcG9ydCB7IGV4dGVuc2lvbnMsIGNsYXNzaWNFbWJlclN1cHBvcnQsIGVtYmVyIH0gZnJvbSAnQGVtYnJvaWRlci92aXRlJztcbmltcG9ydCB7IGJhYmVsIH0gZnJvbSAnQHJvbGx1cC9wbHVnaW4tYmFiZWwnO1xuaW1wb3J0IHsgZmlsZVVSTFRvUGF0aCB9IGZyb20gJ25vZGU6dXJsJztcbmltcG9ydCB7IHJlc29sdmUsIGRpcm5hbWUsIGpvaW4gfSBmcm9tICdub2RlOnBhdGgnO1xuaW1wb3J0IHsgZXhpc3RzU3luYywgbWtkaXJTeW5jLCB3cml0ZUZpbGVTeW5jIH0gZnJvbSAnbm9kZTpmcyc7XG5pbXBvcnQgeyBjcmVhdGVSZXF1aXJlIH0gZnJvbSAnbm9kZTptb2R1bGUnO1xuXG5jb25zdCBfX2Rpcm5hbWUgPSBkaXJuYW1lKGZpbGVVUkxUb1BhdGgoaW1wb3J0Lm1ldGEudXJsKSk7XG5jb25zdCBfcmVxdWlyZSA9IGNyZWF0ZVJlcXVpcmUoaW1wb3J0Lm1ldGEudXJsKTtcblxuZnVuY3Rpb24gZW5zdXJlRW1icm9pZGVyQ2FjaGUoKSB7XG4gIHJldHVybiB7XG4gICAgbmFtZTogJ2Vuc3VyZS1lbWJyb2lkZXItY2FjaGUnLFxuICAgIGVuZm9yY2U6ICdwcmUnLFxuICAgIGNvbmZpZ1Jlc29sdmVkKCkge1xuICAgICAgY29uc3QgZW1icm9pZGVyRGlyID0gam9pbihfX2Rpcm5hbWUsICdub2RlX21vZHVsZXMnLCAnLmVtYnJvaWRlcicpO1xuICAgICAgY29uc3QgY29udGVudEZvclBhdGggPSBqb2luKGVtYnJvaWRlckRpciwgJ2NvbnRlbnQtZm9yLmpzb24nKTtcblxuICAgICAgaWYgKGV4aXN0c1N5bmMoY29udGVudEZvclBhdGgpKSByZXR1cm47XG5cbiAgICAgIGNvbnN0IGdldEVudkNvbmZpZyA9IF9yZXF1aXJlKGpvaW4oX19kaXJuYW1lLCAnY29uZmlnJywgJ2Vudmlyb25tZW50LmpzJykpO1xuICAgICAgY29uc3QgZW52Q29uZmlnID0gZ2V0RW52Q29uZmlnKCdkZXZlbG9wbWVudCcpO1xuICAgICAgY29uc3QgZW5jb2RlZCA9IGVuY29kZVVSSUNvbXBvbmVudChKU09OLnN0cmluZ2lmeShlbnZDb25maWcpKTtcbiAgICAgIGNvbnN0IG1ldGFUYWcgPSBgPG1ldGEgbmFtZT1cIm15LWFwcC9jb25maWcvZW52aXJvbm1lbnRcIiBjb250ZW50PVwiJHtlbmNvZGVkfVwiIC8+YDtcblxuICAgICAgY29uc3QgZW1wdHkgPSAnJztcbiAgICAgIGNvbnN0IGNvbnRlbnRGb3IgPSB7XG4gICAgICAgICcvaW5kZXguaHRtbCc6IHtcbiAgICAgICAgICBoZWFkOiBtZXRhVGFnLFxuICAgICAgICAgICd0ZXN0LWhlYWQnOiBlbXB0eSxcbiAgICAgICAgICAnaGVhZC1mb290ZXInOiBlbXB0eSxcbiAgICAgICAgICAndGVzdC1oZWFkLWZvb3Rlcic6IGVtcHR5LFxuICAgICAgICAgIGJvZHk6IGVtcHR5LFxuICAgICAgICAgICd0ZXN0LWJvZHknOiBlbXB0eSxcbiAgICAgICAgICAnYm9keS1mb290ZXInOiBlbXB0eSxcbiAgICAgICAgICAndGVzdC1ib2R5LWZvb3Rlcic6IGVtcHR5LFxuICAgICAgICAgICdjb25maWctbW9kdWxlJzogZW1wdHksXG4gICAgICAgICAgJ2FwcC1ib290JzogZW1wdHksXG4gICAgICAgIH0sXG4gICAgICAgICcvdGVzdHMvaW5kZXguaHRtbCc6IHtcbiAgICAgICAgICBoZWFkOiBlbXB0eSxcbiAgICAgICAgICAndGVzdC1oZWFkJzogZW1wdHksXG4gICAgICAgICAgJ2hlYWQtZm9vdGVyJzogZW1wdHksXG4gICAgICAgICAgJ3Rlc3QtaGVhZC1mb290ZXInOiBlbXB0eSxcbiAgICAgICAgICBib2R5OiBlbXB0eSxcbiAgICAgICAgICAndGVzdC1ib2R5JzogZW1wdHksXG4gICAgICAgICAgJ2JvZHktZm9vdGVyJzogZW1wdHksXG4gICAgICAgICAgJ3Rlc3QtYm9keS1mb290ZXInOiBlbXB0eSxcbiAgICAgICAgICAnY29uZmlnLW1vZHVsZSc6IGVtcHR5LFxuICAgICAgICAgICdhcHAtYm9vdCc6IGVtcHR5LFxuICAgICAgICB9LFxuICAgICAgfTtcblxuICAgICAgbWtkaXJTeW5jKGVtYnJvaWRlckRpciwgeyByZWN1cnNpdmU6IHRydWUgfSk7XG4gICAgICB3cml0ZUZpbGVTeW5jKGNvbnRlbnRGb3JQYXRoLCBKU09OLnN0cmluZ2lmeShjb250ZW50Rm9yLCBudWxsLCAyKSk7XG4gICAgfSxcbiAgfTtcbn1cblxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHtcbiAgc2VydmVyOiB7XG4gICAgcG9ydDogNDIwMSxcbiAgICBobXI6IHtcbiAgICAgIGNsaWVudFBvcnQ6IDQyMDEsXG4gICAgfSxcbiAgfSxcbiAgcmVzb2x2ZToge1xuICAgIGFsaWFzOiB7XG4gICAgICAnbXktYXBwL2NvbmZpZy9lbnZpcm9ubWVudCc6IHJlc29sdmUoX19kaXJuYW1lLCAnYXBwL2Vudmlyb25tZW50LmpzJyksXG4gICAgICAnbXktYXBwLyc6IHJlc29sdmUoX19kaXJuYW1lLCAnYXBwJykgKyAnLycsXG4gICAgfSxcbiAgfSxcbiAgcGx1Z2luczogW1xuICAgIGVuc3VyZUVtYnJvaWRlckNhY2hlKCksXG4gICAgY2xhc3NpY0VtYmVyU3VwcG9ydCgpLFxuICAgIGVtYmVyKCksXG4gICAgYmFiZWwoe1xuICAgICAgYmFiZWxIZWxwZXJzOiAncnVudGltZScsXG4gICAgICBleHRlbnNpb25zLFxuICAgIH0pLFxuICBdLFxufSk7XG4iXSwKICAibWFwcGluZ3MiOiAiO0FBQTJOLFNBQVMsb0JBQW9CO0FBQ3hQLFNBQVMsWUFBWSxxQkFBcUIsYUFBYTtBQUN2RCxTQUFTLGFBQWE7QUFDdEIsU0FBUyxxQkFBcUI7QUFDOUIsU0FBUyxTQUFTLFNBQVMsWUFBWTtBQUN2QyxTQUFTLFlBQVksV0FBVyxxQkFBcUI7QUFDckQsU0FBUyxxQkFBcUI7QUFOcUcsSUFBTSwyQ0FBMkM7QUFRcEwsSUFBTSxZQUFZLFFBQVEsY0FBYyx3Q0FBZSxDQUFDO0FBQ3hELElBQU0sV0FBVyxjQUFjLHdDQUFlO0FBRTlDLFNBQVMsdUJBQXVCO0FBQzlCLFNBQU87QUFBQSxJQUNMLE1BQU07QUFBQSxJQUNOLFNBQVM7QUFBQSxJQUNULGlCQUFpQjtBQUNmLFlBQU0sZUFBZSxLQUFLLFdBQVcsZ0JBQWdCLFlBQVk7QUFDakUsWUFBTSxpQkFBaUIsS0FBSyxjQUFjLGtCQUFrQjtBQUU1RCxVQUFJLFdBQVcsY0FBYyxFQUFHO0FBRWhDLFlBQU0sZUFBZSxTQUFTLEtBQUssV0FBVyxVQUFVLGdCQUFnQixDQUFDO0FBQ3pFLFlBQU0sWUFBWSxhQUFhLGFBQWE7QUFDNUMsWUFBTSxVQUFVLG1CQUFtQixLQUFLLFVBQVUsU0FBUyxDQUFDO0FBQzVELFlBQU0sVUFBVSxtREFBbUQsT0FBTztBQUUxRSxZQUFNLFFBQVE7QUFDZCxZQUFNLGFBQWE7QUFBQSxRQUNqQixlQUFlO0FBQUEsVUFDYixNQUFNO0FBQUEsVUFDTixhQUFhO0FBQUEsVUFDYixlQUFlO0FBQUEsVUFDZixvQkFBb0I7QUFBQSxVQUNwQixNQUFNO0FBQUEsVUFDTixhQUFhO0FBQUEsVUFDYixlQUFlO0FBQUEsVUFDZixvQkFBb0I7QUFBQSxVQUNwQixpQkFBaUI7QUFBQSxVQUNqQixZQUFZO0FBQUEsUUFDZDtBQUFBLFFBQ0EscUJBQXFCO0FBQUEsVUFDbkIsTUFBTTtBQUFBLFVBQ04sYUFBYTtBQUFBLFVBQ2IsZUFBZTtBQUFBLFVBQ2Ysb0JBQW9CO0FBQUEsVUFDcEIsTUFBTTtBQUFBLFVBQ04sYUFBYTtBQUFBLFVBQ2IsZUFBZTtBQUFBLFVBQ2Ysb0JBQW9CO0FBQUEsVUFDcEIsaUJBQWlCO0FBQUEsVUFDakIsWUFBWTtBQUFBLFFBQ2Q7QUFBQSxNQUNGO0FBRUEsZ0JBQVUsY0FBYyxFQUFFLFdBQVcsS0FBSyxDQUFDO0FBQzNDLG9CQUFjLGdCQUFnQixLQUFLLFVBQVUsWUFBWSxNQUFNLENBQUMsQ0FBQztBQUFBLElBQ25FO0FBQUEsRUFDRjtBQUNGO0FBRUEsSUFBTyxzQkFBUSxhQUFhO0FBQUEsRUFDMUIsUUFBUTtBQUFBLElBQ04sTUFBTTtBQUFBLElBQ04sS0FBSztBQUFBLE1BQ0gsWUFBWTtBQUFBLElBQ2Q7QUFBQSxFQUNGO0FBQUEsRUFDQSxTQUFTO0FBQUEsSUFDUCxPQUFPO0FBQUEsTUFDTCw2QkFBNkIsUUFBUSxXQUFXLG9CQUFvQjtBQUFBLE1BQ3BFLFdBQVcsUUFBUSxXQUFXLEtBQUssSUFBSTtBQUFBLElBQ3pDO0FBQUEsRUFDRjtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AscUJBQXFCO0FBQUEsSUFDckIsb0JBQW9CO0FBQUEsSUFDcEIsTUFBTTtBQUFBLElBQ04sTUFBTTtBQUFBLE1BQ0osY0FBYztBQUFBLE1BQ2Q7QUFBQSxJQUNGLENBQUM7QUFBQSxFQUNIO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
