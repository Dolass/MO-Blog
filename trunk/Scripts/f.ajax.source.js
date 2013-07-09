/*
Ajax Class of Aien
Author : Aien
homepage : http://dev.mo.cn
email : i@ruboy.com
QQ : 1034555083 
Thanks for using this class. You can visit my homepage for help .
You can use this class and don't need to change any code .
Please keep this text block for me,thank you!
*/
if(F==undefined)var F=null;
(function(F){
	var Ajax = F.ajax=window.Ajax = function(opt) {
		opt = Ajax.fn.Ajax_Extend(Ajax.Setting,opt ? opt : {});
		if(opt.form && (opt.form.nodeName.toLowerCase() == "form"))
		{
			///submit a form
			Ajax.fn.postf(opt);
		}else{
			///simple ajax
			Ajax.fn.Do(opt);
		}
	};
	
	///ajax base setting as default : You can change it manually and it will not be changed by other codes
	Ajax.Setting = {
		asc: true,
		url: "",
		dataType: "text",
		method: "GET",
		data: "",
		form:null,
		timeout: 10000,
		isTimeout: false,
		charset: "utf-8",
		username: "",
		userpwd: "",
		cache:false,
		jsonStatic:true,
		succeed: function(a, b, c){return true},
		error: function(a, b, c){return true},
		ontimeout: function(a){return true},
		beforesend: function(a){return true;}
	};
	
	///response fn
	Ajax.response = function(a, s){
		if(a.readyState == 4){
			if(a.status == 200){
				var t = s.dataType.toLowerCase();
				
				///parse Text
				if(t == "text"){
					s.succeed.apply(this,[a.responseText,a]);
				}
				
				if(t == "textp"){
					s.succeed.apply(this,[a.responseText,a]);
					var __regexp=/<script(.*?)>([\s\S]*?)<\/script>/igm;
					var __jotemp = __regexp.exec(a.responseText);
					while(__jotemp){
						eval(__jotemp[2]);
						__jotemp = __regexp.exec(a.responseText);
					}
				}
				
				///parse XML
				if(t == "xml"){
					try{
						var Dom,txt = Ajax.encode.trim(a.responseText);
						if(window.ActiveXObject){
							 Dom= new ActiveXObject( "Microsoft.XMLDOM" );
							 Dom.async = "false";
							 Dom.loadXML(txt);
						}else if ( window.DOMParser ){
							 Dom = (new DOMParser()).parseFromString(txt , "text/xml" );
						}else {
							Dom=document.implementation.createDocument("","",null);
							Dom.loadXML(txt);
						}
						s.succeed.apply(this,[Dom,a]);	
					}catch(ex){
						s.succeed.apply(this,[null,a]);	
					}
				}
				
				///parse JSON
				if(t == "json"){
					var txt = Ajax.encode.trim(a.responseText)
					if ( window.JSON && window.JSON.parse && s.jsonStatic) {
						s.succeed.apply(this,[window.JSON.parse(txt),a]);
					}else{
						var j = null;
						try{
							j=( new Function( "return " + txt ) )();
						}catch(ex){}
						s.succeed.apply(this,[j,a]);
					}
				}
				///parse JSON
				if(t == "jsonp"){
					eval(s.jsonp + "(" + a.responseText + ");");
				}
				a = null;
			}else{
				s.error.apply(this,[a.status,a]);
				a = null;
			}
		}	
	};
	
	///main action
	Ajax.fn = Ajax.prototype = {
		Do:function(options){
			var settings = options;
			var isTimeout = false;
			var s = settings;
			s.method = s.method.toUpperCase();
			s.charset = s.charset.toLowerCase();
			try{
				var a = Ajax.fn.Ajax_GetObj();
				var u = s.url;
				var b = u.indexOf("?") == -1;
				var d = null, _d = "";
				if(!s.cache && s.method!="POST") u+= (b ? "?" : "&") + "_ajax_nonce=" + Ajax.fn.Ajax_Rnd();
				b = u.indexOf("?") == -1;
				_d = s.data;
				if(typeof s.data == "object")_d = Ajax.SerializJson(s.data);
				if(s.method == "GET")u = _d == "" ? u : (u + (b ? "?" : "&") + _d);
				if(s.method == "POST")d = _d;
				s.beforesend.apply(s, [a]);
				if(s.username && s.username != ""){
					a.open(s.method, u, s.asc, s.username, s.userpwd); 
				}else{
					a.open(s.method, u, s.asc); 
				}
				if(s.method == "POST")a.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				if(s.asc){
					a.onreadystatechange = function(){
						if(s.isTimeout && s.readyState <= 3){
							s.ontimeout.apply(s,[a]);
							a.abort();
							a = null;	
							return;
						}
						Ajax.response.apply(s, [a, s]);
					};
				}
				a.send(d);
				if(s.asc){
					window.setTimeout(function(){s.isTimeout = true;}, s.timeout);
					return;
				}
				///for async
				Ajax.response.apply(s, [a, s]);
			}catch(ex){
				///catch error
				s.error.apply(s,[ex.description,null,s]);
			}
		},
		///create xhr
		Ajax_GetObj:function (){
			var b = null;
			if (window.XMLHttpRequest) {  //for other
				b = new XMLHttpRequest(); 
				Ajax.fn.Ajax_GetObj=function(){return new XMLHttpRequest();};
			}else if (window.ActiveXObject) {  //for ie
				var httplist = ["MSXML2.XMLHttp.3.0","MSXML2.XMLHttp","Microsoft.XMLHttp","MSXML2.XMLHttp.5.0","MSXML2.XMLHttp.4.0"];
				for(var i = httplist.length -1;i >= 0;i--){
					try{
						Ajax.fn.Ajax_GetObj=(function(obj){return function(){
							return new ActiveXObject(obj)
						};})(httplist[i]);
						b = Ajax.fn.Ajax_GetObj();
					}catch(ex){}
				}
			}
			return b;
		},
		///get rnd string
		Ajax_Rnd : function (){return Math.random().toString().substr(2);},
		///extend something
		Ajax_Extend : function (a, b){var c = {};for(var m in a){c[m] = a[m];}for(var m in b){c[m] = b[m];}return c;}
	};
	
	///Serializ Json Data
	Ajax.SerializJson = Ajax.fn.SerializJson = function(json){
		if(typeof json != "object"){return "";}
		var _temp="";
		for(var i in json){
			_temp += Ajax.encode.utf8("" + i + "") + "=" + Ajax.encode.utf8("" + json[i] + "") + "&"	
		}
		if(_temp!=""){_temp = _temp.substr(0,_temp.length-1);}
		return _temp;
	};
	
	///Serializ a form
	Ajax.Serializ = Ajax.fn.Serializ = function(nodes,charset){
		charset = charset.toLowerCase();
		var data = "";
		for(var i = 0;i < nodes.length;i++){
			if(!nodes[i].name || (Ajax.encode.trim(nodes[i].name) == "")){continue;}
			var node_name = Ajax.encode.trim(nodes[i].name);
			var node_value = nodes[i].value;
			var isBox = (nodes[i].type.toLowerCase() == "checkbox") || (nodes[i].type.toLowerCase() == "radio");
			if(isBox){
				if(nodes[i].checked == true){
					if(charset == "utf-8"){
						data +=Ajax.encode.utf8(node_name) + "=" + (node_value == "" ? "on": Ajax.encode.utf8(node_value)) + "&";
					}else{
						data += Ajax.encode.gb(node_name) + "=" + (node_value == "" ? "on": Ajax.encode.gb(node_value)) + "&";
					}
				}
			}else{
				if(charset == "utf-8"){
					data += Ajax.encode.utf8(node_name) + "=" + Ajax.encode.utf8(node_value) + "&";
				}else{
					data += Ajax.encode.gb(node_name) + "=" + Ajax.encode.gb(node_value) + "&";	
				}
			}			
		}
		return data;
	};
	
	Ajax.postf = Ajax.fn.postf = function(setting){
		setting = Ajax.fn.Ajax_Extend(Ajax.Setting, setting);
		frm = setting.form;
		if(frm.nodeName.toLowerCase() != "form" || frm.action == ""){return false;}
		setting.method = "POST";
		if(frm.method.toLowerCase() != "post"){setting.method = "GET";}
		setting.url = frm.action;
		var data = "";
		data = Ajax.Serializ(frm,setting.charset);
		if(data != ""){
			data = data.substr(0,data.length - 1);
		}
		setting.data = data;
		Ajax.fn.Do(setting);
		return false;
	};
	
	///redefine some fn for String
	Ajax.encode={
		gb : function(str){
			return escape(str||"");
		},
		utf8 : function(str){
			return encodeURIComponent(str||"").replace(/\+/,"%2B").replace(/\%([0-9a-zA-Z]{2})/ig,function(s){return s.toLowerCase()});
		},
		unUtf8 : function(str){
			return decodeURIComponent(str||"");
		},
		trim : function(str){
			return (str||"").replace(/^(\s+)|(\s+)$/igm,"");
		}
	}
	Ajax.get = Ajax.fn.get = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn});};
	Ajax.getJSON = Ajax.fn.getJSON = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn,"dataType":"json"});};
	Ajax.getXML = Ajax.fn.getXML = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn,"dataType":"xml"});};
	Ajax.post = Ajax.fn.post = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn,"method":"POST"});};
	Ajax.postJSON = Ajax.fn.postJSON = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn,"method":"POST","dataType":"json"});};
	Ajax.postXML = Ajax.fn.postXML = function(url,data,fn){Ajax({"url":url,"data":data,"succeed":fn,"method":"POST","dataType":"xml"});};
})(F||{});