if Meteor.isClient
    Template.omega_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', @data.model
    Template.omega_edit.helpers
        model_docs: ->
            Docs.find
                model:@model
        omega_selection_doc: ->
            page_doc = Docs.findOne Router.current().params.doc_id
            page_model_value = page_doc["#{@model}"]
            # console.log page_model_value
            Docs.findOne
                model:@model
                slug:page_doc["#{@model}"]
            # page_model_value
        child_selector_class: ->
            page_doc = Docs.findOne Router.current().params.doc_id
            page_model_value = page_doc["#{@model}"]
            # console.log 'child selector class', page_model_value
            if page_doc["#{@model}"] is @slug then 'active' else ''
    Template.omega_edit.events
        'click .select_child': ->
            # console.log @
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update page_doc._id,
                $set: "#{@model}":"#{@slug}"
            # location.reload()
        'click .edit_selection_doc': ->
            page_doc = Docs.findOne Router.current().params.doc_id
            page_model_value = page_doc["#{@model}"]
            # console.log page_model_value
            selection_doc = Docs.findOne
                model:@model
                slug:page_doc["#{@model}"]

            Router.go "/omega_doc_edit/#{selection_doc._id}"






    Template.subomega_edit.onCreated ->
        console.log @data.submodel
        @autorun => Meteor.subscribe 'model_docs', @data.submodel
    Template.subomega_edit.helpers
        submodel_docs: ->
            # console.log "#{@submodel}_type"
            Docs.find
                model:"#{@submodel}"
        parent_model: ->
            page_doc = Docs.findOne Router.current().params.doc_id
            # console.log page_doc["#{Template.parentData().model}"]
            model_doc = Docs.findOne
                model:Template.parentData().model
                slug:page_doc["#{Template.parentData().model}"]
            model_doc

        # submodel: ->
        #     console.log @
            # @submodel
            # page_doc = Docs.findOne Router.current().params.doc_id
            # page_model_value = page_doc["#{@model}"]
            # # console.log page_model_value
            # page_model_value
        child_selector_class: ->
            page_doc = Docs.findOne Router.current().params.doc_id
            page_model_value = page_doc["#{@model}"]
            # console.log 'child selector class', page_model_value
            if page_doc["#{@model}"] is @slug then 'active' else ''
    Template.subomega_edit.events
        'click .add_new_submodel_doc': ->
            # console.log @
            page_doc = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:@submodel
            Router.go "/omega_doc_edit/#{new_id}"
        'click .edit_parent_model_doc': ->
            page_doc = Docs.findOne Router.current().params.doc_id
            console.log page_doc["#{Template.parentData().model}"]
            model_doc = Docs.findOne
                model:Template.parentData().model
                slug:page_doc["#{Template.parentData().model}"]
            console.log model_doc

            Router.go "/omega_doc_edit/#{model_doc._id}"


    Template.omega_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.omega.onCreated ->
        @autorun -> Meteor.subscribe 'my_omega'
        @autorun -> Meteor.subscribe 'model_docs','omega_session'
    Template.omega.helpers
        sessions: ->
            Docs.find
                model:'omega_session'
        current_omega: ->
            Docs.findOne
                _id: Session.get('current_omega_id')
                # _author_id:Meteor.userId()
        session_button_class: ->
            if Session.equals 'current_omega_id', @_id then 'black' else 'basic'
        single_doc: ->
            omega = Docs.findOne model:'omega'
            count = omega.result_ids.length
            if count is 1 then true else false

    Template.omega.events
        'keyup .omega_in': (e,t)->
            if e.which is 13
                # parent = Docs.findOne Router.current().params.doc_id
                query = t.$('.omega_in').val()
                # console.log comment
                new_omega_id = Docs.insert
                    model:'omega_session'
                    name:query
                    query:query
                Session.set 'new_omega_id'

        'click .delete_omega': (e,t)->
            omega = Docs.findOne model:'omega'
            if omega
                if confirm "delete  #{omega._id}?"
                    Docs.remove omega._id

        'click .select_omega': ->
            Session.set 'current_omega_id', @_id


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



