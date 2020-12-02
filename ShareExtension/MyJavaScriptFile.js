var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
//    run: function(arguments) {
//        // Pass the baseURI of the webpage to the extension.
//        arguments.completionFunction({"baseURI": document.baseURI});
//    }
//};

run: function(parameters) {
    parameters.completionFunction({"URL": document.URL, "title": document.title });
},
    
finalize: function(parameters) {
    
}
    
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;
