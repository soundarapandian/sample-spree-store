Spree::ProductsHelper.class_eval do
  def cache_key_for_products
    max_updated_at = Spree::Product.maximum(:updated_at).to_s(:number)
    "#{current_currency}/spree/products/all-#{params[:page]}-#{max_updated_at}"
  end
end
