class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  # validates :dollar_off, 
  # validates :percent_off, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validate :validate_discounts
  validates :status, presence: true, inclusion: { in: ["active", "inactive"] }

  def times_used 
    self.invoices.count
  end

  def validate_discounts
    dollar_off.present? || percent_off.present?
  end
end