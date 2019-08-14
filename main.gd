extends Node2D

var nodes = []
var token = "4gZYp1S785NmOaHgxxAUsONsGMm0QIrSDbPDxz5QSRWCd1S0bGvbS3jCFdUzAHha"
var uu = [ "http://localhost:8089", "http://ala01095.deluxe.com:8089"]

func _ready():
	"""
	Initialization when the scene is ready
	"""
	_log("OS name: " + OS.get_name())
	_log("OS class: " + OS.get_class())
	_log("OS date time: " + str(OS.get_datetime()))
	_log("Engine properties: " + str(Engine.get_property_list()))
	
	var envm = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/env_select
	envm.add_item("Localhost", 0)
	envm.add_item("Datascience VM", 1)
	
	$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit/GraphNode.visible = false
	show_loading(false)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	"""
	Executed when we have a complete response from the the HTTP request
	"""
	var json = JSON.parse(body.get_string_from_utf8())
	_log(str(json.result))
	if response_code == 200:
		if json.result.has("error"):
			_log("API ERROR!!!!!")
		elif json.result.has("created") and json.result.has("id"):
			token = json.result.id
			_log("New token set to : " + token)
		elif json.result[0] and json.result[0].has("name"):
			add_origin_nodes(json.result)
	show_loading(false)

func _on_Button_button_up():
	"""
	Executed when the Origins button was pressed
	"""
	call_api({"entity":"origins"})

func _on_btn_databases_button_up():
	"""
	Executed when the Databases button was pressed
	"""
	call_api({"entity":"databases"})

func _on_btn_schemas_button_up():
	"""
	Executed when the Schemas button was pressed
	"""
	call_api({"entity":"schemas"})

func _on_btn_tables_button_up():
	"""
	Executed when the Tables button was pressed
	"""
	call_api({"entity":"tables"})

func _on_btn_fields_button_up():
	"""
	Executed when the Fields button was pressed
	"""
	call_api({"entity":"fields"})

func _on_btn_test_button_up():
	"""
	Executed when the Duplicate table button was pressed
	"""
	create_node("Table " + str(len(nodes)), [
		{'name':'field 01', 'is_pk':1, 'is_fk':0},
		{'name':'field 02', 'is_pk':0, 'is_fk':0},
		{'name':'field 03', 'is_pk':0, 'is_fk':1},
		{'name':'field 04', 'is_pk':0, 'is_fk':0},
		{'name':'field 05', 'is_pk':0, 'is_fk':0},
		{'name':'field 06', 'is_pk':0, 'is_fk':0},
		{'name':'field 07', 'is_pk':0, 'is_fk':0},
		{'name':'field 08', 'is_pk':0, 'is_fk':0},
		{'name':'field 09', 'is_pk':0, 'is_fk':0}
	])

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	"""
	Manages the connection in between table entities
	"""
	$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.connect_node(from, from_slot, to, to_slot)


func _on_btn_submit_button_up():
	"""
	Executed when the submit (username/password) was pressed
	"""
	var username_txt = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_username.text
	var password_txt = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_password.text
	call_api({"entity": "login", "username": username_txt, "password": password_txt})

func _on_btn_clearnodes_button_up():
	"""
	Executed when clear all nodes button is clicked
	"""
	clear_all_nodes()

func get_api_url(model="origins", params={}):
	"""
	Returns the URL of the API
	"""
	var uuenv = uu[$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/env_select.get_selected_id()]
	var prms = "/api/" + model + "?"
	if model == "tables":
		prms += "filter=%7B%22where%22:%7B%22schemas_idh%22:%2270807018e45b3b6ea4dee1a1a3fed17e%22%7D%7D"
	if model == "login":
		return uuenv + "/api/Users/login"
	else:
		prms += "filter=%7B%22limit%22%3A99%7D"
	return uuenv + prms + "&access_token=" + token

func _log(msg):
	"""
	Writes to the visual console in the GUI
	"""
	print(msg)
	#"\n" + str(OS.get_unix_time()) + " : " + msg
	$MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text = msg + "\n" + $MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text

func show_loading(on = true):
	if on:
		$LoadingNode2D.visible = true
		$LoadingNode2D/LoadingNode/LoadingWindowDialog.show()
	else:
		$LoadingNode2D.visible = false
		$LoadingNode2D/LoadingNode/LoadingWindowDialog.hide()		

func create_node(title="", elems=[]):
	"""
	Create a new table node in the graph
	
	@param title The title of the window
	@param elems Array of elements (fields) to populate in the node
	"""
	nodes.append($MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit/GraphNode.duplicate())
	var arnbr = len(nodes)-1
	$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.add_child(nodes[arnbr])
	var n : GraphNode = nodes[arnbr]
	n.title = title
	var vv = n.get_offset()
	vv.x += 20*(arnbr+1)
	vv.y += 20*(arnbr+1)
	n.set_offset(vv)
	# Loop in the elements array (adding field names)
	var idx = 0
	for i in elems:
		var lbl = Label.new()
		lbl.text = i.name
		n.add_child(lbl)
		# Makes connector available for the PK and FKs
		if i.is_pk == 1 or i.is_fk == 1:
			n.set_slot(idx, true, 0, Color.blue, true, 0, Color.white)
		idx += 1
	# make it visible when the rest was done
	n.visible = true

func clear_all_nodes():
	"""
	Clear all the nodes in the graph
	"""
	var kids = $MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.get_children()
	$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.clear_connections()
	
	for kid in kids:
		if kid.is_class("GraphNode"):
			var k : GraphNode = kid
			if k.title != "TABLE (model)":
				kid.clear_all_slots()
				$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.remove_child(kid)
	nodes = []

func call_api(params={}):
	"""
	Calls the API
	"""
	show_loading(true)
	if params.entity != "":
		if params.entity == "login":
			return $HTTPRequest.request(get_api_url(params.entity, params), ["Content-Type: application/json"], false, HTTPClient.METHOD_POST, JSON.print(params))
		else:
			return $HTTPRequest.request(get_api_url(params.entity, params))
	
	return show_loading(false)

func add_origin_nodes(e=[]):
	"""
	Add nodes to the graph
	"""
	for n in e:
		create_node(n.name)

