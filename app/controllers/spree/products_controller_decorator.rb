require Rails.root.join('lib', 'spree', 'core', 'controller_helpers', 'search_decorator.rb')

Spree::ProductsController.class_eval do
  def index
    @searcher = build_searcher(params)
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @filters = build_filters(params)
    @ajax_request = request.xhr?

    if @ajax_request && params[:scope] == 'filters'
      render layout: false
    elsif request.xhr?
      render :infinite_scroll
    end 
  end 
end
