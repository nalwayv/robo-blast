class_name CameraShakeBus
extends Resource


signal shake_request(intencity: float)


# region [helper functions]
func emit_shake(intensity: float) -> void:
    shake_request.emit(intensity)
# endregion
