object false

child @venues, object_root: false do
  extends "manage/venues/show"
end

node(:total){ @venues.count }
