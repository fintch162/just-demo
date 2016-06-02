ActiveAdmin.register ReddotCredential do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  form do |f|
    f.inputs "Reddot Credential" do
      f.input :name
      f.input :url
      f.input :merchant_id, :label => "Merchant Id"
      f.input :key
    end
    f.actions
  end

end
