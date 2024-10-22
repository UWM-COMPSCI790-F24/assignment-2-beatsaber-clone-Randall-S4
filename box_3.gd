extends CSGBox3D


var moveSpeed = 1.0  # Speed of movement
var maxHeight = 2.0  # Maximum height to move up and down
var initial_position = Vector3()  # Store the initial position
var direction = 1
# Called when the node is added to the scene
func _ready():
	# Store the starting position of the box
	initial_position = global_transform.origin


# Called every frame, delta is the time since the last frame
func _process(delta):
	# Move the object in the current direction
	global_transform.origin.y += direction * moveSpeed * delta
	
	if global_transform.origin.y >= initial_position.y + maxHeight:
		direction = -1  # Reverse direction (move down)
	elif global_transform.origin.y <= initial_position.y - maxHeight:
		direction = 1  # Reverse direction (move up)
