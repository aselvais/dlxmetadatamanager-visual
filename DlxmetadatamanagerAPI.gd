extends Node

class_name DlxmetadatamanagerAPI 

# Token used for API authentication
var token = "4gZYp1S785NmOaHgxxAUsONsGMm0QIrSDbPDxz5QSRWCd1S0bGvbS3jCFdUzAHha"
# Possible URLs for the API
var uu = [ 
		"http://localhost:8089", 
		"http://ala01095.deluxe.com:8089"
		]
var LoadingNode2D
var LoadingWindowDialog
var HTTPRequest
var env_select

func _init(_LoadingNode2D, _LoadingWindowDialog, _HTTPRequest, _env_select):
	"""
	constructor
	"""
	LoadingNode2D = _LoadingNode2D
	LoadingWindowDialog = _LoadingWindowDialog
	HTTPRequest = _HTTPRequest
	env_select = _env_select

func show_loading(on = true):
	"""
	Show the loading layer
	"""
	if on:
		LoadingNode2D.visible = true
		LoadingWindowDialog.show()
	else:
		LoadingNode2D.visible = false
		LoadingWindowDialog.hide()		

func get_api_url(model="origins", params={}):
	"""
	Returns the URL of the API
	"""
	var uuenv = uu[env_select.get_selected_id()]
	var prms = "/api/" + model + "?"
	if model == "tables":
		prms += "filter=" + '{"where":{"schemas_idh":"4954873733c5d3600d639b38f1bfc5a6"}}'.percent_encode()
		return uuenv + prms + "&access_token=" + token;
	if model == "login":
		return uuenv + "/api/Users/login"
	else:
		prms += "filter=" + '{"limit":22}'.percent_encode()
	var fullurl = uuenv + prms + "&access_token=" + token;
	return fullurl

func call_api(params={}):
	"""
	Calls the API
	"""
	show_loading(true)
	if params.entity != "":
		if params.entity == "login":
			return HTTPRequest.request(get_api_url(params.entity, params), ["Content-Type: application/json"], false, HTTPClient.METHOD_POST, JSON.print(params))
		else:
			return HTTPRequest.request(get_api_url(params.entity, params))
	return show_loading(false)

