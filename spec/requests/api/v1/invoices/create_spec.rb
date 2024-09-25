require 'rails_helper'


RSpec.describe "Invoice Post Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Merchant Name")
    @customer_1 = Customer.create!(first_name: "John", last_name: "Doe")
    @coupon_1 = Coupon.create!(name: "Test Coupon", code: "TESTY", dollar_off: 15.00, status: "inactive", merchant: @merchant_1)
  end

  describe "POST /invoices" do
    it "creates a new invoice with valid parameters" do
      invoice_params = {
        status: "shipped",
        customer_id: @customer_1.id,
        merchant_id: @merchant_1.id,
        coupon_id: @coupon_1.id
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/invoices", params: JSON.generate(invoice_params), headers: headers
  
      invoice = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response).to have_http_status(201)

      expect(invoice[:attributes][:status]).to eq("shipped")
      expect(invoice[:attributes][:customer_id]).to eq(@customer_1.id)
      expect(invoice[:attributes][:merchant_id]).to eq(@merchant_1.id)
    end
  end

  describe "sad paths" do
    it "fails to create an invoice when missing required parameters" do
      invoice_params = {
        invoice: {
          status: "shipped"
        }
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/invoices", params: JSON.generate(invoice_params), headers: headers
  
      expect(response).to have_http_status(422)
  
      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response).to have_key(:errors)
      expect(error_response[:errors]).to include("Customer must exist", "Merchant must exist")
    end
  end
end