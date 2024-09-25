require 'rails_helper'


RSpec.describe "Coupons Show Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Lito")
    @coupon_1 = Coupon.create!(name: "Super Secret Discount", code: "BOGO20", percent_off: 20.00, status: "active", merchant: @merchant_1)
    @customer_1 = Customer.create!(first_name: "Not", last_name: "Sure")
    @invoice_1 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_2 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_1)
    
    
    get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{@coupon_1.id}"
  end

  it "returns with the proper JSON format including 200 status response code" do
    coupon = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(response).to be_successful
    expect(response).to have_http_status(200)
    
    expect(coupon).to be_a(Hash)

    expect(coupon).to have_key(:id)
    expect(coupon[:id]).to be_a(String)

    expect(coupon).to have_key(:type)
    expect(coupon[:type]).to eq("coupon")

    attributes = coupon[:attributes]

    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to eq(@coupon_1.name)

    expect(attributes).to have_key(:code)
    expect(attributes[:code]).to eq(@coupon_1.code)

    expect(attributes).to have_key(:percent_off)
    expect(attributes[:percent_off].to_f).to eq(@coupon_1.percent_off)

    expect(attributes).to have_key(:status)
    expect(attributes[:status]).to eq(@coupon_1.status)

    expect(attributes).to have_key(:dollar_off)
    expect(attributes[:dollar_off]).to be_nil
  end

  it "has a custom counter attribute showing # of times used" do
    coupon = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]

    expect(coupon).to have_key(:times_used)
    expect(coupon[:times_used]).to eq(2)
  end

  it "returns a specific coupon via id" do
    coupon = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(coupon[:id]).to eq(@coupon_1.id.to_s)
  end

  describe "sad paths" do
    it "returns a 404 error if the coupon does not exist" do
      get "/api/v1/merchants/#{@merchant_1.id}/coupons/9999"
    
      expect(response).to have_http_status(404)
      coupon = JSON.parse(response.body, symbolize_names: true)
    
      expect(coupon).to have_key(:error)
      expect(coupon[:error]).to eq("Coupon not found")
    end

    it "returns a 404 if coupon does not belong to specified merchant" do
      merchant_2 = Merchant.create!(name: "Not Me")
      coupon_2 = Coupon.create!(name: "Tree Fitty", code: "3FITTY", dollar_off: 3.50, percent_off: nil, status: "active", merchant: merchant_2)
    
      get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{coupon_2.id}"
    
      expect(response).to have_http_status(404)
      error_message = JSON.parse(response.body, symbolize_names: true)
    
      expect(error_message).to have_key(:error)
      expect(error_message[:error]).to eq("Coupon not found")
    end
    
    it "returns 0 for times_used if the coupon has not been applied to any invoices" do
      coupon_3 = Coupon.create!(name: "Ain't Got None", code: "NOPE", percent_off: 30.00, status: "active", merchant: @merchant_1)
    
      get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{coupon_3.id}"
    
      attributes = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]

      expect(attributes).to have_key(:times_used)
      expect(attributes[:times_used]).to eq(0)
    end
  end
end