FlowRouter.route '/marketplace', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'marketplace'


@Items = new Meteor.Collection 'items'

Items.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    return


# Items.after.insert (userId, doc)->
#     console.log doc.tags
#     return

Items.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Items.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()




if Meteor.isClient
    Template.marketplace.onCreated -> 
        @autorun -> Meteor.subscribe('items')

    
    
    Template.marketplace.helpers
        items: ->
            Items.find()

        


    Template.marketplace.events
        'click #add_item': ->
            new_id = Items.insert {}
            FlowRouter.go "/item/edit/#{new_id}"    
    
    
        
        
if Meteor.isServer
    
    Items.allow
        insert: (userId, doc) -> doc.author_id is userId
        update: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
        
        

    
    
    
    
    Meteor.publish 'items', ->
        Items.find()
    
    