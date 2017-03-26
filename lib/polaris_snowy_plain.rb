#-------------------------------------------------------------------------------
# Déplacement à l'extérieur de la base
#-------------------------------------------------------------------------------
# Lancer snowy_plain_initialize dans un évènement en démarrage automatique à l'arrivée de la map, et supprimer cet évènement
# Lancer snowy_plain_key_entered dans un évènement en processus parallèle, après que l'évènement d'avant est passé
# Tester snowy_plain_base_found? dans une condition pour vérifier si le joueur est bien juste en face de la base

class Interpreter
  DEFAULT_OUTER_CIRCLE_RADIUS = 100
  DEFAULT_INNER_CIRCLE_RADIUS = 70
  DEFAULT_ANGLE = 0
  MAX_SIGHT_ANGLE = 10        # Angle maximal où le héros peut voir la base
  MIN_DISTANCE_FROM_BASE = 5  # Distance minimale entre le héros et la base
  MOVE_STEP = 2               # Distance de déplacement
  
  # $outer_circle_radius        Rayon du cercle extérieur, au delà duquel le héros ne peut aller
  # $inner_circle_radius        Rayon du cercle intérieur, à partir duquel la base est visible
  # $hero_position_angle        Angle du héros par rapport au cercle trigo
  # $hero_distance_from_base    Distance du héros par rapport à la base
  # $hero_sight_angle           Angle où le héros regarde par rapport à la droite qui va de la base à lui     

  def snowy_plain_initialize(options = {})
    $outer_circle_radius = options[:outer_circle_radius] || DEFAULT_OUTER_CIRCLE_RADIUS
    $inner_circle_radius = options[:inner_circle_radius] || DEFAULT_INNER_CIRCLE_RADIUS
    $hero_position_angle = options[:hero_position_angle] || DEFAULT_ANGLE
    $hero_distance_from_base = options[:hero_distance_from_base] || $outer_circle_radius
    $hero_sight_angle = options[:hero_sight_angle] || DEFAULT_ANGLE
  end
  
  def snowy_plain_key_entered
    case Input.dir4
      when Input::UP
        move_forward
      when Input::DOWN
        move_backwards
      when Input::LEFT
        turn_left
      when Input::RIGHT
        turn_right
    end
    snowy_plain_information if Input.press? Input::A
  end

  def snowy_plain_base_found?
    player_touches_base? && player_looks_at_base?
  end
  
  def snowy_plain_information
    print "#{$hero_sight_angle} - #{$hero_distance_from_base}"
  end

  private
  
  def move_forward
    move_to_direction $hero_sight_angle unless player_touches_base?
  end
  
  def move_backwards
    move_to_direction(-$hero_sight_angle) unless player_touches_outer_limit?
  end
  
  def turn_left
    $hero_sight_angle -= 1
    $hero_sight_angle %= 360
  end
  
  def turn_right
    $hero_sight_angle += 1
    $hero_sight_angle %= 360
  end
  
  def move_to_direction(angle)
    player_new_polar_coordinates(angle)
    resolve_limits
  end

  def player_touches_base?
    $hero_distance_from_base == MIN_DISTANCE_FROM_BASE
  end

  def player_touches_outer_limit?
    $hero_distance_from_base == $outer_circle_radius
  end

  def player_looks_at_base?
    $hero_sight_angle <= MAX_SIGHT_ANGLE || $hero_sight_angle >= 360 - MAX_SIGHT_ANGLE
  end

  def convert_to_radians(degrees)
    degrees.to_f * Math::PI / 180 
  end

  def convert_to_degrees(radians)
    radians.to_f * 180 / Math::PI 
  end

  def hypotenuse_length(x, y)
    Math.sqrt(x * x + y * y)
  end

  def player_new_polar_coordinates(angle)
    move_triangle_adjacent = MOVE_STEP * Math.cos(convert_to_radians(angle))
    move_triangle_opposite = MOVE_STEP * Math.sin(convert_to_radians(angle))
    base_triangle_adjacent = $hero_distance_from_base - move_triangle_adjacent
    base_triangle_opposite = move_triangle_opposite
    base_triangle_angle = convert_to_degrees(Math.atan(base_triangle_opposite / base_triangle_adjacent.to_f))
    $hero_position_angle += base_triangle_angle
    $hero_distance_from_base = hypotenuse_length(base_triangle_opposite, base_triangle_adjacent)
  end

  def resolve_limits
    $hero_distance_from_base = DEFAULT_OUTER_CIRCLE_RADIUS if $hero_distance_from_base > DEFAULT_OUTER_CIRCLE_RADIUS
    $hero_distance_from_base = MIN_DISTANCE_FROM_BASE if $hero_distance_from_base < MIN_DISTANCE_FROM_BASE
  end
end