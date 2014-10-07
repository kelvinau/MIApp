questionTypeEnum = {
	shortAnswer : 1,
	trueFalse : 2,
	table : 3,
	multipleChoice: 4
};

var questionTypeData;

var sectionCount = 0;

var questions = [];

var tables = [];

//Small dialouge box to prompt the user for the size of of table they want.
//var tableSize = document.createElement('div');
//tableSize.id='dialog';
//$( "#dialog" ).dialog({ autoOpen: false });
var numberOfRows;
var numberOfColumns;
var globalSectionList;

//Used to prompt the user for header Titles in the table.

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

/*
function addNewSection() {
	$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>Section Title " + sectionCount + "</u>" + "<button type='button' class='close new-template-delete-button' onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></li>" + "</ul>" + "</div>" + "</div>" + "</div>");
}
*/
function addNewSection() {

	$("#dialog2").dialog("open");
	//$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>Section Title " + sectionCount + "</u>" + "<button type='button' class='close new-template-delete-button' onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></li>" + "</ul>" + "</div>" + "</div>" + "</div>");
}
 
function addNewSectionHelper() {

          $(this).dialog("close");
               var SectionTitle=document.getElementById("TitleOfSection").value;
                    $(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div   class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>"+    SectionTitle + "</u>" + "<button type='button' class='close new-template-delete-button'                         onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" +    "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-      body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></      li>" + "</ul>" + "</div>" + "</div>" + "</div>");
                     }


function addNewSectionHelperBySection(sectionName) {

	//var SectionTitle=document.getElementById("TitleOfSection").value;
    var SectionTitle = sectionName;
	$(".panel-group").append("<div id='section" + (++sectionCount) + "' class='panel panel-default'>" + "<div class='panel-heading'>" + "<h4 class='panel-title'>" + "<a id='panel" + sectionCount + "' data-toggle='collapse' data-parent='#accordion' href='#collapse" + sectionCount + "' class='collapsed'>" + "<u>"+SectionTitle + "</u>" + "<button type='button' class='close new-template-delete-button' onclick='deleteSection(" + sectionCount + ")' aria-hidden='true'>&times;" + "</button>" + "</a>" + "</h4>" + "</div>" + "<div id='collapse" + sectionCount + "' class='panel-collapse collapse'>" + "<div class='panel-body'>" + "<ul id = 'sectionList" + sectionCount + "' class='list-group>" + "<li class='list-group-item></li>" + "</ul>" + "</div>" + "</div>" + "</div>");
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
		type = "Multiple Choice"

	return type;
}

function helperTable() {

	numberOfRows = $("#NumberOfRows").val();
	numberOfColumns = $("#NumberOfColumns").val();
	$(this).dialog("close");
	//alert("rows:" + numberOfRows + "   " + "columns:" + numberOfColumns);
	//After closing the dialogue construct the table.
	makeTable(globalSectionList, numberOfRows, numberOfColumns);

}

function header() {
	var header = document.createElement('input');
	header.type = "text";
	header.class = "form-control new-template-question-input";
	header.placeholder = "title";
	return header;
}

function tableToJson(table, question, section) {
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
		rowType : []
	};

	// first row needs to be headers var headers = [];
	for (var i = 0; i < table.rows[0].cells.length; i++) {
		//headers[i] = table.rows[0].cells[i].childNodes[0].getElementsByTagName('input')[0];
		headers[i] = table.rows[0].getElementsByTagName("th")[i].getElementsByTagName("input")[0].value;
		//alert(headers[i]);
		//$(newtable).get("th")[i].val();

	}
	alert(JSON.stringify(headers));
	//alert("size of headers:" + headers.length);
	//console.log(headers);

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
	alert(JSON.stringify(data));

	return tableQuestion;

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

	//$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'" + "</li>");
	var li = document.createElement('li');
	li.id = "3";
	li.className = "list-group-item";
	li.innerHTML = "<h5>" + "table" + "</h5>";
	var input = document.createElement("input");
	var mybr = document.createElement('br');
	input.type = "text";
	input.placeholder = "Question";
	input.className = "form-control new-template-question-input";

	li.appendChild(input);

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
	li.appendChild(button);

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


function addQuestionByActiveSection(questionType, activeSectionNumber,questionBody) {
	var activeSection = activeSectionNumber;

	if (activeSection != -1) {
		var type = convertIdToString(questionType);

		var sectionList = "#sectionList" + activeSection;
		globalSectionList = sectionList;
		//Need to prompt the user for number of rows and height before appending table to the list of questions
		if (type == "Table") {

			//$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'" + "</li>");
			$("#dialog").dialog("open");
			console.log(numberOfRows);
			console.log(numberOfColumns);

		}
		// $(sectionBody).append(
		// 	"<h5>" + type + "</h5>" +
		// 	"Text Box"
		// 	);
		else
			$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<button type='button' class='close new-template-delete-button' onclick='' aria-hidden='true'>&times;</button>	" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...' value='" + questionBody + "'>" + "</li>");
	} else
		alert('No active section. Please open a section to add a question to.');
}

