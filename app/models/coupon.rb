class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: ["active", "inactive"] }
  validate :validate_discounts
  validate :limit_coupons_to_five

  def limit_coupons_to_five
    if merchant && status == 'active' && (new_record? || status_changed?)
      if merchant.coupons.where(status: 'active').count >= 5
        errors.add(:base, "A merchant may only have 5 active coupons at one time!")
      end
    end
  end

  def times_used 
    self.invoices.count
  end

  def validate_discounts
    unless dollar_off.present? || percent_off.present?
      errors.add(:base, "Either dollar_off or percent_off must be present")
    end
  end

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