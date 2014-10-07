questionTypeEnum = {
	shortAnswer : 1,
	trueFalse : 2,
	table : 3,
	multipleChoice : 4
};

var questionTypeData;

var sectionCount = 0;

var questions = [];

var tables = [];

var numberOfOptions;


var numberOfRows;
var numberOfColumns;
var globalSectionList;
var allImagesInDialogs = {};



function loadQuestionTypes() {
	$.ajax({
		dataType : "json",
		async : false,
		url : "https://aws.gursimran.net:8080/questionTypes",
		success : function(data) {
			questionTypeData = data;
			console.log(data);
			appendQuestionTypeButtons();
		}
	});
}

function findActiveSection() {
	var activeSection = -1;
	for (var i = 1; i <= sectionCount; i++) {
		var section = "#panel" + i;

		if ($(section).length > 0 && !$(section).hasClass("collapsed")) {
			activeSection = i;
			break;
		}
	}

	return activeSection;
}


function addNewSection() {

	$("#dialog2").dialog("open");
	//$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>Section Title " + sectionCount + "</u>" + "<button type='button' class='close new-template-delete-button' onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></li>" + "</ul>" + "</div>" + "</div>" + "</div>");
}

function addNewSectionHelper() {

	$(this).dialog("close");
	var SectionTitle = document.getElementById("TitleOfSection").value;
	$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div   class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>" + SectionTitle + "</u>" + "<button type='button' class='close new-template-delete-button'                         onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-      body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></      li>" + "</ul>" + "</div>" + "</div>" + "</div>");
}

function addNewSectionHelperBySection(sectionName) {

	//var SectionTitle=document.getElementById("TitleOfSection").value;
	var SectionTitle = sectionName;
	$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>" + SectionTitle + "</u>" + "<button type='button' class='close new-template-delete-button' onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></li>" + "</ul>" + "</div>" + "</div>" + "</div>");
}

function deleteSection(sectionId) {
	var section = "#section" + sectionId;
	$(section).remove();
}

function appendQuestionTypeButtons() {
	for (var i = 0; i < questionTypeData.length; i++) {
		$(".new-template-question-buttons-section").append("<button type='button' onclick='addQuestion(" + questionTypeData[i].qid + ") '" + "class='btn btn-default new-template-question-buttons'>" + convertIdToString(questionTypeData[i].qid) + "</button>");
	}
}

function convertIdToString(qid) {
	var type;

	if (qid == questionTypeEnum.shortAnswer)
		type = "Short Answer";
	else if (qid == questionTypeEnum.trueFalse)
		type = "True/False";
	else if (qid == questionTypeEnum.table)
		type = "Table";
	else if (qid == questionTypeEnum.multipleChoice)
		type = "Multiple Choice";

	return type;
}

function helperTable() {

	numberOfRows = $("#NumberOfRows").val();
	numberOfColumns = $("#NumberOfColumns").val();
	$(this).dialog("close");
	makeTable(globalSectionList, numberOfRows, numberOfColumns);

}

function header() {
	var header = document.createElement('input');
	header.type = "text";
	header.class = "form-control new-template-question-input";
	header.placeholder = "title";
	return header;
}

function headerWithValue(value) {
	var header = document.createElement('input');
	header.type = "text";
	header.class = "form-control new-template-question-input";
	header.placeholder = "title";
	header.value = value;
	return header;
}

function tableToJson(table, question, section, info) {
	var data = [];
	var headers = [];
	var rowData = [];
	var rowData2 = [];
	var data = [];

	var tableQuestion = {
		qid : "3",
		"answer-type" : "table-answer",
		"max-answers" : "1",
		numRows : "",
		numColumns : "",
		question : "",
		section : "",
		firstColumn : [],
		firstRow : [],
		rowType : [],
		"helpInfo" : info
	};

	// first row needs to be headers var headers = [];
	for (var i = 0; i < table.rows[0].cells.length; i++) {
		headers[i] = table.rows[0].getElementsByTagName("th")[i].getElementsByTagName("input")[0].value;

	}


	// get the information from first column.
	for (var i = 0; i < table.rows.length; i++) {
		var tableRow = table.rows[i];
		rowData.push(tableRow.cells[0].getElementsByTagName("input")[0].value);
		if (i != 0) {
			rowData2.push(tableRow.cells[0].getElementsByTagName("select")[0].value);
		} else
			rowData2.push("");
	}

	tableQuestion.numRows = table.rows.length;
	tableQuestion.numColumns = table.rows[0].cells.length;
	tableQuestion.firstRow = headers;
	tableQuestion.firstColumn = rowData;
	tableQuestion.rowType = rowData2;
	tableQuestion.question = question;
	tableQuestion.section = section;
	data.push(headers);
	data.push(rowData);
	data.push(rowData2);


	return tableQuestion;

}



function createSelectElementWithType(type) {
	/* create select */
	var select = document.createElement("select");
	select.innerHTML = "Type of Input";
	select.setAttribute("id", "mySelect");
	select.style.width = "160px";

	var option;

	/* we are going to add two options */
	/* create options elements */
	if (type == 'text') {
		option = document.createElement("option");
		option.setAttribute("value", "text");
		option.innerHTML = "text";
		select.appendChild(option);

		option = document.createElement("option");
		option.setAttribute("value", "check");
		option.innerHTML = "check";
		select.appendChild(option);
	} else {
		option = document.createElement("option");
		option.setAttribute("value", "check");
		option.innerHTML = "check";
		select.appendChild(option);

		option = document.createElement("option");
		option.setAttribute("value", "text");
		option.innerHTML = "text";
		select.appendChild(option);
	}
	return select;
}

function createSelectElement() {
	/* create select */
	var select = document.createElement("select");
	//select.setAttribute("input Type", "mySelect");
	select.innerHTML = "Type of Input";
	select.setAttribute("id", "mySelect");
	select.style.width = "160px";

	var option;

	/* we are going to add two options */
	/* create options elements */
	option = document.createElement("option");
	option.setAttribute("value", "text");
	option.innerHTML = "text";
	select.appendChild(option);

	option = document.createElement("option");
	option.setAttribute("value", "check");
	option.innerHTML = "check";
	select.appendChild(option);

	return select;
}

function makeTable(sectionList, rows, cols) {

	var newId = generateRandomId();
	var dialogId = "dialog" + newId;
	var formId = "form" + newId;
	generateHtml(dialogId, formId);

	var li = document.createElement('li');
	li.id = "3";
	li.className = "list-group-item";
	li.innerHTML = "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + "Table" + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'" + "'>";


	var a = document.createElement('a');

	a.classList.add("glyphicon");
	a.classList.add("glyphicon-info-sign");
	a.classList.add("popoverClass");

	a.addEventListener('click', function() {
		note(dialogId, formId);
	});

	var input = document.createElement("input");
	var mybr = document.createElement('br');
	input.type = "text";
	input.placeholder = "Question";
	input.className = "form-control new-template-question-input";

	//li.appendChild(input);
	li.appendChild(mybr);
	li.appendChild(mybr);
	// put it into the DOM

	$(sectionList).append(li);
	console.log(rows);
	console.log(cols);
	row = new Array();
	cell = new Array();

	row_num = rows;
	//edit this value to suit
	cell_num = cols;
	//edit this value to suit

	tab = document.createElement('table');
	tab.setAttribute('id', 'newtable');
	//tab.className="list-group-item";
	tbo = document.createElement('tbody');

	var button = document.createElement("input");
	button.type = "submit";
	button.value = "convert2Json";
	//	button.onclick = "tableToJson(tab)";
	button.addEventListener('click', function() {
		tableToJson(tab);
	});
	//li.appendChild(button);

	for ( c = 0; c < row_num; c++) {

		row[c] = document.createElement('tr');

		for ( k = 0; k < cell_num; k++) {
			if ((c % row_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].appendChild(header());

			} else if ((k % cell_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].appendChild(header());
				cell[k].appendChild(createSelectElement());
			} else {
				cell[k] = document.createElement('td');
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

		$("table").styleTable();
	})(jQuery);
}

function makeEditableTable(activeSection, rows, cols, firstColumn, firstRow, rowType, questionBody, extras) {

	var newId = generateRandomId();
	var dialogId = "dialog" + newId;
	var formId = "form" + newId;
	generateHtml(dialogId, formId,extras);
	var sectionList = "#sectionList" + activeSection;
	globalSectionList = sectionList;
	var li = document.createElement('li');
	li.id = "3";
	li.className = "list-group-item";
	li.innerHTML = "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + "Table" + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...' value='" + questionBody + "'>";
	var input = document.createElement("input");
	var mybr = document.createElement('br');
	input.type = "text";
	input.placeholder = "Question";
	input.className = "form-control new-template-question-input";
	input.value = questionBody;

	//li.appendChild(input);

	li.appendChild(mybr);
	li.appendChild(mybr);
	// put it into the DOM

	$(sectionList).append(li);
	console.log(rows);
	console.log(cols);
	row = new Array();
	cell = new Array();

	row_num = rows;
	//edit this value to suit
	cell_num = cols;
	//edit this value to suit

	tab = document.createElement('table');
	tab.setAttribute('id', 'newtable');
	//tab.className="list-group-item";
	tbo = document.createElement('tbody');

	var button = document.createElement("input");
	button.type = "submit";
	button.value = "convert2Json";
	//	button.onclick = "tableToJson(tab)";
	button.addEventListener('click', function() {
		tableToJson(tab);
	});
	//li.appendChild(button);

	for ( c = 0; c < row_num; c++) {

		row[c] = document.createElement('tr');

		for ( k = 0; k < cell_num; k++) {
			if ((c % row_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].appendChild(headerWithValue(firstRow[k]));

			} else if ((k % cell_num) == 0) {
				cell[k] = document.createElement('th');
				cell[k].appendChild(headerWithValue(firstColumn[c]));
				cell[k].appendChild(createSelectElementWithType(rowType[c]));
			} else {
				cell[k] = document.createElement('td');
			}
			//cont = document.createTextNode((c + 1) * (k + 1))
			//cell[k].appendChild(cont);
			row[c].appendChild(cell[k]);
		}
		tbo.appendChild(row[c]);
	}
	tab.appendChild(tbo);
	//document.getElementById(sectionList).getElementById("3").appendChild(tab);
	$(li).append(tab);
	//document.getElementById("3").appendChild(tab);

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

		$("table").styleTable();
	})(jQuery);
}




function addQuestionByActiveSection(questionType, activeSectionNumber, questionBody,extras, a1, a2, a3, a4,a5) {
	var activeSection = activeSectionNumber;
	console.log("extras"+extras.acceptedAnswer);

	if (activeSection != -1) {
		var type = convertIdToString(questionType);

		var sectionList = "#sectionList" + activeSection;
		globalSectionList = sectionList;
		//Need to prompt the user for number of rows and height before appending table to the list of questions
		if (type == "Table") {

			$("#dialog").dialog("open");
			console.log(numberOfRows);
			console.log(numberOfColumns);

		}


		//MC
		else if (questionType == 4) {
			
			console.log("Add a multiple choice!");
			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			generateHtml(dialogId, formId,extras);

			var initialText = "<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...' value='" + questionBody + "'><br/>" + "<ul class='list-group'>" + "<li class='list-group-item'>";

			for (var i = 1; i <= 5; i++) {
				var answer = "";
				switch(i) {
					case 1:
						answer = a1;
						break;
					case 2:
						answer = a2;
						break;
					case 3:
						answer = a3;
						break;
					case 4:
						answer = a4;
						break;
					case 5:
						answer = a5;
						break;
				}
				initialText += "<input id='option' type='text' class='form-control new-template-question-input' placeholder='Option " + i + "....' value='" + answer + "'>";
			}

			initialText += "</li>" + "</ul>" +"Receive notification when value is NOT equal to (Accepted value): <select class='form-control new-template-question-input' >" +"<option value='none'>No Notification</option><option value='1'>Option 1</option><option value='2'>Option 2</option><option value='3'>Option 3</option><option value='4'>Option 4</option><option value='5'>Option 5</option></select>"  +"</li>";

			$(sectionList).append(initialText);
			$("#"+dialogId+"close").parent().find("select").val(extras.acceptedAnswerEdit);
		}


		//true/false
		else if(questionType==2) {
			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			generateHtml(dialogId, formId,extras);
			var initialText2=("<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...' value='" + questionBody + "'>" );

			initialText2 +="<br>Receive notification when value is NOT equal to (Accepted value): <select class='form-control new-template-question-input'  >"+"<option selected>"+ extras.acceptedAnswer +"</option>" +"<option value='none'>No Notification</option><option value='true'>True</option><option value='false'>False</option></select>"        + "</li>"

			$(sectionList).append(initialText2);
		}
		//short answer
		else if(questionType==1) {
			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			console.log("short inside");
			console.log(extras);
			generateHtml(dialogId, formId,extras);
			var initialText3=("<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...' value='" + questionBody + "'>" );
			
			initialText3 +="<br>Receive notification when value is NOT wihtin this numerical range:" +"<input id='from' value='"+extras.acceptedAnswer.from+ "' type='number' onkeypress='return isNumberKey(event)' class='form-control new-template-question-input' " + "placeholder='From'>" + "<input id='to'  value='"+extras.acceptedAnswer.to+ "' type='number' onkeypress='return isNumberKey(event)' class='form-control new-template-question-input' " + "placeholder='To'>"
         + "</li>"

			$(sectionList).append(initialText3);
		}
		
	} else
		alert('No active section. Please open a section to add a question to.');
}

