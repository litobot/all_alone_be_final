class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: ["active", "inactive"] }
  validate :validate_discounts
  # Add custom validation for >= 5 coupons per merchant

  def limit_coupons_to_five
    if merchant.coupons.active > 5
      errors.add(:base, "A merchant may only have 5 active coupons at one!")
    end
  end

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

  # Must pass the merchant's id from CouponsController
  # How else is it going to know who's coupon we want?
  def self.sort_by_status(merchant_id, status)
    if status == "active"
      Coupon.where(merchant_id: merchant_id, status: :active)
    elsif status == "inactive"
      Coupon.where(merchant_id: merchant_id, status: :inactive)
    else
      Coupon.where(merchant_id: merchant_id)
    end
  end
end