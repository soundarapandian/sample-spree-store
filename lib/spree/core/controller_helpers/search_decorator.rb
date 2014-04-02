Spree::Core::ControllerHelpers::Search.class_eval do
  def build_filters(params)
    taxon_ids = [params[:primary_taxon_id], params[:taxon_ids]].flatten.compact.map(&:to_i)
  
    return [] if taxon_ids.empty?

    product_properties = get_product_properties taxon_ids
    product_option_types = get_product_option_types taxon_ids

    return [] if product_properties.empty? && product_option_types.empty?

    (product_option_types + product_properties).map {|property_or_option_type| build_filter(property_or_option_type)}
  end

  def get_product_properties(taxon_ids)
    get_property_ids(taxon_ids).map {|property_id| Spree::Property.find property_id}
  end

  def get_product_option_types(taxon_ids)
    get_option_type_ids(taxon_ids).map {|option_type_id| Spree::OptionType.find option_type_id}
  end

  def get_option_type_ids(taxon_ids)
    Spree::OptionValue.
        joins(:variants).
        joins('INNER JOIN spree_products_taxons ON spree_variants.product_id = spree_products_taxons.product_id').
        where('spree_products_taxons.taxon_id in (?)', taxon_ids).
        select(:option_type_id).distinct.map(&:option_type_id)
  end

  def get_property_ids(taxon_ids)
    Spree::ProductProperty.
      joins(:product).
      joins('INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id').
      where('spree_products_taxons.taxon_id in (?)', taxon_ids).
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
