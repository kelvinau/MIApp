var https = require('https');
var fs = require('fs');
//Add SSL option to encrypt traffic
var options = {
  key: fs.readFileSync('/etc/httpd/ssl/myserverCert.key'),
  cert: fs.readFileSync('/etc/httpd/ssl/aws_gursimran_net.crt')
};


//Add libraries to interact with mongoDB
var express = require('express'), app = express(), cons = require('consolidate'), MongoClient = require('mongodb').MongoClient, Server = require('mongodb').Server;

app.engine('html', cons.swig);
app.set('view engine', 'html');
app.set('views', __dirname + '/views');
app.use(express.bodyParser({limit: '50mb'}));
app.use(app.router);

var mongoclient = new MongoClient(new Server("aws.gursimran.net", 27017));
var db = mongoclient.db('mi');


var mail = require("nodemailer").mail;

//Accept all types of requests
app.all('/*', function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});


//return a list of question types
app.get('/questionTypes', function(req, res, next) {
	
	db.collection('questionTypes').find().toArray(function(err, documents) {
		res.send(documents);
	});
});


//reroute to home page
app.get('/', function(req, res, next) {

	res.redirect('https://aws.gursimran.net/bc/app/login.html');

});


//function to get the latest version of an MI
function getLargestVersion(versionList){
	var largest = 0;
	var index = 0;
	for(var i=0; i < versionList.length; i++){
		var temp = parseFloat(versionList[i]).toFixed(2);
		if(largest < temp){
			largest = temp;
			index = i;
		}
	}
	return versionList[index];
}


function modifyQuestions(temp)
{
	for(var i=0; i<temp.questions.length; i++){
                if(temp.questions[i].qid=="1"){
                        temp.questions[i]["answers"]=["true", "false"];
                        temp.questions[i]["max-answers"]="1";
                        temp.questions[i]["answer-type"]="short-answer";

                }
                else if(temp.questions[i].qid=="2"){
                        temp.questions[i]["answers"]=["yes", "no"];
                        temp.questions[i]["max-answers"]="1";
                        temp.questions[i]["answer-type"]="true/false";

                }
        }
	return temp;
}




function addToMiTemplates(temp, res, completeTemplate)
{

	db.collection('formNames', function(err, collection){
        	collection.insert(completeTemplate, function (err, result) {
            if(!err){
                //console.log(result);
                res.send('success',200);
            }else{

                res.end();
            }
        	});
	    });

	

	db.collection('miTemplates', function(err, collection){
        	collection.insert(temp, function (err, result) {
            		if(!err){
                		//console.log(result);
                		res.send('success',200);
           		 }else{

                		res.end();
            		}
		});
    	});
}


function addNewTemplate(temp, res, versions){
	

	temp = modifyQuestions(temp);

	var completeTemplate = {
                                        form :temp.Title,
                                        AppliedToEquipment : temp.AppliedToEquipment,
                                        InstructionNumber : temp.InstructionNumber,
                                        MIDiscipline :temp.MIDiscipline,
                                        versions : versions,
                                        OriginalIssueDate : temp.OriginalIssueDate,
                                        References : temp.References,
                                        PreparedBy : temp.PreparedBy,
                                        PreparedByTitle : temp.PreparedByTitle,
                                        AcceptedBy : temp.AcceptedBy,
                                        AcceptedByTitle : temp.AcceptedByTitle,
                                        Eor : temp.Eor,
                                        Supersedes : temp.Supersedes,
                                        FileNumber : temp.FileNumber,
                                        RevisionNumberRevisedBy : temp.RevisionNumberRevisedBy,
                                        RevisionHistory : temp.RevisionHistory,
                                        RevisionNumberDate : temp.RevisionNumberDate
                                };

        addToMiTemplates(temp, res, completeTemplate);


}

app.get('/checkTemplateName/:title', function(req, res, next)
{
	
	db.collection('formNames').find({form : req.params.title}).toArray(function(err, documents) {
		if(documents.length > 0){
			res.send({allowed : false});
		}else{
			res.send({allowed : true});
		}
	});
});


