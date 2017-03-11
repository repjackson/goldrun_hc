FlowRouter.route '/admin/contact_submissions', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'contact_submissions'
 
@Submissions = new Meteor.Collection 'submissions'


if Meteor.isClient
    Template.contact_submissions.onCreated ->
        @autorun -> Meteor.subscribe 'contact_submissions'
        
    Template.contact_submissions.helpers
        submissions: ->
            Submissions.find()
            
            
if Meteor.isServer
    Meteor.publish 'contact_submissions', ->
        Submissions.find()