extends Node

export (PackedScene) var Box

#Enumeraciones
enum BoardSizeTypes {Board_3x3, Board_4x4, Board_5x5}
enum GameState {Shuffle, Started, Finished}

#Variable para saber los MapInputs configurados
var moves = ["up", "down", "left", "right"]

#Variables generales del tablero
var screensize
var mMovingBox:bool = false
var mPendingShuffleMoves:int
var mSkipShuffleMove:String = "up"
var mFirstShuffleMove:bool = true
var mEmptyBoxPosition:Vector2

var mBoardSize:Vector2
var mSpriteSize:int = 64
var mLastNumberPosition:Vector2 #Posición del último numero del tablero, que solo se muestra cuando se ha finalizado la partida

#Variables para guardar la información de la partida
var mGameState = GameState.Shuffle
var mTotalMovimientos:int = 0
var mTotalSegundosPartida:int = 0

#=========================================================================
#Initialize
#=========================================================================
func _ready():
	#Inicializamos la semilla del random
	randomize()
	
	#Obtenemos el tamaño de la ventana
	screensize = get_viewport().get_visible_rect().size
	
	#Inicializamos la información mostrada en el HUD
	$HUD.update_moves(0)
	$HUD.update_time(0)
	
	#Mostramos el mensaje de preparando partida
	$HUD.show_message("Preparando tablero")
	
	#Inicializamos el tablero
	InicializarTablero()

#=========================================================================
#Process loop
#=========================================================================
func _process(delta):
	#Comprobamos si estamos en el proceso de barajar los números
	if (mGameState == GameState.Shuffle):
		#Comprobamos que no se este efectuando algún movimiento
		if (mMovingBox == false):
			#Movemos algún objeto Box de forma aleatoria
			MoveRandomBox()

#=========================================================================
#Función para capturar cuando hay un evento de entrada
#=========================================================================
func _input(event):
	#Comprobamos que el juego no haya finalizado
	if (mGameState == GameState.Started):
		if event.is_action_pressed("pause"):
			#Ponemos o quitamos la pausa del juego
			get_tree().paused = not get_tree().paused
			
			#Comprobamos si el juego está pausado, para mostrar el mensaje de pausa
			if get_tree().paused:
				SetBoxVisibility(false)
				$HUD.show_message("Pausa")
				$btnGotToMainMenu.visible = false
			else:
				SetBoxVisibility(true)
				$HUD.hide_message()
				$btnGotToMainMenu.visible = true
		else:
			#Comprobamos que el juego no este pausado
			if not get_tree().paused:
				#Comprobamos el tipo de tecla pulsada
				for dir in moves:
					if Input.is_action_pressed(dir) and CanMove(dir):
						MakeMove(dir)

#=========================================================================
#Función para inicializar el tablero
#=========================================================================
func InicializarTablero():
	var mCurrentNumber = 0
	var mPosicionNumero:Vector2
	var mScreenCenter = screensize / 2
	
	#Inicializamos las variables del tablero
	mGameState = GameState.Shuffle
	mPendingShuffleMoves = Settings.TotalShuffleMoves
	
	#Movemos el puntero al centro de la pantalla
	$CenterPosition.position = mScreenCenter
	
	#Comprobamos el tipo de tablero a crear
	match Settings.BoardSizeType:
		BoardSizeTypes.Board_3x3:
			mBoardSize = Vector2(3, 3)
			$CenterPosition.position -= Vector2(mSpriteSize + (mSpriteSize / 2), mSpriteSize + (mSpriteSize / 2))
		BoardSizeTypes.Board_4x4:
			mBoardSize = Vector2(4, 4)
			$CenterPosition.position -= Vector2((mSpriteSize * 2), (mSpriteSize * 2))
		_:
			mBoardSize = Vector2(5, 5)
			$CenterPosition.position -= Vector2((mSpriteSize * 2) + (mSpriteSize / 2), (mSpriteSize * 2) + (mSpriteSize / 2))
	
	#Indicamos que la posicion es TopLeft del numero y no el Center del Sprite
	$CenterPosition.position += Vector2(mSpriteSize / 2, mSpriteSize / 2)
	
	#Indicamos la posición actual de la casilla comodín
	mEmptyBoxPosition = mBoardSize - Vector2(1, 1)
	
	#Inicializamos los arrays
	for row in range(mBoardSize.y):
		for col in range(mBoardSize.x):
			#Calculamos la posición del objeto en pantalla
			mPosicionNumero.x = $CenterPosition.position.x + (col * mSpriteSize)
			mPosicionNumero.y = $CenterPosition.position.y + (row * mSpriteSize)
			
			#Incrementamos la variable para la siguiente vuelta del bucle
			mCurrentNumber += 1
			
			#Comprobamos que no sea el último número, ya que ese no lo mostraremos por ahora
			if (mCurrentNumber < (mBoardSize.y * mBoardSize.x)):
				var mBox = Box.instance()
				mBox.connect("MoveStarted", self, "_on_Box_MoveStarted")
				mBox.connect("MoveFinished", self, "_on_Box_MoveFinished")
				mBox.connect("Clicked", self, "_on_Box_Clicked")
				mBox.InitializeBox(mPosicionNumero, mCurrentNumber, Vector2(col, row))
				mBox.SetDisableAnimation(true)
				mBox.visible = false
				$BoxesContainer.add_child(mBox)
			else:
				mLastNumberPosition = mPosicionNumero

