function booleanRenderer(value) {
	var cssClass = value ? 'true' : 'false';
	return '<div class="boolean-' + cssClass + '"></div>';
}

function booleanRenderer2(value) {
  var cssClass;
  switch(value) {
    case 0:   cssClass = 'false'; break;
    case 1:   cssClass = 'true';  break;
    default:  cssClass = 'unknown';
  }
  return '<div class="boolean-' + cssClass + '"></div>';
}

function textSteelBlueRenderer(value) {
	return '<div class="text-steel-blue">' + value + '</div>';
}

function textSteelBlueBoldRenderer(value) {
	return '<div class="text-steel-blue" style="font-weight:bold;">' + value + '</div>';
}