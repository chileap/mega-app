namespace :coupons do
  desc "Imported coupons from LinkMyDeals"
  task import: :environment do
    puts "Importing coupons..."
    @coupon = Coupons::ImportService.call
    puts "Imported #{@coupon.count} coupons"
  end
end
