extends CanvasLayer

#========================================================
#Obtiene el tiempo total en segundos formateado a minutos y segundos
#========================================================
func GetFormattedTime(pTotalSeconds:int)->String:
	var mSeconds:int = pTotalSeconds % 60
	var mMinutes:float = pTotalSeconds / 60
	var mHours:float = mMinutes
	return "%02d:%02d" % [mMinutes, mSeconds]

#========================================================
#Actualiza el tiempo restante en partida
#========================================================
func update_time(pTotalSeconds:int):
	$TextureRect/HBoxContainer/lblGameTime.text = "Tiempo: " + GetFormattedTime(pTotalSeconds)

#========================================================
#Actualiza el total de movimientos realizados
#========================================================
func update_moves(pTotalMoves:int):
	$TextureRect/HBoxContainer/lblMoves.text = "Movimientos: %d" % pTotalMoves

#========================================================
#Muestra un mensaje en pantalla
#========================================================
func show_message(message):
	$lblMessage.text = message
	$lblMessage.show()

#========================================================
#Oculta el mensaje mostrado en pantalla
#========================================================
func hide_message():
	$lblMessage.text = ""
	$lblMessage.hide()
