# world_manager.gd
class_name WorldManager extends Node3D

## Manages the creation and access of all Region nodes in an 8x8 grid,
## and sets up the basic scene environment (camera, light, and environment).

## The size of the region grid (8x8).
const GRID_SIZE: int = 8

## The physical length/width of the entire grid area.
const GRID_WORLD_SIZE: float = float(GRID_SIZE) * 90.0

## The 8x8 dictionary holding all Region instances.
## Key: Vector2i (grid coordinates), Value: Region instance.
var region_dictionary: Dictionary = {}

## NEW: Container node to hold all Region instances for easy manipulation.
var regions_container: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_regions_container() # Must be called first to create the container
	
	_initialize_regions()
	_setup_camera()
	_setup_light()
	_setup_environment() # NEW: Setup a default environment
	
	# NEW: Setup units after grid is ready
	_initialize_units() 
	
	# Example of accessing a region after initialization:
	var region_3_5: Region = get_region(3, 5)
	if region_3_5:
		print("\nSuccessfully retrieved region %s at grid position %s." % [region_3_5.name, region_3_5.grid_position])
		region_3_5.is_active = true
		print("Region 3,5 activation status: %s" % region_3_5.is_active)

## NEW: Sets up the parent Node3D for all regions.
func _setup_regions_container() -> void:
	regions_container = Node3D.new()
	regions_container.name = "RegionsContainer"
	
	# Add the container as a child of the WorldManager (self).
	add_child(regions_container) 
	print("Regions container setup complete.")



## Creates an 8x8 grid of Region nodes, adds them to the scene tree,
## and stores them in the region_dictionary.
func _initialize_regions() -> void:
	print("--- Starting Region Initialization (Grid Size: %dx%d) ---" % [GRID_SIZE, GRID_SIZE])
	
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var grid_pos: Vector2i = Vector2i(x,y)
			
			# 1. Create the new Region instance using the custom class
			var new_region: Region = Region.new(grid_pos)
			
			# 2. Add the Region to the scene tree (making WorldManager its parent)
			#add_child(new_region)
			# 2. Add the Region to the new container node. (CRITICAL CHANGE)
			regions_container.add_child(new_region)
			# 3. Store the Region in the dictionary using its Vector2i position as the key
			region_dictionary[grid_pos] = new_region
			
			# The Region's own constructor will print its initialization status.

	print("\n--- Region Initialization Complete ---")
	print("Total regions created: %s" % region_dictionary.size())

## NEW: Creates and places initial Unit nodes on the grid.
func _initialize_units() -> void:
	print("\n--- Starting Unit Initialization ---")
	
	#var unit_a: Unit = Unit.new("Hero")
	# Units must be added to the scene tree (under WorldManager)
	# before they are placed using the Region's methods.
	#add_child(unit_a)
	#add_child(unit_b)
	#var unit_b: Unit = Unit.new("Enemy")
	# Place Unit A at (0, 0)
	#var start_region: Region = get_region(0, 0)
	#if start_region:
		#start_region.add_unit(unit_a)
		
		
	for x in range( GRID_SIZE):
		for z in range(2):
			var unit_t;
			var region_t;
			unit_t = Unit.new("Enemy")
			add_child(unit_t)
			region_t = get_region( x, GRID_SIZE - 1 - z)
			if region_t:
				region_t.add_unit( unit_t)
	
	for x in range( GRID_SIZE):
		for z in range(2):
			var unit_t;
			var region_t;
			unit_t = Unit.new("Hero")
			add_child(unit_t)
			region_t = get_region( x, z)
			if region_t:
				region_t.add_unit( unit_t)
	
	
	# Place Unit B at (7, 7)
	#var end_region: Region = get_region(GRID_SIZE - 1, GRID_SIZE - 1)
	#if end_region:
		#end_region.add_unit(unit_b)
		
		

			
	print("Unit initialization complete.")
	#print("Placed %s at %s" % [unit_a.name, unit_a.grid_position])
	#print("Placed %s at %s" % [unit_b.name, unit_b.grid_position])


## Sets up a Camera3D positioned to view the entire grid.
func _setup_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "SceneCamera"
	
	# Calculate the center point of the grid.
	var center_target := Vector3(GRID_WORLD_SIZE / 2.0, 0.0, GRID_WORLD_SIZE / 2.0)
	#center_target = Vector3( 0, 0, 0)
	
	# Position the camera high up, slightly offset back and rotated.
	# The '60' is a good height to capture the full 80x80 area.
	camera.position = Vector3(
		center_target.x,
		490.0,
		center_target.z - 360.0 - 100.0# Move back a bit on the Z axis
	)
	#camera.position = Vector3(
		#0.0,
		#500.0,
		#0.0 # Move back a bit on the Z axis
	#)
	# Point the camera directly at the center of the grid.
	#camera.look_at_from_position(center_target, Vector3.UP)
	
	camera.look_at_from_position(camera.position, center_target, Vector3.UP)
	#camera.rotation.x = -1.52
	# Make this camera the active camera when the scene runs.
	camera.make_current()
	
	add_child(camera)
	print("Camera setup complete.")


## Sets up a DirectionalLight3D for basic scene illumination.
func _setup_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SunLight"
	
	# Position the light high above the center of the grid.
	# While position doesn't affect directional light, it helps with organization.
	light.position = Vector3(GRID_WORLD_SIZE, 100.0, GRID_WORLD_SIZE)
	
	# Rotate the light to simulate sunlight coming from the top-left (X: -45, Y: -45 degrees)
	light.rotation_degrees = Vector3(-45.0, -45.0, 0.0)
	light.light_color = Color.from_hsv(0.1, 0.1, 1.0) # Slightly yellow/warm tint
	
	# Enable shadows for a better 3D look
	light.shadow_enabled = true
	
	add_child(light)
	print("Directional light setup complete.")


## Sets up a WorldEnvironment node with a basic sky for ambient illumination.
func _setup_environment() -> void:
	var environment_node := WorldEnvironment.new()
	environment_node.name = "WorldEnvironment"
	
	var environment := Environment.new()
	
	# Create a simple procedural sky
	var sky := Sky.new()
	var procedural_sky := ProceduralSkyMaterial.new()
	sky.sky_material = procedural_sky
	
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	
	environment_node.environment = environment
	add_child(environment_node)
	print("World environment setup complete.")


## Provides safe access to a region using grid coordinates.
func get_region(x: int, y: int) -> Region:
	var grid_pos: Vector2i = Vector2i(x, y)
	
	if region_dictionary.has(grid_pos):
		# We know the value is a Region because that's what we put in.
		return region_dictionary[grid_pos] as Region
	
	push_error("Attempted to access non-existent region at: %s" % grid_pos)
	return null
