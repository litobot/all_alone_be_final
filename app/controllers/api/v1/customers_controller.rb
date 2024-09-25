class Api::V1::CustomersController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    customers = merchant.customers

    render json: CustomerSerializer.new(customers)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Merchant not found" }, status: :not_found
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    customer = merchant.customers.find(params[:id])

    render json: CustomerSerializer.new(customer)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Customer not found" }, status: :not_found
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    customer = merchant.customers.new(customer_params)

    if customer.save
      render json: CustomerSerializer.new(customer), status: 201
    else
      render json: { errors: customer.errors.full_messages }, status: 422
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:first_name, :last_name)
  end
end