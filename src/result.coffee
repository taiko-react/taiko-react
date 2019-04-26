export default class Result
  constructor: (@selector, @options, @result) ->
    {
      result: {
        value = (if @options?.multiple then [] else {}),
        type
      }
    } = @result

    @value = value
    @type = type

  exists: ->
    if @options?.multiple
    then Boolean @value.length
    else Boolean (Object.keys @value).length
  
  length: ->
    if @exists()
      if @options?.multiple
      then @value.length
      else 1
    else 0