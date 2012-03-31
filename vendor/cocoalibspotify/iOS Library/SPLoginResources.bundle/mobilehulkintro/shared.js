function sp_addClass(elem, cls) {
	elem.className += ' ' + cls;
}

function sp_removeClass(elem, cls) {
	var r = new RegExp(cls, "g");
	elem.className = elem.className.replace(r, '');
}