self.addEventListener('message', function(e) { 
    var data=e.data; 
    try { 
        var reader = new FileReaderSync(); 
        postMessage({ 
        	
            result: reader.readAsBinaryString(data)
        });
   } catch(e){ 
        postMessage({ 
            result:'error'
        }); 
   } 
}, false);