require 'rails_helper'


RSpec.describe "Sorted by Status Index Queries", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Lito")
    @merchant_2 = Merchant.create!(name: "Hercules")
    @coupon_1 = Coupon.create!(name: "A Discount", code: "BOGO20", percent_off: 20.00, status: "active", merchant: @merchant_1)
    @coupon_2 = Coupon.create!(name: "Nunya Biznass", code: "10-OFF", dollar_off: 10.00, status: "active", merchant: @merchant_1)
    @coupon_3 = Coupon.create!(name: "Vote For Pedro", code: "BOGO50", percent_off: 50.00, status: "inactive", merchant: @merchant_1)
    @coupon_4 = Coupon.create!(name: "Unicorn Floss", code: "HORNS", percent_off: 40.00, status: "inactive", merchant: @merchant_1)
    @coupon_5 = Coupon.create!(name: "Dragon Farts", code: "BURN", percent_off: 666.00, status: "inactive", merchant: @merchant_1)
    @customer_1 = Customer.create!(first_name: "Not", last_name: "Sure")
    @invoice_1 = Invoice.create!(status: "shipped", customer_id: @customer_1.id, merchant: @merchant_1, coupon: @coupon_1)
  end

  it "returns coupons with a status of 'active' " do
    get "/api/v1/merchants/#{@merchant_1.id}/coupons?status=active"

    coupons = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(response).to be_successful
    expect(coupons.count).to eq(2)

    coupons.each do |coupon|
      expect(coupon[:attributes][:status]).to eq("active")
    end
  end
  
  it "returns coupons with a status of 'inactive' " do
    get "/api/v1/merchants/#{@merchant_1.id}/coupons?status=inactive"

    coupons = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(response).to be_successful
    expect(coupons.count).to eq(3)

    coupons.each do |coupon|
      expect(coupon[:attributes][:status]).to eq("inactive")
    end
  end
end