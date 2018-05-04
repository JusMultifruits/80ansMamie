$(function () {
    $('input#datepicker').datepicker({
	format: "yyyy-mm-dd",
	startView: 1,
	minViewMode: 1,
	maxViewMode: 3,
	autoclose: true,
	language: "fr",
	orientation: "bottom right"
    });
});
