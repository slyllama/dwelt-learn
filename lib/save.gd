extends Node
# save.gd
# Save file and signals

signal save_loaded

# Retrieve data from save_data, or return 'null' if the map or parameter
# doesn't exist
func get_data(map, param):
	if map in save_data:
		if param in save_data[map]:
			return(save_data[map][param])
		else: return(null)
	else: return(null)

var save_data = {
	"lattice": {
		"player_position": Vector3(-9.0, 1.7, 18.7)
	}
}
