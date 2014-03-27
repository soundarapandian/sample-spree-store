Spree::ProductsController.class_eval do
  def index
    @searcher = build_searcher(params)
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)

    if request.xhr? && params[:scope] == 'filters'
      render layout: false
    elsif request.xhr?
      render :infinite_scroll
    end 
  end 
end
