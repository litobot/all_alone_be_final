require 'rails_helper'


RSpec.describe "Coupons Create Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
  end

  describe "Create New Coupon" do
    it "can create a new coupon" do
      coupon_params = {
        name: "Think Green",
        code: "GREEN",
        percent_off: 42.0,
        status: "active",
        merchant_id: @merchant_1.id
      }

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants/#{@merchant_1.id}/coupons", params: JSON.generate(coupon: coupon_params), headers: headers

      puts response.body

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response).to have_http_status(201)

      expect(coupon).to have_key(:id)

      attributes = coupon[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to eq(coupon_params[:name])

      expect(attributes).to have_key(:code)
      expect(attributes[:code]).to eq(coupon_params[:code])

      expect(attributes).to have_key(:percent_off)
      expect(attributes[:percent_off].to_f).to eq(coupon_params[:percent_off])

      expect(attributes).to have_key(:status)
      expect(attributes[:status]).to eq(coupon_params[:status])
    end
  end

  describe "sad path" do
    it "returns a 422 response status when required fields are absent" do
      coupon_params = {
        name: "Bad Coupon",
        percent_off: 25.00,
        status: "active"
      }

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants/#{@merchant_1.id}/coupons", params: JSON.generate(coupon: coupon_params), headers: headers

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(422)
      expect(error_response).to have_key(:errors)

      expect(error_response[:errors]).to include("Code can't be blank")
    end
  end
end