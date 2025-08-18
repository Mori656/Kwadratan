extends Node2D

@export var map_tile: PackedScene
@export var map_point: PackedScene 
@export var tile_count_h: int = 10
@export var tile_count_w: int = 20
var screensize = Vector2i(640,360)
var offsets = [ #do sprawdzania sąsiedztwa
	Vector2i(0, 0),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(-1, -1)
]

func _ready():
	print("EKRAN" , screensize)
	for height in range(tile_count_h):
		for width in range(tile_count_w):
			var tile = map_tile.instantiate()
			#pozycja i wartości dla kafelków
			tile.position = Vector2(width * 16 + 8, 8 + (16 * height))
			tile.position += Vector2(screensize.x /2 - tile_count_w/2*16 +8, screensize.y /2 - tile_count_h/2*16 +8 )
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
				point.position = Vector2(width * 16 - 8 + 8, 8 + (16  * height) - 8) 
				point.position += Vector2(screensize.x /2 - tile_count_w/2*16 +8, screensize.y /2 - tile_count_h/2*16 +8 )
				point.row = width
				point.column = height
				
				#ustalanie sąsiadów dla każdego punktu
				var local_neighbors = []
				for offset in offsets:
					var nx = width + offset.x
					var ny = height + offset.y
					# Sprawdź czy sąsiad jest w granicach mapy 
					if nx >= 0 and nx < tile_count_w and ny >= 0 and ny < tile_count_h:
						local_neighbors.append(Vector2i(nx, ny))
		
				point.neighbors = local_neighbors
				#print( point.neighbors)
				#print(point.row, " " , point.column )
				$points.add_child(point)
				point.owner = self # do zapisu mapy
				#point.add_to_group("points") #do iteracji

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if multiplayer.get_multiplayer_peer():
			multiplayer.get_multiplayer_peer().close() #rozłączenie
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

#zmiana stanu kafelka po kliknięciu
func _on_tile_clicked(_viewport, event, _shape_idx, tile): # _ żeby warningów nie było - to chyba weak declare
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and !tile.active:
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
	var map_name = $CanvasLayer/GUI/map_name_input.text.strip_edges()
	if map_name == "":
		$CanvasLayer/GUI/info_label.text = "⚠️ Please enter map name!"
		return
	
	var path = "res://Scenes/Maps/" + map_name
	
	if FileAccess.file_exists(path + ".tscn"):
		$CanvasLayer/GUI/info_label.text = "❌ A map with that name already exists!!"
		return
	save_current_map(path)

#zapis sceny
func save_current_map(path: String):
	var image_path = path + ".png"
	var map_path = path + ".tscn"
	# Odłączamy node do eksportu
	var GUI = $CanvasLayer/GUI
	GUI.visible = false # do screena
	#remove_child(GUI)
	# Zmiana skryptu dla wyeksportowanej mapy
	var runtime_script = load("res://Scripts/map.gd")
	set_script(runtime_script)
	#eksport do zmiennych
	var new_scene = PackedScene.new()
	var result = new_scene.pack(self)
	
	
	
	#generuj miniaturke mapy - stabliność 
	call_deferred("generate_map_thumbnail", image_path)
	
	# Przywracamy domyślne ustawienia
	#add_child(GUI)
	GUI.visible = true
	set_script(preload("res://Scripts/creator.gd"))

	if result == OK:
		var error = ResourceSaver.save(new_scene, map_path)
		if error == OK:
			print("Mapa pomyślnie zapisana w: ", map_path)
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

func generate_map_thumbnail(path: String):
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()
	img.save_png(path)
