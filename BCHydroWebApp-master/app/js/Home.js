function getAllSearchValuesForExactMatch() {
	var searchValues = {};

	$("#searchFields").children().each(function() {
		if ($(this).is("input")) {
			//console.log($(this).val())
			if ($(this).val().length > 0) {
				var title = $(this).attr("id");
				var content = $(this).val();

				searchValues[title] = content;
			}
		}
	})

	return searchValues;
}

function getAllSearchValuesForApproxMatch() {
	var searchValues = [];

	$("#searchFields").children().each(function() {
		if ($(this).is("input")) {
			//console.log($(this).val())
			if ($(this).val().length > 0) {
				var title = $(this).attr("id");
				console.log(title);
				var content = $(this).val();
				var approxObject = {
					$regex: content, $options: "i"
				}

				var tempObj = {};
				tempObj[title] = approxObject;

				searchValues.push(tempObj);
			}
		}
	})

	var newObj = {
		$or : searchValues
	};
	console.log(newObj);
	return newObj;	
}



function applySearch() {
	var searchData = {};
	if ($("#matchType").val() == "exact")
		searchData = getAllSearchValuesForExactMatch();
	else
		searchData = getAllSearchValuesForApproxMatch();

	var jsonSearchData = encodeURIComponent(JSON.stringify(searchData));

	location.href="ViewCompletedMI.html?keyword=" + jsonSearchData;
}