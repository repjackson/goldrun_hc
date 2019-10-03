if Meteor.isClient
    Router.route '/admin', -> @render 'admin'

    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawel'
    Template.admin.helpers
        withdrawels: ->
            Docs.find {
                model:'withdrawel'
            }, sort: _timestamp: -1



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id
