if Meteor.isClient
    Router.route '/admin', -> @render 'admin'

    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'model_docs', 'payment'
    Template.admin.helpers
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
            }, sort: _timestamp: -1

        payments: ->
            Docs.find {
                model:'payment'
            }, sort: _timestamp: -1



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id
