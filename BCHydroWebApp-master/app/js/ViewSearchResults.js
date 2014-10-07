questionTypeEnum = {
	shortAnswer : 1,
	trueFalse: 2,
	table: 3,
	multipleChoice: 4
}

var miTemplates = [];

function getSearchResults() {
	var url = $.url();
	console.log(url);
	
	var queryString = url.param('keyword');
	console.log(queryString);

	var decodedQueryString = decodeURIComponent(queryString);

	var jsonQuery = JSON.parse(decodedQueryString);

	$.ajax({
		dataType: "json",
		async: false,
		url: "https://aws.gursimran.net:8080/searchCompletedMis/" + queryString,
		success: function(data) {
			miTemplates = data;
			console.log(data);
			//appendTemplates();
		}
	});
}

function appendTemplates() {
	for (var i = 0; i < miTemplates.length; i++) {

		var j = i + 1;

		var accordiionString = 
			"<div class='panel panel-default'>" +
			"<div class='panel-heading'>" + 
			"<h4 class='panel-title'>" + 
			"<a data-toggle='collapse' data-parent='#accordion' href='#collapse" + j + "'>" +
			"Template Title: " + miTemplates[i].Title + 
			"</a>" + 
			"</h4>" + 
			"</div>" + 
			"<div id='collapse" + j + "' class='panel-collapse collapse'>" + 
			"<div class='panel-body'>" + 
			"<ul class='list-group'>";

		for (var k = 0; k < miTemplates[i].questions.length; k++) {
			accordiionString +=
				"<li class='list-group-item'>" +
				"<p><b>Question:</b> " + miTemplates[i].questions[k].question + "</p>" +
				"<p><b>Question Type:</b> " + miTemplates[i].questions[k]['answer-type'] + "</p>";
		}
		accordiionString +=	 
			"</div>" + 
			"</div>" + 
			"</div>";

		$(".panel-group").append(accordiionString);
	}

}