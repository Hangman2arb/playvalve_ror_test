require 'rails_helper'

RSpec.describe IntegrityLog, type: :model do
  it 'is valid with valid attributes' do
    log = build(:integrity_log)
    expect(log).to be_valid
  end

  it 'is invalid without an idfa' do
    log = build(:integrity_log, idfa: nil)
    expect(log).not_to be_valid
  end
end
