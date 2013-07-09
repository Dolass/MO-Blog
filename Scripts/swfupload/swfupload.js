var SWFUpload;
if(SWFUpload==undefined){
	SWFUpload=function(a){
		this.initSWFUpload(a)
	}
}
SWFUpload.prototype.initSWFUpload=function(b){
	try{
		this.customSettings={};
		this.settings=b;
		this.eventQueue=[];
		this.movieName="SWFUpload_"+SWFUpload.movieCount++;
		this.movieElement=null;
		SWFUpload.instances[this.movieName]=this;
		this.initSettings();
		this.loadFlash()
	}catch(a){
		delete SWFUpload.instances[this.movieName];
		throw a
	}
};
SWFUpload.instances={};
SWFUpload.movieCount=0;
SWFUpload.completeURL=function(b){
	if(typeof(b)!=="string"||b.match(/^https?:\/\//i)||b.match(/^\//)){
		return b
	}
	var c=window.location.protocol+"//"+window.location.hostname+(window.location.port?":"+window.location.port:"");
	var a=window.location.pathname.lastIndexOf("/");
	if(a<=0){
		path="/"
	}else{
		path=window.location.pathname.substr(0,a)+"/"
	}
	return path+b
};

SWFUpload.prototype.initSettings=function(){	
	this.ensureDefault=function(b,a){this.settings[b]=(this.settings[b]==undefined)?a:this.settings[b]};
	this.ensureDefault("upload_url","");
	this.ensureDefault("charset","utf-8");
	this.ensureDefault("preserve_relative_urls",false);
	this.ensureDefault("file_post_name","Filedata");
	this.ensureDefault("post_params",{});
	this.ensureDefault("use_query_string",false);
	this.ensureDefault("requeue_on_error",false);
	this.ensureDefault("http_success",[]);
	this.ensureDefault("assume_success_timeout",0);
	this.ensureDefault("file_types","*.*");
	this.ensureDefault("file_types_description","All Files");
	this.ensureDefault("file_size_limit",0);
	this.ensureDefault("file_upload_limit",0);
	this.ensureDefault("file_queue_limit",0);
	this.ensureDefault("flash_url","swfupload.swf");
	this.ensureDefault("prevent_swf_caching",true);
	this.ensureDefault("button_image_url","");
	this.ensureDefault("button_width",1);
	this.ensureDefault("button_height",1);
	this.ensureDefault("button_text","");
	this.ensureDefault("button_text_style","color: #000000; font-size: 16pt;");
	this.ensureDefault("button_text_top_padding",0);
	this.ensureDefault("button_text_left_padding",0);
	this.ensureDefault("button_action",SWFUpload.BUTTON_ACTION.SELECT_FILES);
	this.ensureDefault("button_disabled",false);
	this.ensureDefault("button_placeholder_id","");
	this.ensureDefault("button_append","");
	this.ensureDefault("button_placeholder",null);
	this.ensureDefault("button_cursor",SWFUpload.CURSOR.HAND);
	this.ensureDefault("button_window_mode",SWFUpload.WINDOW_MODE.TRANSPARENT);
	this.ensureDefault("debug",false);
	this.settings.debug_enabled=this.settings.debug;
	this.settings.return_upload_start_handler=this.returnUploadStart;
	this.ensureDefault("swfupload_loaded_handler",null);
	this.ensureDefault("file_dialog_start_handler",null);
	this.ensureDefault("file_queued_handler",null);
	this.ensureDefault("file_queue_error_handler",null);
	this.ensureDefault("file_dialog_complete_handler",null);
	this.ensureDefault("upload_start_handler",null);
	this.ensureDefault("upload_progress_handler",null);
	this.ensureDefault("upload_error_handler",null);
	this.ensureDefault("upload_success_handler",null);
	this.ensureDefault("upload_complete_handler",null);
	this.ensureDefault("debug_handler",this.debugMessage);
	this.ensureDefault("custom_settings",{});
	this.settings.file_size_limit=SWFUpload.formatBytes(this.settings.file_size_limit);
	this.customSettings=this.settings.custom_settings;
	if(!!this.settings.prevent_swf_caching){
		this.settings.flash_url=this.settings.flash_url+(this.settings.flash_url.indexOf("?")<0?"?":"&")+"preventswfcaching="+new Date().getTime()
	}
	if(!this.settings.preserve_relative_urls){
		this.settings.upload_url=SWFUpload.completeURL(this.settings.upload_url);
		this.settings.button_image_url=SWFUpload.completeURL(this.settings.button_image_url)
	}
	delete this.ensureDefault
};
SWFUpload.prototype.loadFlash=function(){
	var a,b;
	if(document.getElementById(this.movieName)!==null){
		throw"ID "+this.movieName+" is already in use. The Flash Object could not be added"
	}
	a=((typeof this.settings.button_append=="string")?document.getElementById(this.settings.button_append):this.settings.button_append);
	if(!a){throw"Could not find the placeholder element: "+this.settings.button_append}
	a.innerHTML=this.getFlashHTML();
	if(window[this.movieName]==undefined){
		window[this.movieName]=this.getMovieElement()
	}
};
SWFUpload.prototype.getFlashHTML=function(){
	return['<object id="',this.movieName,
		   '" type="application/x-shockwave-flash" data="',this.settings.flash_url,
		   '" width="',this.settings.button_width,
		   '" height="',this.settings.button_height,
		   '" class="swfupload">',
		   '<param name="wmode" value="',this.settings.button_window_mode,'" />',
		   '<param name="movie" value="',this.settings.flash_url,'" />',
		   '<param name="quality" value="high" />',
		   '<param name="menu" value="false" />',
		   '<param name="allowScriptAccess" value="always" />',
		   '<param name="flashvars" value="'+this.getFlashVars()+'" />',
		   "</object>"
	].join("")
};
SWFUpload.prototype.getFlashVars=function(){
	var b=this.buildParamString();
	var a=this.settings.http_success.join(",");
	return["movieName=",encodeURIComponent(this.movieName),
			"&amp;charset=",encodeURIComponent(this.settings.charset),
			"&amp;uploadURL=",encodeURIComponent(this.settings.upload_url),
			"&amp;useQueryString=",encodeURIComponent(this.settings.use_query_string),
			"&amp;requeueOnError=",encodeURIComponent(this.settings.requeue_on_error),
			"&amp;httpSuccess=",encodeURIComponent(a),
			"&amp;assumeSuccessTimeout=",encodeURIComponent(this.settings.assume_success_timeout),
			"&amp;params=",encodeURIComponent(b),
			"&amp;filePostName=",encodeURIComponent(this.settings.file_post_name),
			"&amp;fileTypes=",encodeURIComponent(this.settings.file_types),
			"&amp;fileTypesDescription=",encodeURIComponent(this.settings.file_types_description),
			"&amp;fileSizeLimit=",encodeURIComponent(this.settings.file_size_limit),
			"&amp;fileUploadLimit=",encodeURIComponent(this.settings.file_upload_limit),
			"&amp;fileQueueLimit=",encodeURIComponent(this.settings.file_queue_limit),
			"&amp;debugEnabled=",encodeURIComponent(this.settings.debug_enabled),
			"&amp;buttonImageURL=",encodeURIComponent(this.settings.button_image_url),
			"&amp;buttonWidth=",encodeURIComponent(this.settings.button_width),
			"&amp;buttonHeight=",encodeURIComponent(this.settings.button_height),
			"&amp;buttonText=",encodeURIComponent(this.settings.button_text),
			"&amp;buttonTextTopPadding=",encodeURIComponent(this.settings.button_text_top_padding),
			"&amp;buttonTextLeftPadding=",encodeURIComponent(this.settings.button_text_left_padding),
			"&amp;buttonTextStyle=",encodeURIComponent(this.settings.button_text_style),
			"&amp;buttonAction=",encodeURIComponent(this.settings.button_action),
			"&amp;buttonDisabled=",encodeURIComponent(this.settings.button_disabled),
			"&amp;buttonCursor=",encodeURIComponent(this.settings.button_cursor)
	].join("")+((this.settings.extend&&this.settings.extend!="")?("&amp;"+this.settings.extend):"")
};
SWFUpload.prototype.getMovieElement=function(){
	if(this.movieElement==undefined){
		this.movieElement=document.getElementById(this.movieName)
	}
	if(this.movieElement===null){
		throw"Could not find Flash element"
	}
	return this.movieElement
};
SWFUpload.prototype.buildParamString=function(){var c=this.settings.post_params;var a=[];if(typeof(c)==="object"){for(var b in c){if(c.hasOwnProperty(b)){a.push(encodeURIComponent(b.toString())+"="+encodeURIComponent(c[b].toString()))}}}return a.join("&amp;")};
SWFUpload.prototype.destroy=function(){
	try{
		this.cancelUpload(null,false);
		var d=null;
		d=this.getMovieElement();
		if(d&&typeof(d.CallFunction)==="unknown"){
			for(var b in d){
				try{
					if(typeof(d[b])==="function"){
						d[b]=null
					}
				}catch(e){
				}
			}
			try{
				d.parentNode.removeChild(d)
			}catch(c){}
		}
		window[this.movieName]=null;
		SWFUpload.instances[this.movieName]=null;
		delete SWFUpload.instances[this.movieName];
		this.movieElement=null;
		this.settings=null;
		this.customSettings=null;
		this.eventQueue=null;
		this.movieName=null;
		return true
	}catch(a){
		return false
	}
};
SWFUpload.prototype.displayDebugInfo=function(){this.debug(["Version: ",SWFUpload.version,"\n","Movie Name: ",this.movieName,"\n"].join(""))};
SWFUpload.prototype.addSetting=function(a,c,b){if(c==undefined){return(this.settings[a]=b)}else{return(this.settings[a]=c)}};
SWFUpload.prototype.getSetting=function(a){if(this.settings[a]!=undefined){return this.settings[a]}return""};
SWFUpload.prototype.callFlash=function(functionName,argumentArray){
	argumentArray=argumentArray||[];
	var movieElement=this.getMovieElement();
	var returnValue,returnString;
	try{
		returnString=movieElement.CallFunction('<invoke name="'+functionName+'" returntype="javascript">'+__flash__argumentsToXML(argumentArray,0)+"</invoke>");
		returnValue=eval(returnString)
	}catch(ex){
		throw"Call to "+functionName+" failed"
	}
	if(returnValue!=undefined&&typeof returnValue.post==="object"){
		returnValue=this.unescapeFilePostParams(returnValue)
	}
	return returnValue;
};
SWFUpload.prototype.selectFile=function(){this.callFlash("SelectFile")};
SWFUpload.prototype.selectFiles=function(){this.callFlash("SelectFiles")};
SWFUpload.prototype.setButtonDisabled=function(a){if(a!==false){a=true}this.callFlash("SetButtonDisabled",[a])};
SWFUpload.prototype.startUpload=function(a){this.callFlash("StartUpload",[a])};
SWFUpload.prototype.requeueUpload=function(a){this.callFlash("RequeueUpload",[a])};
SWFUpload.prototype.requeueUploadAll=function(){this.callFlash("RequeueUploadAll",[])};
SWFUpload.prototype.cancelUpload=function(a,b){if(b!==false){b=true}this.callFlash("CancelUpload",[a,b])};
SWFUpload.prototype.cancelUploadAll=function(a){if(a!==false){a=true}this.callFlash("CancelUploadAll",[a])};
SWFUpload.prototype.stopUpload=function(){this.callFlash("StopUpload")};
SWFUpload.prototype.getStats=function(){return this.callFlash("GetStats")};
SWFUpload.prototype.setStats=function(a){this.callFlash("SetStats",[a])};
SWFUpload.prototype.getFile=function(a){if(typeof(a)==="number"){return this.callFlash("GetFileByIndex",[a])}else{return this.callFlash("GetFile",[a])}};
SWFUpload.prototype.queueEvent=function(a,c){if(c==undefined){c=[]}else{if(!(c instanceof Array)){c=[c]}}var b=this;if(typeof this.settings[a]==="function"){this.eventQueue.push(function(){this.settings[a].apply(this,c)});setTimeout(function(){b.executeNextEvent()},0)}else{if(this.settings[a]!==null){throw"Event handler "+a+" is unknown or is not a function"}}};
SWFUpload.prototype.executeNextEvent=function(){var a=this.eventQueue?this.eventQueue.shift():null;if(typeof(a)==="function"){a.apply(this)}};
SWFUpload.prototype.unescapeFilePostParams=function(c){var a=/[$]([0-9a-f]{4})/i;var f={};var b;if(c!=undefined){for(var e in c.post){if(c.post.hasOwnProperty(e)){b=e;var d;while((d=a.exec(b))!==null){b=b.replace(d[0],String.fromCharCode(parseInt("0x"+d[1],16)))}f[b]=c.post[e]}}c.post=f}return c};
SWFUpload.prototype.testExternalInterface=function(){try{return this.callFlash("TestExternalInterface")}catch(a){return false}};
SWFUpload.prototype.flashReady=function(){var a=this.getMovieElement();if(!a){this.debug("Flash called back ready but the flash movie can't be found.");return}this.cleanUp(a);this.queueEvent("swfupload_loaded_handler")};
SWFUpload.prototype.cleanUp=function(c){try{if(this.movieElement&&typeof(c.CallFunction)==="unknown"){for(var a in c){try{if(typeof(c[a])==="function"){c[a]=null}}catch(b){}}}}catch(d){}window.__flash__removeCallback=function(f,e){try{if(f){f[e]=null}}catch(g){}}};
SWFUpload.prototype.fileDialogStart=function(){this.queueEvent("file_dialog_start_handler")};
SWFUpload.prototype.fileQueued=function(a){a=this.unescapeFilePostParams(a);this.queueEvent("file_queued_handler",a)};
SWFUpload.prototype.fileQueueError=function(b,c,a){b=this.unescapeFilePostParams(b);this.queueEvent("file_queue_error_handler",[b,c,a])};
SWFUpload.prototype.removeAllFiles=function(){this.cancelUploadAll(true)};
SWFUpload.prototype.requeueAll=function(){if(this.Status().count<=0){return}this.requeueUploadAll()};
SWFUpload.prototype.Status=function(){return this.callFlash("GetMyStatus")};
SWFUpload.prototype.fileDialogComplete=function(a,c,b){this.queueEvent("file_dialog_complete_handler",[a,c,b])};
SWFUpload.prototype.uploadStart=function(a){a=this.unescapeFilePostParams(a);this.queueEvent("return_upload_start_handler",a)};
SWFUpload.prototype.returnUploadStart=function(a){var b;if(typeof this.settings.upload_start_handler==="function"){a=this.unescapeFilePostParams(a);b=this.settings.upload_start_handler.call(this,a)}else{if(this.settings.upload_start_handler!=undefined){throw"upload_start_handler must be a function"}}if(b===undefined){b=true}b=!!b;this.callFlash("ReturnUploadStart",[b])};
SWFUpload.prototype.uploadProgress=function(b,c,a){b=this.unescapeFilePostParams(b);this.queueEvent("upload_progress_handler",[b,c,a])};
SWFUpload.prototype.uploadError=function(b,c,a,d,e){b=this.unescapeFilePostParams(b);this.queueEvent("upload_error_handler",[b,c,a,d,e])};
SWFUpload.prototype.uploadSuccess=function(a,b,c){a=this.unescapeFilePostParams(a);this.queueEvent("upload_success_handler",[a,b,c])};
SWFUpload.prototype.uploadComplete=function(a){a=this.unescapeFilePostParams(a);this.queueEvent("upload_complete_handler",a)};
SWFUpload.prototype.debug=function(a){this.queueEvent("debug_handler",a)};
SWFUpload.prototype.debugMessage=function(a){if(this.settings.debug){var c,d=[];if(typeof a==="object"&&typeof a.name==="string"&&typeof a.message==="string"){for(var b in a){if(a.hasOwnProperty(b)){d.push(b+": "+a[b])}}c=d.join("\n")||"";d=c.split("\n");c="EXCEPTION: "+d.join("\nEXCEPTION: ")}else{}}};SWFUpload.version="SWFUPLOAD 2.2.2(Mod By Anlige)";SWFUpload.QUEUE_ERROR={QUEUE_LIMIT_EXCEEDED:-100,FILE_EXCEEDS_SIZE_LIMIT:-110,ZERO_BYTE_FILE:-120,INVALID_FILETYPE:-130};SWFUpload.UPLOAD_ERROR={HTTP_ERROR:-200,MISSING_UPLOAD_URL:-210,IO_ERROR:-220,SECURITY_ERROR:-230,UPLOAD_LIMIT_EXCEEDED:-240,UPLOAD_FAILED:-250,SPECIFIED_FILE_ID_NOT_FOUND:-260,FILE_VALIDATION_FAILED:-270,FILE_CANCELLED:-280,UPLOAD_STOPPED:-290};SWFUpload.FILE_STATUS={QUEUED:-1,IN_PROGRESS:-2,ERROR:-3,COMPLETE:-4,CANCELLED:-5,NEW:-6};SWFUpload.BUTTON_ACTION={SELECT_FILE:-100,SELECT_FILES:-110,START_UPLOAD:-120};SWFUpload.CURSOR={ARROW:-1,HAND:-2};SWFUpload.WINDOW_MODE={WINDOW:"window",TRANSPARENT:"transparent",OPAQUE:"opaque"};SWFUpload.extend=function(a){if(SWFUpload.prototype[a]==undefined){SWFUpload.prototype[a]=function(){return this.callFlash(a,arguments)}}};SWFUpload.extendCallback=function(b,a){if(SWFUpload.prototype[b]==undefined){SWFUpload.prototype[b]=function(){this.settings[a]=(this.settings[a]==undefined)?null:this.settings[a];var c=[],d=0;while(arguments.length>0&&d<arguments.length){c.push(arguments[d]);d++}this.queueEvent(a,c)}}};SWFUpload.formatBytes=function(e){if(e==undefined||e==null){return 0}if(isNaN(e)){return e}var d=["B","KB","MB","GB","TB","PB"];var f=Math.floor(Math.log(e)/Math.log(1024));return(e/Math.pow(1024,Math.floor(f))).toFixed(0)+" "+d[f]};SWFUpload.New=function(c){var b={post_params:{},file_queue_limit:0,custom_settings:{},debug:false};for(var d in c){if(d=="handlers"){if(typeof c[d]=="object"){for(var a in c[d]){b[a]=c[d][a]}}}else{if(d=="filter"){if(typeof c[d]=="object"){for(var a in c[d]){b["file_"+a]=c[d][a]}}}else{b[d]=c[d]}}}return new SWFUpload(b)};