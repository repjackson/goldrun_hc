# if Meteor.isClient
#     Template.tasks.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'task_stats'
#         @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'task', 10
#
#     Template.task_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.task_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#
#     Template.tasks.helpers
#         task_stats_doc: ->
#             Docs.findOne
#                 model:'task_stats'
#         my_tasks: ->
#             Docs.find
#                 model:'task'
#
#     Template.tasks.events
#         'click .calculate_task_stats': ->
#             Meteor.call 'calculate_task_stats'
#
#         'click .add_task': ->
#             new_id = Docs.insert
#                 model:'task'
#             Router.go "/task/#{new_id}/edit"
#
#
#
# if Meteor.isServer
#     Meteor.methods
#         calculate_task_stats: ->
#             task_stat_doc = Docs.findOne(model:'task_stats')
#             unless task_stat_doc
#                 new_id = Docs.insert
#                     model:'task_stats'
#                 task_stat_doc = Docs.findOne(model:'task_stats')
#             console.log task_stat_doc
#             total_count = Docs.find(model:'task').count()
#             complete_count = Docs.find(model:'task', complete:true).count()
#             incomplete_count = Docs.find(model:'task', complete:false).count()
#             Docs.update task_stat_doc._id,
#                 $set:
#                     total_count:total_count
#                     complete_count:complete_count
#                     incomplete_count:incomplete_count
