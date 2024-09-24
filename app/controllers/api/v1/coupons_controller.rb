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

  def create
    new_coupon = Coupon.create(coupon_params)
    render json: CouponSerializer.new(new_coupon), status: 201
  end

  def update
    updated_coupon = Coupon.update(params[:id], coupon_params)
    render json: CouponSerializer.new(updated_coupon)
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :percent_off, :dollar_off, :status)
  end
end