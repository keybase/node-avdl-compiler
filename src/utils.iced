is_primitive = (type) ->
  # Assume that lowercase first letter means primitive switch type
  if typeof type isnt 'string'
    return true
  first_char = type.charAt 0
  first_char is first_char.toLowerCase() and first_char isnt first_char.toUpperCase()

module.exports = { is_primitive }
