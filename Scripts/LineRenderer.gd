# This script needs to be attached to a MeshInstance3D node
# The MeshInstance3D node needs to have a new ImmediateMesh added to it
#swapped this to area3D so we get collision to work while keeping most of the logic to draw the laser
extends Area3D

@export var points = [Vector3(0,0,0),Vector3(0,5,0)]
@export var startThickness = 0.02
@export var endThickness = 0.01
@export var cornerSmooth = 5
@export var capSmooth = 5
@export var drawCaps = true
@export var drawCorners = true
@export var globalCoords = true
@export var scaleTexture = true
@export var collision_shape: CollisionShape3D  


#tldr this script originally only worked with meshinstance but to get collsion the way i want it had to be changed to area#D
#the nonsense below creates a meashinstance3d during run time to get the beam to draw the same way as before,

var mesh_instance: MeshInstance3D  # Change type to MeshInstance3D
var mesh: ImmediateMesh              # make an immediate mesh 


var camera
var cameraOrigin

func _ready():
	 # Create the MeshInstance3D and add it to the current node
	mesh_instance = MeshInstance3D.new()  # Create a new MeshInstance3D
	mesh = ImmediateMesh.new()              # Create the ImmediateMesh
	mesh_instance.mesh = mesh                # Assign the ImmediateMesh to the MeshInstance3D
	add_child(mesh_instance)                 # Add MeshInstance3D as a child
	
	var color_manager = $Color
	var sword_color = color_manager.get_sword_color()
	set_beam_color(sword_color)  # Apply the beam color


func set_beam_color(color: Color):
	if mesh_instance:
		var material = StandardMaterial3D.new()
		material.albedo_color = color  # Set the color
		mesh_instance.material_override = material  # Override the material
	else:
		push_error("MeshInstance3D not found or not initialized properly.")


func _process(delta):
	
	
	if points.size() < 2:
		return
	
	camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	cameraOrigin = to_local(camera.get_global_transform().origin)
	
	 # Update the laser beam points based on the controller's global position
	points[0] = global_transform.origin  # Start point at the controller's origin
	
	# Adjust the beam direction to point straight up in world space 
	var beam_direction = global_transform.basis.y.normalized()
	
	points[1] = global_transform.origin + beam_direction * 1.0
	
	var progressStep = 1.0 / points.size();
	var progress = 0;
	var thickness = lerp(startThickness, endThickness, progress);
	var nextThickness = lerp(startThickness, endThickness, progress + progressStep);
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(points.size() - 1):
		var A = points[i]
		var B = points[i+1]
	
		if globalCoords:
			A = to_local(A)
			B = to_local(B)
	
		var AB = B - A;
		var orthogonalABStart = (cameraOrigin - ((A + B) / 2)).cross(AB).normalized() * thickness;
		var orthogonalABEnd = (cameraOrigin - ((A + B) / 2)).cross(AB).normalized() * nextThickness;
		
		var AtoABStart = A + orthogonalABStart
		var AfromABStart = A - orthogonalABStart
		var BtoABEnd = B + orthogonalABEnd
		var BfromABEnd = B - orthogonalABEnd
		
		if i == 0:
			if drawCaps:
				cap(A, B, thickness, capSmooth)
		
		if scaleTexture:
			var ABLen = AB.length()
			var ABFloor = floor(ABLen)
			var ABFrac = ABLen - ABFloor
			
			mesh.surface_set_uv(Vector2(ABFloor, 0))
			mesh.surface_add_vertex(AtoABStart)
			mesh.surface_set_uv(Vector2(-ABFrac, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(ABFloor, 1))
			mesh.surface_add_vertex(AfromABStart)
			mesh.surface_set_uv(Vector2(-ABFrac, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(-ABFrac, 1))
			mesh.surface_add_vertex(BfromABEnd)
			mesh.surface_set_uv(Vector2(ABFloor, 1))
			mesh.surface_add_vertex(AfromABStart)
		else:
			mesh.surface_set_uv(Vector2(1, 0))
			mesh.surface_add_vertex(AtoABStart)
			mesh.surface_set_uv(Vector2(0, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(1, 1))
			mesh.surface_add_vertex(AfromABStart)
			mesh.surface_set_uv(Vector2(0, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(0, 1))
			mesh.surface_add_vertex(BfromABEnd)
			mesh.surface_set_uv(Vector2(1, 1))
			mesh.surface_add_vertex(AfromABStart)
		
		if i == points.size() - 2:
			if drawCaps:
				cap(B, A, nextThickness, capSmooth)
		else:
			if drawCorners:
				var C = points[i+2]
				if globalCoords:
					C = to_local(C)
				
				var BC = C - B;
				var orthogonalBCStart = (cameraOrigin - ((B + C) / 2)).cross(BC).normalized() * nextThickness;
				
				var angleDot = AB.dot(orthogonalBCStart)
				
				if angleDot > 0:
					corner(B, BtoABEnd, B + orthogonalBCStart, cornerSmooth)
				else:
					corner(B, B - orthogonalBCStart, BfromABEnd, cornerSmooth)
		
		progress += progressStep;
		thickness = lerp(startThickness, endThickness, progress);
		nextThickness = lerp(startThickness, endThickness, progress + progressStep);
	
	mesh.surface_end()

func cap(center, pivot, thickness, smoothing):
	var orthogonal = (cameraOrigin - center).cross(center - pivot).normalized() * thickness;
	var axis = (center - cameraOrigin).normalized();
	
	var array = []
	for i in range(smoothing + 1):
		array.append(Vector3(0,0,0))
	array[0] = center + orthogonal;
	array[smoothing] = center - orthogonal;
	
	for i in range(1, smoothing):
		array[i] = center + (orthogonal.rotated(axis, lerp(0.0, PI, float(i) / smoothing)));
	
	for i in range(1, smoothing + 1):
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i - 1]);
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i]);
		mesh.surface_set_uv(Vector2(0.5, 0.5))
		mesh.surface_add_vertex(center);
		
func corner(center, start, end, smoothing):
	var array = []
	for i in range(smoothing + 1):
		array.append(Vector3(0,0,0))
	array[0] = start;
	array[smoothing] = end;
	
	var axis = start.cross(end).normalized()
	var offset = start - center
	var angle = offset.angle_to(end - center)
	
	for i in range(1, smoothing):
		array[i] = center + offset.rotated(axis, lerp(0.0, angle, float(i) / smoothing));
	
	for i in range(1, smoothing + 1):
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i - 1]);
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i]);
		mesh.surface_set_uv(Vector2(0.5, 0.5))
		mesh.surface_add_vertex(center);
		
		
		
