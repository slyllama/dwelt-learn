extends Node

# Get the shortest angle between "from", and "to", even if one or both exceeds 360deg
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

# Return a float "num" as a string to 2 decimal places, or snapped to "place"
func fstr(num, place = 0.01):
	return(str(snapped(num, place)))
