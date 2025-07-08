extends CharacterBody2D

@export var move_speed: float = 100.0
@export var chase_duration: float = 2.0 # Duración de la fase 'chasing'
@export var attack_windup_duration: float = 1.5 # Duración de la fase 'winding_up'
@export var attack_duration: float = 0.5 # Duración de la fase 'attacking' (0.5 segundos)
@export var vulnerable_duration: float = 3.0 # Duración de la fase 'vulnerable' (3 segundos)
@export var attack_damage: float = 10.0
@export var player_node: Node2D
@export var health: int
@export var healthbar : Node2D # Se asume que healthbar es un Node2D con un método 'damage()'

# Para el escudito
@export var shield: MeshInstance2D

@onready var attack_area: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Asegúrate de que tu nodo AnimatedSprite2D se llama así

var player_body: CharacterBody2D = null
var state: String = "chasing" # Posibles estados: "chasing", "winding_up", "attacking", "vulnerable"
var movement_timer: Timer = null
var windup_timer: Timer = null
var attack_timer: Timer = null
var vulnerable_timer: Timer = null
var brokenGen: int = 0

# Variables para las animaciones de posición
var original_sprite_offset_y: float # Para almacenar el offset Y original del sprite
var slam_offset_y: float = 16.0 # Cuánto baja el sprite al atacar
@export var rotation_amplitude: float = 5.0 # Grados para la rotación de balanceo en estado vulnerable
var rocking_rotation_duration: float = 0.1 # Duración de cada parte del balanceo de rotación (Aumentada velocidad)

func _ready():
	# Inicializar todos los temporizadores
	movement_timer = _create_timer(true)
	windup_timer = _create_timer(true)
	attack_timer = _create_timer(true)
	vulnerable_timer = _create_timer(true)

	# Conectar los timeouts de los temporizadores a sus funciones respectivas
	movement_timer.timeout.connect(_on_movement_timeout)
	windup_timer.timeout.connect(_on_windup_timeout)
	attack_timer.timeout.connect(_on_attack_timeout)
	vulnerable_timer.timeout.connect(_on_vulnerable_timeout)

	# Conectar las señales de área para la detección de ataque
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.body_entered.connect(_on_attack_body_entered)

	# Encontrar el CharacterBody2D del jugador
	if player_node:
		player_body = player_node.get_node("CharacterBody2D")
		if player_body:
			start_chasing() # Iniciar el comportamiento del jefe
		else:
			printerr("No se pudo encontrar CharacterBody2D en el nodo del jugador")

	# Almacenar el offset Y original del AnimatedSprite2D
	if animated_sprite:
		original_sprite_offset_y = animated_sprite.offset.y
	else:
		printerr("No se pudo encontrar el nodo AnimatedSprite2D. Asegúrate de que sea un hijo y se llame 'AnimatedSprite2D'.")
	
	# Asegurar que el Area2D siempre esté habilitado para la detección
	attack_area.monitorable = true
	attack_area.monitoring = true


func _create_timer(one_shot: bool) -> Timer:
	var timer = Timer.new()
	add_child(timer) # Añadir el temporizador como hijo para asegurar que se procese
	timer.one_shot = one_shot
	return timer

func _physics_process(_delta):
	# La lógica de movimiento solo se aplica durante el estado 'chasing'
	if state == "chasing" and player_body:
		# Calcular la dirección hacia el jugador
		var direction = (player_body.global_position - global_position).normalized()
		# Moverse hacia el jugador
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO # Detener el movimiento en otros estados


func start_chasing():
	print ("chasing")
	state = "chasing"
	# El attack_area siempre está habilitado, la lógica de daño depende del estado.
	
	# Asegurar que el sprite esté en su posición de "vuelo" (offset Y original)
	# Esto solo se ejecuta cuando se llama directamente desde _ready() o después de la animación de subida
	if animated_sprite:
		animated_sprite.offset.y = original_sprite_offset_y
		# Detener cualquier tween anterior para evitar conflictos
		if animated_sprite.has_method("stop_all_tweens"):
			animated_sprite.stop_all_tweens()
		# Asegurar que la rotación esté reseteada inmediatamente
		animated_sprite.rotation_degrees = 0.0
	
	movement_timer.start(chase_duration) # Iniciar el temporizador para la fase de persecución

func start_windup():
	print ("winding-up")
	state = "winding_up"
	# El attack_area siempre está habilitado.
	
	# Detener cualquier tween existente en el sprite y asegurar posición original
	if animated_sprite:
		if animated_sprite.has_method("stop_all_tweens"):
			animated_sprite.stop_all_tweens()
		animated_sprite.offset.y = original_sprite_offset_y # Asegurar que esté arriba antes de cargar
		animated_sprite.rotation_degrees = 0.0 # Asegurar que no haya rotación
	
	windup_timer.start(attack_windup_duration) # Iniciar el temporizador para la fase de carga

func start_attack():
	print ("attacking")
	state = "attacking"
	# El attack_area siempre está habilitado.
	
	# Detener cualquier tween existente en el sprite
	if animated_sprite:
		if animated_sprite.has_method("stop_all_tweens"):
			animated_sprite.stop_all_tweens()
		
		# Animación de "slam" hacia abajo
		var slam_tween = create_tween()
		slam_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		# Mover el sprite 16px hacia abajo desde su posición actual
		slam_tween.tween_property(animated_sprite, "offset:y", animated_sprite.offset.y + slam_offset_y, 0.1)
		# Asegurar que la rotación esté reseteada durante el slam
		slam_tween.tween_property(animated_sprite, "rotation_degrees", 0.0, 0.0)
	
	attack_timer.start(attack_duration) # Iniciar el temporizador para la fase de ataque

