require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:merchant1) { Merchant.create(name: "Lito's Store") }
  let(:customer) { Customer.create(first_name: "John", last_name: "Doe") }
  
  # I might be able to remove this
  # This was an addition when I was lost in the mire of extra validations
  let(:coupon) { Coupon.create(name: "Buy One Get One", code: "BOGO20", percent_off: 20.0, status: "active", merchant_id: merchant1.id) }

  describe "relationships" do
    it { should belong_to :customer }
    it { should belong_to :merchant }
    it { should belong_to(:coupon).optional }
    it { should have_many(:invoice_items) }
    it { should have_many(:transactions) }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe 'validations' do
    it "is invalid without a status" do
      invoice = Invoice.new(customer: customer, merchant: merchant1, coupon: coupon, status: nil)
      expect(invoice).to_not be_valid
      expect(invoice.errors[:status]).to include("is not included in the list")
    end

    # Good sad path for a model test
    it "is invalid with an empty string as status" do
      invoice = Invoice.new(customer: customer, merchant: merchant1, coupon: coupon, status: "")
      expect(invoice).to_not be_valid
      expect(invoice.errors[:status]).to include("is not included in the list")
    end

    it { should validate_inclusion_of(:status).in_array(["shipped", "packaged", "returned"]) }
  end
end