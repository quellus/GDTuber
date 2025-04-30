class_name Gizmo extends Control


var dragging: bool
var target: ScreenObject
var rotating = false
var rotation_center: Vector2 = Vector2()
var starting_rotation: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if dragging:
		if event is InputEventMouseMotion:
			position += event.relative
			if target:
				target.global_position = global_position
				target.user_position = target.global_position

	# maybe move even types into labeled functions
	if event is InputEventMouseMotion and target and rotating:
		var rotvector = event.global_position - rotation_center
		var rotangle = atan2(rotvector.y, rotvector.x)
		var targetrot = rotangle + starting_rotation
		if Input.is_key_pressed(KEY_CTRL):
			target.user_rotation = (
				round(targetrot / PlatformConsts.SNAP_ANGLE) * PlatformConsts.SNAP_ANGLE
			)
		else:
			target.user_rotation = targetrot

	if event is InputEventMouseButton and target:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					if !rotating:
						rotation_center = target.global_position
						var rotvector = event.global_position - rotation_center
						var rotangle = atan2(rotvector.y, rotvector.x)
						starting_rotation = target.user_rotation - rotangle
						rotating = true
				else:
					rotating = false

func _unhandled_input(event):
	# Scroll to zoom
	if event is InputEventMouseButton and target:
		if is_instance_valid(target):
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					target.user_scale *= PlatformConsts.SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					target.user_scale *= 1 / PlatformConsts.SCALE_RATIO


func request_screen_object_gizmo_focus(object_requesting_gizmo: ScreenObject):
	if target == object_requesting_gizmo or object_requesting_gizmo == null:
		target = null
		self.visible = false
		self.target = null
	else:
		self.global_position = object_requesting_gizmo.global_position
		self.visible = true
		self.target = object_requesting_gizmo

func handle_object_recenter(object_requesting_gizmo_recenter: ScreenObject):
	if target == object_requesting_gizmo_recenter:
		self.global_position = object_requesting_gizmo_recenter.global_position

func handle_clear():
	target = null
	visible = false

func drag():
	if !dragging:
		dragging = true


func dragnt():
	dragging = false
