class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :percent_off, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :status, presence: true, inclusion: { in: ["active", "inactive"] }
end