class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: ["active", "inactive"] }
  
  # How can I validate numericality of these if using the custom validations?

  # validates :dollar_off, 
  # validates :percent_off, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validate :validate_discounts

  def times_used 
    self.invoices.count
  end

  ### Make Notes
  ### Will raise coupon-specific error informing user when one of these is missing
  def validate_discounts
    unless dollar_off.present? || percent_off.present?
      errors.add(:base, "Either dollar_off or percent_off must be present")
    end
  end
end