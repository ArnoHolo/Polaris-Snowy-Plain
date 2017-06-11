#-------------------------------------------------------------------------------
# Déplacement à l'extérieur de la base
#-------------------------------------------------------------------------------
# Lancer snowy_plain_initialize dans un évènement en démarrage automatique à l'arrivée de la map, et supprimer cet évènement
# Lancer snowy_plain_key_entered dans un évènement en processus parallèle, après que l'évènement d'avant est passé
# Tester snowy_plain_base_found? dans une condition pour vérifier si le joueur est bien juste en face de la base

class Interpreter
  def snowy_plain_initialize(options = {})
    $snowy_plain_plain = IntroPlain::Plain.new(options)
    $snowy_plain_hero = IntroPlain::Hero.new(options)
    $snowy_plain = SnowyPlain.new(options)
    $snowy_plain_player_actions = IntroPlain::PlayerActions.new
  end
  
  def snowy_plain_key_entered
    $snowy_plain.key_entered
  end

  def snowy_plain_base_found?
    $snowy_plain.base_found?
  end
end

module IntroPlain
  class PlayerActions
    def key_entered
      case Input.dir4
        when Input::UP
          $snowy_plain_hero.move_forward
        when Input::DOWN
          $snowy_plain_hero.move_backwards
        when Input::LEFT
          $snowy_plain_hero.turn_left
        when Input::RIGHT
          $snowy_plain_hero.turn_right
      end
      $snowy_plain.display_base
      $snowy_plain.information if Input.press? Input::A
    end
  end

  class Hero
    DEFAULT_ANGLE = 0

    attr_accessor :sight_angle      # Angle où le héros regarde par rapport à la droite qui va de la base à lui   

    def initialize(options = {})
      @sight_angle = options[:sight_angle] || DEFAULT_ANGLE
    end 
    
    def move_forward
      $snowy_plain.move_to_direction @sight_angle unless $snowy_plain.hero_touches_base?
    end
  
    def move_backwards
      $snowy_plain.move_to_direction(-@sight_angle) unless $snowy_plain.hero_touches_outer_limit?
    end
  
    def turn_left
      @sight_angle -= 1
      @sight_angle %= 360
    end
  
    def turn_right
      @sight_angle += 1
      @sight_angle %= 360
    end
  end

  class Plain
    DEFAULT_RADIUS = 100

    attr_accessor :radius     # Rayon du cercle extérieur, au delà duquel le héros ne peut aller

    def initialize(options = {})
      @radius = options[:radius] || DEFAULT_RADIUS
    end 
  end
end

class SnowyPlain
  DEFAULT_INNER_CIRCLE_RADIUS = 70
  MAX_SIGHT_ANGLE = 10        # Angle où le héros peut entrer dans la base quand il est devant
  WIDE_SIGHT_ANGLE = 30       # Angle maximal où le héros peut voir la base
  MIN_DISTANCE_FROM_BASE = 5  # Distance minimale entre le héros et la base
  MOVE_STEP = 2               # Distance de déplacement
  BASE_PICTURE_ID = 9         # ID of the picture used for the base
  
  attr_accessor :inner_circle_radius        # Rayon du cercle intérieur, à partir duquel la base est visible
  attr_accessor :hero_position_angle        # Angle du héros par rapport au cercle trigo
  attr_accessor :hero_distance_from_base    # Distance du héros par rapport à la base 

  def initialize(options = {})
    @inner_circle_radius = options[:inner_circle_radius] || DEFAULT_INNER_CIRCLE_RADIUS
    @hero_position_angle = options[:hero_position_angle] || IntroPlain::Hero::DEFAULT_ANGLE
    @hero_distance_from_base = options[:hero_distance_from_base] || $snowy_plain_plain.radius
  end
  
  def information
    print "#{$snowy_plain_hero.sight_angle} - #{@hero_distance_from_base}"
  end

  def base_found?
    hero_touches_base? && hero_looks_at_base?
  end

  def display_base
    if hero_can_see_base?
      move_base(:image_x => base_x_position, :zoom => base_zoom)
    else
      hide_base
    end
  end

  def hero_touches_base?
    @hero_distance_from_base == MIN_DISTANCE_FROM_BASE
  end
  
  def move_to_direction(angle)
    hero_new_polar_coordinates(angle)
    resolve_limits
  end

  def hero_touches_outer_limit?
    @hero_distance_from_base == $snowy_plain_plain.radius
  end

  private

  def hero_can_see_base?
    $snowy_plain_hero.sight_angle <= WIDE_SIGHT_ANGLE || $snowy_plain_hero.sight_angle >= 360 - WIDE_SIGHT_ANGLE
  end

  def base_zoom
    distance_of_base_percentage = (@hero_distance_from_base.to_f - MIN_DISTANCE_FROM_BASE) * 100 / (DEFAULT_INNER_CIRCLE_RADIUS - MIN_DISTANCE_FROM_BASE)
    zoom = 100 - distance_of_base_percentage
    zoom = 1 if zoom < 1
    zoom
  end

  def base_x_position
    base_position_cosinus = Math.cos(-convert_to_radians($snowy_plain_hero.sight_angle + 90))
    max_width_cosinus = Math.cos(convert_to_radians(90 - WIDE_SIGHT_ANGLE))
    base_position_scaled = base_position_cosinus * 320 / max_width_cosinus
    base_position_scaled + 320
  end
  
  def move_base(options = {})
    duration = 1; origin = 1; image_x = 320; image_y = 240; zoom_x = 100; zoom_y = 100; opacity = 255; blend_type = 0;

    image_x = options[:image_x] if options[:image_x]
    zoom_x = zoom_y = options[:zoom] if options[:zoom]
    opacity = options[:opacity] if options[:opacity]

    $game_screen.pictures[BASE_PICTURE_ID].move(duration, origin, image_x, image_y, zoom_x, zoom_y, opacity, blend_type)
  end
  
  def hide_base
    move_base(:opacity => 0)
  end

  def hero_looks_at_base?
    $snowy_plain_hero.sight_angle <= MAX_SIGHT_ANGLE || $snowy_plain_hero.sight_angle >= 360 - MAX_SIGHT_ANGLE
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

  def hero_new_polar_coordinates(angle)
    move_triangle_adjacent = MOVE_STEP * Math.cos(convert_to_radians(angle))
    move_triangle_opposite = MOVE_STEP * Math.sin(convert_to_radians(angle))
    base_triangle_adjacent = @hero_distance_from_base - move_triangle_adjacent
    base_triangle_opposite = move_triangle_opposite
    base_triangle_angle = convert_to_degrees(Math.atan(base_triangle_opposite / base_triangle_adjacent.to_f))
    @hero_position_angle += base_triangle_angle
    @hero_distance_from_base = hypotenuse_length(base_triangle_opposite, base_triangle_adjacent)
  end

  def resolve_limits
    @hero_distance_from_base = IntroPlain::Plain::DEFAULT_RADIUS if @hero_distance_from_base > IntroPlain::Plain::DEFAULT_RADIUS
    @hero_distance_from_base = MIN_DISTANCE_FROM_BASE if @hero_distance_from_base < MIN_DISTANCE_FROM_BASE
  end
end