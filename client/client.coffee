@selected_tags = new ReactiveArray []


$.cloudinary.config
    cloud_name:"facet"

    
FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'

Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

    
Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()


Template.registerHelper 'when', () -> moment(@timestamp).fromNow()


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment
