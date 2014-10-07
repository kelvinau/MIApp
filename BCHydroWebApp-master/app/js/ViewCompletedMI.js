

questionTypeEnum = {
	shortAnswer : 1,
	trueFalse: 2,
	table:3,
	mulitpleChoice: 4
};

var completedMis = [];

var specificMi = {};

function getAllCompletedMis() {
	var url = $.url();
	var queryString = url.param('keyword');
	if (queryString == undefined) {
		$.ajax({
			dataType: "json",
			async: false,
			url: "https://aws.gursimran.net:8080/getCompletedMis",
			success: function(data) {
				completedMis = data;
				appendCompletedMis();
			}
		});
	}
	else {
		$.ajax({
			dataType: "json",
			async: false,
			url: "https://aws.gursimran.net:8080/searchCompletedMis/" + queryString,
			success: function(data) {
				completedMis = data;
				console.log(data);
				appendCompletedMis();
			}
		});		
	}
}

function appendCompletedMis() {
	for (var i = 0; i < completedMis.length; i++) {

		var j = i + 1;

		var accordiionString = 
			"<div class='panel panel-default'>" +
			"<div class='panel-heading'>" + 
			"<h4 class='panel-title'>" + 
			"<a data-toggle='collapse' data-parent='#accordion' onclick='getAnswerById(\"" + completedMis[i]._id + "\")' href='#collapse" + j + "'>" +
			"MI Title: " + completedMis[i].Title + " <h5>Submitted Date: " + completedMis[i].SubmittedDate + "</h5>" +
			"</a>" + 
			"</h4>" + 
			"<h5>Version: " + completedMis[i].version + " &nbsp;&nbsp;&nbsp;Discipline: " + completedMis[i].MIDiscipline + " &nbsp;&nbsp;&nbsp;Equipment: " + completedMis[i].AppliedToEquipment + " &nbsp;&nbsp;&nbsp;Instruction Number: " + completedMis[i].InstructionNumber + "</h5>" +
			"</div>" + 
			"<div id='collapse" + j + "' class='panel-collapse collapse'>" + 
			"<div class='panel-body'>" + 
			"<ul id='" + completedMis[i]._id + "' class='list-group'>";

		accordiionString +=	 
			"</li>" +
			"</div>" + 
			"</div>" + 
			"</div>";

		$(".panel-group").append(accordiionString);
	}
}

function getAnswerById(MiId) {
	$.ajax({
		dataType: "json",
		async: false,
		url: "https://aws.gursimran.net:8080/getAnswerById/" + MiId,
		success: function(data) {
			specificMi = data;
			addSpecificMiData();
		}
	});
}

function addSpecificMiData() {
		var imageArray = specificMi.media.images;
		var videoArray = specificMi.media.videos;
		var voiceArray = specificMi.media.voice;

		var accordiionString = "";

		for (var k = 0; k < specificMi.questions.length; k++) {
			accordiionString +=
				"<li class='list-group-item'>" +
				"<p><b>Question:</b> " + specificMi.questions[k].question + "</p>";

			if(specificMi.questions[k].qid == questionTypeEnum.table)	{
				var columnNumber = specificMi.questions[k]['numColumns'];
        		var rowNumber = specificMi.questions[k]['numRows'];
       	 		var firstColumn = specificMi.questions[k].firstColumn;
        		var firstRow = specificMi.questions[k].firstRow;
        		var rowType = specificMi.questions[k].rowType;
        		var answer=specificMi.questions[k]['user-answer']['table-answer'];

        		accordiionString +=
					"<p><b>Answer:</b> " +makeEditableTable(rowNumber, columnNumber, firstColumn, firstRow, rowType, answer)  + "</p>";	
        		if(specificMi.questions[k]['user-answer']['comment']!=""){
        			accordiionString +=
					"<p><b>Comment:</b> " + specificMi.questions[k]['user-answer']['comment'] + "</p>";	

        		}

			}

			 else if (specificMi.questions[k].qid == questionTypeEnum.shortAnswer) {
				accordiionString +=
					"<p><b>Answer:</b> " + specificMi.questions[k]['user-answer']['short-answer'] + "</p>";	
					if(specificMi.questions[k]['user-answer']['comment']!=""){
        			accordiionString +=
					"<p><b>Comment:</b> " + specificMi.questions[k]['user-answer']['comment'] + "</p>";	

        		}
			}
			else if (specificMi.questions[k].qid == questionTypeEnum.trueFalse) {
				accordiionString +=
					"<p><b>Answer:</b> " + specificMi.questions[k]['user-answer']['check-boxes'][0] + "</p>";
					if(specificMi.questions[k]['user-answer']['comment']!=""){
        			accordiionString +=
					"<p><b>Comment:</b> " + specificMi.questions[k]['user-answer']['comment'] + "</p>";	

        		}	
			}
			else if (specificMi.questions[k].qid == questionTypeEnum.mulitpleChoice) {
				accordiionString +=
					"<p><b>Answer:</b> " + specificMi.questions[k]['user-answer']['check-boxes'][0] + "</p>";
					if(specificMi.questions[k]['user-answer']['comment']!=""){
        			accordiionString +=
					"<p><b>Comment:</b> " + specificMi.questions[k]['user-answer']['comment'] + "</p>";	

        		}	
			}

			if (typeof specificMi.questions[k]['user-answer'].images != "undefined") {
				for (var n = 0; n < specificMi.questions[k]['user-answer'].images.length; n++) {
					var currentImage = specificMi.questions[k]['user-answer'].images[n].split(".");
					currentImage = currentImage[0];
					var imageData = imageArray[currentImage];

					var imageString = "data:image/gif;base64," + imageData;

					accordiionString +=
						"<img class='view-mi-picture-width-height' src='" + imageString + "'/><br><br>";
				}
			}

			//justins function
			if (typeof specificMi.questions[k]['user-answer'].videos != "undefined"){
				 for (var n = 0; n < specificMi.questions[k]['user-answer'].videos.length; n++) {
                                        var currentVideo = specificMi.questions[k]['user-answer'].videos[n];
                                        var videoData = videoArray[currentVideo];

                                        var videoString = videoData;

                                        accordiionString +=
                                                "<video controls><source type='video/mp4' src='data:video/mp4;base64," + videoString + "'></video>";
                                }
			}

			

			if (typeof specificMi.questions[k]['user-answer'].voice != "undefined") {
				for (var n = 0; n < specificMi.questions[k]['user-answer'].voice.length; n++) {
					var currentVoice = specificMi.questions[k]['user-answer'].voice[n].split(".");
					currentVoice = currentVoice[0];
					var voiceData = voiceArray[currentVoice];

					var voiceString = voiceData;
					console.log(voiceString);

					accordiionString +=
                                                "<br><br><video  width='320' height='240' controls><source type='video/mp4' src='data:video/mp4;base64," + voiceString + "'></video>";
				}
			}


		}

		if(specificMi.foremanComment['comment'] !=""){

				accordiionString +=
				"<li class='list-group-item'>" + "<p><b>Foreman Comment:</b> " + specificMi.foremanComment['comment'] + "</p>";	
					accordiionString +="<p><b>Foreman Supervisor:</b> " + specificMi.foremanComment['supervisor'] + "</p>";	

        }

		$("#" + specificMi._id).empty();
		$("#" + specificMi._id).append(accordiionString);
}



function headerWithValue(value) {
	return "<input type='text' value='"+value   +"'  " + "'>";
}


function makeEditableTable(rows, cols, firstColumn, firstRow, rowType, answer) {


	var li = document.createElement('li');
	li.id = "3";
	li.className = "list-group-item";

	var mybr = document.createElement('br');
	li.appendChild(mybr);
	li.appendChild(mybr);


	// put it into the DOM

	row = new Array();
	cell = new Array();

	row_num = rows;
	
	cell_num = cols;
	

	tab = document.createElement('table');
	tab.setAttribute('id', 'newtable');

	tbo = document.createElement('tbody');


	for ( c = 0; c < row_num; c++) {

		row[c] = document.createElement('tr');

		for ( k = 0; k < cell_num; k++) {
			if ((c % row_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].innerHTML=headerWithValue(firstRow[k]);


			} else if ((k % cell_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].innerHTML=headerWithValue(firstColumn[c]);

			} else {
				cell[k] = document.createElement('td');
				var txt=new String(c+1+","+(k+1));

				cell[k].innerHTML=answer[txt];

			}

			row[c].appendChild(cell[k]);
		}
		tbo.appendChild(row[c]);
	}
	tab.appendChild(tbo);

	$(li).append(tab);


	//Use this funciton to style the table after its done
	(function($) {
		$.fn.styleTable = function(options) {
			var defaults = {
				css : 'ui-styled-table'
			};
			options = $.extend(defaults, options);

			return this.each(function() {
				$this = $(this);
				$this.addClass(options.css);

				$this.on('mouseover mouseout', 'tbody tr', function(event) {
					$(this).children().toggleClass("ui-state-hover", event.type == 'mouseover');
				});

				$this.find("th").addClass("ui-state-default");
				$this.find("td").addClass("ui-widget-content");
				$this.find("tr:last-child").addClass("last-child");
			});
		};

		
	})(jQuery);
	$(tab).styleTable();

	return li.innerHTML;
}


