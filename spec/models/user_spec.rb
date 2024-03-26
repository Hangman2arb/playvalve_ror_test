require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'is invalid without an idfa' do
    user = build(:user, idfa: nil)
    expect(user).not_to be_valid
  end
end
