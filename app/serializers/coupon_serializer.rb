class CouponSerializer
  include JSONAPI::Serializer

  attributes :name, :code, :dollar_off, :percent_off, :status

  attribute :times_used, if: Proc.new {|coupons, params| params && params[:action] == "show" }
end