# == Schema Information
#
# Table name: coupons
#
#  id                   :bigint           not null, primary key
#  categories           :text
#  category_array       :jsonb
#  coupon_code          :string
#  description          :text
#  image_url            :string
#  merchant_homepage    :string
#  offer_text           :text
#  offer_type           :string
#  offer_value          :string
#  payload              :jsonb
#  publisher_exclusive  :string
#  smart_link           :string
#  status               :string
#  store                :string
#  terms_and_conditions :string
#  title                :string
#  type                 :string
#  url                  :string
#  valid_from           :datetime
#  valid_to             :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  coupon_importer_id   :bigint
#  lmd_id               :string
#
# Indexes
#
#  index_coupons_on_coupon_importer_id  (coupon_importer_id)
#  unique_not_null_lmd_id               (lmd_id) UNIQUE WHERE (lmd_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (coupon_importer_id => coupon_importers.id)
#
class Coupon < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :coupon_importer, optional: true, counter_cache: true

  validates :lmd_id, uniqueness: {allow_blank: true}

  validates :valid_from, presence: true, comparison: {less_than: :valid_to}
  validates :valid_to, presence: true, comparison: {greater_than: :valid_from}

  default_scope { order(valid_from: :asc) }

  def valid_dates
    "#{valid_from&.to_date&.strftime("%b %d, %Y")} - #{valid_to&.to_date&.strftime("%b %d, %Y")}"
  end

  def payload_json
    payload.to_json
  end

  def self.filter_by(params)
    coupons = all

    if params[:name].present?
      coupons = coupons.where("title ILIKE ?", "%#{params[:name]}%")
    end

    if params[:valid_from].present?
      coupons = coupons.where("valid_from >= ?", params[:valid_from])
    end

    if params[:valid_to].present?
      coupons = coupons.where("valid_to <= ?", params[:valid_to])
    end

    coupons
  end
end
