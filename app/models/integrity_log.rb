class IntegrityLog < ApplicationRecord
  enum ban_status: { unbanned: 0, banned: 1 }

  validates :idfa, presence: true
  validates :ban_status, presence: true, inclusion: { in: %w[banned unbanned] }
  validates :ip, presence: true, format: { with: /\A(?:[0-9]{1,3}\.){3}[0-9]{1,3}\z/ }
  validates :rooted_device, inclusion: { in: [true, false] }
  validates :country, presence: true, length: { is: 2 }
end