function isNumberKey(evt) {
	var charCode = (evt.which) ? evt.which : event.keyCode;
	if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57))
		return false;

	return true;
};

function mcHelper() {

	var numberOfOptions = $("#mcOptions").val();
	$(this).dialog("close");

	

}

function addQuestion(questionType) {
	var activeSection = findActiveSection();

	if (activeSection != -1) {
		var type = convertIdToString(questionType);

		var sectionList = "#sectionList" + activeSection;
		globalSectionList = sectionList;
		//Need to prompt the user for number of rows and height before appending table to the list of questions
		if (type == "Table") {

			
			$("#dialog").dialog("open");
			console.log(numberOfRows);
			console.log(numberOfColumns);

		} else if (type == "Multiple Choice") {

			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			generateHtml(dialogId, formId);

			var initialText = "<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + "' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + "<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'> <br>" + "<ul class='list-group'>" + "<li class='list-group-item'>";

			
			for (var i = 1; i <= 5; i++) {
				initialText += "<input id='option' type='text' class='form-control new-template-question-input' placeholder='Option " + i + "....' >";
			}

			initialText += "</li>" + "</ul>" +"Receive notification when value is NOT equal to (Accepted value): <select class='form-control new-template-question-input'><option value='none'>No Notification</option><option value='1'>Option 1</option><option value='2'>Option 2</option><option value='3'>Option 3</option><option value='4'>Option 4</option><option value='5'>Option 5</option></select>"+ "</li>";
			
			$(sectionList).append(initialText);
		} else if (type == "True/False") {
			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			generateHtml(dialogId, formId);
			$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + 
			"' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + 
			"<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + 
			"<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'>" + 
			"<br>Receive notification when value is NOT equal to (Accepted value): <select class='form-control new-template-question-input'><option value='none'>No Notification</option><option value='true'>True</option><option value='false'>False</option></select>" + "</li>");

		} else if (type == "Short Answer") {
			var newId = generateRandomId();
			var dialogId = "dialog" + newId;
			var formId = "form" + newId;
			generateHtml(dialogId, formId);
			$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<button id='" + dialogId + "close" + 
			"' type='button' class='close new-template-delete-button' onclick='deleteQuestion(\"" + dialogId + "\");' aria-hidden='true'>&times;</button>	" + 
			"<a class='glyphicon glyphicon-info-sign popoverClass' href='#' onclick='note(\"" + dialogId + "\",\"" + formId + "\");'></a>" + "<h5>" + type + "</h5>" + 
			"<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'>" + 
			"<br>Receive notification when value is NOT wihtin this numerical range:" +"<input id='from' type='number' onkeypress='return isNumberKey(event)' class='form-control new-template-question-input' " + "placeholder='From'>" + "<input id='to' type='number' onkeypress='return isNumberKey(event)' class='form-control new-template-question-input' " + "placeholder='To'>"
 +"</li>"); 
			
		}
	} else
		alert('No active section. Please open a section to add a question to.');
}

