module Mystore
  class Searcher
    attr_accessor :current_user
    attr_accessor :current_currency
    attr_reader :search
    
    def initialize(params)
      page = (params[:page].to_i <= 0) ? 1 : params[:page].to_i

      @search = Spree::Product.solr_search do
        # Full text search
        if params[:keywords].present?
          fulltext params[:keywords] do
            highlight :name, :description
          end
        end

        # Filter by taxonomy
        if params[:taxon_ids].present?
          params[:taxon_ids].each do |_,taxon_ids|
            with :taxon_ids, taxon_ids.map(&:to_i)
          end
        end

        # Filter by price
        if params[:price].present?
          with(:price, params[:price][:min].to_f..params[:price][:max].to_f)
        end
        
        # Filter by brand
        if params[:brand_any].present?
          any_of do
            params[:brand_any].each do |brand|
              with :product_brand, brand
            end
          end
        end

        # Filter by gender
        if params[:gender_any].present?
          any_of do
            params[:gender_any].each do |gender|
              with :product_gender, gender
            end
          end
        end

        # Filter by manufacturer
        if params[:manufacturer_any].present?
          any_of do
            params[:manufacturer_any].each do |manufacturer|
              with :product_manufacturer, manufacturer
            end
          end
        end

        paginate page: page, per_page: Spree::Config[:products_per_page]
      end
    end
     
    def retrieve_products
      @search.results
    end
  end
end
