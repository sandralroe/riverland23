var webpack = require("webpack"); // eslint-disable-line no-unused-vars
var path = require("path");

module.exports = [{
  context: __dirname,
  entry: {
    main: "./main.js"
  },
  mode: "production",
  output: {
    path: path.join(__dirname, "./dist"),
    publicPath: "./dist",
    filename: "[name].bundle.js",
  },
},{
  context: __dirname,
  entry: {
    "pdf.viewer": "./pdf.viewer.js",
    "pdf.worker": "pdfjs-dist/build/pdf.worker.entry",
  },
  mode: "production",
  output: {
    path: path.join(__dirname, "./dist"),
    publicPath: "./dist",
    filename: "[name].bundle.js",
  },
}];