#=========================================================================
#Función para determinar si la partida ha finalizado o no
#=========================================================================
func IsGameEnd()->bool:
	var mIsGameEnd:bool = true
	
	#Recorremos todos los números, para saber si estan posicionados correctamente
	for mBox in $BoxesContainer.get_children():
		#Comprobamos si el número esta posicionado correctamente dentro del tablero
		if (mBox.IsPositionCorrectToEndGame() == false):
			#Indicamos que la partida no ha finalizado porque hay un objeto Box que no está en la posición deseada
			mIsGameEnd = false
			
			#Salimos del bucle
			break
	
	return mIsGameEnd

#=========================================================================
#Función para mostrar la cuenta atrás del inicio de partida
#=========================================================================
func ShowStartCountDown():
	var mTotalCountDown:int = 3
	
	for i in range(mTotalCountDown):
		$HUD.show_message(str(mTotalCountDown - i))
		yield(get_tree().create_timer(1.0), "timeout")
	
	#Ocultamos el mensaje
	$HUD.hide_message()
	
	#Mostramos los objetos Box del tablero
	SetBoxVisibility(true)
	
	#Cambiamos el estado del juego
	mGameState = GameState.Started
	
	#Iniciamos el timer de la partida
	$GameTimer.start()
	
	#Mostramos el botón para poder volver al menú principal
	$btnGotToMainMenu.visible = true

#=========================================================================
#Función que retorna el objeto Box que ocupa la posición indicada en el tablero
#=========================================================================
func GetBoxByMoveDirection(dir:String):
	var mBoxInstance
	var mBoxPosition:Vector2
	
	#Comprobamos en que dirección se desea mover el objeto Box
	match dir:
		"up":
			mBoxPosition = Vector2(mEmptyBoxPosition.x, mEmptyBoxPosition.y + 1)
		"down":
			mBoxPosition = Vector2(mEmptyBoxPosition.x, mEmptyBoxPosition.y - 1)
		"left":
			mBoxPosition = Vector2(mEmptyBoxPosition.x + 1, mEmptyBoxPosition.y)
		_:
			mBoxPosition = Vector2(mEmptyBoxPosition.x - 1, mEmptyBoxPosition.y)
	
	#Recorremos todos los objetos Box
	for mBox in $BoxesContainer.get_children():
		if (mBox.boardPosition == mBoxPosition):
			mBoxInstance = mBox
			break
	
	return mBoxInstance

#=========================================================================
#Retorna la dirección contraria de la que recibe en el parámetro
#=========================================================================
func OpositeDirection(dir:String)->String:
	var mOpositeDir:String = "up"
	
	#Comprobamos en que dirección se quiere mover
	match dir:
		"up":
			mOpositeDir = "down"
		"down":
			mOpositeDir = "up"
		"left":
			mOpositeDir = "right"
		_:
			mOpositeDir = "left"
	
	return mOpositeDir

#=========================================================================
#Comprueba si se puede efectuar el movimiento o no
#=========================================================================
func CanMove(dir:String)->bool:
	var mbResult:bool = false
	
	#Comprobamos que no se esté efectuando ningún movimiento
	if (mMovingBox == false):
		#Comprobamos que la partida no haya finalizado
		if ((mGameState == GameState.Shuffle) or (mGameState == GameState.Started)):
			#Comprobamos en que dirección se quiere mover
			match dir:
				"up":
					#Comprobamos que la casilla en blanco no este abajo del todo
					mbResult = (mEmptyBoxPosition.y < (mBoardSize.y - 1))
				"down":
					#Comprobamos que la casilla en blanco no este arriba del todo
					mbResult = (mEmptyBoxPosition.y > 0)
				"left":
					#Comprobamos que la casilla en blanco no este a la derecha del todo
					mbResult = (mEmptyBoxPosition.x < (mBoardSize.x - 1))
				_:
					#Comprobamos que la casilla en blanco no este a la izquierda del todo
					mbResult = (mEmptyBoxPosition.x > 0)
				
	return mbResult

