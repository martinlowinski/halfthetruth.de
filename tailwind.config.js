/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_includes/**/*.html",
    "./_layouts/**/*.html",
    "./*.html",
    "./_posts/*.markdown",
  ],
  darkMode: 'class',
  theme: {
    extend: {
    }
  },
  variants: {},
  plugins: [
    require("@tailwindcss/typography"),
  ],
};
