class Api::V1::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons

    render json: CouponSerializer.new(coupons)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Merchant not found" }, status: :not_found
  end
  
  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])

    render json: CouponSerializer.new(coupon, {params: {action: "show"} })
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Coupon not found" }, status: :not_found
  end
end