#=========================================================================
#Efectua el movimiento indicado
#=========================================================================
func MakeMove(dir:String)->bool:
	var bResult:bool = false
	var mCurrentBox = GetBoxByMoveDirection(dir)
	var mNewEmptyBoxPosition:Vector2 = mCurrentBox.boardPosition
	
	#Efectuamos el movimiento y comprobamos el resultado de la operación
	if mCurrentBox.move(dir):
		#Indicamos las nuevas coordenadas que ocupa el objeto Box dentro del tablero
		mCurrentBox.boardPosition = mEmptyBoxPosition
		
		#Actualizamos la posición de la casilla en blanco
		mEmptyBoxPosition = mNewEmptyBoxPosition
		
		#Establecemos el resultado de la operación
		bResult = true
	
	return bResult

#=========================================================================
#Comprueba si la instancia del número que recibe en el parámetro puede efectua algún movimiento o no
#=========================================================================
func GetAvailableDirectionByBox(box)->String:
	var dir:String = ""
	
	#Comprobamos si la casilla vacia está en la misma columna
	if (mEmptyBoxPosition.x == box.boardPosition.x):
		if (mEmptyBoxPosition.y == box.boardPosition.y - 1): #Comprobamos si se puede mover arriba
			dir = "up"
		elif (mEmptyBoxPosition.y == box.boardPosition.y + 1): #Comprobamos si se puede mover abajo
			dir = "down"
	elif (mEmptyBoxPosition.y == box.boardPosition.y):
		if (mEmptyBoxPosition.x == box.boardPosition.x + 1): #Comprobamos si se puede mover a la derecha
			dir = "right"
		elif (mEmptyBoxPosition.x == box.boardPosition.x - 1): #Comprobamos si se puede mover a la izquierda
			dir = "left"
	
	return dir

#=========================================================================
#Función para Des/Habilitar la animación del movimiento de los objetos Box
#=========================================================================
func EnableBoxAnimation(pEnable:bool):
	#Recorremos todos los objetos
	for mBox in $BoxesContainer.get_children():
		#Cambiamos el valor para que habilite o no la animación
		mBox.SetDisableAnimation(not pEnable)

#=========================================================================
#Función para ocultar o mostrar los objetos Box
#=========================================================================
func SetBoxVisibility(pVisible:bool):
	#Recorremos todos los objetos
	for mBox in $BoxesContainer.get_children():
		mBox.visible = pVisible

#=========================================================================
#Función para capturar la señal de cuando un objeto Box ha empezado a moverse
#=========================================================================
func  _on_Box_MoveStarted():
	#Marcamos el flag para indicar que se está moviendo un objeto Box
	mMovingBox = true

#=========================================================================
#Función para capturar la señal de cuando un objeto Box ha dejado de moverse
#=========================================================================
func _on_Box_MoveFinished():
	#Comprobamos el estado del juego
	match mGameState:
		GameState.Shuffle:
			#Restamos un movimiento pendiente de barajar
			mPendingShuffleMoves -= 1
			
			#Comprobamos que no queden más movimientos pendientes
			if mPendingShuffleMoves <= 0:
				#Habilitamos la animación del movimiento de los objetos
				EnableBoxAnimation(true)
				
				#Cambiamos el estado del juego
				mGameState = GameState.Started
				
				#Ocultamos el mensaje de preparando tablero
				$HUD.hide_message()
				
				#Mostramos la cuenta atrás para iniciar la partida
				ShowStartCountDown()
		GameState.Started:
			#Incrementamos el total de movimientos realizados
			mTotalMovimientos += 1
			
			#Actualizamos el HUD
			$HUD.update_moves(mTotalMovimientos)
			
			#Comprobamos si la casilla en blanco esta en la esquina inferior derecha, para comprobar si se ha finalizado la partida
			if ((mEmptyBoxPosition.x == (mBoardSize.x - 1)) and (mEmptyBoxPosition.y == (mBoardSize.y - 1))):
				#Comprobamos si la partida ha finalizado
				if (IsGameEnd() == true):
					#Finalizamos la partida
					FinishGame()
	
	#Marcamos el flag para indicar que se está moviendo un objeto Box
	mMovingBox = false

