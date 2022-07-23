const colors = require("tailwindcss/colors");

module.exports = {
  purge: ["./src/**/*.cr", "./src/**/*.scss"],
  theme: {
    extend: {
      colors: {
        sky: colors.sky,
        rose: colors.rose,

        // Pre-2.0 colors for backwards compatibility
        "grey-darkest": "#3d4852",
        "grey-darker": "#606f7b",
        "grey-dark": "#8795a1",
        grey: "#b8c2cc",
        "grey-light": "#dae1e7",
        "grey-lighter": "#f1f5f8",
        "grey-lightest": "#f8fafc",

        "orange-darkest": "#462a16",
        "orange-darker": "#613b1f",
        "orange-dark": "#de751f",
        orange: "#f6993f",
        "orange-light": "#faad63",
        "orange-lighter": "#fcd9b6",
        "orange-lightest": "#fff5eb",

        "teal-darkest": "#0d3331",
        "teal-darker": "#20504f",
        "teal-dark": "#38a89d",
        teal: "#4dc0b5",
        "teal-light": "#64d5ca",
        "teal-lighter": "#a0f0ed",
        "teal-lightest": "#e8fffe",

        "blue-darkest": "#12283a",
        "blue-darker": "#1c3d5a",
        "blue-dark": "#2779bd",
        blue: "#3490dc",
        "blue-light": "#6cb2eb",
        "blue-lighter": "#bcdefa",
        "blue-lightest": "#eff8ff",

        "lucky-blue": "#031e37",
        "lucky-teal-blue": "#1b92b3",
        "lucky-dark-green": "#37DE97",
        "lucky-light-green": "#9DFF66",
      },
      width: {
        sidebar: "335px",
      },
    },
  },
  variants: {
    width: ["responsive", "focus"],
    textColor: ["responsive", "hover", "focus", "group-hover"],
    extend: {
      ringWidth: ["hover"],
    },
  },
  plugins: [],
};
