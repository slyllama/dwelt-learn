extends SubViewport

var status: int
var progress: Array[float] # ResourceLoader will put its status details here
var current_model = ""
var loaded = true
var Model

const MODEL_DATA = {
	"fourier": {
		"path": "res://characters/fourier/fourier.glb",
		"rotation_degrees": Vector3(0.0, -20.0, 0.0)},
	"euclid": {
		"path": "res://characters/euclid/euclid.glb",
		"rotation_degrees": Vector3(0.0, 160.0, 0.0)}
}

func load_model(model_name):
	status = -1
	progress = []
	current_model = model_name
	loaded = false
	if Model != null: Model.queue_free()
	if !model_name in MODEL_DATA:
		print("[DialogueWorld] no model for character '" + model_name + "'!")
	ResourceLoader.load_threaded_request(MODEL_DATA[model_name].path)

func _ready(): pass

func _process(_delta):
	if loaded == true: return
	status = ResourceLoader.load_threaded_get_status(
		MODEL_DATA[current_model].path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var get_model = ResourceLoader.load_threaded_get(MODEL_DATA[current_model].path)
			Model = get_model.instantiate()
			$World.add_child(Model)
			Model.position.z = -1.0
			Model.get_node("AnimationPlayer").play("Idle")
			if "rotation_degrees" in MODEL_DATA[current_model]:
				Model.rotation_degrees = MODEL_DATA[current_model].rotation_degrees
			loaded = true
