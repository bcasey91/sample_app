Factory.define :user do |user|
  user.name            "Brendan"
  user.email           "Brendan@exam.net"
  user.password        "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end
