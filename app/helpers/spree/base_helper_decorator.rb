Spree::BaseHelper.class_eval do
  def taxons_tree(root_taxon, current_taxon, max_level = 1)
    @root_taxon_id = root_taxon.id unless root_taxon.parent

    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, class: 'filter_choices' do
      root_taxon.children.map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        prodcuts_count = Spree::Product.joins(:taxons).where('spree_products_taxons.taxon_id = ?', taxon.id).count

        content_tag :li, class: css_class do
          taxon_id = taxon.id
          
          if taxon.parent.present? && taxon.children.present?
            taxons_tree(taxon, current_taxon, max_level - 1)
          else
            [
              check_box_tag("taxon_ids[#{@root_taxon_id}][]", taxon_id, false, id: "taxon-#{taxon_id}"),
              content_tag(:label, taxon.name, for: "taxon-#{taxon_id}"),
              content_tag(:span, "(#{prodcuts_count})")
            ].join(" ").html_safe
          end
        end 
      end.join("\n").html_safe
    end 
  end 
end
