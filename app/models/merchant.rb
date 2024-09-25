class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :coupons
  has_many :customers, through: :invoices # Are we using this?

  validates_presence_of :name, presence: true

  def self.sort_and_filter(params)
    if params[:status] == "returned"
      merchants_with_returns
    elsif params[:sorted] == "age"
      sort
    else
      Merchant.all
    end
  end

  def self.sort
    Merchant.order(created_at: :desc)
  end

  def self.merchants_with_returns
    Merchant.joins(:invoices).where(invoices: { status: "returned" })
  end

  def item_count 
    self.items.count
  end

  def coupons_count
    self.coupons.count
  end

  def invoice_coupon_count
    self.invoices.where.not(coupon_id: nil).count
  end

  def self.filter_by_name(name)
    self.where("name ILIKE '%#{name}%'").order(:name).first
  end
end

