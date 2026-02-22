class_name CameraShakeBus
extends Resource


signal shake_request(intencity: float)


# helper function to make code look cleaner.
func emit_shake(intensity: float) -> void:
    shake_request.emit(intensity)
