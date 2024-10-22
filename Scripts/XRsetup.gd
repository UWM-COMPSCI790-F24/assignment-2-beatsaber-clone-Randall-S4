extends Node3D

var xr_interface: XRInterface

# Called when the node is added to the scene
func _ready():
	# Initialize the OpenXR interface
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Disable V-sync for smoother performance
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Output the main viewport to the HMD
		get_viewport().use_xr = true

		# Connect to the pose recentered signal
		xr_interface.connect("pose_recentered", Callable(self, "_on_openxr_pose_recentered"))
		# Connect the OpenXR events
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
	else:
		print("OpenXR not initialized, please check if your headset is connected")

# Handle OpenXR pose recentered signal
func _on_openxr_pose_recentered() -> void:
	print("Pose recentered! Recentering the player...")
	
	# Recenters the player's view to face forward in VR
	get_viewport().center_on_hmd()
