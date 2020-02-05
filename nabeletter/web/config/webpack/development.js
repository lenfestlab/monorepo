process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

let config = environment.toWebpackConfig()

// NOTE: enable localhost https
// https://webpack.js.org/configuration/dev-server/#devserverhttps
const fs = require("fs")
const path = require("path")
const key = fs.readFileSync(path.resolve(process.env.PATH_SSL_KEY))
const cert = fs.readFileSync(path.resolve(process.env.PATH_SSL_CERT))
const https = { key, cert }
config = {
  ...config,
  devServer: {
    ...config.devServer,
    https,
  },
}

module.exports = config
