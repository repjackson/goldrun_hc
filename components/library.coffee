if Meteor.isClient
    Template.library.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'library_item'
    Template.library.helpers
        library_items: ->
            Docs.find
                model:'library_item'


    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'event'
    Template.events.helpers
        event_items: ->
            Docs.find
                model:'event'
