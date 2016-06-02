object false

child @instructors, object_root: false do
  extends "manage/instructors/show"
end

node(:total){ @instructors.count }