//Add a new MI template
app.post('/addtemplate', function(req, res, next) {
	
	var temp = req.body;

	var versions = [];
	//check if form with this title exists or not
	db.collection('formNames').find({form : temp.Title}).toArray(function(err, documents) {
               	if (documents.length > 0){
			 // Fetch a collection to insert document into
			db.collection("formNames", function(err, collection) {
			      collection.remove({_id:(documents[0]._id)}, {w:1}, function(err, numberOfRemovedDocs) {
			      });
			});
			versions = documents[0].versions;
			versions.push(temp.RevisionNumber);			
		}
		else{
			versions = [temp.RevisionNumber];
		}
		addNewTemplate(temp, res, versions);
  });
	
});


//Add a new completeMI AFTER Checking if any of the values in the MI are out of range and notifying the appropiate user
app.post('/addCompletedMi', function(req, res, next) {
	
	var temp=req.body;
	
	//temp.push(data);
	
	var questions = (temp["questions"]);
	
	var emailBody = "\n";
	
	for (var i = 0; i < questions.length; i++){
		var singleQuestion = questions[i];
		var addQuestion = false;
		var acceptedAnswerString = "";
		if ((singleQuestion["answer-type"] == "true/false") || (singleQuestion["answer-type"] == "multiple-choice")){
			var userAnswer = singleQuestion["user-answer"]["check-boxes"];
			var acceptedAnswer = singleQuestion["acceptedAnswer"];
			if ((String(userAnswer).toUpperCase() != String(acceptedAnswer).toUpperCase()) && (String(acceptedAnswer).toUpperCase() != "none".toUpperCase())) {
				acceptedAnswerString = acceptedAnswer;
				addQuestion = true;		
			}
		}else if (singleQuestion["answer-type"] == "short-answer"){

			if(singleQuestion["numberInput"] == true){
				var userAnswer = singleQuestion["user-answer"]["short-answer"];
				var from = singleQuestion["acceptedAnswer"]["from"];
				var to = singleQuestion["acceptedAnswer"]["to"];
				
				if(from != undefined && to != undefined){
					from = parseFloat(from);
					to  = parseFloat(to);
					userAnswer = parseFloat(userAnswer);
					if(userAnswer < from || userAnswer > to){
						addQuestion = true;
						acceptedAnswerString = "Between " + from + " to " + to;
					}
				}else if (from != undefined){
					from = parseFloat(from);
					userAnswer = parseFloat(userAnswer);
					if(userAnswer > from){
						acceptedAnswerString = "Less than equal to " + from;
						addQuestion = true;
					}
				}else if (to != undefined){
					to = parseFloat(to);
					userAnswer = parseFloat(userAnswer);
					if(userAnswer < to){
						acceptedAnswerString = "Greater than equal to " + to;
						addQuestion = true;
					}
				}
			}
		}



		if(addQuestion == true){
			emailBody = emailBody.concat("\nQuestion: ");
			emailBody = emailBody.concat(singleQuestion["question"]);
			emailBody = emailBody.concat("\nAnswer entered: ");
			emailBody = emailBody.concat(userAnswer);
			emailBody = emailBody.concat("\nComment entered: ");
			emailBody = emailBody.concat(singleQuestion["user-answer"]["comment"]);
			emailBody = emailBody.concat("\nAcceptable answer: ");
			emailBody = emailBody.concat(acceptedAnswerString);
			emailBody = emailBody.concat("\n\n");
		}

	}

	if (emailBody != "\n"){
		var startingTextOfBody = "A new instruction for '";
              	startingTextOfBody = startingTextOfBody.concat(temp["Title"]);
              	startingTextOfBody = startingTextOfBody.concat("' was submitted by '");
              	startingTextOfBody = startingTextOfBody.concat(temp["username"]);
              	startingTextOfBody = startingTextOfBody.concat("'. The answers for the following questions should not have been what were entered. Please review the following questions and take appropriate actions.");
              	startingTextOfBody = startingTextOfBody.concat(emailBody);
                startingTextOfBody = startingTextOfBody.concat("The instruction was checked by '");
                startingTextOfBody = startingTextOfBody.concat(temp["foremanComment"]["supervisor"]);
                startingTextOfBody = startingTextOfBody.concat("'.");
		mail({
                	from: "BcHydro Web App <webapp@bchydro.com>", // sender address
                	to: temp["email"], // list of receivers
                	subject: "Attention required on new submission", // Subject line
                	text: startingTextOfBody // plaintext body
        	});
	}

	db.collection('answers', function(err, collection){
        collection.insert(temp, function (err, result) {
            if(!err){
                //console.log(result);
                res.send('success',200);
            }else{
            	
                res.end();
            }
        });
    });
	
});

