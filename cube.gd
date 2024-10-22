extends Area3D

# Signal to notify the spawner that the cube has been destroyed
signal cube_destroyed

@export var speed: float = 5.0  # Speed at which the cube moves

var direction: Vector3 = Vector3.ZERO  # Movement direction
var cube_color: Color
var cube_mark: int  # Mark indicating left (1) or right (2)


func _ready():

	
	# Use the cube's local -Z axis as the forward direction
	direction = global_transform.basis.z.normalized()

	# Connect the area_entered signal to detect laser beam hits
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	# Move the cube straight forward in its initial direction
	global_transform.origin += direction * speed * delta

	# Check if the cube has passed the user and remove it
	if global_transform.origin.z > 0:
		queue_free()
		
func set_color(color: Color) -> void:
	cube_color = color
	var mesh_instance = $MeshInstance3D
	var material = StandardMaterial3D.new()  # Create a new material
	material.albedo_color = color  # Set the cube color visually
	mesh_instance.material_override = material  # Override the material
	
func set_mark(mark: int) -> void:
	cube_mark = mark  # Set the cube's mark
	
func _on_area_entered(area: Area3D) -> void:
	var laser_name = ""
	if area.is_in_group("lasers"):  
		laser_name = area.name  # Get the laser name (
		
	

	if (laser_name == "LaserBeam_Left" and cube_mark == 1) or (laser_name == "LaserBeam_Right" and cube_mark == 2):
		
		  # Play the destruction sound
		$AudioStreamPlayer.play()

		emit_signal("cube_destroyed")
		  
		$AudioStreamPlayer.connect("finished", Callable(self, "_on_audio_finished"))
	
	
			
			
			# Function called when the audio finishes
func _on_audio_finished():
	queue_free()  # Free the cube after sound playback
