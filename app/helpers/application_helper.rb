module ApplicationHelper
  def link_to_highlighted_product_name(hit, product, url)
    link_to truncate(highlighted_product_name(hit), length: 100), url, class: 'info',
      itemprop: 'name', title: product.name
  end

  def highlighted_product_name(hit)
    hit.highlight(:name).format {|fragment| content_tag(:em, fragment)}.html_safe
  end
end
