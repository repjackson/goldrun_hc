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
            if Session.get 'editing_id'
                Docs.find
                    _id: Session.get('editing_id')
            else
                Docs.find
                    type: 'key_checkout'
                
    
        checkout_cal: -> moment(@checkout_dt).calendar()
        checkin_cal: -> moment(@checkin_dt).calendar()
    
        is_editing: ->
            Session.equals 'editing_id', @_id
    
    Template.view_key.events    
        'click #log_checkout': ->
            new_id = Docs.insert 
                building_code: @building_code
                apartment_number: @apartment_number
                checkout_dt: Date.now()
                type: 'key_checkout'
            Docs.update FlowRouter.getParam('doc_id'),
                $set: checked_out: true
            Session.set 'editing_id', new_id
    
        'click .edit_checkout': -> Session.set 'editing_id', @_id
        'click .stop_editing': -> Session.set 'editing_id', null
        
        'click #delete_key': ->
            if confirm 'Delete Key?'
                Docs.remove @_id
                Session.set 'editing_id', null
        'click .check_in_key': -> 
            Docs.update @_id,
                $set: checkin_dt: Date.now()
            Docs.update FlowRouter.getParam('doc_id'),
                $set: checked_out: false

        'blur #name': ->
            name = $('#name').val()
            Docs.update @_id,
                $set: name: name

    
        'blur #phone': ->
            phone = $('#phone').val()
            Docs.update @_id,
                $set: phone: phone

    
        'blur #company': ->
            company = $('#company').val()
            Docs.update @_id,
                $set: company: company

    
        'blur #notes': ->
            notes = $('#notes').val()
            Docs.update @_id,
                $set: notes: notes

    
    
    
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