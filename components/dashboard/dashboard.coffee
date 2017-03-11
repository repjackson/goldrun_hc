FlowRouter.route '/dashboard', action: (params) ->
    BlazeLayout.render 'layout',
        # sub_nav: 'account_nav'
        main: 'dashboard'
        
if Meteor.isClient
    Template.dashboard.onCreated ->
        @autorun => Meteor.subscribe 'me'
        
        
    Template.dashboard.events
    

    Template.dashboard.helpers
