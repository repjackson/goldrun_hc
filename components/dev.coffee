Router.route '/dev', -> @render 'dev'

if Meteor.isClient
    Template.dev.onCreated ->
        # @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'event'

    Template.dev.helpers
        events: ->
            Docs.find
                model:'event'
    Template.dev.events
        'click .lookup_email': ->
            email = $('.enter_email').val()
            console.log email
            Meteor.call 'find_user_by_email', email, (err,res)->
                alert res


if Meteor.isServer
    Meteor.methods
        find_user_by_email: (email)->
            console.log email
            result = Accounts.findUserByEmail(email)
            console.log result
            result
