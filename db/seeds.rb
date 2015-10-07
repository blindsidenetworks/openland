# Default admin user

user = User.new
user.email = 'admin@nomail.com'
user.password = 'adminadmin'
user.password_confirmation = 'adminadmin'
user.username = 'admin'
user.roles_mask = 1
user.first_name = 'Admin'
user.last_name = 'User'
user.save!