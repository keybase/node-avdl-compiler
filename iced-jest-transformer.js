const Iced = require("iced-coffee-script");

module.exports = {
  process: src => {
    const compiledJS = Iced.compile(src);
    return {
      code: compiledJS
    };
  }
};
