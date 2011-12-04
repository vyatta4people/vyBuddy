function booleanRenderer(value) {
	var cssClass = value ? 'true' : 'false';
	return '<div class="boolean-' + cssClass + '"></div>';
}