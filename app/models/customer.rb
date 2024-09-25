class Customer < ApplicationRecord
  has_many :invoices
  has_many :merchants, through: :invoices

  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.for_merchant(merchant_id)
    joins(:invoices).where(invoices: { merchant_id: merchant_id }).distinct
  end
end