
FlowRouter.route '/admin/members', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'user_table'
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        self = @
        self.autorun ->
            self.subscribe 'tori_members'
    
    
    Template.user_table.helpers
        tori_members: -> 
            Meteor.users.find {}
            
        user_is_admin: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'admin')
    
        user_is_member: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'member')
    
    
    
    
    
    Template.user_table.events
        'click .remove_admin': ->
            self = @
            swal {
                title: "Remove #{@emails[0].address} from Admins?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'admin'
                swal "Removed Admin Privilages from #{self.emails[0].address}", "",'success'
                return
    
    
        'click .make_admin': ->
            self = @
            swal {
                title: "Make #{@emails[0].address} an Admin?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make Admin'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'admin'
                swal "Made #{self.emails[0].address} an Admin", "",'success'
                return
    
        'click .remove_member': ->
            self = @
            swal {
                title: "Remove #{@emails[0].address} from members?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Member Status'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'member'
                swal "Removed member privilages from #{self.emails[0].address}", "",'success'
                return
    
    
        'click .make_member': ->
            self = @
            swal {
                title: "Make #{@emails[0].address} a member?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make Member'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'member'
                swal "Made #{self.emails[0].address} an member", "",'success'
                return
    
    
    
 
 
        
if Meteor.isServer
    Meteor.publish 'tori_members', ->
        match = {}
        match.site = 'tori'
        Meteor.users.find match
         
    Accounts.onCreateUser (options, user) ->
        user.site = 'tori'
        console.log user
        user
