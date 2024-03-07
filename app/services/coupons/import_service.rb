class Coupons::ImportService < ApplicationService
  attr_reader :coupons

  def call
    existed_importer = CouponImporter.find_by(last_extracted_at: Time.current.beginning_of_day)
    return [] if existed_importer.present? && existed_importer.coupons_count > 0

    @coupons = LinkMyDealClient.new.get_offers["offers"]
    create_coupon_importer
    if @coupons.present?
      serializer_coupons
      import_coupons
    end
  end

  private

  attr_reader :coupon_importer

  def create_coupon_importer
    @coupon_importer = CouponImporter.find_or_create_by(last_extracted_at: Time.current.beginning_of_day)
  end

  def serializer_coupons
    return [] if coupons.blank?
    @coupons = coupons.map do |coupon|
      coupon_serializer(coupon)
    end
  end

  def import_coupons
    return [] if @coupons.blank?
    Coupon.upsert_all(
      @coupons,
      record_timestamps: true,
      unique_by: [:lmd_id]
    )
  end

  def coupon_serializer(coupon)
    {
      lmd_id: coupon["lmd_id"],
      title: coupon["title"],
      status: coupon["status"],
      offer_text: coupon["offer_text"],
      type: coupon["type"],
      offer_value: coupon["offer_value"],
      offer_type: coupon["offer"],
      store: coupon["store"],
      categories: coupon["categories"],
      image_url: coupon["image_url"],
      url: coupon["url"],
      smart_link: coupon["smartLink"],
      publisher_exclusive: coupon["publisher_exclusive"],
      valid_from: coupon["start_date"],
      valid_to: coupon["end_date"],
      merchant_homepage: coupon["merchant_homepage"],
      category_array: coupon["category_array"],
      terms_and_conditions: coupon["terms_and_conditions"],
      coupon_importer_id: coupon_importer.id,
      payload: coupon
    }
  end
end
