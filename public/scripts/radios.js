$(function(){
    $('div.product-chooser').not('.disabled').find('div.product-chooser-item').on('click', function(){
	console.log ("ici");
	$(this).parent().parent().find('div.product-chooser-item').removeClass('selected');
	$(this).addClass('selected');
	$(this).find('input[type="radio"]').prop("checked", true);
	
    });
});
