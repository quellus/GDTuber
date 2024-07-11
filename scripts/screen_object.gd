class_name ScreenObject extends Node2D

var mat = preload("res://Resources/HSVMat.tres")
var visualsroot: Node2D = Node2D.new()
var rng = RandomNumberGenerator.new()
var texture: Texture2D:
	set(value): 
		texture = value
		create_visual()
var user_hidden: bool = false:
	set(value):
		user_hidden = value
		if sprite:
			sprite.visible = !user_hidden
var user_hue: float = 0:
	set(value):
		user_hue = value
		if sprite:
			sprite.material.set_shader_parameter("hue", remap(value, -0.5, 0.5, -PI, PI))
var user_val: float = 0.5:
	set(value):
		user_val = value
		if sprite:
			sprite.material.set_shader_parameter("val", value)
var user_sat: float = 1:
	set(value):
		user_sat = value
		if sprite:
			sprite.material.set_shader_parameter("sat", value)
var filter: bool = true:
	set(value):
		sprite.texture_filter = TEXTURE_FILTER_LINEAR if value else TEXTURE_FILTER_NEAREST
		filter = value
var user_rotation: float = 0:
	set(value):
		if sprite:
			sprite.global_rotation = value
		user_rotation = value
var blinking := true:
	set(value):
		blinking = value
		create_visual()
var reactive := true:
	set(value):
		reactive = value
		create_visual()
var talking := true:
	set(value):
		talking = value
		create_visual()

var user_scale: Vector2  = Vector2(1, 1) :
	set(value):
		if sprite:
			sprite.scale = value
			user_scale = value

var user_name: String = ""

signal update_menu

var texturepath: String
var user_position: Vector2:
	set(value):
		user_position = value
		global_position = value
var sprite: Node2D
var blink_timer: Timer
var bounce_animator: AnimationPlayer
var is_blinking: bool:
	set(value):
		is_blinking = value
		if value:
			sprite.frame += 2
		else:
			sprite.frame -= 2
var is_talking: bool:
	set(value):
		is_talking = value
		if talking and sprite is AnimatedSprite2D:
			if value:
				sprite.frame += 1
			else:
				sprite.frame -= 1
		if is_instance_valid(bounce_animator):
			if !bounce_animator.is_playing():
				bounce_animator.play("bounce")

func _ready():
	visualsroot.name = "VisualsRoot"
	add_child(visualsroot)
	create_visual()

func create_visual():
	remove_from_group("reactive")
	if reactive or talking:
		add_to_group("reactive")
	if texture:
		if sprite:
			sprite.queue_free()
			sprite = null
			bounce_animator = null
		if talking or blinking:
			create_atlas()
		else:
			create_normal_sprite()
		if reactive:
			generate_animation()
		else:
			if bounce_animator:
				bounce_animator.queue_free()
				bounce_animator = null
		sprite.texture_filter = TEXTURE_FILTER_LINEAR if filter else TEXTURE_FILTER_NEAREST
		sprite.global_rotation = user_rotation
		sprite.material = mat.duplicate()
		sprite.material.set_shader_parameter("sat", user_sat)
		sprite.material.set_shader_parameter("hue", remap(user_hue, -0.5, 0.5, -PI, PI))
		sprite.material.set_shader_parameter("val", user_val)

	
func create_atlas():
	var width = floor(float(texture.get_width())/2) if talking else texture.get_width()
	var height = floor(float(texture.get_height())/2) if blinking else texture.get_height()
	sprite = AnimatedSprite2D.new()
	sprite.scale = user_scale
	sprite.sprite_frames = SpriteFrames.new()
	var voffset = -height
	for i in range(2 if blinking else 1):
		voffset += height
		var hoffset = -width
		for d in range(2 if talking else 1):
			hoffset += width
			var atlas_texture = AtlasTexture.new()
			var atlas_rect = Rect2(hoffset, voffset, width, height)
			atlas_texture.atlas = texture
			atlas_texture.region = atlas_rect
			sprite.sprite_frames.add_frame("default", atlas_texture)
	sprite.name = "Sprite"
	visualsroot.add_child(sprite)
	
	if is_instance_valid(blink_timer):
			blink_timer.queue_free()
	if is_inside_tree():
		_gentimer()

func _gentimer():
	if blinking:
		blink_timer = Timer.new()
		add_child(blink_timer)
		blink_timer.timeout.connect(_on_blink_timer_timeout)
		blink_timer.start(1)

func _enter_tree():
	_gentimer()

func create_normal_sprite():
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.name = "Sprite"
	sprite.scale = user_scale
	visualsroot.add_child(sprite)

func generate_animation():
	bounce_animator = AnimationPlayer.new()
	visualsroot.add_child(bounce_animator)
	var animation_lib = AnimationLibrary.new()
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation_lib.add_animation("bounce", animation)
	bounce_animator.add_animation_library("", animation_lib)
	
	animation.track_set_path(track_index, ".:position")
	animation.track_insert_key(track_index, 0.0, Vector2(0,0))
	animation.track_insert_key(track_index, 0.2, Vector2(0,-20))
	animation.track_insert_key(track_index, 0.4, Vector2(0,0))
	animation.length = 0.4
	bounce_animator.animation_finished.connect(_on_animator_stopped)


func _on_animator_stopped(_anim_name):
	if is_talking:
		bounce_animator.play("bounce")

func _on_blink_timer_timeout():
	if is_blinking:
		blink_timer.start(rng.randf_range(2, 4))
	else:
		blink_timer.start(0.2)
	is_blinking = !is_blinking

func _set_hue(value):
	sprite.material.set_shader_parameter("hue", value)
