require 'rails_helper'


RSpec.describe "Coupons Index Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Lito")
    @merchant_2 = Merchant.create!(name: "Hercules")
    @coupon_1 = Coupon.create!(name: "Super Secret Discount", code: "BOGO20", percent_off: 20.00, status: "active", merchant: @merchant_1)
    @coupon_2 = Coupon.create!(name: "Nunya Biznass", code: "10-OFF", dollar_off: 10.00, status: "active", merchant: @merchant_1)
    @coupon_3 = Coupon.create!(name: "Vote For Pedro", code: "BOGO50", percent_off: 50.00, status: "active", merchant: @merchant_1)
    @customer_1 = Customer.create!(first_name: "Not", last_name: "Sure")
    @invoice_1 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_2 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_2)
    @invoice_3 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_3)

    
    get "/api/v1/merchants/#{@merchant_1.id}/coupons"
  end

  it "returns all coupons for a specific merchant" do
    expect(response).to be_successful
    coupons = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(coupons.count).to eq(3)

    coupons.each do |coupon|
      expect(coupon).to have_key(:id)
      expect(coupon[:id]).to be_a(String)

      expect(coupon).to have_key(:type)
      expect(coupon[:type]).to eq("coupon")

      attributes = coupon[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)

      expect(attributes).to have_key(:code)
      expect(attributes[:code]).to be_a(String)

      expect(attributes).to have_key(:percent_off).or have_key(:dollar_off)
    end
  end

  describe "sad paths" do
    it "returns a 404 error if the merchant does not exist" do
      get "/api/v1/merchants/9999/coupons"
  
      expect(response).to have_http_status(404)
      error_message = JSON.parse(response.body, symbolize_names: true)
  
      expect(error_message).to have_key(:error)
      expect(error_message[:error]).to eq("Merchant not found")
    end
  
    it "returns an empty array when merchant has no coupons" do
      get "/api/v1/merchants/#{@merchant_2.id}/coupons"
  
      expect(response).to be_successful
      coupons = JSON.parse(response.body, symbolize_names: true)[:data]
  
      expect(coupons).to eq([])
    end
  end
end