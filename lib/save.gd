extends Node
# save.gd
# Save file and signals

signal save_loaded

var save_data = {
	"lattice": {
		"player_position": Vector3(-9.0, 1.7, 18.7)
	}
}

# Retrieve data from save_data, or return 'null' if the map or parameter
# doesn't exist
func get_data(map, param):
	if map in save_data:
		if param in save_data[map]:
			return(save_data[map][param])
		else: return(null)
	else: return(null)

func set_data(map, param, value):
	if map in save_data:
		if param in save_data[map]:
			save_data[map][param] = value
		else: return
	else: return

func load_from_file():
	if FileAccess.file_exists("user://save.dat"):
		print("[Save] save.dat exists, loading.")
		var save_file = FileAccess.open("user://save.dat", FileAccess.READ)
		save_data = save_file.get_var()
		save_loaded.emit()
	else: print("[Save] no existing save.dat.")

func save_to_file():
	print("[Save] saving to save.dat.")

	# Write to file
	var save_file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()
