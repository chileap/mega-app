class CouponImporterWorker < ApplicationWorker
  def perform(*args)
    Coupons::ImportService.call
  end
end
