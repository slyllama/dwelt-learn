extends Node
# save.gd
# Save file and signals

signal save_loaded
# save_to_file should only be called after World_loader has handled the calling
# of this signal
signal game_saved

var save_data = { }

# Retrieve data from save_data, or return 'null' if the map or parameter
# doesn't exist
func get_data(map, param):
	if map in save_data:
		if param in save_data[map]:
			return(save_data[map][param])
		else: return(null)
	else: return(null)

func set_data(map, param, value):
	# Create the map in the save file if it doesn't exist
	if !map in save_data: save_data[map] = {}
	save_data[map][param] = value

func reset_file():
	Global.printc("[Save] resetting save.dat!")
	var save_file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	save_file.store_var({ })
	save_file.close()

func load_from_file():
	if FileAccess.file_exists("user://save.dat"):
		Global.printc("[Save] save.dat exists, loading.")
		var save_file = FileAccess.open("user://save.dat", FileAccess.READ)
		save_data = save_file.get_var()
		save_loaded.emit()
	else: Global.printc("[Save] no existing save.dat.")

func save_to_file():
	Global.printc("[Save] saving to save.dat.")

	# Write to file
	var save_file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()
