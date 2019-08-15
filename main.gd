extends Node2D

const DlxmetadatamanagerAPI = preload("res://DlxmetadatamanagerAPI.gd")
const GraphProcessing = preload("res://GraphProcessing.gd")

# Container array for the nodes we are displaying in the graph
var api : DlxmetadatamanagerAPI
var graphProcessing : GraphProcessing

func _ready():
	"""
	Initialization when the scene is ready
	"""
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
		elif json.result[0] and json.result[0].has("name"):
			graphProcessing.add_origin_nodes(json.result)
	api.show_loading(false)

func _on_Button_button_up():
	"""
	Executed when the Origins button was pressed
	"""
	api.call_api({"entity":"origins"})

func _on_btn_databases_button_up():
	"""
	Executed when the Databases button was pressed
	"""
	api.call_api({"entity":"databases"})

func _on_btn_schemas_button_up():
	"""
	Executed when the Schemas button was pressed
	"""
	api.call_api({"entity":"schemas"})

func _on_btn_tables_button_up():
	"""
	Executed when the Tables button was pressed
	"""
	api.call_api({"entity":"tables"})

func _on_btn_fields_button_up():
	"""
	Executed when the Fields button was pressed
	"""
	api.call_api({"entity":"fields"})

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
	api.call_api({"entity": "login", "username": username_txt, "password": password_txt})

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
	print(msg)
	$MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text = msg + "\n" + $MainGUI2D/VSplitContainer/PanelContainer/RichTextLabel.text


