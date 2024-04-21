extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

func move(): # transition through acceleration to a moving sound
	print("[SoundHandler] move.")

func stop_moving():
	print("[SoundHandler] stop moving.")

func _ready():
	print("[SoundHandler] idle.")
