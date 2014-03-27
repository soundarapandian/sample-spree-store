Spree::Product.class_eval do
  searchable do
    text :name, :description, stored: true

    text :taxons do
      taxons.map(&:name).join(' ')
    end

    text :properties do
      product_properties.map(&:value).join(' ')
    end

    text :variants do
      variants.map(&:options_text).join(' ')
    end
    
    float :price, stored: true
    
    integer :taxon_ids, multiple: true

    integer :taxonomy_ids, multiple: true do
      taxons.map(&:taxonomy_id)
    end

    string :product_brand do
       product_properties.joins(:property).where("spree_properties.name = 'Brand'").take.try(:value)
    end

    string :product_manufacturer do
       product_properties.joins(:property).where("spree_properties.name = 'Manufacturer'").take.try(:value)
    end

    string :product_gender do
       product_properties.joins(:property).where("spree_properties.name = 'Gender'").take.try(:value)
    end
  end
end
