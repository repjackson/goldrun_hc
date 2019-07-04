if Meteor.isClient
    Template.game.onCreated ->
        @autorun -> Meteor.subscribe 'game', Router.current().params.game_slug
    Template.game.helpers
        current_game: ->
            console.log @
            Docs.findOne
                model:'game'
                slug:Router.current().params.game_slug



    Template.picker.onCreated ->
        @autorun -> Meteor.subscribe 'unvoted_product'
    Template.picker.helpers
        current_product: ->
            console.log @
            Docs.findOne
                model:'shop'
                upvoter_ids:$nin:[Meteor.userId()]
                downvoter_ids:$nin:[Meteor.userId()]


if Meteor.isServer
    Meteor.publish 'game', (game_slug)->
        Docs.find
            model:'game'
            slug:game_slug

    Meteor.publish 'unvoted_product', ()->
        Docs.find
            model:'shop'
            upvoter_ids:$nin:[Meteor.userId()]
            downvoter_ids:$nin:[Meteor.userId()]
