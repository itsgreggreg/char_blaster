# Runs on both server and client
Scores = new Mongo.Collection("scores")


if Meteor.isClient
  window.scores = Scores
  chars_default = '<>:;"\'(){}[]=+-'
  time_default  = 30
  keypressed    = false
  timeout       = null
  game_chars    = []
  Session.setDefault 'chars', chars_default
  Session.setDefault 'current_char', ""
  Session.setDefault 'score', 0
  Session.setDefault 'misses', 0
  Session.setDefault 'start_time', time_default
  Session.setDefault 'time', 0
  Session.setDefault 'running', false
  Session.setDefault 'player_name' , ''

  # Template helpers
  Template.char_blaster.helpers
    chars:        -> Session.get('chars')
    current_char: -> Session.get('current_char')
    score:        -> Session.get('score')
    time:         -> Session.get('time')
    start_time:   -> Session.get('start_time')
    running:      -> {class: if Session.get('running') then "running" else ""}

  Template.score_board.helpers
    scores: -> Scores.find({date: {$gt: 1}}, {sort: {"date": -1}})

  # User input events
  Template.char_blaster.events
    "keydown #attempt": (e)->
      $(e.target).removeClass "wrong"
      $(e.target).val ""

    "keypress #attempt": (e)->
      keypressed = true

    "keyup #attempt": (e)->
      return unless Session.get('running')
      return unless keypressed
      val = $("#attempt").val()
      return unless val
      if val is Session.get('current_char')
        Session.set('score', Session.get('score') + 1)
        Session.set('time', Session.get('time') + 1)
        pick_new_char()
      else
        Session.set('misses', Session.get('misses') + 1)
        Session.set('time', Session.get('time') - 1)
        $(e.target).addClass "wrong"
      keypressed = false
      e.preventDefault()

    "keyup #chars": (e)->
      Session.set 'chars', $(e.target).val()

    "keyup #start_time": (e)->
      Session.set 'start_time', $(e.target).val()

    "click #start": (e) ->
      start_game()

  # Shuffles an array in place.
  shuffle = (arr)->
    randInt = (n) -> Math.floor(n * Math.random())
    for i in [0 .. arr.length - 1]
      index = randInt(arr.length)
      [arr[index], arr[i]] = [arr[i], arr[index]]

  # Picks a random character
  pick_new_char = ->
    # if were at the end of a shuffle
    if game_chars.length is 1
      # remember the char
      last_char = game_chars.pop()
    # if there are no chars left
    if game_chars.length is 0
      # generate a new shuffle
      game_chars = Session.get('chars').split("")
      shuffle(game_chars)
    # if we are remembering the last char, make sure it
    # doesn't match the first char of the new shuffle
    while last_char and last_char is game_chars[0]
      shuffle(game_chars)
    Session.set('current_char', game_chars.pop())

  # New Game
  start_game = ->
    Session.set('score', 0)
    Session.set('misses', 0)
    $("#start").hide()
    $("#current_char").show()
    $("#attempt").show().focus().removeClass("wrong").val("")
    countdown 3, ->
      Session.set('time', Session.get('start_time'))
      Session.set('running', true)
      start_timer()
      pick_new_char()

  countdown = (seconds, cb)->
    Session.set('current_char', seconds)
    window.setTimeout((->
     if Session.get('current_char') is 1 then cb()
     else countdown(seconds - 1, cb)
    ), 1000)

  start_timer = ->
    timeout = window.setTimeout((->
      Session.set('time', Session.get('time') - 1)
      start_timer()
    ), 1000)

  Tracker.autorun ->
    # When the time reaches zero, stop the game
    if Session.get('time') <= 0
      # Save score
      if Session.get('running') and
         Session.get('chars') is chars_default and
         Session.get('start_time') is time_default
        Scores.insert
          player_name: Session.get('player_name')
          score: Session.get('score')
          date: Date.now()

      window.clearTimeout(timeout)
      $("#current_char").hide()
      $("#attempt").hide()
      $("#start").show()
      Session.set('running', false)


  # get the user's name once the page loads
  $ ->
    player_name = ""
    until player_name
      player_name = prompt("What's your name?").trim()
    Session.set('player_name', player_name)



if Meteor.isServer
  Meteor.publish "all-scores", ->
    Scores.find({})
  # Meteor.startup ->
    # // code to run on server at startup
