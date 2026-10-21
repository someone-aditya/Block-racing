extends Node2D

@onready var lane_markers = $LaneMarkers

var scroll_y = 0
var marker_spacing = 80
var markers = []

const ROAD_LEFT = 60
const ROAD_RIGHT = 420
const LANES = [120, 200, 280, 360]

func _ready():
	create_lane_markers()

func create_lane_markers():
	# Clear existing
	for marker in markers:
		if marker:
			marker.queue_free()
	markers.clear()
	
	# Create dashed lane markers
	for lane_x in LANES:
		if lane_x == LANES[0]:  # Skip leftmost edge
			continue
		
		var y = -100
		while y < 900:
			var marker = create_marker(lane_x, y)
			lane_markers.add_child(marker)
			markers.append(marker)
			y += marker_spacing

func create_marker(x: float, y: float) -> ColorRect:
	var rect = ColorRect.new()
	rect.color = Color(1, 1, 1, 0.4)
	rect.size = Vector2(4, 40)
	rect.position = Vector2(x - 2, y)
	return rect

func scroll(amount: float):
	scroll_y += amount
	scroll_y = fmod(scroll_y, marker_spacing)
	
	# Update marker positions
	for i in range(markers.size()):
		var marker = markers[i]
		if marker:
			var base_y = -100 + (i % 12) * marker_spacing
			marker.position.y = base_y + scroll_y
			
			# Wrap around
			if marker.position.y > 900:
				marker.position.y -= 1000
