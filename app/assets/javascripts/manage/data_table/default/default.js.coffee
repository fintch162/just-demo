window.defaultKendoScheme =
  schema:
    data: "root_object" #need to override as rootNode in params for kendoSchemeBuilder class
    total: "total"
    model:
      id: "id"
  pageSize: 20,
  serverPaging: true,
  serverFiltering: true,
  serverSorting: true
  batch: false

window.kendoSchemeBuilder = class kendoSchemeBuilder
  constructor: (params={})->
    alert "please provide 'url' parameter" unless params.url?
    alert "please provide 'root' parameter" unless params.rootNode?
    @transportUrl = params.url
    @mapper = params.dataMapper
    @modelScheme = params.model
    @rootNode = params.rootNode
    @initScheme()

  initScheme: ->
    @scheme = jQuery.extend({}, defaultKendoScheme)
    @scheme.transport = @transport()
    @scheme.schema.model = @modelScheme if @modelScheme?
    @scheme.schema.data = @rootNode

  transport: ->
    read:
      url: @transportUrl
      dataType: "json"
      contentType: 'application/json',
      method: "GET"

    update:
      url: (data)=>
        "#{@transportUrl}/#{data.id}"
      dataType: "json"
      contentType: 'application/json',
      method: "PUT"

    create:
      url: @transportUrl
      dataType: "json"
      method: "POST"
      contentType: 'application/json',

    destroy:
      url: (data)=>
        "#{@transportUrl}/#{data.id}"
      dataType: "json"
      contentType: 'application/json',
      type: "DELETE"

    parameterMap: (data, operation) =>
      params = {}
      switch operation
        when "read"
          params["per_page"] = data.take
          params["page"] = data.page
          params["sort"] =  data.sort[0] if data.sort?
          params["search"] = data.filter.filters[0] if data.filter?.filters?
        when "update"
          params = kendo.stringify @mapper(data)
        when "create"
          params = kendo.stringify @mapper(data)
      params


