function booleanRenderer(value) {
	var cssClass = value ? 'true' : 'false';
	return '<div class="boolean-' + cssClass + '"></div>';
}

function textSteelBlueRenderer(value) {
	return '<div class="text-steel-blue">' + value + '</div>';
}

function textSteelBlueBoldRenderer(value) {
	return '<div class="text-steel-blue" style="font-weight:bold;">' + value + '</div>';
}