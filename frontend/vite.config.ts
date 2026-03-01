import react from '@vitejs/plugin-react'
import { defineConfig } from 'vitest/config'
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ["./vitest.setup.ts"],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'text-summary'],
      exclude: ["node_modules/","src/**/*.types.ts", "src/**/types.ts", "src/**/*.d.ts"],
    },
  },
})

