# def paypal_url(return_url) 
#   values = { 
#   :business => "dipen@example.com",
#   :cmd => '_cart',
#   :upload => 1,
#   :return => return_url
#   }

#   values.merge!({ 
#     "amount_1" => 1,
#     "item_name_1" => "Ball",
#     "item_number_1" => 1,
#     "quantity_1" => '1'
#   })

#   "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
# end