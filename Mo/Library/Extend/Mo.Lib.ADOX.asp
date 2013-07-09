<script language="JScript" runAt="server">
/*'by anlige at www.9fn.net*/
function MoLibADOX(path){
	this.path = path||"";
	this.tables=[];
	this.datatype=",BOOLEAN,BYTE,COUNTER,CURRENCY,DATETIME,DOUBLE,GUID,LONG,LONGBINARY,LONGTEXT,SINGLE,SHORT,TEXT,";
	this.exception=[];
	this.conn=new ActiveXObject("Adodb.Connection");
	this.lasttablename="";
	var self = this;
	this.Fields={
		"set__":{
			"name":"",
			"length":0,
			"default":null,
			"type":null,
			"primarykey":false,
			"datedefaultnow":false
		},
		"New":function(name){
			this.set__={
				"name":"",
				"length":0,
				"default":null,
				"type":null,
				"primarykey":false
			};
			if(name!=undefined)this.set__.name=name;
			return this;
		},
		"name":function(name){
			this.set__.name=name;
			return this;
		},
		"length":function(length){
			if(isNaN(length)){
				self.exception.push("Argument 'length' Error:" + length);
				return this;
			}
			this.set__.length=length;
			return this;
		},
		"default":function(default_){
			this.set__["default"]=default_;
			return this;
		},
		"datatype":function(ty){
			ty = ty ||"";
			ty=""+ty+"";
			if(self.datatype.toLowerCase().indexOf("," + ty.toLowerCase() + ",")<0){
				self.exception.push("datatype Error:" + ty);
				return this;
			}
			this.set__.type=ty.toUpperCase();
			return this;
		},
		"primarykey":function(isprimarykey){
			this.set__.primarykey=(isprimarykey!==false);
			return this;
		},
		"defaultnow":function(isdefaultnow){
			this.set__.datedefaultnow=(isdefaultnow!==false);
			return this;
		},
		"Append":function(){
			return this.AppendTo();
		},
		"AppendTo":function(tablename){
			self.AddFiled(tablename,this.set__);
			return this;
		},
		"DeleteFrom":function(tablename){
			return self.DeleteFiled(tablename,this.set__.name);
		}
	};
	var ext = this.datatype.split(",");
	for(var i in ext){
		this.Fields[ext[i]] = (function(dt){
			return function(tablename){
				return this.datatype(dt).AppendTo(tablename);
			}
		})(ext[i]);	
		this.Fields["new"+ext[i]] = (function(dt){
			return function(name){
				return this.New(name).datatype(dt).AppendTo();
			}
		})(ext[i]);
	}
}

MoLibADOX.New = function(path){return new MoLibADOX(path);};
MoLibADOX.Mappath = function(path){
	if(path.length<2)return Server.MapPath(path)
	if(path.substr(1,1)==":") return path;
	return Server.MapPath(path);	
};
MoLibADOX.prototype.DeleteFiled = function(tablename,name){
	if(name==undefined){
		name = 	tablename;
		tablename = null;
	}
	if(!this.Open())return false;
	if(!name || name=="" || !/[0-9a-zA-Z\_]/ig.test(name))return false;
	tablename = tablename || this.lasttablename;
	if(!tablename || tablename=="" || !/[0-9a-zA-Z\_]/ig.test(tablename))return false;
	try{
		this.conn.execute("ALTER TABLE [" + tablename + "] DROP COLUMN [" + name +"]");
		this.lasttablename = tablename;
		return true;
	}catch(ex){
		this.exception.push("DeleteFiled："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.AddFiled=function(name,set_){
	if(!this.Open())return false;
	name = name || this.lasttablename;
	if(!name || name=="" || !/[0-9a-zA-Z\_]/ig.test(name))return false;
	var sql="ALTER TABLE [" + name + "] ADD COLUMN [" + set_.name + "] " + set_.type;
	if(set_.length>0)sql+="(" + set_.length + ")"
	if(set_.type=="COUNTER")sql+="(1,1)"
	if(set_.primarykey===true)sql+=" PRIMARY KEY"
	if(set_["default"]!==null){
		sql+=" default " + set_["default"] + "";
	}else{
		if(	set_.type=="DATETIME" && set_.datedefaultnow) sql+=" default Now()"
	}
	try{
		this.conn.execute(sql);
		this.lasttablename = name;
		return true;
	}catch(ex){
		this.exception.push("AddFiled："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.Open = function(path){
	if(this.conn.state==1)return true;
	this.path = this.path || path;
	try{
		this.conn.open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + MoLibADOX.Mappath(this.path));
		return true;
	}catch(ex){
		this.exception.push("Open："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.Select = function(tablename){
	this.lasttablename = tablename;
};
MoLibADOX.prototype.Create = function(path){
	this.path = this.path || path;
	try{
		var Cate = new ActiveXObject("ADOX.Catalog");
		Cate.create("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + MoLibADOX.Mappath(this.path));
		Cate = null;
		this.Open();
	}catch(e){
		this.exception.push("Create："+e.description);
		return false;
	}
};
MoLibADOX.prototype.Exec = function(sql){
	if(!sql || sql=="")return false;
	if(!this.Open())return false;
	try{
		this.conn.execute(sql);
		return true;
	}catch(ex){
		this.exception.push("Exec："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.CreateTable = function(name,delete_){
	name = name || this.lasttablename;
	if(!name || name=="" || !/[0-9a-zA-Z\_]/ig.test(name))return false;
	if(!this.Open())return false;
	if(delete_===true){
		try{
			this.DropTable(name,true);
		}catch(ex){}	
	}
	try{
		this.conn.execute("create table " + name);
		this.lasttablename = name;
		return true;
	}catch(ex){
		this.exception.push("CreateTable："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.DropTable = function(name,noerror){
	if(noerror!==true)noerror=false;
	name = name || this.lasttablename;
	if(!name || name=="" || !/[0-9a-zA-Z\_]/ig.test(name))return false;
	if(!this.Open())return false;
	try{
		this.conn.execute("drop table [" + name +"]");
		this.lasttablename = name;
		return true;
	}catch(ex){
		if(!noerror)this.exception.push("DropTable："+ex.description);
		return false;
	}
};
MoLibADOX.prototype.Debug=function(){
	return this.exception.join("<br />");
};
MoLibADOX.prototype.Close = function(){
	try{this.conn.close();}catch(ex){}	
};
</script>