function addQuestion(questionType) {
	var activeSection = findActiveSection();

	if (activeSection != -1) {
		var type = convertIdToString(questionType);

		var sectionList = "#sectionList" + activeSection;
		globalSectionList = sectionList;
		//Need to prompt the user for number of rows and height before appending table to the list of questions
		if (type == "Table") {

			//$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'" + "</li>");
			$("#dialog").dialog("open");
			console.log(numberOfRows);
			console.log(numberOfColumns);

		}
		else if(type == "Multiple Choice") {
			console.log("Add a multiple choice!");

			var initialText = 
				"<li id=" + questionType + " class='list-group-item'>" +
					"<button type='button' class='close new-template-delete-button' onclick='' aria-hidden='true'>&times;</button>" +
					"<h5>" + type + "</h5>" + 
				 	"<input id='question' type='text' class='form-control new-template-question-input' " + "placeholder='Question...'><br/>" +
					"<ul class='list-group'>" + 
						"<li class='list-group-item'>";
			

			for (var i = 1; i <= 4; i++) {
				initialText += "<input id='option' type='text' class='form-control new-template-question-input' placeholder='Option " + i + "....' >";
			} 

			initialText +=
						"</li>" +
					"</ul>" +
				"</li>";

			$(sectionList).append(initialText);
		}
		else
			$(sectionList).append("<li id=" + questionType + " class='list-group-item'>" + "<button type='button' class='close new-template-delete-button' onclick='' aria-hidden='true'>&times;</button>	" + "<h5>" + type + "</h5>" + "<input type='text' class='form-control new-template-question-input' " + "placeholder='Question...'>" + "</li>");
	} else
		alert('No active section. Please open a section to add a question to.');
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

				var jsonTable = tableToJson(tableData, questionString, sectionTitle);

				questions.push(jsonTable);
			} 
			else if (this.id == questionTypeEnum.multipleChoice) {
				var answers = [];

				$(this).find("ul").children().find("input").each(function() {
					answers.push($(this).val());
				})

				var questionData = {
					"qid" : this.id,
					"question" : $(this).find("input").val(),
					"answers" : answers,
					"answer-type": "multiple-choice",
					"max-answers": 1,
					"section" : $(section).children("u").text()
				}

				questions.push(questionData);
			}
			else {
				questions.push({
					"qid" : this.id,
					"question" : $(this).find("input").val(),
					"section" : $(section).children("u").text()
				})
			}
		})
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

	// var questions = [];

	// $(".list-group li").each(function () {
	// 	questions.push({
	// 		"qid": this.id,
	// 		"question": $(this).find("input").val()
	// 	});
	// });

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
	completedTemplate.AcceptedBy = $("#AcceptedBy").val();
	completedTemplate.AcceptedByTitle = $("#AcceptedByTitle").val();
	completedTemplate.Eor = $("#EOR").val();
	/*
	 completedTemplate.RevisionHistory=$("#RevisionHistory").val();
	 completedTemplate.RevisionNumber=$("#RevisionNumber").val();
	 completedTemplate.RevisionNumberRevisedBy=$("#RevisedBy").val();
	 completedTemplate.RevisionNumberDate=$("Date").val();
	 */
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
