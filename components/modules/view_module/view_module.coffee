FlowRouter.route '/view_module/:module_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_module'


if Meteor.isClient
    Template.view_module.onCreated ->
        self = @
        self.autorun ->
            self.subscribe 'module', FlowRouter.getParam('module_id')
    
    
    Template.view_module.helpers
        module: ->
            Modules.findOne FlowRouter.getParam('module_id')
    
    
    
    Template.view_module.events
        'click #mark_as_complete': ->
            Modules.update FlowRouter.getParam('module_id'),
                $set: complete: true
            
        'click #mark_as_incomplete': ->
            Modules.update FlowRouter.getParam('module_id'),
                $set: complete: false
    
        'click .edit': ->
            module_id = FlowRouter.getParam('module_id')
            FlowRouter.go "/edit/#{module_id}"


