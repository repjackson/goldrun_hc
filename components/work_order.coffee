Router.route '/work_orders', (->
    @render 'work_orders'
    ), name:'work_orders'
Router.route '/work_order/:doc_id/view', (->
    @render 'work_order_view'
    ), name:'work_order_view'
Router.route '/work_order/:doc_id/edit', (->
    @render 'work_order_edit'
    ), name:'work_order_edit'


if Meteor.isClient
    @selected_author_ids = new ReactiveArray []
    @selected_location_tags = new ReactiveArray []
    @selected_building_tags = new ReactiveArray []
    @selected_unit_tags = new ReactiveArray []
    @selected_timestamp_tags = new ReactiveArray []

    Template.work_orders.onCreated ->
        # @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work_order'
        @autorun => Meteor.subscribe 'model_docs', 'work_order_stats'
        @autorun => Meteor.subscribe 'facet',
            selected_theme_tags.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_building_tags.array()
            selected_unit_tags.array()
            selected_timestamp_tags.array()
            model = 'work_order'
            author_id = null
            # parent_id = FlowRouter.getParam('doc_id')
            tag_limit = null
            doc_limit = 10
            # view_private = Session.get 'view_private'

    Template.work_order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_orders.helpers
        wos_doc: ->
            Docs.findOne
                model:'work_order_stats'

        work_orders: ->
            Docs.find
                model:'work_order'
    Template.work_orders.events
        'click .add_work_order': ->
            new_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_id}/edit"




    Template.location_tags_facet.helpers
        location_tags: ->
            doc_count = Docs.find(model: Template.currentData().model).count()
            # if selected_location_tags.array().length
            if 0 < doc_count < 3
                Location_tags.find {
                    count: $lt: doc_count
                    }, limit:20
            else
                Location_tags.find({}, limit:20)
        selected_location_tags: -> selected_location_tags.array()
    Template.location_tags_facet.events
        'click .select_location_tag': -> selected_location_tags.push @name
        'click .unselect_location_tag': -> selected_location_tags.remove @valueOf()
        'click #clear_location_tags': -> selected_location_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_location_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_location_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_location_tags.pop()

        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_location_tags.push doc.name
            $('#search').val ''

    Template.username_facet.onCreated ->
        @autorun => Meteor.subscribe 'usernames'
    Template.username_facet.helpers
        author_tags: ->
            author_usernames = []
            for author_id in Author_ids.find().fetch()
                found_user = Meteor.users.findOne(author_id.text)
                # if found_user
                #     console.log Meteor.users.findOne(author_id.text).username
                author_usernames.push Meteor.users.findOne(author_id.text)
            author_usernames
        selected_author_ids: ->
            selected_author_usernames = []
            for selected_author_id in selected_author_ids.array()
                selected_author_usernames.push Meteor.users.findOne(selected_author_id).username
            selected_author_usernames
    Template.username_facet.events
        'click .select_author': ->
            selected_author = Meteor.users.findOne username: @username
            selected_author_ids.push selected_author._id
        'click .unselect_author': ->
            selected_author = Meteor.users.findOne username: @valueOf()
            selected_author_ids.remove selected_author._id
        'click #clear_authors': -> selected_author_ids.clear()













if Meteor.isServer
    Meteor.methods
        calc_work_order_stats: ->
            work_order_stat_doc = Docs.findOne(model:'work_order_stats')
            unless work_order_stat_doc
                new_id = Docs.insert
                    model:'work_order_stats'
                work_order_stat_doc = Docs.findOne(model:'work_order_stats')
            console.log work_order_stat_doc
            total_count = Docs.find(model:'work_order').count()
            complete_count = Docs.find(model:'work_order', complete:true).count()
            incomplete_count = Docs.find(model:'work_order', complete:$ne:true).count()
            Docs.update work_order_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
