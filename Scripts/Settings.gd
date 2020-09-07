extends Node

#Variables publicas con la configuración del juego
var BoardSizeType:int
var TotalShuffleMoves:int

var MainScene = "res://ui_scenes/main/Main.tscn"

#=========================================================================
#Initialize
#=========================================================================
func _ready():
	#Cargamos la configuración del juego
	LoadSettings()

#=========================================================================
#Carga la configuración actual desde la base de datos
#=========================================================================
func LoadSettings()->bool:
	var bResult = false
	var db = DataBase.new()
	var mSettings:Dictionary = db.GetSettings()
	
	#Comprobamos si se ha obtenido la configuración
	if (mSettings.size() > 0):
		#Obtenemos los valores de la configuración
		BoardSizeType = int(mSettings["BoardType"])
		TotalShuffleMoves = int(mSettings["ShuffleMoves"])
		
		#Establecemos el resultado de la operación
		bResult = true
	
	#Liberamos de la memoria el objeto Database
	db.queue_free()
	
	return bResult

#=========================================================================
#Guarda la configuración actual en la base de datos
#=========================================================================
func SaveSettings():
	var db = DataBase.new()
	
	#Guardamos la configuración del juego en base de datos
	db.SaveSettings(BoardSizeType, TotalShuffleMoves)
	
	#Liberamos de la memoria el objeto Database
	db.queue_free()
