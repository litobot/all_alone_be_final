require 'rails_helper'

RSpec.describe "Merchant Invoices Endpoint", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Litobot's Garden Products")
    @coupon_1 = Coupon.create!(name: "Deactivate Me", code: "BALEEETED", percent_off: 10.00, status: "active", merchant: @merchant_1)
    @coupon_2 = Coupon.create!(name: "Activate Me", code: "LETSGO", percent_off: 10.00, status: "inactive", merchant: @merchant_1)
    @customer_1 = Customer.create!(first_name: "Bill", last_name: "Brasky")
    @invoice_1 = Invoice.create!(status: "packaged", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_2 = Invoice.create!(status: "shipped", customer: @customer_1, merchant: @merchant_1, coupon: @coupon_1)
    @invoice_3 = Invoice.create!(status: "returned", customer: @customer_1, merchant: @merchant_1, coupon: nil)

    get "/api/v1/merchants/#{@merchant_1.id}/invoices/:id"
  end
  
  describe "returning a merchant's invoices" do
    it "can return a merchant's invoices by merchant_id" do
      invoice_responses = JSON.parse(response.body, symbolize_names: true)[:data]
  
      expect(response).to be_successful
      # invoice_responses contains an array of multiple invoices
      expect(invoice_responses).to be_an(Array)
  
      invoice_responses.each do |invoice_response|
        # Each invoice_response will be only a hash - makes sure it's just one returned
        expect(invoice_response).to be_a(Hash)
  
        expect(invoice_response).to have_key(:id)
        expect(invoice_response[:id]).to be_a(String)
  
        expect(invoice_response).to have_key(:type)
        expect(invoice_response[:type]).to eq("invoice")
  
        attributes = invoice_response[:attributes]
  
        # DRY way to check each invoice_response has each key
        # Some might have a status of `null`, so this is good enough.
        [:customer_id, :merchant_id, :status].each do |key|
          expect(attributes).to have_key(key)
        end
  
        # Verifies they all came from same merchant by id in HTTP request
        expect(attributes[:merchant_id]).to eq(@merchant_1.id)
      end
    end

    it "includes a coupon's id if one was applied" do
      invoice_responses = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful

      # Get inside attributes for each invoice_response
      # We know invoice_3 has a nil value for :coupon_id
      # The others should match with @coupon_1.id
      invoice_responses.each do |invoice_response|
        attributes = invoice_response[:attributes]
        
        expect(attributes).to have_key(:coupon_id)

        if invoice_response[:id] == @invoice_3.id
          expect(attributes[:coupon_id]).to be_nil
        else
          expect(attributes[:coupon_id]).to eq(@coupon_1.id)
        end
      end
    end
  end
end