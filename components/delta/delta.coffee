if Meteor.isClient
    Template.delta.onCreated ->
        # @autorun -> Meteor.subscribe 'model', Router.current().params.type
        # @autorun -> Meteor.subscribe 'type', 'model'
        # @autorun -> Meteor.subscribe 'tags', selected_tags.array(), Router.current().params.type
        # @autorun -> Meteor.subscribe 'docs', selected_tags.array(), Router.current().params.type
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.type
        @autorun -> Meteor.subscribe 'model_bricks_from_slug', Router.current().params.type
        # @autorun -> Meteor.subscribe 'deltas', Router.current().params.type
        @autorun -> Meteor.subscribe 'my_delta'

    Template.delta.helpers
        selected_tags: -> selected_tags.list()

        current_delta: ->
            Docs.findOne
                type:'delta'
                _author_id:Meteor.userId()

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            delta = Docs.findOne type:'delta'
            count = delta.result_ids.length
            if count is 1 then true else false


    Template.delta.events
        'click .create_delta': (e,t)->
            Docs.insert
                type:'delta'

        'click .print_delta': (e,t)->
            delta = Docs.findOne type:'delta'
            console.log delta

        'click .reset': ->
            delta = Docs.findOne type:'delta'
            # console.log 'hi'
            Meteor.call 'fum', delta._id, (err,res)->

        'click .delete_delta': (e,t)->
            delta = Docs.findOne type:'delta'
            if delta
                if confirm "delete  #{delta._id}?"
                    Docs.remove delta._id

    Template.delta.events
        'click .add_type_doc': ->
            new_doc_id = Docs.insert
                type:Router.current().params.type
            Router.go "/m/#{Router.current().params.type}/#{new_doc_id}/edit"

        'click .create_delta': (e,t)->
            Docs.insert
                type:'delta'
                # left_column_size: 6
                # right_column_size: 10

        'click .print_delta': (e,t)->
            delta = Docs.findOne type:'delta'
            console.log delta

        'click .reset': ->
            delta = Docs.findOne type:'delta'
            Meteor.call 'fum', delta._id, (err,res)->

        'click .edit_model': ->
            model = Docs.findOne
                type:'model'
                slug: Router.current().params.type
            Router.go "/m/#{model.slug}/#{model._id}/edit"

        'click .delete_delta': (e,t)->
            delta = Docs.findOne type:'delta'
            if delta
                if confirm "delete  #{delta._id}?"
                    Docs.remove delta._id


        'click .page_up': (e,t)->
            delta = Docs.findOne type:'delta'
            Docs.update delta._id,
                $inc: current_page:1
            Session.set 'is_calculating', true
            Meteor.call 'fo', (err,res)->
                if err then console.log err
                else
                    Session.set 'is_calculating', false

        'click .page_down': (e,t)->
            delta = Docs.findOne type:'delta'
            Docs.update delta._id,
                $inc: current_page:-1
            Session.set 'is_calculating', true
            Meteor.call 'fo', (err,res)->
                if err then console.log err
                else
                    Session.set 'is_calculating', false

        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'keyup #search': (e)->
            switch e.which
                when 13
                    if e.target.value is 'clear'
                        selected_tags.clear()
                        $('#search').val('')
                    else
                        selected_tags.push e.target.value.toLowerCase().trim()
                        $('#search').val('')
                when 8
                    if e.target.value is ''
                        selected_tags.pop()


    Template.facet.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500

    Template.facet.events
        'click .ui.accordion': ->
            $('.accordion').accordion()

        'click .toggle_selection': ->
            delta = Docs.findOne type:'delta'
            facet = Template.currentData()
            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            if e.which is 13
                delta = Docs.findOne type:'delta'
                facet = Template.currentData()
                filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')




    Template.facet.helpers
        filtering_res: ->
            delta = Docs.findOne type:'delta'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < delta.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res



        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne type:'delta'
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'grey'
            else ''

    Template.delta_result.onRendered ->
        # Meteor.setTimeout ->
        #     $('.progress').popup()
        # , 2000



    Template.delta_result.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id

    Template.delta_result.helpers
        result: ->
            if Docs.findOne @_id
                Docs.findOne @_id
            else if Meteor.users.findOne @_id
                Meteor.users.findOne @_id

    Template.delta_result.events
        'click .set_model': ->
            Meteor.call 'set_delta_facets', @slug, Meteor.userId()



if Meteor.isServer
    Meteor.publish 'model_from_slug', (tribe_slug, model_slug)->
        if model_slug in ['model','brick','field','tribe','block','page']
            Docs.find
                type:'model'
                slug:model_slug
        else
            match = {}
            # if tribe_slug then match.slug = tribe_slug
            match.type = 'model'
            match.slug = model_slug

            Docs.find match

    Meteor.publish 'model_from_doc_id', (tribe_slug, model, id)->
        doc = Docs.findOne id
        # console.log 'pub', tribe_slug, model, id
        if model in ['model','tribe','page','block','brick']
            Docs.find
                type:'model'
                slug:doc.type
                # tribe:tribe_slug
        else
            match = {}
            # if tribe_slug then match.slug = tribe_slug
            match.type = 'model'
            match.slug = doc.type

            Docs.find match


    Meteor.publish 'model_bricks_from_slug', (type, tribe_slug)->
        console.log tribe_slug
        # console.log type

        # else if type in ['field', 'brick','tribe','page','block','model']
        model = Docs.findOne
            type:'model'
            slug:type
            # tribe:tribe_slug
        # else
        #     model = Docs.findOne
        #         type:'model'
        #         slug:type
        #         tribe:tribe_slug

        Docs.find
            type:'brick'
            parent_id:model._id
