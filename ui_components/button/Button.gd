tool
extends Control

export(String) onready var Text setget SetTexto, GetTexto
export(int) onready var FontSize setget SetFontSize, GetFontSize
export(bool) onready var Disabled setget SetDisabled, GetDisabled

signal Clicked

const mDisableTexture = preload("res://assets/images/ButtonDisabled.png")
const mIdleTexture = preload("res://assets/images/ButtonNormalState.png")
const mOverTexture = preload("res://assets/images/ButtonOverState.png")
const mPressedTexture = preload("res://assets/images/ButtonPressedState.png")

enum ButtonStates {Idle, MouseOver, Pressed, Disabled}

var mCurrentButtonState
var mLastButtonState

var mPressed:bool

#=========================================================================
#Initialize
#=========================================================================
func _ready():
	#Inicializamos las variables
	mCurrentButtonState = ButtonStates.Idle
	mLastButtonState = ButtonStates.Idle
	ShowIdleStyle()
	mPressed = false

#=========================================================================
#Proceso
#=========================================================================
func _process(delta):
	#Comprobamos si el botón está deshabilitado
	if (Disabled == true):
		if (mCurrentButtonState != ButtonStates.Disabled):
			#Actualizamos el estado actual del botón
			mCurrentButtonState = ButtonStates.Disabled
	
	#Comprobamos si el estado ha cambiado
	if (mCurrentButtonState != mLastButtonState):
		#Comprobamos el estado del botón para saber que estilo mostrar
		if (mCurrentButtonState == ButtonStates.Idle):
			ShowIdleStyle()
		elif (mCurrentButtonState == ButtonStates.MouseOver):
			ShowOverStyle()
		elif (mCurrentButtonState == ButtonStates.Pressed):
			ShowPressedStyle()
		elif (mCurrentButtonState == ButtonStates.Disabled):
			ShowDisabledStyle()
		
		#Actualizamos cual ha sido el último estado del botón
		mLastButtonState = mCurrentButtonState

#=========================================================================
#Cambia el texto del botón
#=========================================================================
func SetTexto(pValue:String):
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.text = pValue
	Text = pValue

#=========================================================================
#Obtiene el texto del botón
#=========================================================================
func GetTexto()->String:
	var mResult:String = ""
	
	#Comprobamos si se puede leer la propiedad del control
	if has_node("lblText"):
		mResult = $lblText.text
	else:
		mResult = Text
	
	return mResult

#=========================================================================
#Establece el estado del botón
#=========================================================================
func SetDisabled(pValue:bool):
	Disabled = pValue

#=========================================================================
#Obtiene el estado del botón
#=========================================================================
func GetDisabled()->bool:
	return Disabled

#=========================================================================
#Captura la señal para saber cuando el ratón está dentro del control
#=========================================================================
func _on_TextureButton_mouse_entered():
	#Comprobamos que el botón no esté presionado
	if (mPressed == false):
		#Cambiamos el estado del botón
		mCurrentButtonState = ButtonStates.MouseOver

#=========================================================================
#Captura la señal para saber cuando el ratón está fuera del control
#=========================================================================
func _on_TextureButton_mouse_exited():
	#Comprobamos que el botón no esté presionado
	if (mPressed == false):
		#Cambiamos el estado del botón
		mCurrentButtonState = ButtonStates.Idle

#=========================================================================
#Captura la señal para saber cuando el ratón está presionando el botón
#=========================================================================
func _on_TextureButton_button_down():
	#Marcamos el flag para indicar que el botón está presionado
	mPressed = true
	
	#Cambiamos el estado del botón
	mCurrentButtonState = ButtonStates.Pressed

#=========================================================================
#Captura la señal para saber cuando el ratón ha dejado de presionar el botón
#=========================================================================
func _on_TextureButton_button_up():
	#Marcamos el flag para indicar que el botón no está presionado
	mPressed = false
	
	if ($TextureButton.is_hovered() == false):
		#Cambiamos el estado del botón
		mCurrentButtonState = ButtonStates.Idle
	else:
		#Cambiamos el estado del botón
		mCurrentButtonState = ButtonStates.MouseOver

#=========================================================================
#Muestra el estilo del botón "Deshabilitado"
#=========================================================================
func ShowDisabledStyle():
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Background"):
		$Background.texture = mDisableTexture
	
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.set("custom_colors/font_color", Color(0.67, 0.67, 0.67, 1))
		$lblText.margin_top = -12

#=========================================================================
#Muestra el estilo del botón "En reposo"
#=========================================================================
func ShowIdleStyle():
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Background"):
		$Background.texture = mIdleTexture
	
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.set("custom_colors/font_color", Color(1, 1, 1, 1))
		$lblText.margin_top = -12

#=========================================================================
#Muestra el estilo del botón "Ratón encima"
#=========================================================================
func ShowOverStyle():
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Background"):
		$Background.texture = mOverTexture
	
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.set("custom_colors/font_color", Color(0.66, 0.53, 0, 1))
		$lblText.margin_top = -12

#=========================================================================
#Muestra el estilo del botón "Presionado"
#=========================================================================
func ShowPressedStyle():
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Background"):
		$Background.texture = mPressedTexture
	
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.set("custom_colors/font_color", Color(0.66, 0.53, 0, 1))
		$lblText.margin_top = -7

#=========================================================================
#Cambia el tamaño de la letra
#=========================================================================
func SetFontSize(pValue:int):
	#Comprobamos si se puede editar la propiedad del control
	if has_node("lblText"):
		$lblText.get("custom_fonts/font").size = pValue
	FontSize = pValue

#=========================================================================
#Obtiene el tamaño de la letra
#=========================================================================
func GetFontSize()->int:
	var iResult = 0
	
	if has_node("lblText"):
		iResult = $lblText.get("custom_fonts/font").size
	else:
		iResult = FontSize
	
	return iResult

#=========================================================================
#Obtiene el tamaño de la letra
#=========================================================================
func _on_TextureButton_pressed():
	emit_signal("Clicked")
