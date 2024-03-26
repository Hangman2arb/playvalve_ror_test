class User < ApplicationRecord
  enum ban_status: { unbanned: 0, banned: 1 }

  validates :idfa, presence: true, uniqueness: true
  validates :ban_status, presence: true, inclusion: { in: %w[banned unbanned] }
end
