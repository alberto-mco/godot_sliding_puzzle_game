extends Area2D

onready var raycast = {"left" : $RayCast_Left, "right" : $RayCast_Right, "up" : $RayCast_UP, "down" : $RayCast_Down}

var boardPosition:Vector2 = Vector2(0, 0) #Indica la posición del número dentro del tablero
var correctBoardPosition:Vector2 = Vector2(0, 0) #Inidica la posición correcta del número dentro del tablero para determinar el fin de partida
var moves = {"left" : Vector2(-1, 0), "right" : Vector2(1, 0), "up" : Vector2(0, -1), "down" : Vector2(0, 1)}
var canmove:bool = true
var mSize:int = 64
var DisableAnimation:bool = false setget SetDisableAnimation

var mDuration:float = 0.1 #Si se cambia, afecta a la duración del AnimationPlayer y habrá que ajustarla
var mNumeroActual:int

signal MoveStarted
signal MoveFinished
signal Clicked

#=========================================================================
#Mueve la ficha en la dirección indicada
#=========================================================================
func move(dir)->bool:
	var bResult = false
	
	#Comprobamos si se puede efectuar el movimiento
	if can_move(dir):
		#Marcamos el flag indicando que no se puede efectuar otro movimiento en estos momentos
		canmove = false
		
		#Emitimos una señal para indicar que el movimiento ha iniciado
		emit_signal("MoveStarted")
		
		#Efectuamos el movimiento
		$MoveTween.interpolate_property(self, "position", position, position + (mSize * moves[dir]), mDuration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$MoveTween.start()
		
		#Comprobamos si la animación está habilitada
		if (not DisableAnimation):
			#Iniciamos la animación
			$AnimationPlayer.play("animation_move")
		
		#Establecemos el resultado de la operación
		bResult = true
	
	return bResult

#=========================================================================
#Determina si la ficha colisionará con algún otro número si se mueve en la dirección indicada
#=========================================================================
func can_move(dir)->bool:
	return canmove and (not raycast[dir].is_colliding())

#=========================================================================
#Señales del objeto MoveTween
#=========================================================================
func _on_MoveTween_tween_completed(object, key):
	#Marcamos el flag indicando que se puede volver a efectuar un movimiento
	canmove = true
	
	#Emitimos una señal para indicar que el movimiento ha finalizado
	emit_signal("MoveFinished")

#=========================================================================
#Función para saber si el número esta posicionado correctamente dentro del tablero (utilizada para saber si hay final de partida o no)
#=========================================================================
func IsPositionCorrectToEndGame()->bool:
	return (correctBoardPosition == boardPosition)

#=========================================================================
#Función para inicializar el tipo de número y el número al que representa
#=========================================================================
func InitializeBox(pPosicionInicial:Vector2, pNumero:int, pBoardPosition:Vector2):
	#Establecemos la posición inicial del objeto
	position = pPosicionInicial
	
	#Guardamos los valores actuales
	mNumeroActual = pNumero
	
	#Cambiamos el texto al número
	$lblBoxNumber_Mini.set_text(str(pNumero))
	$lblBoxNumber_Center.set_text(str(pNumero))
	
	#Guardamos la posición del número dentro del tablero
	boardPosition = pBoardPosition
	correctBoardPosition = pBoardPosition

#=========================================================================
#Función para Des/Habilitar la animación del movimiento
#=========================================================================
func SetDisableAnimation(value:bool):
	DisableAnimation = value
	
	#Comprobamos el valor, para cambiar la duración de la animación
	if (value):
		mDuration = 0
	else:
		mDuration = 0.1

#=========================================================================
#Función para capturar los eventos de entrada
#=========================================================================
func _on_Box_input_event(viewport, event, shape_idx):
	#Comprobamos si es un evento de click
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		#Emitimos una señal para indicar el evento de click, y le enviamos la instancia del número como parámetro
		emit_signal("Clicked", self)
