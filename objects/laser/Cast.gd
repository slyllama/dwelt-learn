extends RayCast3D

# Returns true if the cast is on the type, or false in any other case (i.e.,
# the object the cast is on doesn't have a type, etc. Set get_type to "_any"
# to bypass checking an individual name.
func cast_is_on_type(get_type = "_any"):
	if get_collider() == null: return(false)
	if !"TYPE" in get_collider(): return(false)
	
	if get_collider().TYPE == get_type: 
		return(true)
	else:
		if get_type == "_any": return(true)
		else: return(false)
