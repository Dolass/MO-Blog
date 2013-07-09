(function(){
	Sizzle.selectors.filters.visible = function( elem ) {
		return !(elem.type=="hidden"||elem.style.display=="none"||elem.style.visibility=="hidden");
	};
	Sizzle.selectors.filters.hidden = function( elem ) {
		return !Sizzle.selectors.filters.visible(elem);
	};
	var F = window.F = function(selector,element){
		if(typeof selector =="function"){
			F.load(selector);
			return;
		}
		return new F.fn.F__(selector,element||document);
	}
	F.fn=F.prototype={
		__l__:[],
		$$guid:0,
		returnValue:null,
		F__:function(opt,SOU){
			while(this.__l__.length>0)this.__l__.pop();
			if(opt==window){
				this.__l__.push(opt);return;
			}
			if(opt.nodeType && (opt.nodeType==1 || opt.nodeType==9)){
				this.__l__.push(opt);return;
			}
			if(opt.constructor==Array){
				this.__l__=	opt;return;
			}
			this.__l__ = Sizzle(opt,SOU);
		},
		find:function(selector){
			var ary_=[];
			this.each(function(){
				var tmp=Sizzle(selector,this);
				while(tmp.length>0){
					ary_.push(tmp.pop());	
				}
			});
			return F(ary_);
		},
		filter:function(selector){
			return F(Sizzle.matches(selector,this.__l__));
		},
		html:function(value){
			var val=null;
			this.each(function(){
				if(value==undefined){
					val = this.innerHTML;
					return false;
				}else{
					this.innerHTML=value;
				}
			});
			if(val!=null)return val;
			return this;
		},
		addClass:function(cn){
			this.each(function(){
				F(this).attr("class",F.trim((F.trim(F(this).attr("class").replace(new RegExp('\\b' + cn + '\\b', 'g'), '')) + ' ' + cn)));
			 });
			return this;
		},
		removeClass:function(cn){
			this.each(function(){
				F(this).attr("class",F.trim(F(this).attr("class").replace(new RegExp('\\b' + cn + '\\b', 'g'), '')));
			});
			return this;
		},
		Class:function(value){
			var val=null;
			this.each(function(){
				if(value==undefined){
					val = F(this).attr("class");
					return false;
				}else{
					F(this).attr("class",value);
				}
			});
			if(val!=null)return val;
			return this;
		},
		css:function(){
			var val=null;
			var args=arguments;
			this.each(function(){
				var str = this.style.cssText;
				if(str.substr(str.length-1,1)==";"){str = str.substr(0,str.length-1);}
				if(args.length==0){val=this.style.cssText;return false;	}
				if(args.length==1){
					if(typeof(args[0])=="string"){
						if(args[0].indexOf(":")<=0){
							//eval("var _sss = this.style." + args[0] + ";");
							val = this.style[args[0]];
							return false;
						}else{
							this.style.cssText = args[0];
						}
					}else if(typeof(args[0])=="object"){
						var arg = args[0];
						for(var i in arg){
							if(typeof arg[i]=="object")break;
							var regexp=new RegExp("(\\;|^)"+i.replace("-","\\-")+"(\\s*)\\:(.+?)(\\;|$)","igm");
							str = str.replace(regexp,"$1");
							str += ";" + i + ":" + arg[i];
						}
						this.style.cssText = str;
					}
				}
				if(args.length==2){
					name = args[0];
					if(name === "float" || name === "cssFloat"){
						if(F.browser.ie){
							name = "styleFloat";
						}else{
							name = "cssFloat";
						}
					}
					if(name=="opacity" && F.browser.ie && F.browser.version<9){
						var opacity = parseInt(parseFloat(args[1])*100);
						this.style.filter = 'alpha(opacity="' + opacity + '")';
						if(!this.style.zoom){
							this.style.zoom = 1;
						}
						return;
					}
					this.style[name] =args[1];
				}
			});
			if(val!=null)return val;
			return this;			
		},
		val:function(value){
			var val=null;
			this.each(function(){
				if(value==undefined){
					val = this.value;
					return false;
				}else{
					this.value=value;
				}
			});
			if(val!=null)return val;
			return this;
		},
		text:function(txt){
			if(txt==undefined){
				if(this.__l__[0].length<=0)return"";
				return F.text(this.__l__[0].innerHTML) ;
			}else{
				this.each(function(){
					if(this.innerText){
						this.innerText=txt;
					}else{
						this.textContent=txt;
					}
				});
			}
			return this;			
		},
		parent:function(){
			var _ary=[];
			this.each(function(){
				if(this.parentNode)_ary.push(this.parentNode);
			 });
			return F(_ary);
		},
		tag:function(){
			return this.__l__.length>0?this.__l__[0].nodeName.toLowerCase():"";
		},
		first:function(){
			var _ary=[];
			this.each(function(){
				if(!this.firstChild)return;
				var ele = this.firstChild;
				while(ele.nodeType!=1 && ele.nextSibling){
					ele = ele.nextSibling;
				}
				if(ele.nodeType==1)_ary.push(ele);
			 });
			return F(_ary);
		},
		last:function(){
			var _ary=[];
			this.each(function(){
				if(!this.lastChild)return;
				var ele = this.lastChild;
				while(ele.nodeType!=1 && ele.previousSibling){
					ele = ele.previousSibling;
				}
				if(ele.nodeType==1)_ary.push(ele);
			 });
			return F(_ary);
		},
		remove:function(){
			this.each(function(){
				if(this.parentNode)this.parentNode.removeChild(this);
			 });
		},
		append:function(nod){
			if(typeof(nod)=="string"){
				var div = document.createElement("div");
				div.innerHTML=nod;
				this.each(function(){
					var self=this;
					F(div).child().each(function(){if(this.nodeName) self.appendChild(this);});
				});
			}else{
				this.each(function(){
					this.appendChild(nod.cloneNode(true));   
				});
			}
			return this;
		},
		hasAttr:function(name){
			return this.__l__.length>0?
			(this.__l__[0].hasAttribute ? this.__l__[0].hasAttribute(name) : (this.__l__[0].getAttribute(name)!=null)):false;
		},
		attr:function(name,value){
			if(name.toLowerCase()=="class")name = F.classstr;
			if(value===undefined){
				var ret = this.__l__.length>0?this.__l__[0].getAttribute(name):"";
				if(ret==null)return "";
				return ret;
			}else{
				this.each(function(){
					if(value!=null){
						this.setAttribute(name,value);
					}else{
						this.removeAttribute(name);
					}
				});
			}
			return this;
		},
		next:function(){
			var Ary=[];
			this.each(function(){
				var ele = this.nextSibling;
				while(ele !=null && ele.nodeType!=1){
					ele = ele.nextSibling;
				}
				if(ele)Ary.push(ele);
			});
			return F(Ary);
		},
		prev:function(){
			var Ary=[];
			this.each(function(){
				var ele = this.previousSibling;
				while(ele !=null && ele.nodeType!=1){
					ele = ele.previousSibling;
				}
				if(ele)Ary.push(ele);
			});
			return F(Ary);
		},
		child:function(){
			var Ary=[];
			this.each(function(){
				for(var i in this.childNodes){
					if(this.childNodes[i].nodeType==1)Ary.push(this.childNodes[i]);
				}
			});
			return F(Ary);
		},
		hover:function(fn1,fn2){
			this.each(function(){
				F(this).mouseover(fn1);
				F(this).mouseout(fn2);
			});
			return this;					
		},
		toggle:function(){
			this.each(function(){
				this.style.display = this.style.display!="none" ?"none":"block";	   
			});
		},
		position:function(){
			if(this.__l__ ==null || this.__l__.length<=0)return;
			var el = this.__l__[0];
			var box = el.getBoundingClientRect(), 
			doc = el.ownerDocument, 
			body = doc.body, 
			html = doc.documentElement,
			clientTop = html.clientTop || body.clientTop || 0, clientLeft = html.clientLeft || body.clientLeft || 0, 
			top = box.top + (self.pageYOffset || html.scrollTop || body.scrollTop ) - clientTop, 
			left = box.left + (self.pageXOffset || html.scrollLeft || body.scrollLeft) - clientLeft;
			return { "top": top, "left": left,"box":box };	
		},
		unbind:function(evt){
			this.each(function(){
				if(!this.events)return;
				while(this.events[evt].length>0){
					var fn = this.events[evt].pop();
					fn = null;
				}
			});
			return this;
		},
		each:function(fn,args){
			if(this.__l__ ==null || this.__l__.length<=0)return;
			this.returnValue=null;
			F.each.call(this,this.__l__,fn,args);
			return ((this.returnValue==null||this.returnValue==undefined)?this : this.returnValue);
		},length:function(){return this.__l__.length;},get:function(index){if(index<0||index>=this.__l__.length)return null;return this.__l__[index];}
	};
	F.extend=function(){
		if(arguments.length<=0)return;
		if(arguments.length==2){
			var srcObj=arguments[0];
			var newObj=arguments[1];
			if(typeof srcObj!="object")srcObj={};
			if(typeof newObj!="object")newObj={};
			for(var i in newObj)srcObj[i]=newObj[i];
			return srcObj;
		}
		var name = arguments[0];
		var args=[];
		if(typeof name=="function"){
			name.apply(this,args);	
		}else{
			var self=this;
			for(var i in name){
				if(this.__l__ && (typeof name[i]=="function")){
					this[i]=(function(fn){
						return function(){
							var ret=this.each(fn,arguments);
							return ret;
						};		  
					})(name[i]);
				}else{
					this[i]=name[i];
				}
			}
		}
	};
	F.fn.extend=function(){
		F.extend.apply(F.fn,arguments);
	};
	F.fn.F__.prototype=F.fn;
	
	F.each= function(object, callback, args){
		if(object==null || object==undefined)return;
		var name, i = 0,length = object.length,returnValue=null;
		if (args) {
			if (length == undefined) {
				for (name in object) {
					returnValue = callback.apply(object[name], args);
					if (returnValue != undefined) break;
				}
			} else {
				for (; i < length;) {
					returnValue = callback.apply(object[i++], args);
					if (returnValue != undefined) break;
				}
			}
		} else {
			if (length == undefined) {
				for (name in object) {
					returnValue=callback.call(object[name], name, object[name]);
					if (returnValue != undefined) break;
				}
			} else {
				for (var value = object[0]; i < length; value = object[++i]) {
					returnValue = callback.call(value, i, value);
					if (returnValue != undefined) break;
				}
			}
		}
		this.returnValue=returnValue;
		return object;
	};
	/*code from jquery*/
	F.fix=function(e) { 
	　　　 if (e["packaged"] == true) return e;
	　　　 var originalEvent = e;
	　　　 var event = {　originalEvent : originalEvent}; 
			for (var i in originalEvent) {
　　　　　 		event[i] = originalEvent[i]; 
			}
	　　　 event["packaged"] = true; 
	　　　 event.preventDefault = function() {
	　　　　　 if (originalEvent.preventDefault) 
	　　　　　　　originalEvent.preventDefault(); 
	　 　　　　 originalEvent.returnValue = false; 
	　　　 }; 
	　　　 event.stopPropagation = function() {
	　　　　　 if (originalEvent.stopPropagation) 
	　　　　　　　 originalEvent.stopPropagation(); 
	　　　　　 originalEvent.cancelBubble = true; 
	　　　 }; 
	　　　 event.timeStamp = event.timeStamp || (new Date()); 
	　　　 if (!event.target)
	　　　　　 event.target = event.srcElement || document;　　　　 
	　　　 if (event.target.nodeType == 3)
	　　　　　 event.target = event.target.parentNode; 
	　　　 if (!event.relatedTarget && event.fromElement)
	　　　　　 event.relatedTarget = event.fromElement == event.target 
	　　　　　　　　　? event.toElement : event.fromElement; 
	　　　 if (event.pageX == null && event.clientX != null) {
	　　　　　 var doc = document.documentElement, body = document.body; 
	　　　　 event.pageX = event.clientX 
	　　　　　　　+ (doc && doc.scrollLeft || body && body.scrollLeft || 0) 
	　　　　　　　　　- (doc.clientLeft || 0); 
	　　　　　 event.pageY = event.clientY 
	　　　　　　　+ (doc && doc.scrollTop || body && body.scrollTop || 0) 
	　　　　　　　　　- (doc.clientTop || 0); 
	　　　 }
	　 　if (!event.which　&& ((event.charCode || event.charCode === 0)
	　 　　　　　　　　　 ? event.charCode　: event.keyCode)) 
	　　　　　 {event.which = event.charCode || event.keyCode;}
	　　　 if (!event.metaKey && event.ctrlKey)
	　　　　　 event.metaKey = event.ctrlKey; 
	　　　 if (!event.which && event.button)
	　　　　　 event.which = (event.button & 1 ? 1 : (event.button & 2 
	　　　　　　　　　? 3 : (event.button & 4 ? 2 : 0))); 
	　　　 return event; 
	};
	F.events = F.fn.events = "blur,focus,load,resize,scroll,unload,click,dblclick,mousedown,mouseup,mousemove,mouseover,mouseout,change,select,submit,keydown,keypress,keyup,error".split(",");
	F.each(F.events,function(){
		F.fn[this] = (function(evt){
			return function(fn){
				var self=this;
				this.each(function(){
					self.$$guid++;
					fn.$$guid=self.$$guid;
					if(!this.events)this.events={};
					if(!this.events[evt]){
						this.events[evt]=[];
						if((typeof this["on"+evt]=="function")){
							this.events[evt].push(this["on"+evt]);
						}
						this["on"+evt] = function(e){
							e = e || window.event;
							if(this.events[evt].length<=0)return;
							for(i=0;i<this.events[evt].length;i++){
								this.events[evt][i].apply(this,[F.fix(e)]);
							}
						}
					}
					this.events[evt].push(fn);
				});
				return this;
				
			};
		})(this);
	});
	F.load = F.fn.load = function(fn){
		var isReady=false;
		if(F.browser.ie){
			while(/loaded|complete/i.test(document.readyState)){
				fn();
				isReady = true;
			}	
			if(!isReady){
				window.attachEvent("onload",fn);	
				isReady = true;
			}
		}else{
			document.addEventListener("DOMContentLoaded",fn,false);
			isReady = true;
		}
		if(!isReady){
			window.addEventListener("load",fn,false);
		}
	};
	F.extend(function(){
		this.classstr="class";
		this.agent = this.fn.agent = window.navigator.userAgent;
		this.trim=function(val){return val.replace(/(^\s*)|(\s*$)/g,"");};
		this.browser = this.fn.browser = {ie:false,ff:false,google:false,sa:false,op:false,wk:false};
		this.browser.ie = /MSIE/i.test(this.agent);
		this.browser.ff = /firefox/i.test(this.agent);
		this.browser.google = /safari/i.test(this.agent) && /chrome/i.test(this.agent);
		this.browser.sa = /safari/i.test(this.agent) && !(/chrome/i.test(this.agent));
		this.browser.op = /Opera/i.test(this.agent);
		this.browser.wk = /webkit/i.test(this.agent);
		this.browser.version="-1";
		if(this.agent.match(/MSIE ([\d\.]+)/i)){
			this.browser.version =this.agent.match(/MSIE ([\d\.]+)/i)[1];
			if(parseInt(this.browser.version)<8)this.classstr="className";
		}
		if(F.agent.match(/Safari\/([\d\.]+)/i)){
			this.browser.version =this.agent.match(/Safari\/([\d\.]+)/)[1];
		}
		if(F.agent.match(/Chrome\/([\d\.]+)/i)){
			this.browser.version =this.agent.match(/Chrome\/([\d\.]+)/)[1];
		}
		if(F.agent.match(/Opera\/([\d\.]+)/i)){
			this.browser.version =this.agent.match(/Opera\/([\d\.]+)/)[1];
		}					  
	});
})();