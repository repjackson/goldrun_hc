Templates.admin_enrollment_email = {
  path: 'admin_enrollment_email.html'
  # scss: 'scss/activity-email.scss'

  # Attached template helpers.
  helpers:
    preview: ->
      'This is the first preview line of the email'

    firstName: ->
      @user.name.split(' ')[0]

    teamMembers: ->
      @team.users.map (user) -> Meteor.users.findOne(user)

  # For previewing the email in your browser.
  route:
    path: '/activity/:user'
    data: ->
      user = Meteor.users.findOne(@params.user)
      team = Teams.findOne(_id: { $in: user.teams })

      return {
        user: user
        team: team
      }
}
