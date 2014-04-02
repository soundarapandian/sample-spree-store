Spree::BaseHelper.class_eval do
  def taxons_tree(root_taxon, current_taxon, max_level = 1)
    @root_taxon_id = root_taxon.id unless root_taxon.parent

    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, class: 'filter_choices' do
      root_taxon.children.map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        filter_input = get_filter_input taxon

        content_tag :li, class: css_class do
          if taxon.parent.present? && taxon.children.present?
            taxons_tree(taxon, current_taxon, max_level - 1)
          else
            [
              filter_input,
              content_tag(:label, taxon.name, for: "taxon-#{taxon.id}"),
              content_tag(:span, "(#{taxon.products.count})")
            ].join(" ").html_safe
          end
        end 
      end.join("\n").html_safe
    end 
  end
  
  def get_filter_input(taxon)
    taxon_id = taxon.id

    if taxon.root.name == 'Categories'
      radio_button_tag("primary_taxon_id", taxon_id, params_taxon_ids.include?(taxon_id), id: "taxon-#{taxon_id}")
    else
      check_box_tag("taxon_ids[]", taxon_id, params_taxon_ids.include?(taxon_id), id: "taxon-#{taxon_id}")
    end
  end

  def params_taxon_ids 
    @params_taxon_ids ||= [params[:primary_taxon_id], params[:taxon_ids]].flatten.compact.map(&:to_i)
  end

  def maximum_product_price
    Spree::Price.maximum(:amount).to_i
  end

  def minimum_product_price
    Spree::Price.minimum(:amount).to_i
  end

  def starting_product_price
    params[:price] && params[:price][:min].to_i || minimum_product_price
  end

  def ending_product_price
    params[:price] && params[:price][:max].to_i || maximum_product_price
  end
end
