# if Meteor.isClient
#     Template.gamma.onCreated ->
#         @autorun -> Meteor.subscribe 'my_gamma'
#
#
#     Template.gamma.helpers
#         selected_tags: -> selected_tags.list()
#
#         current_gamma: ->
#             Docs.findOne
#                 model:'gamma'
#                 # _author_id:Meteor.userId()
#
#         global_tags: ->
#             doc_count = Docs.find().count()
#             if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()
#
#         single_doc: ->
#             gamma = Docs.findOne model:'gamma'
#             count = gamma.result_ids.length
#             if count is 1 then true else false
#
#
#
#
#     Template.gamma.events
#         'click .create_gamma': (e,t)->
#             new_gamma_id = Docs.insert
#                 model:'gamma'
#             Meteor.call 'fa', new_gamma_id, (err,res)->
#
#
#         'click .print_gamma': (e,t)->
#             gamma = Docs.findOne model:'gamma'
#             console.log gamma
#
#         'click .reset': ->
#             gamma = Docs.findOne model:'gamma'
#             Meteor.call 'fa', gamma._id, (err,res)->
#
#         'click .delete_gamma': (e,t)->
#             gamma = Docs.findOne model:'gamma'
#             if gamma
#                 if confirm "delete  #{gamma._id}?"
#                     Docs.remove gamma._id
#
#
#
#         'click .select_tag': -> selected_tags.push @name
#         'click .unselect_tag': -> selected_tags.remove @valueOf()
#         'click #clear_tags': -> selected_tags.clear()
#
#         'keyup #search': (e)->
#             switch e.which
#                 when 13
#                     if e.target.value is 'clear'
#                         selected_tags.clear()
#                         $('#search').val('')
#                     else
#                         selected_tags.push e.target.value.toLowerCase().trim()
#                         $('#search').val('')
#                 when 8
#                     if e.target.value is ''
#                         selected_tags.pop()
#
#
#
#     Template.gamma_facet.onRendered ->
#         Meteor.setTimeout ->
#             $('.accordion').accordion()
#         , 1500
#
#     Template.gamma_facet.events
#         # 'click .ui.accordion': ->
#         #     $('.accordion').accordion()
#
#         'click .toggle_selection': ->
#             gamma = Docs.findOne model:'gamma'
#             facet = Template.currentData()
#
#             Session.set 'loading', true
#             if facet.filters and @name in facet.filters
#                 Meteor.call 'remove_gamma_facet_filter', gamma._id, facet.key, @name, ->
#                     Session.set 'loading', false
#             else
#                 Meteor.call 'add_gamma_facet_filter', gamma._id, facet.key, @name, ->
#                     Session.set 'loading', false
#
#         'keyup .add_filter': (e,t)->
#             if e.which is 13
#                 gamma = Docs.findOne model:'gamma'
#                 facet = Template.currentData()
#                 filter = t.$('.add_filter').val()
#                 Session.set 'loading', true
#                 Meteor.call 'add_gamma_facet_filter', gamma._id, facet.key, filter, ->
#                     Session.set 'loading', false
#                 t.$('.add_filter').val('')
#
#
#
#
#     Template.gamma_facet.helpers
#         filtering_res: ->
#             gamma = Docs.findOne model:'gamma'
#             filtering_res = []
#             if @key is '_keys'
#                 @res
#             else
#                 for filter in @res
#                     if filter.count < gamma.total
#                         filtering_res.push filter
#                     else if filter.name in @filters
#                         filtering_res.push filter
#                 filtering_res
#
#
#
#         toggle_value_class: ->
#             facet = Template.parentData()
#             gamma = Docs.findOne model:'gamma'
#             if Session.equals 'loading', true
#                  'disabled'
#             else if facet.filters.length > 0 and @name in facet.filters
#                 'teal'
#             else 'basic'
#
#     Template.gamma_result.onRendered ->
#         # Meteor.setTimeout ->
#         #     $('.progress').popup()
#         # , 2000
#     Template.gamma_result.onCreated ->
#         @autorun => Meteor.subscribe 'doc', @data._id
#         @autorun => Meteor.subscribe 'user_from_id', @data._id
#
#     Template.gamma_result.helpers
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
#     Template.gamma_result.events
#         'click .set_model': ->
#             Meteor.call 'set_gamma_facets', @slug, Meteor.userId()
#
#         'click .route_model': ->
#             Session.set 'loading', true
#             Meteor.call 'set_facets', @slug, ->
#                 Session.set 'loading', false
#             # gamma = Docs.findOne model:'gamma'
#             # Docs.update gamma._id,
#             #     $set:model_filter:@slug
#             #
#             # Meteor.call 'fum', gamma._id, (err,res)->
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
#     Meteor.publish 'my_gamma', ->
#         if Meteor.userId()
#             Docs.find
#                 _author_id:Meteor.userId()
#                 model:'gamma'
#         else
#             Docs.find
#                 _author_id:null
#                 model:'gamma'
