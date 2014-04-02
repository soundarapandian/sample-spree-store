Spree::Product.class_eval do

  def self.searchable_properties
    {
      'shirts' => ['Brand', 'Gender', 'Manufacturer', 'Fit', 'Made From'],
      't-shirts' => ['Brand', 'Gender', 'Manufacturer', 'Fit', 'Made From'],
      'bags' => ['Type', 'Size', 'Material'],
      'mugs' => ['Type', 'Size']
    }
  end

  def self.searchable_variants
    {
      't-shirts' => ['Tshirt Color', 'Tshirt Size']
    }
  end

  searchable do
    text :name, :description

    text :taxons do
      taxons.map(&:name).join(' ')
    end

    text :properties do
      product_properties.map(&:value).join(' ')
    end

    float :price
    
    integer :taxon_ids, multiple: true

    searchable_properties.values.flatten.uniq.each do |searchable_property|
      string searchable_property.parameterize.underscore.to_sym do
        product_properties.joins(:property).where('spree_properties.name = ?', searchable_property).take.try(:value)
      end
    end

    searchable_variants.values.flatten.uniq.each do |searchable_variant|
      string searchable_variant.parameterize.underscore.to_sym, multiple: true do
        option_type = Spree::OptionType.find_by(name: searchable_variant)

        if option_type
          Spree::OptionValue.joins(:variants).
            where('spree_variants.product_id = ? AND option_type_id = ?', send(:id), option_type.id).distinct.pluck(:name)
        else
          []
        end
      end
    end
  end
end