var myDropzones = new Array();
function closeDialog() {
	$(this).dialog("close");
}

function generateHtml(dialogId, formId,extras) {
	console.log("HTML");
	
	var text2 = '<div id="' + dialogId + '" class="ui-dialog-content ui-widget-content" style="width: auto; min-height: 10px; max-height: none; height: auto;"> <input  type="text" class="form-control new-template-question-input" placeholder="' + dialogId + '"> </div>';

	$(document.body).append(text2);
	$(function() {
		$("#" + dialogId).dialog({
			autoOpen : false
		}, {
			modal : true
		}, {
			width : 800
		}, {
			height : 400
		}, {
			maxHeight : 400
		}, {
			show : {
				effect : "blind",
				duration : 300
			}
		}, {
			buttons : [{
				text : "Close",
				click : closeDialog //This function is in CreateNewTemplate.js
			}]
		});
	});

	$("#" + dialogId).addClass("dropzone");

	var dropzoneObject = {
		"dialog" : dialogId,
		"dropzone" : ""
	};

	allImagesInDialogs[dialogId] = [];

	Dropzone.autoDiscover = false;

	var myDropzone = new Dropzone("div#" + dialogId, {

		url : "/file/post",
		paramName : "file", // The name that will be used to transfer the file
		addRemoveLinks : true,
		autoProcessQueue:false,
		init : function() {
			this.on("addedfile", function(file) {
				var reader = new FileReader();
				reader.onload = function(readerEvt) {
					var binaryString = readerEvt.target.result;
					console.log(file.name);
					var filename = file.name;
					allImagesInDialogs[dialogId][filename] = btoa(binaryString);
					//print=btoa(binaryString);
				};

				reader.readAsBinaryString(file);
			});

			this.on("removedfile", function(file) {

				var filename = file.name;
				delete allImagesInDialogs[dialogId][filename];
				//console.log(allImagesInDialogs);
				//print=btoa(binaryString);
			});

		}
	});
	
	myDropzone.createImageThumbnails=true;
	//extract the image from the extras object.
	if(extras!=undefined){

		$("#"+dialogId).find("input").val(extras.helpInfo.text);

	for (var i = 0; i < (extras.helpInfo.images.length); i++) {
		var contentType = 'image/png';
		var b=base64toBlob(extras.helpInfo.images[i].image,contentType);
		b["name"] = generateRandomId();
		console.log("BBBB");
		console.log(b);

		var image = new Image;
		image.src = "data:image/png;base64"+(extras.helpInfo.images[i].image);

		var url = URL.createObjectURL(b);
		//var b=atob(extras.helpInfo.images[i].image);
		myDropzone.emit("addedfile",b );
		myDropzone.emit("thumbnail", b, url);
	}
}

// Call the default addedfile event handler
	
	dropzoneObject.dropzone = myDropzone;
	myDropzones.push(dropzoneObject);

}

function getBase64Image(img) {
    // Create an empty canvas element
    var canvas = document.createElement("canvas");
    canvas.width = img.width;
    canvas.height = img.height;

    // Copy the image contents to the canvas
    var ctx = canvas.getContext("2d");
    ctx.drawImage(img, 0, 0);

    // Get the data-URL formatted image
    // Firefox supports PNG and JPEG. You could check img.src to guess the
    // original format, but be aware the using "image/jpg" will re-encode the image.
    var dataURL = canvas.toDataURL("image/png");

    return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
}

