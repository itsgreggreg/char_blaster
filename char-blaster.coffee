if Meteor.isClient
  Session.setDefault 'chars', '<>:;"\'(){}[]=+-'

  pick_new_char = ->
    chars = Session.get('chars')
    Session.set('current_char', chars[Math.floor(Math.random() * chars.length)])

  Template.char_blaster.helpers
    chars: -> Session.get('chars')
    current_char: -> Session.get('current_char')

  Template.char_blaster.events
    "keydown #attempt": (e)->
      $(e.target).removeClass "wrong"
      $(e.target).val ""

    "keyup #attempt": (e)->
      return unless e.key.length == 1
      if e.key is Session.get('current_char')
        pick_new_char()
      else
        $(e.target).addClass "wrong"
      e.preventDefault()

    "keyup #chars": (e)->
      Session.set 'chars', $(e.target).val()

  pick_new_char()


if Meteor.isServer
  Meteor.startup ->
    # // code to run on server at startup
