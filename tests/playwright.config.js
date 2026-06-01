// @ts-check
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  timeout: 45_000,
  retries: 1,
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
  ],
  use: {
    baseURL: 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app',
    extraHTTPHeaders: {
      'Content-Type': 'application/json',
    },
    ignoreHTTPSErrors: false,
  },
});
