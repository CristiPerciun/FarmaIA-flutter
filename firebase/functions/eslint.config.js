const tsParser = require("@typescript-eslint/parser");

module.exports = [
  // Don't lint compiled output.
  {
    ignores: ["lib/**"],
  },
  {
    files: ["**/*.ts"],
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 2020,
      sourceType: "module",
    },
    rules: {
      "no-restricted-globals": ["error", "name", "length"],
      "prefer-arrow-callback": "error",
      "quotes": ["error", "double", { allowTemplateLiterals: true }],
    },
  },
];
