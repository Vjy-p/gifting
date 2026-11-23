module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2022,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
    "max-len": [
      "warn",
      {
        code: 120,
        ignoreComments: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
      },
    ],
    "object-curly-spacing": ["error", "always"],
    "camelcase": "off",
    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    "no-empty": ["error", { allowEmptyCatch: true }],
    "comma-dangle": ["error", "always-multiline"],
    "indent": ["error", 2, { SwitchCase: 1 }],
  },
  overrides: [
    {
      files: ["**/*.spec.*", "**/test/**"],
      env: {
        mocha: true,
        node: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
