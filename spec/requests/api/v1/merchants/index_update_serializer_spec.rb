require 'rails_helper'

RSpec.describe "Merchant Index Serializer Update", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
    @merchant_2 = Merchant.create!(name: "Rocko's Rock Shop")
    @merchant_3 = Merchant.create!(name: "Taco's To Go")
    @merchant_4 = Merchant.create!(name: "Chum Lee's Thrift Shop")

    @coupon_1 = Coupon.create!(name: "Deactivate Me", code: "BALEEETED", percent_off: 10.00, status: "active", merchant: @merchant_1)
    @coupon_2 = Coupon.create!(name: "Activate Me", code: "LETSGO", percent_off: 10.00, status: "active", merchant: @merchant_2)
    @coupon_3 = Coupon.create!(name: "Coopins", code: "COOP", percent_off: 10.00, status: "active", merchant: @merchant_2)
    @coupon_4 = Coupon.create!(name: "Save-A-Lot", code: "SAVER", percent_off: 10.00, status: "active", merchant: @merchant_3)

    @customer_1 = Customer.create!(first_name: "Bill", last_name: "Brasky")

    @invoice_1 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_2 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_3 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_2, coupon: @coupon_2)
    @invoice_4 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_2, coupon: @coupon_3)
    @invoice_5 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_3, coupon: @coupon_4)
    @invoice_6 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_4, coupon: nil)

    get "/api/v1/merchants"

    merchant_responses = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(response).to be_successful
    expect(merchant_responses).to be_an(Array)

    # Find the merchant from the merchant_responses with the matching id
    # Assign to a variable
    # Verify each merchant's response contains the :coupons_count showing # coupons per merchant
    merchant_1_response = merchant_responses.find { |merchant| merchant[:id].to_i == @merchant_1.id }
    merchant_2_response = merchant_responses.find { |merchant| merchant[:id].to_i == @merchant_2.id }
    merchant_3_response = merchant_responses.find { |merchant| merchant[:id].to_i == @merchant_3.id }
    merchant_4_response = merchant_responses.find { |merchant| merchant[:id].to_i == @merchant_4.id }
  end

  describe "update Merchant Serializer for index action" do
    it "returns JSON with a coupons_count attribute showing # of coupons per merchant" do
      expect(merchant_1_response[:attributes][:coupons_count]).to eq(1)
      expect(merchant_2_response[:attributes][:coupons_count]).to eq(2)
      expect(merchant_3_response[:attributes][:coupons_count]).to eq(1)
      expect(merchant_4_response[:attributes][:coupons_count]).to eq(0)
    end

    it "returns JSON with an invoice_coupon_count showing # of invoices w/coupons per merchant" do
      expect(merchant_1_response[:attributes][:invoice_coupon_count]).to eq(2)
      expect(merchant_2_response[:attributes][:invoice_coupon_count]).to eq(2)
      expect(merchant_3_response[:attributes][:invoice_coupon_count]).to eq(1)
      expect(merchant_4_response[:attributes][:invoice_coupon_count]).to eq(0)
    end
  end
end