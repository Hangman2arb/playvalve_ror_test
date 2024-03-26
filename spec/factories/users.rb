FactoryBot.define do
  factory :user do
    idfa { SecureRandom.uuid }
    ban_status { [:unbanned, :banned].sample }
    created_at { Time.current }
    updated_at { created_at }
  end
end
