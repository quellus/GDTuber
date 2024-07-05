class_name ScreenObject extends Node2D

var rng = RandomNumberGenerator.new()
@export var texture: Texture2D:
	set(value): 
		texture = value
		create_visual()

var id: String
@export var blinking := true:
	set(value):
		blinking = value
		create_visual()
@export var reactive := true:
	set(value):
		reactive = value
		create_visual()
@export var talking := true:
	set(value):
		talking = value
		create_visual()
var user_scale: Vector2
var user_position: Vector2
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
		if talking:
			create_talking_atlas()
			if blinking:
				blink_timer = Timer.new()
				add_child(blink_timer)
				blink_timer.timeout.connect(_on_blink_timer_timeout)
				blink_timer.start(1)
				
		else:
			create_normal_sprite()
		if reactive:
			generate_animation()
		else:
			if bounce_animator:
				bounce_animator.queue_free()
				bounce_animator = null
		
	
func create_talking_atlas():
	var width = floor(texture.get_width()/2)
	var height = floor(texture.get_height()/2)
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = SpriteFrames.new()
	for i in range(4):
		var atlas_texture = AtlasTexture.new()
		var atlas_rect
		match i:
			0:
				atlas_rect = Rect2(0, 0, width, height)
			1:
				atlas_rect = Rect2(width, 0, width, height)
			2:
				atlas_rect = Rect2(0, height, width, height)
			3:
				atlas_rect = Rect2(width, height, width, height)
				
		atlas_texture.atlas = texture
		atlas_texture.region = atlas_rect
		
		sprite.sprite_frames.add_frame("default", atlas_texture)
		sprite.name = "Sprite"
	add_child(sprite)
	
	
func create_normal_sprite():
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.name = "Sprite"
	add_child(sprite)

func generate_animation():
	bounce_animator = AnimationPlayer.new()
	sprite.add_child(bounce_animator)
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


func _on_animator_stopped(anim_name):
	if is_talking:
		bounce_animator.play("bounce")


func _on_blink_timer_timeout():
	if is_blinking:
		blink_timer.start(rng.randf_range(2, 4))
	else:
		blink_timer.start(0.2)
	is_blinking = !is_blinking
