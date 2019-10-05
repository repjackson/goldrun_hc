if Meteor.isClient
    Router.route '/admin', -> @render 'admin'

    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'model_docs', 'payment'
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

    Template.call_method.events
        'click .call_method': ->
            Meteor.call @name



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id




if Meteor.isServer
    Meteor.methods
        calculate_model_doc_count: ->
            model_cursor = Docs.find(model:'model')
            console.log model_cursor.count()
            for model in model_cursor.fetch()
                model_docs_count =
                    Docs.find(
                        model:model.slug
                    ).count()
                console.log model.slug, model_docs_count
