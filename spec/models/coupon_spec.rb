require 'rails_helper'


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

    context "must apply at least one discount" do
      it "is valid with a percent_off discount" do
        coupon = Coupon.new(name: "Buy One Get One 30% Off", code: "BOGO30", percent_off: 30.00, status: "active", merchant: merchant)
        expect(coupon).to be_valid
      end

      it "is valid with a dollar_off discount" do
        coupon = Coupon.new(name: "$50 Off", code: "50-OFF", dollar_off: 50.00, status: "active", merchant: merchant)
        expect(coupon).to be_valid
      end

      it "is not valid if neither discounts present" do
        coupon = Coupon.new(name: "No Soup For You", code: "NOSOUP", status: "active", merchant: merchant)
        expect(coupon).to_not be_valid
      end
    end

    context "custom validation - #limit_coupons_to_five" do
      before(:each) do
        @merchant_1 = Merchant.create!(name: "Limit To 5")
        @coupon_1 = Coupon.create!(name: "1", code: "1", dollar_off: 1.00, status: "active", merchant: @merchant_1)
        @coupon_2 = Coupon.create!(name: "2", code: "2", dollar_off: 2.00, status: "active", merchant: @merchant_1)
        @coupon_3 = Coupon.create!(name: "3", code: "3", dollar_off: 3.00, status: "active", merchant: @merchant_1)
        @coupon_4 = Coupon.create!(name: "4", code: "4", dollar_off: 4.00, status: "active", merchant: @merchant_1)
        @coupon_5 = Coupon.create!(name: "5", code: "5", dollar_off: 5.00, status: "active", merchant: @merchant_1)
      end

      it "disallows more than 5 active coupons to be created" do
        expect { Coupon.create!(name: "6", code: "6", dollar_off: 6.00, status: "active", merchant: @merchant_1) }.to raise_error(ActiveRecord::RecordInvalid, /A merchant may only have 5 active coupons at one time!/)
      end
    end
  end

  describe "class methods" do
    before(:each) do
      @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
      @customer_1 = Customer.create!(first_name: "Bill", last_name: "Brasky")
      @coupon_1 = Coupon.create!(name: "Money Money Money", code: "CASH", percent_off: 10.00, status: "active", merchant: @merchant_1)
      @coupon_2 = Coupon.create!(name: "Negative Ghostrider", code: "FULL", percent_off: 25.00, status: "active", merchant: @merchant_1)
      @coupon_3 = Coupon.create!(name: "Nacho Pro'lem", code: "NACHO", dollar_off: 17.00, status: "inactive", merchant: @merchant_1)
      
      @invoice_1 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
      @invoice_2 = Invoice.create!(status: "packaged", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
      @invoice_3 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
      @invoice_4 = Invoice.create!(status: "returned", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_2)
      @invoice_5 = Invoice.create!(status: "packaged", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_2)
    end
    
    context "#times_used method" do
      it "returns # of times a coupon is used" do
        expect(@coupon_1.times_used).to eq(3)
        expect(@coupon_2.times_used).to eq(2)
      end
      
      it "returns 0 if the coupon is never used" do
        expect(@coupon_3.times_used).to eq(0)
      end
    end

    context "#sort_by_status" do
      it "returns only coupons with an 'active' status" do
        result = Coupon.sort_by_status(@merchant_1.id, "active")

        expect(result.count).to eq(2)
      end

      it "returns only coupons with an 'inactive' status" do
        result = Coupon.sort_by_status(@merchant_1.id, "inactive")

        expect(result.count).to eq(1)
      end

      it "returns ALL coupons if no status is sent via query params" do
        result = Coupon.sort_by_status(@merchant_1.id, nil)

        expect(result.count).to eq(3)
      end

      it "returns ALL coupons if query params are invalid" do
        result = Coupon.sort_by_status(@merchant_1, "XXXX")

        expect(result.count).to eq(3)
      end
    end
  end
end