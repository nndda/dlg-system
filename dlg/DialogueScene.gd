extends Control


#	Add this scene as an autoload/singleton with the name "dlg"

var active = false
var step = 0
var current_set = []
var dialogue_text = "" setget set_dlg_txt, get_dlg_txt

func set_dlg_txt(v : String):
	dialogue_text = v
func get_dlg_txt():
	return dialogue_text

#	Load the main dictionary
var dictionary = "res://dlg/Sample Dictionary.tres"
var dict_chr = {}
var dict_cfg = {}

#	Containers, Portrait, and UI
onready var label_name = $Panel/Name
onready var dlg_display = $Panel/DlgLines
onready var portrait_display = $Panel/Portrait



func load_dict():

	var dict_raw = File.new()
	dict_raw.open( dlg.dictionary, File.READ )

	dlg.dict_chr = str2var( dict_raw.get_as_text() ).characters
	dlg.dict_cfg = str2var( dict_raw.get_as_text() )._CONFIG

	dict_raw.close()
	get_portrait_properties()


	# Start the dialogue
func start( dlg_sets_file : String ):

	var dlg_lines = File.new()
	dlg_lines.open( dlg_sets_file, File.READ )

	dlg.current_set = str2var( dlg_lines.get_as_text() )
	dlg_lines.close()

	dlg.active = true
	dlg_display.visible_characters = 0
	dlg.set_line(
		dlg.current_set[ dlg.step * 4		],
		dlg.current_set[ dlg.step * 4 + 1	],
		dlg.current_set[ dlg.step * 4 + 2	],
		dlg.current_set[ dlg.step * 4 + 3	]
		)


	# Stop the dialogue
func stop():
	dlg.step = 0
	dlg.dialogue_text = ""
	dlg.active = false


	# Set the dialogue line's properties to the container and portraits
func set_line(
	chr_name,
	chr_expressions,
	dlg_text,
	use_quotes
	):

	dlg.label_name.text = dlg.dict_chr[ chr_name ][ "label" ]
	dlg.portrait_display.region_rect = dlg.portrait_crop(
		dlg.dict_chr[ chr_name ]["expressions"][ chr_expressions ][ 0 ],
		dlg.dict_chr[ chr_name ]["expressions"][ chr_expressions ][ 1 ]
		)

	if !use_quotes:
		dlg.dialogue_text = dlg_text
	else:
		dlg.dialogue_text = "\"" + str(dlg_text) + "\""

	dlg.dlg_display.text = dlg.dialogue_text



	#	Portrait cropping
var portrait_grid_size = Vector2()		# Row and Column 
var portrait_size = Vector2()			# Portrait sheet image dimension
var portrait_chr_size = Vector2()
var portrait_gap = Vector2()

func get_portrait_properties():
	dlg.portrait_size = dlg.portrait_display.texture.get_size()
	dlg.portrait_chr_size = Vector2(
		dlg.dict_cfg["portrait_size_px"][0],
		dlg.dict_cfg["portrait_size_px"][1]
		)
	dlg.portrait_grid_size = Vector2(
		dlg.dict_cfg["portrait_size_grid"][0],
		dlg.dict_cfg["portrait_size_grid"][1]
		)
func set_portrait_gap():
	dlg.portrait_gap = Vector2(
		( dlg.portrait_size.x - ( dlg.portrait_chr_size.x * dlg.portrait_grid_size.x ) ) / dlg.portrait_grid_size.x / 2,
		( dlg.portrait_size.y - ( dlg.portrait_chr_size.y * dlg.portrait_grid_size.y ) ) / dlg.portrait_grid_size.y / 2
		)
func portrait_crop(
	column : int,
	row : int	):
	dlg.set_portrait_gap()
	return Rect2(
		( ( dlg.portrait_size.x / dlg.portrait_grid_size.x ) * column ) + dlg.portrait_gap.x,
		( ( dlg.portrait_size.y / dlg.portrait_grid_size.y ) * row ) + dlg.portrait_gap.y,
		dlg.portrait_chr_size.x,
		dlg.portrait_chr_size.y
		)



func _ready():

	dlg.load_dict()

func _process(_delta):
	self.visible = dlg.active

	if dlg.active:

		if Input.is_action_just_pressed( "ui_accept" ):
			dlg.step += 1

			if dlg.step * 4 >= dlg.current_set.size():
				dlg.stop()

			else:
				dlg_display.visible_characters = 0
				dlg.set_line(
					dlg.current_set[ dlg.step * 4		],
					dlg.current_set[ dlg.step * 4 + 1	],
					dlg.current_set[ dlg.step * 4 + 2	],
					dlg.current_set[ dlg.step * 4 + 3	]
					)

		var total_chr = dlg_display.get_total_character_count()

		if get_dlg_txt() != dlg.dialogue_text:
			set_dlg_txt( dlg.dialogue_text )
			dlg_display.text = get_dlg_txt()
			dlg_display.visible_characters = 0

		if dlg_display.visible_characters < total_chr:
			dlg_display.visible_characters += 1

