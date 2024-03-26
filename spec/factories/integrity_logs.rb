FactoryBot.define do
  factory :integrity_log do
    idfa { SecureRandom.uuid }
    ban_status { [:unbanned, :banned].sample }
    ip { Faker::Internet.ip_v4_address }
    rooted_device { Faker::Boolean.boolean }
    country { Faker::Address.country_code }
    proxy { Faker::Boolean.boolean }
    vpn { Faker::Boolean.boolean }
    created_at { Time.now }
    updated_at { created_at }
  end
end
