if Meteor.isClient
    Router.route '/user/:username/view', -> @render 'view_profile'


    Template.view_profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_by_username', Router.current().params.username


    Template.view_profile.helpers
        user: ->
            Meteor.users.findOne
                username: Router.current().params.username

        # can_edit_profile: -> Meteor.userId() is Router.getParam('user_id') or Roles.userIsInRole(Meteor.userId(),'dev')

    Template.view_profile.events

if Meteor.isServer
    Meteor.publish 'user_by_username', (username)->
        Meteor.users.find
            username: username
