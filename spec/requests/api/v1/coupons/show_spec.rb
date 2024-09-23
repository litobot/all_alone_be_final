require 'rails_helper'

RSpec.describe "Coupons Show Endpoint", type: :request, do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Lito")
    @coupon_1 = Coupon.create!(name: "Super Secret Discount", code: "BOGO20", percent_off: 20.00, status: "active", merchant: @merchant_1)
    
    get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{@coupon_1.id}"
  end

  it "returns with the proper JSON format including 200 status response code" do
    expect(response).to be_successful
    expect(response).to have_http_status(200)
    coupon = JSON.parse(response.body, symbolize_names: true)[:data]
    
    # Want to check only one coupon object being returned
    # Response would be an array if multiple objects returned
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
    expect(attributes[:percent_off]).to eq(@coupon_1.percent_off)

    expect(attributes).to have_key(:status)
    expect(attributes[:status]).to eq(@coupon_1.status)
  end

  # (Number of invoices it appears on)
  # Add to JSON response via serializer
  it "has a counter attribute showing # of times used" do

  end

  it "returns a specific coupon via id" do

  end
end