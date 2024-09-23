require 'rails_helper'

RSpec.describe Coupon, type: :model do
  let(:merchant) { Merchant.create(name: "Lito's Store") }

  let(:coupon) { Coupon.create(name: "Name", code: "BOGO20", percent_off: 20.00, status: "active", merchant_id: merchant.id)}

  it "validate uniqueness of coupon code" do 
    expect(coupon).to validate_uniqueness_of(:code) 
  end

  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:percent_off) }
    it { should validate_numericality_of(:percent_off).is_greater_than(0).is_less_than_or_equal_to(100) }
    it { should validate_inclusion_of(:status).in_array(["active", "inactive"]) }
  end
end