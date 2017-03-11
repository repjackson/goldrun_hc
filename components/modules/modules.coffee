@Modules = new Meteor.Collection 'modules'


FlowRouter.route '/modules', action: (params) ->
    BlazeLayout.render 'layout',
        # cloud: 'cloud'
        main: 'modules'

if Meteor.isClient
    Template.modules.onCreated -> 
        @autorun -> Meteor.subscribe('modules')

    Template.modules.helpers
        modules: -> 
            Modules.find { },
                sort: number: 1
    

    

    Template.view.events
    
        'click .edit': -> FlowRouter.go("/edit/#{@_id}")

    Template.modules.events
        'click #add_module': ->
            id = Modules.insert({})
            FlowRouter.go "/edit_module/#{id}"
    
    


if Meteor.isServer
    Modules.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    
    
    
    Meteor.publish 'modules', ()->
    
        self = @
        match = {}
        # selected_tags.push current_herd
        # match.tags = $all: selected_tags
        # if selected_tags.length > 0 then match.tags = $all: selected_tags

        

        Modules.find match
    
    Meteor.publish 'module', (id)->
        Modules.find id
    
