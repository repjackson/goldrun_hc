if Meteor.isClient
    Router.route '/frontdesk', -> @render 'frontdesk'
    Router.route '/frontdesk/edit/:doc_id', -> @render 'edit_frontdesk'

    Template.frontdesk.onCreated ->
        @autorun -> Meteor.subscribe('frontdesk')

    Template.frontdesk.helpers
        frontdesk: ->
            Docs.find
                type: 'frontdesk'



    Template.frontdesk.events
        'click #add_impounded_frontdesk': ->
            id = Docs.insert
                type: 'frontdesk'
            Router.go "/frontdesk/edit/#{id}"




if Meteor.isServer
    Meteor.publish 'frontdesk', ()->

        self = @
        match = {}
        match.type = 'frontdesk'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true

        Docs.find match,
            limit: 10
            sort:
                timestamp: -1

    Meteor.publish 'frontdesk', (doc_id)->
        Docs.find doc_id
