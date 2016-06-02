object false

child @group_classes, object_root: false do
  extends "manage/group_classes/show"
end

node(:total){ @group_classes.count }
