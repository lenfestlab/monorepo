// https://storybook.js.org/docs/configurations/custom-webpack-config/#using-your-existing-config
const { environment } = require("@rails/webpacker")

module.exports = {
  addons: ["@storybook/addon-viewport/register"],
  stories: ["../app/javascript/**/*.stories.ts"],
  webpackFinal: async (config) => {
    // enable config debugging:
    // $ yarn storybook --debug-webpack
    // https://storybook.js.org/docs/configurations/custom-webpack-config/#debug-the-default-webpack-config
    // console.dir(config, { depth: null })

    // https://storybook.js.org/docs/configurations/typescript-config/
    config.resolve.extensions.push(".ts", ".tsx")
    config.module.rules.push({
      test: /\.(ts|tsx)$/,
      use: [
        {
          loader: require.resolve("ts-loader"),
        },
      ],
    })
    config.module.rules.concat(environment.rules)

    return {
      ...config,
      module: { ...config.module },
    }
  },
}
