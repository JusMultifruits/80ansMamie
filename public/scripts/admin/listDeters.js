function removeDeter (i) {
    if (confirm ("Supprimer le determinant numéro : " + i + " ?")) { 
	var xhttp = new XMLHttpRequest ();
	xhttp.open ("GET", "remove_deter?id=" + i, false);
	xhttp.send ();
	if (xhttp.status == 200)
	    window.location.reload ();
    }
}
