# region.gd
class_name Region extends Node3D

## A custom Node3D class representing a single region in the game world.
## This uses PascalCase for the class name as per GDScript style guide.

## The position of this region in the grid (e.g., (0, 0) to (7, 7)).
## Use Vector2i for integer grid coordinates.
var grid_position: Vector2i = Vector2i.ZERO

## A simple boolean state for example use.
var is_active: bool = false
var occupied_unit: Unit = null # NEW: Tracks the unit currently on this region

# Constants for the region's physical dimensions.
const REGION_SIZE: float = 80.0  # Width and depth of the tile
const TILE_HEIGHT: float = 0.5  # Thickness of the tile

const LAYER_REGION: int = 1                 # Collision layer 1 (bit 0) for the board
const LAYER_UNIT: int = 2  


## Constructor for the Region.
func _init(position: Vector2i = Vector2i.ZERO) -> void:
	# Set the grid position
	self.grid_position = position
	
	# Name the node descriptively based on its position for easier debugging in the scene tree.
	self.name = "Region_%s_%s" % [position.x, position.y]
	
	# Calculate the 3D position for the center of the grid tile.
	# The Y position is set so the top surface of the tile is exactly at Y=0.
	self.position = Vector3(
		float(position.x) * (REGION_SIZE + (REGION_SIZE / 8.0)),
		-TILE_HEIGHT / 2.0, 
		float(position.y) * (REGION_SIZE + (REGION_SIZE / 8.0))
	)
	

	# Set up the visual mesh and collision shape
	_setup_visuals_and_collision()

	print("Initialized region: %s at 3D position %s" % [self.name, self.position])


## Helper function to create the MeshInstance3D and CollisionShape3D.
func _setup_visuals_and_collision() -> void:
	# --- 1. Static Body (Physics Root) ---
	# StaticBody3D is the base for rigid bodies that are not meant to move.
	var static_body := StaticBody3D.new()
	static_body.name = "PhysicsRoot"
	
	#static_body.position = self.position
	
	# Setup Collision Layers:
	static_body.set_collision_layer_value(LAYER_REGION, true)
	static_body.set_collision_mask_value(LAYER_UNIT, true) # Collide with UNITS

	add_child(static_body)
	
	# --- 2. Visual Mesh (The Box) ---
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TileMesh"
	
	var box_mesh := BoxMesh.new()
	# The size of the mesh is (width, height, depth)
	box_mesh.size = Vector3(REGION_SIZE, TILE_HEIGHT, REGION_SIZE)
	
	# Create a simple material to make the regions visible
	var standard_material := StandardMaterial3D.new()
	#standard_material.albedo_color = Color.DARK_GREEN 
	standard_material.albedo_color = Color(0.2 + (0.8 * randf()), 0.6, 0.2) 
		
	box_mesh.material = standard_material
	
	mesh_instance.mesh = box_mesh
	static_body.add_child(mesh_instance)
	
	# --- 3. Collision Shape (The Bounding Box) ---
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "TileCollision"
	
	var box_shape := BoxShape3D.new()
	# The collision shape size should match the mesh size exactly.
	box_shape.size = Vector3(REGION_SIZE, TILE_HEIGHT, REGION_SIZE)
	
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	
func _physics_process(delta):
	pass
	rotation.x += (0.0 * delta)
	
	
	
## NEW: Places a unit on this region.
## Sets the unit's position and updates both the unit's and region's state.
func add_unit(unit: Unit) -> bool:
	if occupied_unit:
		push_warning("Region %s is already occupied by unit %s." % [name, occupied_unit.name])
		return false
		
	
	# Calculate the starting position 10 units above the center of the tile.
	var start_pos: Vector3 = Vector3(global_position.x, 10.0, global_position.z)
	
	# FIX: Set the position directly and zero the velocity. This is generally the most 
	# reliable method for preventing tunneling when spawning RigidBody3D nodes in Godot 4, 
	# assuming the unit has already been added to the scene tree.
	unit.global_position = start_pos
	unit.linear_velocity = Vector3.ZERO
	
	unit.grid_position = grid_position
	occupied_unit = unit
	print("Unit %s added to region %s." % [unit.name, name])
	return true


## NEW: Removes the unit from this region.
func remove_unit() -> Unit:
	if !occupied_unit:
		return null
		
	var unit_to_remove: Unit = occupied_unit
	occupied_unit = null
	unit_to_remove.grid_position = Vector2i(-1, -1) # Mark unit as off-grid
	print("Unit %s removed from region %s." % [unit_to_remove.name, name])
	return unit_to_remove
