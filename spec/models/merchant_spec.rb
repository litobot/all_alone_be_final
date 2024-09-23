require 'rails_helper'

RSpec.describe Merchant, type: :model do

  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many :coupons }
    it { should have_many(:customers).through(:invoices) } # Again, not sure if I am using this and/or should remove it.
  end

  describe 'validations' do
    it { should validate_presence_of(:name)}
  end

  describe "Merchant Class Methods" do
    before(:each) do
      @merchant_1 = Merchant.create!(name: "Merchant A", created_at: 2.days.ago)
      @merchant_2 = Merchant.create!(name: "Merchant B", created_at: 1.day.ago)
      @merchant_3 = Merchant.create!(name: "Merchant C", created_at: Time.now)

      @customer_1 = Customer.create!(first_name: "Johnny", last_name: "Carson")

      @coupon_1 = Coupon.create!(name: "Buy One Get One", code: "BOGO20", percent_off: 20.0, status: "active", merchant_id: @merchant_1.id)

      @invoice_1 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant_id: @merchant_1.id, coupon: @coupon_1)
      @invoice_2 = Invoice.create!(status: "returned", customer_id: @customer_1.id, merchant_id: @merchant_2.id, coupon: @coupon_1)
      @invoice_3 = Invoice.create!(status: "returned", customer_id: @customer_1.id, merchant_id: @merchant_3.id, coupon: @coupon_1)
    end

    it "retrieves all merchants" do
      expected = [@merchant_1, @merchant_2, @merchant_3]

      result = Merchant.sort_and_filter({})  

      expect(result).to eq(expected)
    end

    it "retrieves merchants sorted by creation date (newest first)" do
      expected = [@merchant_3, @merchant_2, @merchant_1]
      result = Merchant.sort_and_filter({sorted: "age"})
      expect(result).to eq(expected)
    end

    it "retrieves merchants whose invoices have a status of 'returned'" do
      expected = [@merchant_2, @merchant_3]
      result = Merchant.sort_and_filter({status: "returned"})
      expect(result).to eq(expected)
    end

    context "filter_by_name" do
      it "returns the 1st item in A-Z order with a case insensitive search" do
        result = Merchant.filter_by_name("meRcHa")
        expect(result.id).to eq(@merchant_1.id)
      end
      
      it "returns nil when no merchants match query in part or whole" do
        result = Merchant.filter_by_name("xxx")
        expect(result).to be_nil
      end
    end
  end

  describe "instance methods" do
    before :each do
      @merchant = Merchant.create!(name: "Merchant A")
      @item_1 = @merchant.items.create!(name: "Item 1", description: "Things", unit_price: 10)
      @item_2 = @merchant.items.create!(name: "Item 2", description: "Other Things", unit_price: 15)
    end

    it "#item_count returns the correct number of items" do
      expect(@merchant.item_count).to eq(2)
      
      @item_3 = @merchant.items.create!(name: "Item 3", description: "More Things 3", unit_price: 20)
      expect(@merchant.item_count).to eq(3)
    end
  end
end