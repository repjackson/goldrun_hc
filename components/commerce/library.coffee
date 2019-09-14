if Meteor.isClient
    Template.library.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'library_item'
    Template.library.helpers
        library_items: ->
            Docs.find
                model:'library_item'


    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'food_item'
    Template.food.helpers
        food_items: ->
            Docs.find
                model:'food_item'


    # Template.shop.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'shop_item'
    # Template.shop.helpers
    #     shop_items: ->
    #         Docs.find
    #             model:'shop_item'
    # Template.shop_item_page.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # Template.shop_item_page.helpers
    #     doc: ->
    #         Docs.findOne Router.current().params.doc_id
    #
    #
    #
    # Template.events.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'event'
    # Template.events.helpers
    #     event_items: ->
    #         Docs.find
    #             model:'event'
