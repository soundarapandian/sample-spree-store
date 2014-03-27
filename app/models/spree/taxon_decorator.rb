require Rails.root.join('lib', 'spree', 'core', 'product_filters_decorator.rb').to_s

Spree::Taxon.class_eval do
  def applicable_filters
    filters = []
    
    filters << Spree::Core::ProductFilters.brand_filter
    filters << Spree::Core::ProductFilters.manufacturer_filter
    filters << Spree::Core::ProductFilters.gender_filter

    filters
  end
end
