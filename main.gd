extends Node2D

var nodes = []
var token = "6RfEWmbpVckHUNOCYYorC6aExrOfXvFFFoEXSwSayrxghyHIJGUPQSZCJm2Ay52d"
var uu = "http://localhost:8089"
#var uu = "http://ala01095.deluxe.com:8089"

func _ready():
	$VSplitContainer/HSplitContainer/GraphEdit/GraphNode.visible = false
	pass

func get_api_url(model="origins"):
	return uu + "/api/" + model + "?access_token=" + token

func addLineToLog(msg):
	$VSplitContainer/PanelContainer/RichTextLabel.text = msg #"\n" + str(OS.get_unix_time()) + " : " + msg

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	addLineToLog(str(json.result))

func _on_Button_button_up():
	$HTTPRequest.request(get_api_url("origins"))

func _on_btn_databases_button_up():
	$HTTPRequest.request(get_api_url("databases"))

func _on_btn_schemas_button_up():
	$HTTPRequest.request(get_api_url("schemas"))

func _on_btn_tables_button_up():
	$HTTPRequest.request(get_api_url("tables"))

func _on_btn_fields_button_up():
	$HTTPRequest.request(get_api_url("fields"))


func _on_btn_test_button_up():
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

func create_node(title="", elems=[]):
	nodes.append($VSplitContainer/HSplitContainer/GraphEdit/GraphNode.duplicate())
	var arnbr = len(nodes)-1
	$VSplitContainer/HSplitContainer/GraphEdit.add_child(nodes[arnbr])
	var n : GraphNode = nodes[arnbr]
	n.title = title
	var vv = n.get_offset()
	vv.x += 20*(arnbr+1)
	vv.y += 20*(arnbr+1)
	n.set_offset(vv)
	
	var idx = 0
	for i in elems:
		var lbl = Label.new()
		lbl.text = i.name
		n.add_child(lbl)
		if i.is_pk == 1 or i.is_fk == 1:
			n.set_slot(idx, true, 0, Color.aliceblue, true, 0, Color.aliceblue)
		idx += 1
	
	n.visible = true
	# set_slot ( int idx, 	bool enable_left, int type_left, Color color_left, bool enable_right, int type_right, Color color_right, Texture custom_left=null, Texture custom_right=null )
