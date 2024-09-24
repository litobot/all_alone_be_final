require 'rails_helper'

# Because coupons can have EITHER a percent_off or a dollar_off amount, but not BOTH, will I need a way to test this here?

RSpec.describe Coupon, type: :model do
  let(:merchant) { Merchant.create(name: "Lito's Store") }

  let(:coupon) { Coupon.create(name: "Name", code: "BOGO20", percent_off: 20.00, status: "active", merchant: merchant)}

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
    it { should validate_inclusion_of(:status).in_array(["active", "inactive"]) }
    # it { should validate_presence_of(:percent_off) }
    # it { should validate_numericality_of(:percent_off).is_greater_than(0).is_less_than_or_equal_to(100) }

    # Must use .new for custom validations to avoid raising errors upon failure
    context "must apply at least one discount" do
      it "is valid with a percent_off discount" do
        coupon = Coupon.new(name: "Buy One Get One 30% Off", code: "BOGO30", percent_off: 30.00, status: "active", merchant: merchant)
        expect(coupon).to be_valid
      end

      it "is valid with a dollar_off discount" do
        coupon = Coupon.new(name: "$50 Off", code: "50-OFF", dollar_off: 50.00, status: "active", merchant: merchant)
        expect(coupon).to be_valid
      end

      ### Make Notes
      it "is not valid if neither discounts present" do
        coupon = Coupon.new(name: "No Soup For You", code: "NOSOUP", status: "active", merchant: merchant)
        expect(coupon).to_not be_valid
      end
    end
  end
end