
FlowRouter.route '/admin/members', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'user_table'
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'
    
    
    Template.user_table.helpers
        users: -> Meteor.users.find {}
            
        user_is_admin: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'admin')
    
        user_is_member: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'member')
    
    
    
    
    
    Template.user_table.events
        'click #add_user': ->
            
    
    
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
    
 
 