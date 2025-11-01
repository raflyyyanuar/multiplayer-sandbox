extends UIOverlay
class_name ConfirmationPanel

signal positive_pressed
signal negative_pressed


func _set_title(title: String) -> ConfirmationPanel:
	%TitleLabel.text = title
	return self


func _set_subtitle(subtitle: String) -> ConfirmationPanel:
	%SubtitleLabel.visible = not subtitle.is_empty()
	%SubtitleLabel.text = subtitle
	return self


func _set_positive_text(text: String) -> ConfirmationPanel:
	%PositiveButton.text = text
	return self


func _set_negative_text(text: String) -> ConfirmationPanel:
	%NegativeButton.text = text
	return self


func _reset() -> ConfirmationPanel:
	%PositiveButton.disabled = false
	%NegativeButton.disabled = false
	return self


func _force_positive() -> ConfirmationPanel:
	%PositiveButton.disabled = false
	%NegativeButton.disabled = true
	return self


func _force_negative() -> ConfirmationPanel:
	%PositiveButton.disabled = true
	%NegativeButton.disabled = false
	return self


func _on_positive_button_pressed() -> void:
	positive_pressed.emit()


func _on_negative_button_pressed() -> void:
	negative_pressed.emit()
