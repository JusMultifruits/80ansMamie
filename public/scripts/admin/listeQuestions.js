function supprimerQuestion (numero) {
    if (confirm ("Supprimer le determinant numéro : "+ i +" ?")) {
	var xhttp = new XMLHttpRequest ();
	xhttp.open ("GET", "remove_question?id=" + i, false);
	xhtpp.send ();
	if (xhttp.status == 200)
	    window.location.reload ();
    }
}
