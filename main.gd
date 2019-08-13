extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var nline = 0
var maxlines = 65
var token = ""

func _ready():
	$ItemList.add_item('--- NAME ---')
	$ItemList.add_item('--- ORGANIZATION ---')
	$ItemList.add_item('--- DOCUMENTATION ---')
	$ItemList.add_item('--- HOST ---')

func get_api_url():
	token = $TextEdit.text
	#var uu = "http://localhost:8089"
	var uu = "http://ala01095.deluxe.com:8089"
	return uu + "/api/origins?access_token=" + token

func addLineToLog(msg):
	nline += 1
	if nline%maxlines == 0:
		$RichTextLabel.text = ""
	$RichTextLabel.text += "\n" + str(nline) + " : "  + str(OS.get_unix_time()) + " : " + msg

func _on_Button_button_up():
	$HTTPRequest.request(get_api_url())

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	display_in_grid(json.result)


func display_in_grid(data):
	for row in data:
		addLineToLog(str(row))
		$ItemList.add_item(row.name)
		$ItemList.add_item(row.organization)
		$ItemList.add_item(row.documentation)
		$ItemList.add_item(row.host)
