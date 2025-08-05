extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Deathcounter.death_count_updated.connect(_on_death_count_updated)
	self.text = "Deaths: %d" % Deathcounter.death_count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_death_count_updated(new_count: int):
	self.text = "Deaths: %d" % new_count