#     Template.omega_facet.onRendered ->
#         Meteor.setTimeout ->
#             $('.accordion').accordion()
#         , 1500
#
#     Template.omega_facet.events
#         # 'click .ui.accordion': ->
#         #     $('.accordion').accordion()
#
#         'click .toggle_selection': ->
#             omega = Docs.findOne model:'omega'
#             facet = Template.currentData()
#
#             Session.set 'loading', true
#             if facet.filters and @name in facet.filters
#                 Meteor.call 'remove_omega_facet_filter', omega._id, facet.key, @name, ->
#                     Session.set 'loading', false
#             else
#                 Meteor.call 'add_omega_facet_filter', omega._id, facet.key, @name, ->
#                     Session.set 'loading', false
#
#         'keyup .add_filter': (e,t)->
#             if e.which is 13
#                 omega = Docs.findOne model:'omega'
#                 facet = Template.currentData()
#                 filter = t.$('.add_filter').val()
#                 Session.set 'loading', true
#                 Meteor.call 'add_omega_facet_filter', omega._id, facet.key, filter, ->
#                     Session.set 'loading', false
#                 t.$('.add_filter').val('')
#
#
#
#
#     Template.omega_facet.helpers
#         filtering_res: ->
#             omega = Docs.findOne model:'omega'
#             filtering_res = []
#             if @key is '_keys'
#                 @res
#             else
#                 for filter in @res
#                     if filter.count < omega.total
#                         filtering_res.push filter
#                     else if filter.name in @filters
#                         filtering_res.push filter
#                 filtering_res
#
#
#
#         toggle_value_class: ->
#             facet = Template.parentData()
#             omega = Docs.findOne model:'omega'
#             if Session.equals 'loading', true
#                  'disabled'
#             else if facet.filters.length > 0 and @name in facet.filters
#                 'grey'
#             else ''
#
#     Template.omega_result.onRendered ->
#         # Meteor.setTimeout ->
#         #     $('.progress').popup()
#         # , 2000
#     Template.omega_result.onCreated ->
#         @autorun => Meteor.subscribe 'doc', @data._id
#         @autorun => Meteor.subscribe 'user_from_id', @data._id
#
#     Template.omega_result.helpers
#         result: ->
#             if Docs.findOne @_id
#                 result = Docs.findOne @_id
#                 if result.private is true
#                     if result._author_id is Meteor.userId()
#                         result
#                 else
#                     result
#             else if Meteor.users.findOne @_id
#                 Meteor.users.findOne @_id
#
#     Template.omega_result.events
#         'click .set_model': ->
#             Meteor.call 'set_omega_facets', @slug, Meteor.userId()
#
#         'click .route_model': ->
#             Session.set 'loading', true
#             Meteor.call 'set_facets', @slug, ->
#                 Session.set 'loading', false
#             # omega = Docs.findOne model:'omega'
#             # Docs.update omega._id,
#             #     $set:model_filter:@slug
#             #
#             # Meteor.call 'fum', omega._id, (err,res)->
#     Template.key_view.helpers
#         key: -> @valueOf()
#
#         meta: ->
#             key_string = @valueOf()
#             parent = Template.parentData()
#             parent["_#{key_string}"]
#
#         context: ->
#             # console.log @
#             {key:@valueOf()}
#
#
#         field_view: ->
#             # console.log @
#             key_string = @valueOf()
#             meta = Template.parentData(2)["_#{@key}"]
#             # console.log meta
#             # console.log "#{meta.field}_view"
#             "#{meta.field}_view"
#
#         data: ->
#             {direct:true}
#
# if Meteor.isServer
#     Meteor.publish 'my_omega', ->
#         if Meteor.userId()
#             Docs.find
#                 _author_id:Meteor.userId()
#                 model:'omega'
#         else
#             Docs.find
#                 _author_id:null
#                 model:'omega'
