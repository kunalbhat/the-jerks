def create_users
  @users = [
    { username: '', initial: 'J', password: '' },
    { username: '', initial: 'E', password: '' },
    { username: '', initial: 'R', password: '' },
    { username: '', initial: 'K', password: '' },
    { username: '', initial: 'S', password: '' }
  ]

  @users.each do |user|
    @user = User.new(username: user[:username], initial: user[:initial], password: user[:password])
    @user.save
  end
end
