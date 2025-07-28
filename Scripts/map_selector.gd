extends PopupPanel

signal map_selected(map_path: String) # Sygnał wybranej mapy

func _ready():
	var dir_path = "res://Scenes/Maps"
	var dir = DirAccess.open(dir_path)

	if dir == null:
		print("Nie udało się otworzyć katalogu:", dir_path)
		return

	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			var map_path_full = dir_path + "/" + file_name
			var map_name = file_name.get_basename()

			# KONTENER kafelka
			var tile = VBoxContainer.new()
			tile.size_flags_horizontal = Control.SIZE_FILL

			# PRZYCISK lub placeholder pod miniaturkę
			var button = Button.new()
			button.custom_minimum_size = Vector2(0, 100)  
			button.position = tile.position
			# Wczytujemy miniaturę, jeśli istnieje
			var thumbnail_path = dir_path + "/" + map_name + ".png"
			if FileAccess.file_exists(thumbnail_path):
				var texture = load(thumbnail_path)
				if texture:
					button.icon = texture
					button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER  # Ikonka na środku
					button.expand_icon = true  # Ikona wypełni przycisk
			button.connect("pressed", func(): emit_signal("map_selected", map_path_full))
			tile.add_child(button)

			# NAZWA mapy
			var label = Label.new()
			label.text = map_name
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.autowrap_mode = TextServer.AUTOWRAP_WORD
			tile.add_child(label)

			# Dodajemy do GridContainer
			$ScrollContainer/MarginContainer/GridContainer.add_child(tile)
