import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // Add this 'server' block
  server: {
    proxy: {
      "/api": {
        target: "https://linkedin-6id0.onrender.com", // <-- This is your local backend port
        changeOrigin: true,
      },
    },
  },
});
