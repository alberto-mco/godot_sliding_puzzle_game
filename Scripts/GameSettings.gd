extends Node

class_name GameSettings

#Variables publicas con la configuración del juego
var BoardSizeType:int
var ShuffleSpeedType:int
var TotalShuffleMoves:int

#=========================================================================
#Initialize
#=========================================================================
func _init():
	#Comprobamos si existe el fichero de configuración
	if (ExistsFileSettings() == false):
		#Establecemos la configuración por defecto del juego
		SetDefaultSettings()
		
		#Guardamos el fichero de configuración, con la configuración inicial
		SaveSettings()
	
	#Cargamos el fichero de configuración
	LoadSettings()

#=========================================================================
#Comprueba si el fichero de configuración existe
#=========================================================================
func ExistsFileSettings()->bool:
	var mResult:bool = false
	var mFile = File.new()
	
	#Comprobamos si el fichero existe
	mResult = mFile.file_exists("user://Settings.dat")
	
	#Retornamos el resultado de la operación
	return mResult

#=========================================================================
#Carga la configuración actual desde el fichero de configuración
#=========================================================================
func LoadSettings():
	var mFile = File.new()
	
	#Abrimos el fichero en modo Lectura/Escritura
	mFile.open("user://Settings.dat", File.READ)
	
	#Comprobamos que el fichero este abierto
	if (mFile.is_open()):
		var mJsonResult:JSONParseResult = JSON.parse(mFile.get_line())
		
		#Cerramos el fichero ya que no va a hacer más falta
		mFile.close()
		
		#Comprobamos si se ha podido parsear correctamente el json
		if (mJsonResult.error == OK):
			BoardSizeType = mJsonResult.result["BoardSizeType"]
			ShuffleSpeedType = mJsonResult.result["ShuffleSpeedType"]
			TotalShuffleMoves = mJsonResult.result["TotalShuffleMoves"]

#=========================================================================
#Carga la configuración actual desde el fichero de configuración
#=========================================================================
func SetDefaultSettings():
	#Establecemos la configuración por defecto del juego
	BoardSizeType = 0
	ShuffleSpeedType = 0
	TotalShuffleMoves = 32

#=========================================================================
#Guarda la configuración actual en el fichero de configuración
#=========================================================================
func SaveSettings():
	var data = {"BoardSizeType": BoardSizeType, "ShuffleSpeedType": ShuffleSpeedType, "TotalShuffleMoves": TotalShuffleMoves}
	var mFile = File.new()
	
	#Abrimos el fichero en modo Lectura/Escritura
	mFile.open("user://Settings.dat", File.WRITE)
	
	#Comprobamos que el fichero este abierto
	if (mFile.is_open()):
		#Escribimos la configuración en el fichero
		mFile.store_line(JSON.print(data))
		
		#Cerramos el fichero
		mFile.close()
