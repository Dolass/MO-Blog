<script language="jscript" runat="server">
var F={
	fso:null,post__:null,get__:{},server__:{},activex__:[],postinited:false,rewrite:false,
	has:function(obj,key){return obj.hasOwnProperty(key);},
	dispose:function(obj){
		if(obj!=undefined){obj=null;return;}
		while(F.activex__.length>0){
			F.dispose(F.activex__.pop());
		}
	},
	mappath:function(path){
		if(path.length<2)return Server.MapPath(path)
		if(path.substr(1,1)==":") return path;
		return Server.MapPath(path);	
	},
	activex:function(classid){
		try{
			F.activex__.push(new ActiveXObject(classid));
			return F.activex__[F.activex__.length-1];
		}catch(ex){return null;}
	},
	activex_:function(classid){
		try{
			var obj = new ActiveXObject(classid);
			obj = null;
			return true;
		}catch(ex){return false;}
	},
	deletefile:function(path,isfolder){
		path = path|| "";
		if(isfolder!==true)isfolder=false;
		if(path=="")return;
		try{
			if(isfolder){
				F.fso.deletefolder(F.mappath(path));
			}else{
				F.fso.deletefile(F.mappath(path));
			}
			return true;
		}catch(ex){return false;}
	},
	stream:function(mode,type){
		var stream = F.activex("Adodb.Stream");
		if(mode!=undefined)stream.Mode = mode;
		if(type!=undefined)stream.Type = type;
		return stream;
	},
	file:{
		"delete":function(path){try{F.fso.deletefile(path);}catch(ex){}}	
	},
	init:function(){
		this.fso = F.activex("Scripting.FileSystemObject");	
		for(var i =1;i<=Request.QueryString.Count;i++){
			F.get__[Request.QueryString.Key(i)] = Request.QueryString.Item(i)+"";
		}
		for(var i =1;i<=Request.ServerVariables.Count;i++){
			F.server__[Request.ServerVariables.Key(i)] = Request.ServerVariables.Item(i)+"";
		}
		return this;
	},
	json:function(src){
		var ret = null;
		try{
			eval("ret = (function(){return " + src + "})();");
		}catch(ex){}
		return ret;
	},
	post:function(key,value){
		if(!F.postinited){
			F.post__={};
			for(var i =1;i<=Request.Form.Count;i++){
				if(F.post__[Request.Form.Key(i)]!=undefined){
					F.post__[Request.Form.Key(i)] = F.post__[Request.Form.Key(i)] + ", " + Request.Form.Item(i);
				}else{
					F.post__[Request.Form.Key(i)] = Request.Form.Item(i) +"";
				}
			}	
			F.postinited = true;
		}
		if(key==undefined)return"";
		if(value===null){delete F.post__[key];return;}
		if(value==undefined) return (F.post__[key]==undefined ? "":F.post__[key]);
		F.post__[key] = value;
		return;
	},
	session:function(key,value){
		if(key==undefined)return"";
		if(value===null){Session.Contents.Remove(key);return}
		if(value==undefined) return Session.Contents(key)==undefined ? "":Session.Contents(key);
		Session(key) = value;
	},
	get:function(key,value){
		if(key==undefined)return"";
		if(value===null){delete F.get__[key];return;}
		if(value==undefined) return (F.get__[key]==undefined ? "":F.get__[key]);
		F.get__[key] = value;
		return;
	},
	server:function(key,value){
		if(key==undefined)return"";
		if(value===null){delete F.server__[key];return;}
		if(value==undefined) return (F.server__[key]==undefined ? "":F.server__[key]);
		F.server__[key] = value;
		return;
	},
	cookie:function(key,value,expired,domain,path,Secure){
		if(key==undefined)return"";
		var mkey=key,skey="";
		if(key.indexOf(".")>0){
			mkey=key.split(".")[0];	
			skey=key.split(".")[1];	
		}
		if(value===null){Response.Cookies(mkey).Expires="1980-1-1";return;}
		if(value==undefined){
			if(skey=="")return Request.Cookies(mkey);
			return Request.Cookies(mkey)(skey);
		}
		if(skey==""){
			Response.Cookies(mkey)=	value;
		}else{
			Response.Cookies(mkey)(skey)=value;
		}
		if(expired!=undefined && !isNaN(expired)){
			var dt = new Date();
			dt.setTime(dt.getTime() + parseInt(expired)*1000);
			Response.Cookies(mkey).Expires = F.format("{0}-{1}-{2} {3}:{4}:{5}",dt.getYear(),dt.getMonth()+1,dt.getDate(),dt.getHours(),dt.getMinutes(),dt.getSeconds());
		}
		if(domain!=undefined){
			Response.Cookies(mkey).Domain = domain;
		}
		if(path!=undefined){
			Response.Cookies(mkey).Path = path;
		}
		if(Secure!=undefined){
			Response.Cookies(mkey).Secure = Secure;
		}
	},
	echo:function(debug){
		debug=debug||"";
		Response.Write(debug);
	},
	exit:function(debug){
		debug=debug||"";
		Response.Write(debug);
		Response.End();
	},
	format:function(Str){
        var arg = arguments;
        if(arg.length<=1){return Str;}
        return Str.replace(/\{(\d*)\}/igm,function(ma){
                try{
                        return arg[parseInt(ma.replace(/\{(\d+)\}/igm,"$1"))+1];        
                }catch(ex){
                        return ma;
                }        
        });
	},
	redirect:function(url,msg){
		url=url||"";
		if(url=="")return;
		msg=msg||"";
		if(msg!=""){
			msg = encodeURIComponent(msg);
			F.echo("<s"+"cript type=\"text/javascript\">alert(decodeURIComponent('" + msg + "'));window.location='" + url + "';</s"+"cript>");
		}else{
			Response.Redirect(url);
			Response.End();			
		}
	},
	goto:function(url,msg){
		url=url||"";
		if(url=="")return;
		msg=msg||"";
		if(msg!=""){
			msg = encodeURIComponent(msg);
			F.echo("<s"+"cript type=\"text/javascript\">alert(decodeURIComponent('" + msg + "'));window.location='" + url + "';</s"+"cript>");
		}else{
			F.echo("<s"+"cript type=\"text/javascript\">window.location='" + url + "';</s"+"cript>");
		}
	},
	eval:function(scripts,lib,tag,ext){
		var obj=null;
		tag = tag || "Lib";
		ext = ext || "Mo";
		try{
			eval(scripts + "\r\nobj=(typeof " + ext + tag + lib + "==\"object\") ? " + ext + tag + lib + " :(new " + ext + tag + lib + "());");
		}catch(ex){
			throw "can not load the library:" + lib + "," + ex.message
		}
		return obj;
	},
	execute:function(src){
		try{
			eval(src);
			return true;
		}catch(ex){
			return false;
		}
	},
	executeglobal:function(src,tag,lib,ext){
		try{
			ext = ext || "Mo";
			eval(src);
			F.executeglobal_(ext+ tag + lib,eval(ext + tag + lib));
			return true;
		}catch(ex){
			return false;
		}
	},
	executeglobal_:function(src,obj_){
		try{
			eval(src + " = obj_");
			return true;
		}catch(ex){
			return false;
		}
	},
	Import:function(tag,lib,ext,isstatic){
		ext = ext || "Mo";
		if(isstatic!==true)isstatic = false;
		eval("var ___ = (typeof " + ext + tag + lib + "==\"object\" || isstatic) ? " + ext + tag + lib + " :(new " + ext + tag + lib + "());");
		return ___;
	},
	encode:function(src){src=src||"";return encodeURIComponent(src);},
	encodeHtml:function(src){
		src=src||"";
		var ret = src.replace(/&/igm,"&amp;");
		ret = ret.replace(/>/igm,"&gt;");
		ret = ret.replace(/</igm,"&lt;");
		ret = ret.replace(/ /igm,"&nbsp;");
		ret = ret.replace(/\"/igm,"&quot;");
		ret = ret.replace(/©/igm,"&copy;");
		ret = ret.replace(/®/igm,"&reg;");
		ret = ret.replace(/±/igm,"&plusmn;");
		ret = ret.replace(/×/igm,"&times;");
		ret = ret.replace(/§/igm,"&sect;");
		ret = ret.replace(/¢/igm,"&cent;");
		ret = ret.replace(/¥/igm,"&yen;");
		ret = ret.replace(/•/igm,"&middot;");
		ret = ret.replace(/€/igm,"&euro;");
		ret = ret.replace(/£/igm,"&pound;");
		ret = ret.replace(/™/igm,"&trade;");
		return ret
	},
	decodeHtml:function(src){
		src=src||"";
		var ret = src.replace(/&amp;/igm,"&");
		ret = ret.replace(/&gt;/igm,">");
		ret = ret.replace(/&lt;/igm,"<");
		ret = ret.replace(/&nbsp;/igm," ");
		ret = ret.replace(/&quot;/igm,"\"");
		ret = ret.replace(/&copy;/igm,"©");
		ret = ret.replace(/&reg;/igm,"®");
		ret = ret.replace(/&plusmn;/igm,"±");
		ret = ret.replace(/&times;/igm,"×");
		ret = ret.replace(/&sect;/igm,"§");
		ret = ret.replace(/&cent;/igm,"¢");
		ret = ret.replace(/&yen;/igm,"¥");
		ret = ret.replace(/&middot;/igm,"•");
		ret = ret.replace(/&euro;/igm,"€");
		ret = ret.replace(/&pound;/igm,"£");
		ret = ret.replace(/&trade;/igm,"™");
		return ret
	},
	jsEncode:function(str){
		if(str==undefined) return "";
		if(str=="")return "";
		var i, j, aL1, aL2, c, p,ret="";
		aL1 = Array(0x22, 0x5C, 0x2F, 0x08, 0x0C, 0x0A, 0x0D, 0x09);
		aL2 = Array(0x22, 0x5C, 0x2F, 0x62, 0x66, 0x6E, 0x72, 0x74);
		for(i = 0;i<str.length;i++){
			p = true;
			c = str.substr(i,1);
			for(j = 0;j<=7;j++){
				if(c == String.fromCharCode(aL1[j])){
					ret += "\\" + String.fromCharCode(aL2[j]);
					p = false;
					break;
				}
			}
			if(p){
				var a = c.charCodeAt(0);
				if(a > 31 && a < 127){
					ret +=c
				}else if(a > -1 || a < 65535){
					var slashu = a.toString(16);
					while(slashu.length<4){slashu="0"+slashu;}
					ret += "\\u" + slashu;
				}
			}
		}
		return ret;
	},
	formatstring:function(src,format){
		if(!/^(left|right)\s(\d+)$/i.test(format))return src;
		var direction = /^(left|right)\s(\d+)$/i.exec(format)[1];
		var len = parseInt(/^(left|right)\s(\d+)$/i.exec(format)[2]);
		if(direction=="left")return src.substr(0,len);
		if(direction=="right")return src.substr(src.length-len,len);
	},
	formatdate:function(dt,fs){
		if(typeof dt!="date")dt=new Date();
		dt = new Date(dt);
		var y=new Array(2),m=new Array(2),d=new Array(2),h=new Array(2),n=new Array(2),s=new Array(2),w,ws=new Array(2),t = new Array(1),H=new Array(2),ms=new Array(2);
		y[0] = dt.getFullYear();
		m[0] = dt.getMonth()+1;
		d[0] = dt.getDate();
		h[0] = dt.getHours();
		H[0] = h[0] % 12;
		n[0] = dt.getMinutes();
		s[0] = dt.getSeconds();
		y[1] = y[0];
		m[1] = F.string.right("0" +m[0],2);
		d[1] = F.string.right("0" +d[0],2);
		h[1] = F.string.right("0" +h[0],2);
		H[1] = F.string.right("0" +H[0],2);
		n[1] = F.string.right("0" +n[0],2);
		s[1] = F.string.right("0" +s[0],2);
		ws[0] = Array("Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday");
		ws[1] = Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
		ms[0] = Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December","");
		ms[1] = Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","");
		t[0] = dt.getMilliseconds();
		w=dt.getDay()-1;
		
		fs = fs.replace(/dddd/g,"{````}");
		fs = fs.replace(/ddd/g,"{```}");
		fs = fs.replace(/MMMM/g,"{~~~~}");
		fs = fs.replace(/MMM/g,"{~~~}");
		var ret = fs.replace(/yyyy/g,y[0]);
		ret = ret.replace(/yy/g,y[1]);
		ret = ret.replace(/ss/g,s[1]);
		ret = ret.replace(/s/g,s[0]);
		ret = ret.replace(/MM/g,m[1]);
		ret = ret.replace(/M/g,m[0]);
		ret = ret.replace(/HH/g,h[1]);
		ret = ret.replace(/H/g,h[0]);
		ret = ret.replace(/hh/g,H[1]);
		ret = ret.replace(/h/g,H[0]);
		ret = ret.replace(/mm/g,n[1]);
		ret = ret.replace(/m/g,n[0]);
		ret = ret.replace(/tttt/g,t[0]);
		ret = ret.replace(/dd/g,d[1]);
		ret = ret.replace(/d/g,d[0]);
		ret = ret.replace(/\{````\}/g,ws[0][w+1]);
		ret = ret.replace(/\{```\}/g,ws[1][w+1]);
		ret = ret.replace(/\{~~~~\}/g,ms[0][m[0]-1]);
		ret = ret.replace(/\{~~~\}/g,ms[1][m[0]-1]);
		return ret;			
	},
	decode:function(src){src=src||"";return decodeURIComponent(src);},
	safe:function(src){src=src||"";return src.replace(/\'/igm,"").replace(/((^[\s]+)|([\s]+$))/igm,"").replace(/[\r\n]+/igm,"").replace(/>/igm,"&gt;").replace(/</igm,"&lt;");},
	string:{
		left:function(src,len){
			src=src||"";
			if(typeof len=="number"){
				if(src.length<=len)return src;
				return src.substr(0,len);
			}
			if(typeof len=="string"){
				if(src.indexOf(len)<0)return src;
				return src.substr(0,src.indexOf(len));
			}
			return src;
		},
		right:function(src,len){
			src=src||"";
			if(typeof len=="number"){
				if(src.length<=len)return src;
				return src.substr(src.length-len);
			}
			if(typeof len=="string"){
				if(src.indexOf(len)<0)return src;
				return src.substr(src.indexOf(len)+1);
			}
			return src;
		}
	},
	parseGet:function(){
		var qs=Request.QueryString+"";
		var mat=/^404\;http\:\/\/(.+?)\/(.*?)$/i.exec(qs);
		if(mat!=null)MO_REWRITE_MODE="404";
		var uri="";
		if(MO_REWRITE_MODE=="404"){
			if(mat==null)return;
			if(mat.length<=0)return;
			this.rewrite = true;
			uri="/"+mat[2];
			if(F.server("HTTP_X_REWRITE_URL")!="")uri = F.server("HTTP_X_REWRITE_URL");
		}else if(MO_REWRITE_MODE=="URL"){
			uri = qs;
			this.rewrite = true;
			if(uri=="")return;
		}else{
			return;
		}
		var C = Mo.C("Rewrite");
		if(C==undefined)return;
		for(var i in C.Rules){
			uri = uri.replace(C.Rules[i].LookFor,C.Rules[i].SendTo);
		}
		mat = /^\/\?(.+?)$/i.exec(uri);
		if(mat && mat.length>0) uri = mat[1];
		var items = uri.split("&");
		for(var i in items){
			var stem = /^(.+?)\=(.+?)$/i.exec(items[i]);
			if(stem && stem.length>0){
				F.get(stem[1],decodeURIComponent(stem[2]));
			}else{
				F.get(stem,"");	
			}
		}
	}
};

F.string.email = function(str){return F.string.exp(str,"/^([\\w\\.\\-]+)@([\\w\\.\\-]+)$/");};
F.string.url = function(str){return F.string.exp(str,"/^http(s)?\\:\\/\\/(.+?)$/");};
F.string.exp = function(str,exp,option){if(typeof exp!=="string")return str;option = option||"";if(!/^\/(.+)\/([igm]*)$/.test(exp))exp = "/" + exp + "/" + option;try{eval("exp = " + exp);}catch(ex){return str;}str = str ||"";return (exp.test(str)? str:"");}

F.get.exp=function(key,exp,option){return F.string.exp(F.get(key),exp,option);};
F.post.exp=function(key,exp,option){return F.string.exp(F.post(key),exp,option);};
F.session.exp=function(key,exp,option){return F.string.exp(F.session(key),exp,option);};

F.get.email=function(key){return F.string.email(F.get.safe(key));};
F.post.email=function(key){return F.string.email(F.post.safe(key));};
F.session.email=function(key){return F.string.email(F.session.safe(key));};

F.get.url=function(key){return F.string.url(F.get.safe(key));};
F.post.url=function(key){return F.string.url(F.post.safe(key));};
F.session.url=function(key){return F.string.url(F.session.safe(key));};

F.get.safe=function(key,len){if(len!==undefined) return F.safe(F.get(key)).substr(0,len);return F.safe(F.get(key));};
F.post.safe=function(key,len){if(len!==undefined) return F.safe(F.post(key)).substr(0,len);return F.safe(F.post(key));};
F.session.safe=function(key,len){if(len!==undefined) return F.safe(F.session(key)).substr(0,len);return F.safe(F.session(key));};

F.get.intList = function(key,default_){return F.get.int(key,default_,true);};
F.post.intList = function(key,default_){return F.post.int(key,default_,true);};
F.session.intList = function(key,default_){return F.session.int(key,default_,true);};

F.post.remove = function(key){delete F.post__[key];};
F.get.remove = function(key){delete F.get__[key];};
F.post.clear = function(){delete F.post__;F.post__={};};
F.get.clear = function(){delete F.get__;F.get__={};};

F.post.exists = function(key){return F.post__[key]!=undefined};
F.get.exists = function(key){return F.get__[key]!=undefined};

F.session.exists = function(key){return Session.Contents(key)!=undefined};
F.session.destroy = function(key){if(key){Session.Contents.Remove(key);return;}Session.Abandon();};
F.session.clear = function(){Session.Contents.RemoveAll();};

F.get.int=function(key,default_,islist){
	if(islist!==true)islist=false;
	var value = F.get(key);
	value = value.replace(/\s/igm,"");
	if(value=="")return default_||0;
	if(!islist){
		if(isNaN(value))return default_||0;
		return parseInt(value);
	}else{
		value = value.replace(/(\s+)/igm,"");
		if(!/^([\d\,]+)$/.test(value))return default_||0;
		return (value);
	}
};
F.get.dbl=function(key,default_){
	var value = F.get(key);
	if(value=="")return default_||0;
	if(isNaN(value))return default_||0;
	return parseFloat(value);
};
F.get.bool=function(key,default_){
	var value = F.get(key).toLowerCase();
	if(value=="")return !!(default_||false);
	return (value==="true"?true:false);
};
F.post.int=function(key,default_,islist){
	if(islist!==true)islist=false;
	var value = F.post(key);
	value = value.replace(/\s/igm,"");
	if(value=="")return default_||0;
	if(!islist){
		if(isNaN(value))return default_||0;
		return parseInt(value);
	}else{
		if(!/^([\d\,]+)$/.test(value))return default_||0;
		return (value);
	}
};
F.post.dbl=function(key,default_){
	var value = F.post(key);
	if(value=="")return default_||0;
	if(isNaN(value))return default_||0;
	return parseFloat(value);
};
F.post.bool=function(key,default_){
	var value = F.post(key).toLowerCase();
	if(value=="")return !!(default_||false);
	return (value==="true"?true:false);
};
F.session.int=function(key,default_,islist){
	if(islist!==true)islist=false;
	var value = F.session(key);
	value = value.replace(/\s/igm,"");
	if(value=="")return default_||0;
	if(!islist){
		if(isNaN(value))return default_||0;
		return parseInt(value);
	}else{
		if(!/^([\d\,]+)$/.test(value))return default_||0;
		return (value);
	}
};
F.session.dbl=function(key,default_){
	var value = F.session(key);
	if(value=="")return default_||0;
	return parseFloat(value);
};
F.session.bool=function(key,default_){
	var value = F.session(key).toLowerCase();
	if(value=="")return default_||false;
	return (value==="true"?true:false);
};	
F.init();
</script>