extends kinematicbody3D

var speed : int = 30
var velo = Vector3.()
var grav = Vector3.()

var pull = 0.1



func _process(delta):
	movement(delta)

func movement(delta):
	velo = Vector.ZERO
	if Input.is_action_pressed("w"):
		velo -= transform.basis.z * speed
	if Input.is_action_pressed("s"):
		velo += transform.basis.z * speed
	if Input.is_action_pressed("a"):
		velo -= transform.basis.x * speed
if Input.is_action_pressed("d"):
		velo += transform.basis.x * speed