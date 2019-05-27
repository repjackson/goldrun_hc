if Meteor.isClient
    Template.meal_widget.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.meals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'

    Template.meal_doc.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.meal_doc

    Template.meal_widget.events
        'click .set_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
    Template.meal_widget.helpers
        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1



    Template.meals.helpers
        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1


    Template.meal_reviews.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'review'
    Template.meal_reviews.helpers
        can_leave_review: ->
            console.log @
        reviews: ->
            Docs.find
                model: 'review'
                parent_id:Router.current().params.doc_id




    # Template.model_scroller.onCreated ->
    #     @skip = new ReactiveVar 0
    #     @autorun => Meteor.subscribe 'model_docs_with_skip', @data.model, @skip.get()
    # Template.model_scroller.helpers
    #     user_results: -> Template.instance().user_results.get()
    #     current_doc: ->
    #         # console.log @model
    #         Docs.findOne {
    #             model:@model
    #         }, skip: Template.instance().skip.get()
    #         # }
    #     model_doc_template: ->
    #         # console.log "#{@model}_doc_view"
    #         "#{@model}_doc_view"
    #
    #     can_go_left: ->
    #         Template.instance().skip.get() > 0
    #     can_go_right: ->
    #         count = Docs.find(model:@model).count()
    #         # console.log count
    #         Template.instance().skip.get() < count-1
    #
    #
    # Template.model_scroller.events
    #     'click .go_to_model': ->
    #         # console.log @
    #         Session.set 'loading', true
    #         Meteor.call 'set_facets', @model, ->
    #             Session.set 'loading', false
    #         # Router.go "/m/#{@model}"
    #     'click .go_left': ->
    #         current_skip = Template.instance().skip.get()
    #         unless current_skip is 0
    #             Template.instance().skip.set(current_skip-1)
    #     'click .go_right': ->
    #         current_skip = Template.instance().skip.get()
    #         Template.instance().skip.set(current_skip+1)





# if Meteor.isServer
    # Meteor.publish 'model_docs_with_skip', (model, skip)->
    #     # console.log model
    #     # console.log skip
    #     Docs.find {
    #         model:model
    #     }
