Router.route '/account', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_account'



Router.route '/account/settings', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'account_settings'
