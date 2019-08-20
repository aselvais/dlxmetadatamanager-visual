extends Node

class_name GraphProcessing

var _GraphEdit : GraphEdit
var _GraphNode : GraphNode
var nodes = []

func _init(graphEdit, graphNode):
	"""
	Constructor
	"""
	_GraphEdit = graphEdit
	_GraphNode = graphNode
	_GraphNode.visible = false
	pass

func create_node(title="", elems=[]):
	"""
	Create a new table node in the graph
	
	@param title The title of the window
	@param elems Array of elements (fields) to populate in the node
	"""
	nodes.append(_GraphNode.duplicate())
	var arnbr = len(nodes)-1
	_GraphEdit.add_child(nodes[arnbr])
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
		if i.has('datatype') and i.has('datalength'):
			lbl.text += "  <" + str(i.datatype) + '(' + str(i.datalength) + ')>'
		n.add_child(lbl)
		# Makes connector available for the PK and FKs
		#if i.is_pk == 1 or i.is_fk == 1:
		#	n.set_slot(idx, true, 0, Color.blue, true, 0, Color.white)
		if i.is_pk == 1:
			n.set_slot(idx, true, 0, Color.white, true, 0, Color.white)
		if i.is_fk == 1:
			n.set_slot(idx, true, 0, Color.red, true, 0, Color.red)
		idx += 1
	# make it visible when the rest was done
	n.visible = true

func clear_all_nodes():
	"""
	Clear all the nodes in the graph
	"""
	var kids = _GraphEdit.get_children()
	_GraphEdit.clear_connections()
	
	for kid in kids:
		if kid.is_class("GraphNode"):
			var k : GraphNode = kid
			if k.title != "TABLE (model)":
				kid.clear_all_slots()
				_GraphEdit.remove_child(kid)
	nodes = []

func add_test_table():
	"""
	Adds a test table
	@todo Remove this thing when prod ready
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
	
func connect_node(from, from_slot, to, to_slot):
	"""
	Connecting nodes together (use by the event _on_GraphEdit_connection_request in main.gd)
	"""
	_GraphEdit.connect_node(from, from_slot, to, to_slot)

func add_nodes(e=[]):
	"""
	Add nodes to the graph
	"""
	for n in e:
		var flds = []
		var name = n.name
		if n.fields:
			flds = n.fields
		create_node(n.name, flds)



