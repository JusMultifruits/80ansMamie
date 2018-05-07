var xhttp = new XMLHttpRequest();
// (methode, url, synchrone ?)
xhttp.open("GET", "data?name=mydata", true);     
xhttp.send();

var xhttp = new XMLHttpRequest ();
xhttp.onreadystatechange = function () {
    // 200 est le code de succes
    if (this.readystate == 4 && this.status == 200) {
	document.getElementById ("data").innerHTML =
	    this.responseText;	
    }
}
xhttp.open("GET", "data?name=mydata", true);     
xhttp.send();


var obj = JSON.parse (this.responseText);
document.getElementById ("data").innerHTML =
    obj.name;
    


