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
        percent_off: 42.00,
        status: "active"
      }

      ### Want to know more about how this works
      ### This is just the HTTP request header, right?
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants/#{@merchant_1.id}/coupons", params: JSON.generate(coupon: coupon_params), headers: headers

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
      expect(attributes).to eq(coupon_params[:percent_off])

      expect(attributes).to have_key(:status)
      expect(attributes).to eq(coupon_params[:status])
    end

    context "sad paths" do
      it "returns a 422 status if required fields are missing" do
        coupon_params = {
          name: "Sumpin's Missin'",
          code: "NOSSIR",
          status: "inactive"
        }

        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/merchants/#{@merchant_1.id}/coupons", params: JSON.generate(coupon: coupon_params), headers: headers
  
        coupon = JSON.parse(response.body, symbolize_names: true)[:data]
  
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        
        expect(coupon[:attributes]).to have_key(:percent_off)
        expect(coupon[:attributes][:percent_off]).to be_nil
        
        expect(coupon[:attributes]).to have_key(:dollar_off)
        expect(coupon[:attributes][:dollar_off]).to be_nil
      end

      it "returns 404 if merchant does not exist" do
        coupon_params = {
          name: "Ghostman",
          code: "NEGATIVE",
          percent_off: 10.0,
          status: "active"
        }

        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/merchants/9999/coupons", params: JSON.generate(coupon: coupon_params), headers: headers

        coupon = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
      end
    end
  end
end