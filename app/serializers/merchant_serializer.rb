class MerchantSerializer
  include JSONAPI::Serializer

  attributes :name

  attribute :item_count, if: Proc.new {|merchants, params| params && params[:action] == "index" }
  attribute :coupons_count, if: Proc.new {|merchants, params| params && params[:action] == "index" }
  attribute :invoice_coupon_count, if: Proc.new {|merchants, params| params && params[:action] == "index" }
end
