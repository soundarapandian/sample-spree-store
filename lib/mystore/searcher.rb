module Mystore
  class Searcher
    attr_accessor :current_user
    attr_accessor :current_currency
    attr_reader :search
    
    def initialize(params)
      page = (params[:page].to_i <= 0) ? 1 : params[:page].to_i

      @search = Spree::Product.solr_search do
        # Full text search
        fulltext params[:keywords] if params[:keywords].present?

        # Filter by taxonomy
        with :taxon_ids, params[:primary_taxon_id].to_i if params[:primary_taxon_id].present?
        with :taxon_ids, params[:taxon_ids].map(&:to_i) if params[:taxon_ids].present?

        # Filter by price
        with(:price, params[:price][:min].to_f..params[:price][:max].to_f) if params[:price].present?
        
        # Filter by product properties and variants
        (Spree::Product.searchable_properties.values.flatten.uniq + Spree::Product.searchable_variants.values.flatten.uniq).each do |search_field|
          underscored_search_field = search_field.parameterize.underscore
          product_search_key =  underscored_search_field + '_any'

          if params[product_search_key].present?
            any_of do
              params[product_search_key].each do |product_search_value|
                with underscored_search_field.to_sym, product_search_value
              end
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
