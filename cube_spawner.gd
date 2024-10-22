extends Node3D

@export var cube_scene: PackedScene  # The Cube scene
@export var spawn_interval_min: float = 0.5
@export var spawn_interval_max: float = 2.0
@export var spawn_distance: float = 20.0  # Distance from the user to spawn the cube
@export var max_y_offset: float = 0.8  # Maximum Y offset from user's height
@export var max_x_offset: float = 1.3  # Maximum X offset to the left or right


# Define the cube colors
const COLORS = [Color(1, 0, 0), Color(0, 0, 1)]  # Red, Blue

var timer: Timer

func _ready():
	# Create a timer to control spawning
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

func _on_timer_timeout():
	spawn_cube()
	timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)  # Randomize next spawn time
	timer.start()

func spawn_cube():
	var cube_instance = cube_scene.instantiate()  # Instantiate the cube scene

	# figure out the random X and Y positions
	var random_x = randf_range(-max_x_offset, max_x_offset)  # Left to right spawn range
	var random_y = randf_range(-max_y_offset, max_y_offset)  # Slight height variation

	
	cube_instance.global_transform.origin = Vector3(random_x, random_y, -spawn_distance)
	
	  # Randomly assign a mark and color to the cube
	var mark = randi() % 2 + 1  # Randomly get 1 or 2
	cube_instance.set_mark(mark)
	cube_instance.set_color(COLORS[mark - 1])  # Set the color based on the mark

	add_child(cube_instance)

	cube_instance.connect("cube_destroyed", Callable(self, "_on_cube_destroyed"))




func _on_cube_destroyed():
	print("A cube has been destroyed.")
