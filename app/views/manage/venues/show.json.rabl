attributes :id, :name
node(:edit_link){ |venue| edit_manage_venue_path(venue) }
node(:delete_link){ |item| url_for([:manage, item]) }