function base64toBlob(base64Data, contentType) {
    contentType = contentType || '';
    var sliceSize = 1024;
    var byteCharacters = atob(base64Data);
    var bytesLength = byteCharacters.length;
    var slicesCount = Math.ceil(bytesLength / sliceSize);
    var byteArrays = new Array(slicesCount);

    for (var sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
        var begin = sliceIndex * sliceSize;
        var end = Math.min(begin + sliceSize, bytesLength);

        var bytes = new Array(end - begin);
        for (var offset = begin, i = 0 ; offset < end; ++i, ++offset) {
            bytes[i] = byteCharacters[offset].charCodeAt(0);
        }
        byteArrays[sliceIndex] = new Uint8Array(bytes);
    }
    return new Blob(byteArrays, { type: contentType});
}

function generateRandomId() {
	var randLetter = String.fromCharCode(65 + Math.floor(Math.random() * 26));
	var uniqid = randLetter + Date.now();
	return uniqid;

}

function note(dialogId, formId) {
	$(document).ready(function() {
		$("#" + dialogId).dialog("open");

	});
	//$("#" + dialogId).dialog("open");
}

function deleteQuestion(dialogId) {
	delete allImagesInDialogs[dialogId];
	console.log("delet question: " + dialogId);
	$("#" + dialogId + "close").parent().remove();
	$("#" + dialogId).remove();
	$("#" + dialogId).dialog("destroy");

}

function convert64(file) {
	var reader = new FileReader();
	reader.onload = function(readerEvt) {
		var binaryString = readerEvt.target.result;
		//console.log(btoa(binaryString));
		var answer = btoa(binaryString);
		return answer;
	};

	reader.readAsBinaryString(file);
}

function gatherQuestions() {
	var questions = [];

	for (var i = 1; i <= sectionCount; i++) {
		var section = "#panel" + i;
		var sectionList = "#sectionList" + i;

		$(sectionList).children().each(function() {
			if (this.id == questionTypeEnum.table) {
				var tableData = $(this).find("table")[0];
				var questionString = $(this).find("input").val();
				var sectionTitle = $(section).children("u").text();

				var answers = [];

				var images = new Array();

				var buttonId = $(this).find("button").attr("id");
				var dialogId = buttonId.split("close")[0];

				for (var key in allImagesInDialogs[dialogId]) {
					var imageObject = {
						"imageText" : "",
						"image" : allImagesInDialogs[dialogId][key]
					};

					images.push(imageObject);

				}

				var note = $("#" + dialogId).find("input").val();

				var info = {
					"text" : note,
					"images" : images
				};

				var jsonTable = tableToJson(tableData, questionString, sectionTitle, info);

				questions.push(jsonTable);
			} else if (this.id == questionTypeEnum.multipleChoice) {
				var answers = [];

				var images = new Array();

				var buttonId = $(this).find("button").attr("id");
				var dialogId = buttonId.split("close")[0];

				for (var key in allImagesInDialogs[dialogId]) {
					var imageObject = {
						"imageText" : "",
						"image" : allImagesInDialogs[dialogId][key]
					};

					images.push(imageObject);

				}

				var note = $("#" + dialogId).find("input").val();

				var info = {
					"text" : note,
					"images" : images
				};

				$(this).find("ul").children().find("input").each(function() {
					answers.push($(this).val());
				});
				var selectedAcepted = $(this).find("select").val();
				var acceptedAnswer;
				if (selectedAcepted != "none"){
					intSelected = parseInt(selectedAcepted) - 1;
					acceptedAnswer = answers[intSelected];
				}else{
					acceptedAnswer = "none";
				}
				

				var questionData = {
					"qid" : this.id,
					"question" : $(this).find("input").val(),
					"acceptedAnswer" : acceptedAnswer,
					"acceptedAnswerEdit":selectedAcepted,
					"answers" : answers,
					"answer-type" : "multiple-choice",
					"max-answers" : 1,
					"section" : $(section).children("u").text(),
					"helpInfo" : info
				};

				questions.push(questionData);
			} else if (this.id == questionTypeEnum.trueFalse){

				var images = new Array();

				var buttonId = $(this).find("button").attr("id");
				var dialogId = buttonId.split("close")[0];

				for (var key in allImagesInDialogs[dialogId]) {
					var imageObject = {
						"imageText" : "",
						"image" : allImagesInDialogs[dialogId][key]
					};

					images.push(imageObject);

				}

				var note = $("#" + dialogId).find("input").val();

				var acceptedAnswer = $(this).find("select").val();

				
				var info = {
					"text" : note,
					"images" : images
				};
				questions.push({
					"qid" : this.id,
					"question" : $(this).find("input").val(),
					"acceptedAnswer" : acceptedAnswer,
					"section" : $(section).children("u").text(),
					"helpInfo" : info
				});

			}else if(this.id == questionTypeEnum.shortAnswer){

				var images = new Array();

				var buttonId = $(this).find("button").attr("id");
				var dialogId = buttonId.split("close")[0];

				for (var key in allImagesInDialogs[dialogId]) {
					var imageObject = {
						"imageText" : "",
						"image" : allImagesInDialogs[dialogId][key]
					};

					images.push(imageObject);

				}

				var note = $("#" + dialogId).find("input").val();

				var info = {
					"text" : note,
					"images" : images
				};

				var acceptedAnswer={
					from:"",
					to:""
				}; 

				acceptedAnswer.from= $(this).find("#from").val();
				acceptedAnswer.to= $(this).find("#to").val();
				var number = false;
				if((acceptedAnswer.from.length>0) || (acceptedAnswer.to.length>0) ){
					number = true;
				}
				questions.push({
					"qid" : this.id,
					"numberInput" : number,
					"acceptedAnswer" : acceptedAnswer,
					"question" : $(this).find("input").val(),
					"section" : $(section).children("u").text(),
					"helpInfo" : info
				});
			
			}
		});
	}

	return questions;
}

