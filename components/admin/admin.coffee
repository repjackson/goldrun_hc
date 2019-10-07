if Meteor.isClient
    Router.route '/admin', -> @render 'admin'

    Template.global_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'global_stats'

    Template.global_stats.events
        'click .refresh_global_stats': ->
            Meteor.call 'refresh_global_stats', ->

    Template.global_stats.helpers
        global_stats: ->
            Docs.findOne {
                model:'global_stats'
            }, sort: _timestamp: -1





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



        refresh_global_stats: ->
            global_stat_doc = Docs.findOne(model:'global_stats')
            unless global_stat_doc
                new_id = Docs.insert
                    model:'global_stats'
                global_stat_doc = Docs.findOne(model:'global_stats')
            console.log global_stat_doc
            total_count = Docs.find().count()
            complete_count = Docs.find(model:'global', complete:true).count()
            incomplete_count = Docs.find(model:'global', complete:$ne:true).count()
            Docs.update global_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
