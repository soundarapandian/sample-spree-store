Spree::Product.class_eval do

  searchable do
    text :name, :description, stored: true

    text :taxons do
      taxons.map(&:name).join(' ')
    end

    text :properties do
      product_properties.map(&:value).join(' ')
    end

    float :price, stored: true
    
    integer :taxon_ids, multiple: true

    string :product_brand do
       product_properties.joins(:property).where("spree_properties.name = 'Brand'").take.try(:value)
    end

    string :product_manufacturer do
       product_properties.joins(:property).where("spree_properties.name = 'Manufacturer'").take.try(:value)
    end

    string :product_gender do
       product_properties.joins(:property).where("spree_properties.name = 'Gender'").take.try(:value)
    end

    string :product_fit do
      product_properties.joins(:property).where("spree_properties.name = 'Fit'").take.try(:value)
    end

    string :product_model do
      product_properties.joins(:property).where("spree_properties.name = 'Model'").take.try(:value)
    end

    string :product_shirt_type do
      product_properties.joins(:property).where("spree_properties.name = 'Shirt Type'").take.try(:value)
    end

    string :product_sleeve_type do
      product_properties.joins(:property).where("spree_properties.name = 'Sleeve Type'").take.try(:value)
    end

    string :product_made_from do
      product_properties.joins(:property).where("spree_properties.name = 'Made From'").take.try(:value)
    end

    string :product_tshirt_color, multiple: true do
      option_type = Spree::OptionType.find_by(name: 'Tshirt Color')

      if option_type
        Spree::OptionValue.joins(:variants).
          where('spree_variants.product_id = ? AND option_type_id = ?', send(:id), option_type.id).distinct.pluck(:name)
      else
        []
      end
    end

    string :product_tshirt_size, multiple: true do
      option_type = Spree::OptionType.find_by(name: 'Tshirt Size')

      if option_type
        Spree::OptionValue.joins(:variants).
            where('spree_variants.product_id = ? AND option_type_id = ?', send(:id), option_type.id).distinct.pluck(:name)
      else
        []
      end
    end
  end
end