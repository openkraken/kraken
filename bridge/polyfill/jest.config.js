module.exports = {
  "coverageDirectory": "<rootDir>/coverage",
  "moduleFileExtensions": [
    "ts",
    "tsx",
    "js",
    "jsx",
    "json"
  ],
  "testMatch": [
    "<rootDir>/test/**/__tests__/**/*.ts?(x)",
    "<rootDir>/test/**/?(*.)(spec|test).ts?(x)"
  ],
  "testEnvironment": "node",
  "testURL": "http://localhost",
  "transform": {
    "\\.tsx?$": "ts-jest"
  },
  "transformIgnorePatterns": [
    "[/\\\\]node_modules[/\\\\].+\\.(js|jsx|ts|tsx)$"
  ],
  "collectCoverageFrom": [
    "<rootDir>/packages/**/*.{tsx,ts}",
    "!<rootDir>/packages/**/*.d.{tsx,ts}"
  ]
};
