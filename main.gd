extends Node2D

const DlxmetadatamanagerAPI = preload("res://DlxmetadatamanagerAPI.gd")
const GraphProcessing = preload("res://GraphProcessing.gd")

# Container array for the nodes we are displaying in the graph
var api : DlxmetadatamanagerAPI
var graphProcessing : GraphProcessing
var origins_list
var databases_list
var schemas_list
var tables_list
var origins_selected
var databases_selected
var schemas_selected
var tables_selected

func _ready():
	"""
	Initialization when the scene is ready
	"""
	_show_hidden_gui_elements(false)
	api = DlxmetadatamanagerAPI.new( 
			$LoadingNode2D,
			$LoadingNode2D/LoadingNode/LoadingWindowDialog,
			$HTTPRequest, 
			$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/env_select
	)
	graphProcessing = GraphProcessing.new(
			$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit, 
			$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit/GraphNode
	)
	_log("OS name: " + OS.get_name())
	_log("OS class: " + OS.get_class())
	_log("OS date time: " + str(OS.get_datetime()))
	_log("Engine properties: " + str(Engine.get_property_list()))
	var envm : OptionButton = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/env_select
	envm.add_item("Localhost", 0)
	envm.add_item("Datascience VM", 1)
	api.show_loading(false)

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
			api.token = json.result.id
			_log("New token set to : " + api.token)
			_show_hidden_gui_elements()
			api.call_api("getentity", {"entity":"origins"})
		elif json.result[0] and json.result[0].has("name"):
			if json.result[0].has("origins_idh"):
				# Databases
				graphProcessing.clear_all_nodes()
				databases_list = json.result
				_populate_option_button($MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/databases_select, json.result)
			elif json.result[0].has("databases_idh"):
				# Schemas
				graphProcessing.clear_all_nodes()
				schemas_list = json.result
				_populate_option_button($MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/schemas_select, json.result)
			elif json.result[0].has("schemas_idh"):
				# Tables
				graphProcessing.clear_all_nodes()
				tables_list = json.result
				#_populate_option_button($MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/tables_select, json.result)
				graphProcessing.add_nodes(tables_list)
			elif json.result[0].has("tables_idh"):
				# Fields
				#_populate_option_button($MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/fields_select, json.result)
				pass
			else:
				# Origins
				graphProcessing.clear_all_nodes()
				origins_list = json.result
				_populate_option_button($MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/origins_select, json.result)
	api.show_loading(false)
	
func _populate_option_button(btn : OptionButton, values):
	"""
	Populate data to a drop down
	"""
	btn.clear()
	var u = 0
	btn.add_item("----", 0)
	for i in values:
		u += 1
		btn.add_item(i.name, u)
	btn.selected = -1

func _on_origins_select_item_selected(ID):
	"""
	When origin selected
	"""
	origins_selected = origins_list[ID-1]
	api._call_entity({"entity":"databases"}, {"origins_idh": origins_selected.idh})

func _on_databases_select_item_selected(ID):
	"""
	When databases selected
	"""
	_log(str(ID))
	databases_selected = databases_list[ID-1]
	api._call_entity({"entity":"schemas"}, {"databases_idh": databases_selected.idh})

func _on_schemas_select_item_selected(ID):
	"""
	When schemas selected
	"""
	_log(str(ID))
	schemas_selected = schemas_list[ID-1]
	# api._call_entity({"entity":"tables"}, {"schemas_idh": schemas_selected.idh})
	api._call_tables_and_fields({"entity":"tables"}, {"schemas_idh": schemas_selected.idh})

func _on_btn_test_button_up():
	"""
	Executed when the Duplicate table button was pressed
	"""
	graphProcessing.add_test_table()

func _on_btn_submit_button_up():
	"""
	Executed when the submit (username/password) was pressed
	"""
	var username_txt = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_username.text
	var password_txt = $MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_password.text
	api.call_api("login", {"entity": "login", "username": username_txt, "password": password_txt})

func _on_btn_clearnodes_button_up():
	"""
	Executed when clear all nodes button is clicked
	"""
	graphProcessing.clear_all_nodes()

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	"""
	Manages the connection in between table entities
	"""
	graphProcessing.connect_node(from, from_slot, to, to_slot)

func _log(msg):
	"""
	Writes to the visual console in the GUI
	"""
	#print(msg)
	#$MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text = msg + "\n" + $MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text
	pass

func _show_hidden_gui_elements(loggedin=true):
	"""
	Hides the login form and show the rest of the GUI
	"""
	$MainGUI2D/VSplitContainer/PanelContainer.visible = false
	$MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.visible = false
	# hide GUI
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/env_select.visible = !loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/label_username.visible = !loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_username.visible = !loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/label_password.visible = !loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/input_password.visible = !loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/btn_submit.visible = !loggedin
	# show GUI
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/label_APIs2.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/btn_test.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/label_APIs3.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/btn_clearnodes.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/label_APIs4.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/origins_select.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/databases_select.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/schemas_select.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/Label01.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/Label02.visible = loggedin
	$MainGUI2D/VSplitContainer/HSplitContainer/PanelContainer/VBoxContainer/Label03.visible = loggedin
	$MainGUI2D/VSplitContainer/PanelContainer.visible = loggedin
	#$MainGUI2D/VSplitContainer/HSplitContainer/GraphEdit.visible = loggedin
