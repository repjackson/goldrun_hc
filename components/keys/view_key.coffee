if Meteor.isClient
    Template.view_key.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))
        @autorun -> Meteor.subscribe('key_checkouts', FlowRouter.getParam('doc_id'))
    
    Template.view_key.helpers
        key: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 
    
        checkouts: ->
            Docs.find
                type: 'key_checkout'
    
    Template.view_key.events    
        'click #log_checkout': ->
            Docs.insert 
                building_code: @building_code
                apartment_number: @apartment_number
                type: 'key_checkout'
    

    
if Meteor.isServer
    Meteor.publish 'key_checkouts', (doc_id)->
        
        key = Docs.findOne doc_id
        
        self = @
        match = {}
        match.type = 'key_checkout'
        match.building_code = key.building_code
        match.apartment_number = key.apartment_number
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match