function removeDeter (i) {
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "remove_deter?id=" + i);
    xhttp.send ();
    console.log ("ici");
}
