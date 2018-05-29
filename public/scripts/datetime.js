$(function () {
    $('.form_date').datetimepicker ({
	language:  'fr',
        weekStart: 1,
	autoclose: 1,
	todayHighlight: 0,
	startView: 4,
	minView: 2,
	forceParse: 0

    });
    
    $('form').submit (function () {
	return checkDate ();	
    });
    
});

function checkDate () {
    var ret = true;
    if ($("#id").val () == "") {
	$('#display1').addClass ('has-error');
	ret = false;
    } else $('#display1').removeClass ('has-error');
    
    if ($('#dtp_input2').val() == "") {
	$('#display').addClass ('has-error');
	ret = false;
    } else $('#display').removeClass ('has-error');
    
    return ret;
}

