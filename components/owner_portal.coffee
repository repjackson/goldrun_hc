if Meteor.isClient
    Router.route '/owner_portal', -> @render 'owner_portal'

    Template.documents_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'document'
    Template.documents_small.helpers
        documents: ->
            Docs.find {model:'document'},
                sort: _timestamp: -1
                limit:10

    Template.board_member_small.onCreated ->
        @autorun -> Meteor.subscribe 'users_by_role', 'board_member'
    Template.board_member_small.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']

    Template.minutes_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'minute'
    Template.minutes_small.helpers
        minutes: ->
            Docs.find
                model:'minute'


    Template.projects_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'project'
    Template.projects_small.helpers
        projects: ->
            Docs.find
                model:'project'


if Meteor.isServer
    Meteor.publish 'users_by_role', (role)->
        Meteor.users.find
            roles:$in:[role]
    #
    # Meteor.publish 'most_viewed_models', ->
    #     Docs.find {model:'model'},
    #         sort:views:-1
    #         limit:10
    #
    # Meteor.publish 'karma_leaderboard', ->
    #     Meteor.users.find {},
    #         sort:points:-1
    #         limit:10
