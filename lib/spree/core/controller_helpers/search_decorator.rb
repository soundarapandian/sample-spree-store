Spree::Core::ControllerHelpers::Search.class_eval do
  def build_filters(params)
    return [] unless params[:primary_taxon_id].present?

    taxon = Spree::Taxon.find params[:primary_taxon_id]
    taxon_name = taxon.name.downcase
    product_properties = get_product_properties params[:primary_taxon_id]
    product_option_types = get_product_option_types params[:primary_taxon_id]

    return [] if product_properties.empty? && product_option_types.empty?

    allowed_filters = [Spree::Product.searchable_properties[taxon_name], Spree::Product.searchable_variants[taxon_name]].flatten.compact
    (product_option_types + product_properties).
      select {|property_or_option_type| allowed_filters.include?(property_or_option_type.name) }.
      map {|property_or_option_type| build_filter property_or_option_type}
  end

  def get_product_properties(taxon_id)
    get_property_ids(taxon_id).map {|property_id| Spree::Property.find property_id}
  end

  def get_product_option_types(taxon_id)
    get_option_type_ids(taxon_id).map {|option_type_id| Spree::OptionType.find option_type_id}
  end

  def get_option_type_ids(taxon_id)
    Spree::OptionValue.
        joins(:variants).
        joins('INNER JOIN spree_products_taxons ON spree_variants.product_id = spree_products_taxons.product_id').
        where('spree_products_taxons.taxon_id = ?', taxon_id).
        select(:option_type_id).distinct.map(&:option_type_id)
  end

  def get_property_ids(taxon_id)
    Spree::ProductProperty.
      joins(:product).
      joins('INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id').
      where('spree_products_taxons.taxon_id = ?', taxon_id).
      select(:property_id).distinct.map(&:property_id)
  end

  def build_filter(filter_source)
    filter_name = filter_source.name
    labels = filter_source.kind_of?(Spree::Property) ? labels_for_property(filter_name) : labels_for_option_type(filter_name)

    {
      labels: labels,
      name: filter_name,
      scope: filter_name.downcase.parameterize.underscore + '_any'
    }
  end

  def labels_for_property(filter_name)
    Spree::ProductProperty.joins(:property).
      where("spree_properties.name = ?", filter_name).distinct.pluck(:value).collect {|value| [value, value]}
  end

  def labels_for_option_type(filter_name)
    Spree::OptionValue.joins(:option_type).
      where("spree_option_types.name = ?", filter_name).distinct.pluck(:name).collect {|name| [name, name]}
  end
end