function submitTemplate() {
	var completedTemplate = {
		Title : "",
		MIDiscipline : "",
		InstructionNumber : "",
		OriginalIssueDate : "",
		AppliedToEquipment : "",
		Supersedes : "",
		References : "",
		FileNumber : "",
		PreparedBy : "",
		PreparedByTitle : "",
		AcceptedBy : "",
		AcceptedByTitle : "",
		Eor : "",
		RevisionHistory : "",
		RevisionNumber : "",
		RevisionNumberRevisedBy : "",
		RevisionNumberDate : "",

		questions : []
	};

	//Uncomment this line when merging the new POST JSON format and delete the proceeding code
	var questions = gatherQuestions();


	completedTemplate.Title = $("#templateTitle").val();
	completedTemplate.MIDiscipline = $("#MIDiscipline").val();
	completedTemplate.InstructionNumber = $("#InstructionNumber").val();
	completedTemplate.OriginalIssueDate = $("#OriginalIssueDate").val();
	completedTemplate.AppliedToEquipment = $("#AppliedtoEquipment").val();
	completedTemplate.Supersedes = $("#Supersedes").val();
	completedTemplate.References = $("#References").val();
	completedTemplate.FileNumber = $("#FileNumber").val();
	completedTemplate.PreparedBy = $("#PreparedBy").val();
	completedTemplate.PreparedByTitle = $("#PreparedByTitle").val();
	completedTemplate.email = $("#email").val();
	completedTemplate.AcceptedBy = $("#AcceptedBy").val();
	completedTemplate.AcceptedByTitle = $("#AcceptedByTitle").val();
	completedTemplate.Eor = $("#EOR").val();

	completedTemplate.RevisionHistory = $("#RevisionHistory").val();
	completedTemplate.RevisionNumber = $("#RevisionNumber").val();
	completedTemplate.RevisionNumberRevisedBy = $("#RevisedBy").val();
	completedTemplate.RevisionNumberDate = $("Date").val();

	console.log($("#templateTitle").val());
	completedTemplate.questions = questions;

	var jsonTemplate = JSON.stringify(completedTemplate);
	console.log(jsonTemplate);

	var contentLength = jsonTemplate.length;

	$.ajax({
		type : "POST",
		asyn : false,
		contentType : "application/json",
		url : "https://aws.gursimran.net:8080/addtemplate",
		dataType : "json",
		async : false,
		data : jsonTemplate,
		success : function(data) {
			alert('Template submitted successfully');
			location.href = "home.html";
		}
	});

	alert('Template submitted successfully');
	location.href = "home.html";
}
