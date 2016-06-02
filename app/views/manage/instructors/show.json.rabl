attributes :id, :email, :name, :mobile
node(:edit_link){ |item| url_for([:edit, :manage, item]) }
node(:view_link){| item| url_for([:manage, item]) }
node(:delete_link){ |item| url_for([:manage, item]) }
