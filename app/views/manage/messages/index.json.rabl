object false

child @messages, object_root: false do
  extends "manage/messages/show"
end

node(:total){ @messages.count }