//Get a list of MiTemplates currently in the Database
app.get('/getMiTemplates', function(req, res, next) {
	db.collection('miTemplates').find().toArray(function(err, documents) {
		res.send(documents);
	});
});



app.get('/getMiTemplatesLatest', function(req, res, next) {
	var result = [];
	var length;
	var retrieved = 0;
	var docs;
	db.collection('formNames').find().toArray(function(err, documents) {
                console.log(documents.length);
                length = documents.length;
                docs = documents;
                for(i=0; i < length; i++){
                	var title = docs[i].form;
                	var versions = docs[i].versions;
                	var largestVersion = getLargestVersion(versions);
                	db.collection('miTemplates').findOne({Title:title, RevisionNumber:largestVersion},function(err, documentsingle) {
						retrieved++;
						result.push(documentsingle);
						if (retrieved == length){
							var newArray = [];
							for (var j = 0; j < length; j++) {
 								 if (result[j] !== undefined && result[j] !== null && result[j] !== "") {
    								newArray.push(result[j]);
  								}
 							}	
							res.send(newArray);
						}
					});		
                }
               
    });
});


//Get a list of NAMES of the MiTemplates currently in the Database

app.get('/getMiTemplateNames', function(req, res, next) {

        db.collection('formNames').find().toArray(function(err, documents) {
                res.send(documents);
        });
});


//Search for a completed MI
app.get('/searchCompletedMis/:searchField', function(req, res, next){
	
	var search = JSON.parse(req.params.searchField);	
	//console.log(search);
	db.collection('answers').find(search, { Title: 1, InstructionNumber: 1, MIDiscipline: 1, AppliedToEquipment: 1, RevisionNumber: 1, SubmittedDate: 1}).toArray(function(err, documents) {
		res.send(documents);
 	});
});


//Return a list of all the completed MIs
app.get('/getCompletedMis', function(req, res, next) {

	db.collection('answers').find({ }, { Title: 1, InstructionNumber: 1, MIDiscipline: 1, AppliedToEquipment: 1, RevisionNumber: 1, SubmittedDate: 1}).toArray(function(err, documents) {
		res.send(documents);
	});

});

//Retrieve a completed MI given its ID
app.get('/getAnswerById/:id', function (req, res, next){

	db.collection('answers', function(error, collection) {
    	collection.findOne({ _id : collection.db.bson_serializer.ObjectID.createFromHexString(req.params.id) },
        function(error, document) {
          		res.send(document);
        });
  });

});


//Retrieve the latest version of a template given a title

app.get('/getMiTemplate/:Title', function(req, res, next) {
	//gets the title and gets the latest version
    
	var Title=req.params.Title;
	var tempResult=new Array();
	var temp;
	db.collection('formNames').find({form : Title}).toArray(function(err, documents)  {
		tempResult=documents[0].versions;
		temp=getLargestVersion(tempResult);
		db.collection('miTemplates').findOne({Title:Title, RevisionNumber:temp},function(err, documents) {
			res.send(documents);
		});
	});

	
});

//Retrieve a specfic template given a title
app.get('/getMiTemplates/:Title', function(req, res, next) {
	
    
	var Title=req.params.Title;
	db.collection('miTemplates').find({Title: { $regex: Title, $options: 'i' }}).toArray(function(err, documents) {
		res.send(documents);
	});
});


app.get('*', function(req, res, next) {
	res.send('Page Not Found', 404);
});


//Start the Connection to the Database and authenticate as "moe"
//THIS PART WILL NEED TO CHANGE ONCE AUTHENTICATION IS IMPLEMENTED
mongoclient.open(function(err, mongoclient) {

	if (err)
		throw err;
	db.authenticate('moe', 'moe', function(err, result) {
		
		if (err)
			throw err;

	});

	https.createServer(options, app).listen(8080);

	console.log('Express server started on port 8080');

});
