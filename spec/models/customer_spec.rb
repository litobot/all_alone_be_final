require 'rails_helper'


RSpec.describe Customer, type: :model do
  describe "relationships" do
    it { should have_many(:invoices) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe "class methods" do
    before :each do
      @merchant_1 = Merchant.create!(name: "Merchant A")
      @merchant_2 = Merchant.create!(name: "Merchant B")
      @customer_1 = Customer.create!(first_name: "John", last_name: "Doe")
      @customer_2 = Customer.create!(first_name: "Jane", last_name: "Doe")

      @coupon_1 = Coupon.create!(name: "Buy One Get One", code: "BOGO20", percent_off: 20.0, status: "active", merchant_id: @merchant_1.id)

      @invoice_1 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant_id: @merchant_1.id, coupon: @coupon_1)
      @invoice_2 = Invoice.create!(status: "packaged", customer_id: @customer_1.id, merchant_id: @merchant_1.id, coupon: @coupon_1)
      @invoice_3 = Invoice.create!(status: "shipped", customer_id: @customer_2.id, merchant_id: @merchant_2.id, coupon: @coupon_1)
    end

    it ".for_merchant returns customers based on merchant_id" do
      result = Customer.for_merchant(@merchant_1.id)
      expect(result).to match_array([@customer_1])

      result_2 = Customer.for_merchant(@merchant_2.id)
      expect(result_2).to match_array([@customer_2])
    end
  end
end