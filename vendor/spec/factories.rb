FactoryGirl.define do
  factory :user do
    name     "Michael Hartl"
    email    "michael@example.com"
    password "foobar"
    password_confirmation "foobar"
  end

  factory :place do
    name     "A Test Place"
    description    "A cool place to be"
    location 'POINT(-41.2889 174.7772)'
    altitude 1000
    createdBy
  end

end
