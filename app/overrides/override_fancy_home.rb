Deface::Override.new(virtual_path: 'spree/home/_slider',
                     name: 'override_fancy_home',
                     replace: "erb[loud]:contains('number_field_tag')",
                     text: "<%= number_field_tag :quantity, 1, :class => 'title', :in => 1..Spree::Stock::Quantifier.new(product.master).total_on_hand, :min => 1 %><%= hidden_field_tag :variant_id, product.master.id%>")
