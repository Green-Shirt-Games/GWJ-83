extends CPUParticles2D


func _ready() -> void:
	emitting = true
	one_shot = true
	get_tree().create_timer(lifetime + 2).timeout.connect(queue_free)