func start_vulnerable():
	print ("vulnerable")
	state = "vulnerable"
	# El attack_area siempre está habilitado.
	
	# Detener cualquier tween existente en el sprite (especialmente el tween de "slam" si aún está corriendo)
	if animated_sprite:
		if animated_sprite.has_method("stop_all_tweens"):
			animated_sprite.stop_all_tweens()
		# Asegurar que el sprite permanezca en la posición "slam"
		animated_sprite.offset.y = original_sprite_offset_y + slam_offset_y
	
		# Iniciar el movimiento de rotación de "rocking"
		var rocking_rotation_tween = create_tween()
		rocking_rotation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		rocking_rotation_tween.tween_property(animated_sprite, "rotation_degrees", rotation_amplitude, rocking_rotation_duration) # Rotar a la derecha
		rocking_rotation_tween.tween_property(animated_sprite, "rotation_degrees", -rotation_amplitude, rocking_rotation_duration * 2) # Rotar a la izquierda
		rocking_rotation_tween.tween_property(animated_sprite, "rotation_degrees", 0.0, rocking_rotation_duration) # Volver al ángulo original
		rocking_rotation_tween.set_loops(8) # Aplicar set_loops al objeto tween principal para un "rocking" continuo
	vulnerable_timer.start(vulnerable_duration) # Iniciar el temporizador para la fase vulnerable


# Funciones de timeout de los temporizadores para la transición entre estados
func _on_movement_timeout():
	start_windup()

func _on_windup_timeout():
	start_attack()

func _on_attack_timeout():
	start_vulnerable()

func _on_vulnerable_timeout():
	# Animación de subida de 16px antes de volver a 'chasing'
	if animated_sprite:
		if animated_sprite.has_method("stop_all_tweens"):
			animated_sprite.stop_all_tweens()
		
		var lift_tween = create_tween()
		lift_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		# Mover el sprite 16px hacia arriba hasta su posición original
		lift_tween.tween_property(animated_sprite, "offset:y", original_sprite_offset_y, 0.3)
		# Resetear la rotación a 0 grados
		lift_tween.tween_property(animated_sprite, "rotation_degrees", 0.0, 0.3)
		# Conectar la llamada a start_chasing() al finalizar el tween
		lift_tween.finished.connect(start_chasing)
	else:
		# Si no hay sprite, simplemente transicionar
		start_chasing()


# Detección de colisión para el área de ataque
func _on_attack_area_entered(area: Area2D):
	# El área de ataque siempre está activa, la lógica de daño depende del estado
	if area.is_in_group("player") and state == "attacking":
		deal_damage()
	# Solo recibir daño si el jefe está en el estado "vulnerable" y es golpeado por un arma
	if area.is_in_group("weapon") and not shield and state == "vulnerable":
		takeDamage()

func _on_attack_body_entered(body: Node2D):
	# El área de ataque siempre está activa, la lógica de daño depende del estado
	if body.is_in_group("player") and state == "attacking":
		deal_damage()
	# Solo recibir daño si el jefe está en el estado "vulnerable" y es golpeado por un arma
	if body.is_in_group("weapon") and not shield and state == "vulnerable":
		takeDamage()

# Función para habilitar/deshabilitar el área de ataque (se mantiene por si se usa externamente, pero no se llama aquí)
func set_attack_area_enabled(enabled: bool):
	# Usando set_deferred para evitar problemas con las actualizaciones del motor de físicas
	attack_area.set_deferred("monitorable", enabled)
	attack_area.set_deferred("monitoring", enabled)

# Función para infligir daño al jugador
func deal_damage():
	GameManager.takeDamage(attack_damage)
	# El attack_area siempre está habilitado, no se deshabilita aquí.

# Función llamada cuando un generador es destruido (presumiblemente desde una fuente externa)
func on_destroy_gen():
	brokenGen += 1
	print("Se rompieron " + str(brokenGen) + " gens")
	if brokenGen == 2: # Dejado en 1 para facilitar testing, cambiar a 2 si es el valor final
		if shield:
			shield.queue_free() # Destruir el escudo
			print("ADIOS ESCUDOS")
			healthbar.pull_in()

# Función para manejar el daño recibido por el jefe
func takeDamage():
	if health <= 0:
		queue_free() # Eliminar al jefe si la vida es cero o menos
	else:
		health -= GameManager.playerDamage # Reducir la vida por el daño del jugador
		print(health)
		if healthbar: # Verificar si la barra de vida está asignada
			healthbar.damage() # Llamar al método damage en la barra de vida
		if health <= 0:
			# Instanciar partículas de confeti al derrotar al jefe
			var particle_scene = load("res://Scenes/Particles/confetti.tscn")
			var particles_instance = particle_scene.instantiate()
			var particles = particles_instance.get_node("GPUParticles2D")
			get_parent().add_child(particles_instance)
			particles.emitting = true
			particles.restart()
			healthbar.pull_out()
			takeDamage()
