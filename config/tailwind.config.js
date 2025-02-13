module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        // sans: ['InterVariable', '...defaultTheme.fontFamily.sans']
      },
    },
  },
  plugins: [
    // require("@tailwindcss/forms"),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}