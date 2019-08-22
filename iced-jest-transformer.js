const Iced = require("iced-coffee-script");

module.exports = {
  process: src => {
    return {
      code: Iced.compile(src)
    };
  }
};
