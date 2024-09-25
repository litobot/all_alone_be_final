require 'rails_helper'


RSpec.describe "Modify Coupon Status Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
    @coupon_1 = Coupon.create!(name: "Deactivate Me", code: "BALEEETED", percent_off: 10.00, status: "active", merchant: @merchant_1)
    @coupon_2 = Coupon.create!(name: "Activate Me", code: "LETSGO", percent_off: 10.00, status: "inactive", merchant: @merchant_1)
    @customer_1 = Customer.create!(first_name: "Bill", last_name: "Brasky")
    @invoice_1 = Invoice.create!(status: "packaged", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_2 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_3 = Invoice.create!(status: "returned", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
  end

  describe "deactivating a merchant's coupon" do
    it "can change the status of a coupon from active to inactive" do
      coupon_params = { status: "inactive" }
      headers = { "CONTENT_TYPE" => "application/json" }
      id = @coupon_1.id
      previous_status = Coupon.find(id).status
      
      patch "/api/v1/merchants/:merchant_id/coupons/#{@coupon_1.id}", headers: headers, params: JSON.generate(coupon: coupon_params)
      coupon = Coupon.find_by(id: id)

      coupon_response = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon_response).to be_a(Hash)
      
      expect(response).to be_successful
      expect(coupon_response[:attributes][:status]).to_not eq(previous_status)
      expect(coupon_response[:attributes][:status]).to eq("inactive")

      expect(coupon_response).to have_key(:id)
      expect(coupon_response[:id]).to be_a(String)
  
      expect(coupon_response).to have_key(:type)
      expect(coupon_response[:type]).to eq("coupon")
  
      attributes = coupon_response[:attributes]
  
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to eq(@coupon_1.name)
  
      expect(attributes).to have_key(:code)
      expect(attributes[:code]).to eq(@coupon_1.code)
  
      expect(attributes).to have_key(:percent_off)
      expect(attributes[:percent_off].to_f).to eq(@coupon_1.percent_off)
  
      expect(attributes).to have_key(:dollar_off)
      expect(attributes[:dollar_off]).to be_nil
    end

    it "can change the status of a coupon from inactive to active" do
      coupon_params = { status: "active" }
      headers = { "CONTENT_TYPE" => "application/json" }
      id = @coupon_2.id
      previous_status = Coupon.find(id).status
      
      patch "/api/v1/merchants/:merchant_id/coupons/#{@coupon_2.id}", headers: headers, params: JSON.generate(coupon: coupon_params)
      coupon = Coupon.find_by(id: id)

      coupon_response = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon_response).to be_a(Hash)
      
      expect(response).to be_successful
      expect(coupon_response[:attributes][:status]).to_not eq(previous_status)
      expect(coupon_response[:attributes][:status]).to eq("active")

      expect(coupon_response).to have_key(:id)
      expect(coupon_response[:id]).to be_a(String)
  
      expect(coupon_response).to have_key(:type)
      expect(coupon_response[:type]).to eq("coupon")
  
      attributes = coupon_response[:attributes]
  
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to eq(@coupon_2.name)
  
      expect(attributes).to have_key(:code)
      expect(attributes[:code]).to eq(@coupon_2.code)
  
      expect(attributes).to have_key(:percent_off)
      expect(attributes[:percent_off].to_f).to eq(@coupon_2.percent_off)
  
      expect(attributes).to have_key(:dollar_off)
      expect(attributes[:dollar_off]).to be_nil
    end
  end
end