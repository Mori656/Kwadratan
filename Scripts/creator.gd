extends Node2D

@export var map_tile: PackedScene
@export var map_point: PackedScene 
@export var tile_count_h: int = 10
@export var tile_count_w: int = 20

var offsets = [ #do sprawdzania sąsiedztwa
	Vector2i(0, 0),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(-1, -1)
]

func _ready():
	for height in range(tile_count_h):
		for width in range(tile_count_w):
			var tile = map_tile.instantiate()
			#pozycja i wartości dla kafelków
			tile.position = Vector2(width * 16, 0 + (16 * height))
			tile.row = width
			tile.column = height
			tile.value = 0  # narazie 0
			tile.active = false
			$tiles.add_child(tile)
			tile.owner = self #do zapisu mapy
			# Podpinamy sygnał i bindowanie tile jako argument (żeby później korzystać z jego funkcji) - Pierwsze kliknięcie
			tile.connect("input_event", Callable(self, "_on_tile_clicked").bind(tile))
			# NOWA LINIA: Podpinamy sygnał mouse_entered (dla przeciągania/rysowania)
			tile.connect("mouse_entered", Callable(self, "_on_tile_mouse_entered").bind(tile))
			#tile.add_to_group("tiles") #do iteracji
			
	# dodajemy punkt w lewym górnym rogu kafla 
	for height in range(tile_count_h + 1):
			for width in range(tile_count_w + 1):
				var point = map_point.instantiate()
				point.position = Vector2(width * 16 - 8, 0 + (16  * height) - 8) 
				point.row = height
				point.column = width
				#ustalanie sąsiadów dla każdego punktu
				var local_neighbors = []
				for offset in offsets:
					var nx = width + offset.x
					var ny = height + offset.y
					# Sprawdź czy sąsiad jest w granicach mapy 
					if nx >= 0 and nx < tile_count_w and ny >= 0 and ny < tile_count_h:
						local_neighbors.append(Vector2i(nx, ny))
		
				point.neighbors = local_neighbors
				print( point.neighbors)
				print(point.row, " " , point.column )
				$points.add_child(point)
				point.owner = self # do zapisu mapy
				#point.add_to_group("points") #do iteracji


#zmiana stanu kafelka po kliknięciu
func _on_tile_clicked(_viewport, event, _shape_idx, tile): # _ żeby warningów nie było - to chyba weak declare
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile.toggle_active()
		activate_points_with_neighbors(tile) #aktywuj pointy sąsiadujące z tym tile
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if tile.active:
			tile.toggle_active()
			deactivate_unused_points(tile) #deaktywuj pointy bez sąsiadów

# Nowa funkcja do "rysowania" po kafelkach (i usuwania)
func _on_tile_mouse_entered(tile):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		tile.set_active(true);
		activate_points_with_neighbors(tile) #aktywuj pointy sąsiadujące z tym tile
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		tile.set_active(false);
		deactivate_unused_points(tile) #deaktywuj pointy bez sąsiadów

func _on_button_pressed() -> void:
	#obsługa nazwy i duplikatów
	var map_name = $GUI/map_name_input.text.strip_edges()
	if map_name == "":
		$GUI/info_label.text = "⚠️ Please enter map name!"
		return
	
	var path = "res://Scenes/Maps/" + map_name + ".tscn"
	
	if FileAccess.file_exists(path):
		$GUI/info_label.text = "❌ A map with that name already exists!!"
		return
	save_current_map(path)

#zapis sceny
func save_current_map(path: String):
	# Odłączamy node do eksportu
	var GUI = $GUI
	remove_child(GUI)
	# Zmiana skryptu dla wyeksportowanej mapy
	var runtime_script = load("res://Scripts/map.gd")
	set_script(runtime_script)
	#eksport do zmiennych
	var new_scene = PackedScene.new()
	var result = new_scene.pack(self)
	# Przywracamy domyślne ustawienia
	add_child(GUI)
	set_script(preload("res://Scripts/creator.gd"))

	if result == OK:
		var error = ResourceSaver.save(new_scene, path)
		if error == OK:
			print("Mapa pomyślnie zapisana w: ", path)
		else:
			print("Błąd podczas zapisywania mapy: ", error)
	else:
		print("Błąd podczas pakowania sceny: ", result)
		
func activate_points_with_neighbors(tile):
	for point in $points.get_children():
			for neighbor in point.neighbors:
				if neighbor.x == tile.row and neighbor.y == tile.column:
					point.active = true
					break  # ma sąsiada więc aktywny

func deactivate_unused_points(tile):
	for point in $points.get_children():
		var still_has_active_neighbor = false
		for neighbor in point.neighbors:
			# Szukamy tile pasującego do neighbor
			for other_tile in $tiles.get_children():
					if other_tile.row == neighbor.x and other_tile.column == neighbor.y and other_tile.active:
						still_has_active_neighbor = true
						break
		if !still_has_active_neighbor:
			point.active = false
