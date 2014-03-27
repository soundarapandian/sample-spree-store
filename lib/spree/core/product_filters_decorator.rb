Spree::Core::ProductFilters.instance_eval do
  def gender_filter
    build_filter 'gender'
  end

  def manufacturer_filter
    build_filter 'manufacturer'
  end

  def build_filter(filter_name)
    {
      labels: labels_for(filter_name),
      name: filter_name.capitalize,
      scope: filter_name + '_any'
    }
  end

  def labels_for(filter_name)
    Spree::ProductProperty.joins(:property).
      where("spree_properties.name = '#{filter_name}'").
      select(:value).distinct.map(&:value).
      collect {|manu| [manu, manu]}
  end
end
