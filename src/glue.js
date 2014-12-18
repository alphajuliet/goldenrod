// glue.js
// Taken from https://gist.github.com/LaurensRietveld/7d8beca5dbeb6b909b6f
// aj 2014-12-18

YASQE.defaults.sparql.endpoint = "http://localhost:5820/goldenrod/query";
YASQE.defaults.sparql.requestMethod = "GET";
YASQE.defaults.value = "select * where {\ngraph ?g { ?s ?p ?o . } }\nlimit 10";


var yasqe = YASQE(document.getElementById("yasqe"), {
  sparql: {
    showQueryButton: true
  }
});

var yasr = YASR(document.getElementById("yasr"), {
  //this way, the URLs in the results are prettified using the defined prefixes in the query
  getUsedPrefixes: yasqe.getPrefixesFromQuery
});

//link both together
yasqe.options.sparql.callbacks.complete = yasr.setResponse;
yasqe.addPrefixes({
  "sfdc": "http://alphajuliet.com/ns/rsa/sfdc#",
  "proj": "http://alphajuliet.com/ns/rsa/proj#",
  "subcon": "http://alphajuliet.com/ns/rsa/subcon#",
  "dct": "http://purl.org/dc/terms/"
});

// The End
