extends XRController3D


@export var laser_beam: Area3D  # Assign LaserBeam_Left or LaserBeam_Right in the Inspector
func _ready():
	# Ensure the laser is initially visible (or hidden, depending on your preference)
	laser_beam.visible = true  
	# Connect the signal for input actions
	connect("input_pressed",Callable(self, "_on_input_pressed"))

func _on_input_pressed(action: String):
	if action == "ax_button": 
		toggle_laser()
	
func toggle_laser():
	# Toggle the laser's visibility
	laser_beam.visible = !laser_beam.visible

	# Disable collision when the laser is off
	var collision_shape = laser_beam.get_node("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = !laser_beam.visible