#=========================================================================
#Función para finalizar la partida
#=========================================================================
func FinishGame():
	#Cambiamos el estado del juego
	mGameState = GameState.Finished
	
	#Paramos el timer para que no cuente más segundos transcurridos en partida
	$GameTimer.stop()
	
	#Mostramos la última casilla, ya que se ha resuelto el puzzle correctamente
	var mBox = Box.instance()
	mBox.InitializeBox(mLastNumberPosition, mBoardSize.x * mBoardSize.y, Vector2(mBoardSize.x, mBoardSize.y))
	$BoxesContainer.add_child(mBox)
	
	#Ocultamos el tablero
	SetBoxVisibility(false)
	
	#Rellenamos la información de la partida en el menú de fin de partida
	$gbEndGame/VBoxContainer/lblTotalMovements.text = "Movimientos realizados: %d" % mTotalMovimientos
	$gbEndGame/VBoxContainer/lblTotalTime.text = "Tiempo total: %s" % $HUD.GetFormattedTime(mTotalSegundosPartida)
	
	#Creamos una nueva instancia de la base de datos
	var db = DataBase.new()
	
	#Comprobamos si los resultados de la partida han quedado entre los mejores o no, para dejar o no registrar la clasificación
	var mClasified = db.IsGameResultClasified(Settings.BoardSizeType, mTotalSegundosPartida, mTotalMovimientos)
	
	#Liberamos el objeto de la memoria
	db.queue_free()
	
	#Mostramos o ocultamos la opción para poder registrar los datos de la partida en el ranking
	$gbEndGame/VBoxContainer/HBoxContainer/lblPlayerName.visible = mClasified
	$gbEndGame/VBoxContainer/HBoxContainer/txtPlayerName.visible = mClasified
	$gbEndGame/HBoxContainer/btnSave.visible = mClasified
	
	#Mostramos el menú de fin de partida
	$gbEndGame.visible = true

#=========================================================================
#Función para barajar los objetos Box del tablero de forma aleatoria
#=========================================================================
func MoveRandomBox()->bool:
	var mResult:bool = false
	
	#Generamos una dirección de movimiento aleatoria
	var dir:String = moves[randi() % moves.size()]

	#Comprobamos si podemos mover el objeto Box en esa dirección
	if (CanMove(dir)):
		#Comprobamos que no sea el primer movimiento de la acción de barajar
		if (mFirstShuffleMove != true):
			#Comprobamos que la nueva posición, no sea volver a la anterior (Efecto rebote)
			if (mSkipShuffleMove != dir):
				#Movemos el objeto Box y obtenemos el resultado de la operación
				mResult = MakeMove(dir)
		else:
			#Indicamos que ya no es el primer movimiento de la acción de barajar números
			mFirstShuffleMove = false
			
			#Movemos el objeto Box y obtenemos el resultado de la operación
			mResult = MakeMove(dir)
		
		#Comprobamos si el movimiento se ha efectuado
		if mResult:
			#Guardamos el movimiento que no se puede permitir la siguiente vez para evitar el efecto rebote
			mSkipShuffleMove = OpositeDirection(dir)
	
	#Retornamos el resultado de la operación
	return mResult

#=========================================================================
#Función para capturar la señal de cuando se ha hecho click en un objeto Box
#=========================================================================
func _on_Box_Clicked(sender):
	#Comprobamos que la partida este iniciada y que no se esté realizando ningún movimiento
	if ((mGameState == GameState.Started) and (mMovingBox == false)):
		#Obtenemos las posibles direcciones en las que se puede mover un número
		var dir = GetAvailableDirectionByBox(sender)
		
		#Comprobamos que haya alguna dirección de movimiento válida
		if (dir != ""):
			#Efectuamos el movimiento
			MakeMove(dir)

#=========================================================================
#Función para capturar el GameTime
#=========================================================================
func _on_GameTimer_timeout():
	#Comprobamos que la partida este iniciada y no haya finalizado
	if (mGameState == GameState.Started):
		#Incrementamos el total de segundos en partida
		mTotalSegundosPartida = mTotalSegundosPartida + 1
		
		#Actualizamos el total de segundos en el HUD
		$HUD.update_time(mTotalSegundosPartida)

#=========================================================================
#Función para guardar los resultados de la partida finalizada
#=========================================================================
func _on_btnSaveResults_Clicked():
	var db = DataBase.new()
	
	#Registramos la clasificación
	db.AddRankingResult(Settings.BoardSizeType, mTotalSegundosPartida, mTotalMovimientos, $gbEndGame/VBoxContainer/HBoxContainer/txtPlayerName.text)
	
	#Eliminamos las clasificaciones que ya no estan entre las mejores
	db.EraseNonClasifiedResults(Settings.BoardSizeType)
	
	#Liberamos el objeto db de la memoria
	db.queue_free()
	
	#Cerramos el diálogo
	_on_gbEndGame_CloseButtonClicked()

#=========================================================================
#Función para ocultar el diálogo de "Fin de partida"
#=========================================================================
func _on_gbEndGame_CloseButtonClicked():
	#Iniciamos la animación
	$gbEndGame_Animations.play("close_effect")
	
	#Esperamos a que la animación finalize
	yield($gbEndGame_Animations, "animation_finished")
	
	#Ocultamos el diálogo de fin de partida
	$gbEndGame.visible = false
	
	#Mostramos de nuevo el tablero
	SetBoxVisibility(true)

#=========================================================================
#Función para volver al menú principal
#=========================================================================
func _on_btnGotToMainMenu_Clicked():
	get_tree().change_scene(Settings.MainScene)
