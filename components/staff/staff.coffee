FlowRouter.route '/staff', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'staff_nav'
        main: 'staff'
