# unit.gd
class_name Unit extends RigidBody3D

## A base class for characters or pieces that occupy a region.

# --- State Variables ---
var grid_position: Vector2i = Vector2i.ZERO
var max_health: int = 100
var current_health: int = 100
var move_range: int = 3 # Represents regions/tiles the unit can move
var is_turn_active: bool = false

## The target list of other Unit nodes.
var target_units: Array[Unit] = [] 

# Constants for the unit's physical dimensions.
const UNIT_RADIUS: float = 20.5
const UNIT_HEIGHT: float = 30.0

const LAYER_REGION: int = 1                 # Collision layer 1 (bit 0) for the region
const LAYER_UNIT: int = 2  

## Constructor for the Unit.
func _init(name_suffix: String = "") -> void:
	self.name = "Unit_%s" % name_suffix
	# Configure RigidBody3D properties for physics interaction
	self.mass = 1.0
	self.gravity_scale = 1.0
	self.linear_damp = 0.5 # Adds a bit of resistance to stabilize falling
	self.can_sleep = false # Ensures it starts simulating physics immediately
	# NEW: Ensure the physics body is awake and active immediately.
	# This prevents the unit from phasing through the ground on spawn.
	set_sleeping(false)
	# NEW: Configure collision layers and masks
	# Units are on Layer 2 (used for unit-to-unit interaction later)
	#self.collision_layer = 1 << 1 
	## Units check Layer 1 (the ground/Regions)
	#self.collision_mask = 1 << 0 
	
	self.set_collision_layer_value(LAYER_UNIT, true) # Units are on their own layer (for raycasting)
	self.set_collision_mask_value(LAYER_REGION, true)  # UNITS collide only with the REGION

	_setup_visuals_and_collision()
	print("Initialized unit: %s" % self.name)


## Helper function to create the MeshInstance3D and CollisionShape3D.
func _setup_visuals_and_collision() -> void:
	# We use StaticBody3D for physics interaction, although CharacterBody3D is 
	# more common for movable units in a full game.
	#var static_body := StaticBody3D.new()
	#static_body.name = "UnitPhysics"
	#static_body.set_collision_layer_value(LAYER_UNIT, true) # Units are on their own layer (for raycasting)
	#static_body.set_collision_mask_value(LAYER_REGION, true)  # UNITS collide only with the REGION
#
	#add_child(static_body)
	
	# --- 2. Visual Mesh (The Capsule/Pawn) ---
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "UnitMesh"
	
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = UNIT_RADIUS
	capsule_mesh.height = UNIT_HEIGHT
	
	# Create a simple red material for units
	var standard_material := StandardMaterial3D.new()
	standard_material.albedo_color = Color(0.8, 0.2, 0.2) 
	capsule_mesh.material = standard_material
	
	mesh_instance.mesh = capsule_mesh
	
	# Offset the mesh vertically so its base sits at the parent's origin (Y=0).
	mesh_instance.position = Vector3(0.0, UNIT_HEIGHT / 2.0, 0.0) 
	self.add_child(mesh_instance)
	
	# --- 3. Collision Shape (The Bounding Capsule) ---
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "UnitCollision"
	
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = UNIT_RADIUS
	capsule_shape.height = UNIT_HEIGHT
	
	collision_shape.shape = capsule_shape
	# Offset the collision shape to match the mesh.
	collision_shape.position = Vector3(0.0, UNIT_HEIGHT / 2.0, 0.0)
	

	self.add_child(collision_shape)
