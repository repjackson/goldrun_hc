if Meteor.isClient
    Template.slider.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'slide'

    Template.slider.helpers
        slides: ->
            Docs.find
                model:'slide'
