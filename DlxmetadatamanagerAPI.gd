extends Node

class_name DlxmetadatamanagerAPI 

# Token used for API authentication
var token = "4gZYp1S785NmOaHgxxAUsONsGMm0QIrSDbPDxz5QSRWCd1S0bGvbS3jCFdUzAHha"
# Possible URLs for the API
var uu = [ 
		"http://127.0.0.1:8089", 
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

func _call_login(params={}):
	"""
	Call the login API
	"""
	show_loading(true)
	return HTTPRequest.request(
		uu[env_select.get_selected_id()] + "/api/Users/login",
		["Content-Type: application/json"], 
		false, 
		HTTPClient.METHOD_POST, 
		JSON.print(params)
	)
	
func _call_entity(params={}, where={}):
	"""
	Call entity list
	"""
	show_loading(true)
	return HTTPRequest.request(
		uu[env_select.get_selected_id()] + 
			"/api/" + params.entity + "?" + 
			"filter=" +  ('{"where":' + JSON.print(where) + '}').percent_encode() + 
			"&access_token=" + token
	)

func call_api(action="", params={}):
	"""
	Calls the API
	"""
	show_loading(true)
	if action == "login":
		return _call_login(params)
	elif action == "getentity":
		params.limit = 20
		return _call_entity(params)
	return show_loading(false)

