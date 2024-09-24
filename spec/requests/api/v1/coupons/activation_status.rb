require 'spec_helper'

RSpec.describe "Modify Coupon Status Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
    @coupon_1 = Coupon.create!(name: "Deactivate Me", code: "BALEEETED", percent_off: 10.00, status: "active")
    @customer_1 = Customer.create!(first_name: "Bill", last_name: "Brasky")
    @invoice_1 = Invoice.create!(status: "pending")
  end

  describe "deactivating a merchant's coupon" do
    it "can change the status of a coupon from active to inactive" do
      id = @coupon_1.id
      previous_status = Coupon.find(id).status
      coupon_params { status: "inactive" }
      headers = { "CONTENT_TYPE" => "application/json" }
      
      patch "/api/v1/merchants/:merchant_id/coupons/#{@coupon_1.id}", headers: headers, params: JSON.generate(coupon: coupon)
      coupon = Coupon.find_by(id: id)

      coupon_response = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(coupon.status).to_not eq(previous_status)
      expect(coupon.status).to eq("inactive")

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
  
      expect(attributes).to have_key(:dollar_off)
      expect(attributes[:dollar_off]).to be_nil
    end
  end

  describe "sad paths" do
    # A coupon cannot be deactivated if there are any pending invoices with that coupon.
    # Do I need to change the status of invoices to include a pending?
  end
end