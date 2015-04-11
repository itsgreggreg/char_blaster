if Meteor.isClient
  # Global Variables
  Session.setDefault 'chars', '<>:;"\'(){}[]=+-'
  Session.setDefault 'current_char', ""
  Session.setDefault 'score', 0
  Session.setDefault 'time', 0
  timeout = null

  # Template helpers
  Template.char_blaster.helpers
    chars:        -> Session.get('chars')
    current_char: -> Session.get('current_char')
    score:        -> Session.get('score')
    time:         -> Session.get('time')
    running:      -> "running" if Session.get('time') > 0

  # User input events
  Template.char_blaster.events
    "keydown #attempt": (e)->
      $(e.target).removeClass "wrong"
      $(e.target).val ""

    "keyup #attempt": (e)->
      return unless e.key.length == 1
      if e.key is Session.get('current_char')
        Session.set('score', Session.get('score') + 1)
        Session.set('time', Session.get('time') + 1)
        pick_new_char()
      else
        Session.set('time', Session.get('time') - 1)
        $(e.target).addClass "wrong"
      e.preventDefault()

    "keyup #chars": (e)->
      Session.set 'chars', $(e.target).val()

    "click #start": (e) ->
      start_game()

  # Picks a random character
  pick_new_char = ->
    chars = Session.get('chars')
    Session.set 'current_char',
      chars[Math.floor(Math.random() * chars.length)]

  # Starts a new game
  start_game = ->
    Session.set('score', 0)
    Session.set('time', 10)
    $("#attempt").focus()
    start_timer()
    pick_new_char()


  start_timer = ->
    timeout = window.setTimeout((->
      Session.set('time', Session.get('time') - 1)
      start_timer()
    ), 1000)

  Tracker.autorun ->
    if Session.get('time') <= 0
      window.clearTimeout(timeout)


if Meteor.isServer
  Meteor.startup ->
    # // code to run on server at startup
