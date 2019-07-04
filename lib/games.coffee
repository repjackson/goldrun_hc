if Meteor.isClient
    Template.game.onCreated ->
        @autorun -> Meteor.subscribe 'game', Router.current().params.game_slug


    Template.game.helpers
        current_game: ->
            console.log @


# if Meteor.isServer
