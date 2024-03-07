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
FactoryBot.define do
  factory :coupon do
    lmd_id { "123456" }
    title { "Test Coupon" }
    description { "This test coupon" }
    valid_from { Date.current }
    valid_to { 2.days.after }
  end
end
