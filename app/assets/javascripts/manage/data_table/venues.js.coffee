# window.venueModel = kendo.observable
#   venues: new kendo.data.DataSource(
#     new kendoSchemeBuilder(
#       rootNode: 'venues',
#       url: '/manage/venues'
#       model:
#         id: "id"
#         fields:
#           actions: { editable: false }

#       dataMapper: (data)->
#         venue:
#           name: data.name

#     ).scheme
#   )