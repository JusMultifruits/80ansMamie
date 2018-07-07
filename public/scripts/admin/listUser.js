function editUser (id) {
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "change_team?id=" + id, false);
    xhttp.send ();
    if (xhttp.status == 200)
	window.location.reload ();
}

function rendreAdmin (id) {
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "rendre_admin?id=" +id, false)
    xhttp.send ();
    if (xhttp.status == 200)
	window.location.reload ();
}
