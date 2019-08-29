const Iced = require("iced-coffee-script");

module.exports = {
  process: src => ({
    code: Iced.compile(src)
  })
};
