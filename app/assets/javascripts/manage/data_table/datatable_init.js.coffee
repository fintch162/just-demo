# ready = =>
#   for observable in ["venue", "groupClass", "instructor"]
#     kendo.bind $("##{observable}List"), window["#{observable}Model"] if $("##{observable}List").length

#   filterRow = $("#row-filters").find("tr")

#   grid = $("div[data-role='grid']")

#   if filterRow.length
#     grid.data("kendoGrid").thead.append(filterRow);

#   if (".filter").length
#     reloadGrid = ->
#       filters = {}
#       $(".filter").each ->
#         self = $(@)
#         filters[self.data('field')] = self.val()
#       grid.data("kendoGrid").dataSource.filter(filters)

#     window.reloadGrid = reloadGrid

#     $(".filter:not(.live)").on "change", ->
#       reloadGrid()

#     $(".filter.live").on "keyup", ->
#       val = $(@).val()
#       if val.length > 2 or val is ""
#         reloadGrid()

# $(document).ready ready
# $(document).on('page:load', ready)

