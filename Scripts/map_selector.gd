extends PopupPanel

signal map_selected(map_path: String) # Sygnał wybranej mapy

func _ready():
	var dir_path = "res://Scenes/Maps"
	var dir = DirAccess.open(dir_path)

	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			var base_name = file_name.get_basename()
			var thumbnail_path = base_name + ".png"
			print(thumbnail_path)
			var button = Button.new()
			button.text = base_name
			# Ikonka dla buttona - narazie tak (placeholder powiedzmy)
			var icon_texture_rect = TextureRect.new()
			icon_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED # 
			var desired_icon_size = Vector2(32, 32) 
			icon_texture_rect.custom_minimum_size = desired_icon_size

			if FileAccess.file_exists(dir_path+ "/" + thumbnail_path):
				var texture = load(dir_path+ "/" + thumbnail_path)
				if texture:
					icon_texture_rect.texture = texture
				else:
					print("Failed to load thumbnail texture")
			else:
				print("thumbnail doesn't exist")
			button.add_child(icon_texture_rect)

			var map_path_full = dir_path + "/" + file_name
			button.connect("pressed", func(): emit_signal("map_selected", map_path_full))
			$GridContainer.add_child(button)
