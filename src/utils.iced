is_primitive = (type) ->
  # Assume that lowercase first letter means primitive switch type
  first_char = type.charAt 0
  first_char is first_char.toLowerCase() and first_char isnt first_char.toUpperCase()

module.exports = { is_primitive }
