<script language="jscript" runat="server">
//var conn__=null;
function Model__(tablename,pk,dbConf){
	Model__.list.push(new __Model__(tablename,pk,dbConf));
	return Model__.list[Model__.list.length-1];	
}
Model__.defaultDBConf = "DB";
Model__.list=[];
Model__.debugs=[];
Model__.connections = [];
Model__.connectionsIndex = {};

Model__.isobject=function(src){var ty=(typeof src);return (ty=="function" || ty=="object");};
Model__.setDefault = function(dbConf){Model__.defaultDBConf = dbConf || "DB";};
Model__.connection=function(dbConf){
	if(Model__.connectionsIndex[dbConf]===undefined)return null;
	return Model__.connections[Model__.connectionsIndex[dbConf]][0];
};
Model__.dispose=function(){
	while(Model__.list.length>0){
		var M = Model__.list.pop().dispose();
		M = null;
	}
	while(Model__.connections.length>0){
		var M = Model__.connections.pop();
		try{
			M[0].close();
			Model__.debugs.push("database(" + M[2] +") disconnected");
		}catch(ex){
			Model__.debugs.push("database(" + M[2] +") disconnect failed");
		}
		M[0] = null;
		M = null;
	}
	delete Model__.connectionsIndex;
	Model__.connectionsIndex = {};
};
Model__.debug=function(){
	F.echo(Model__.debugs.join("<br />"));
};
function __Model__(tablename,pk,dbConf){
	dbConf = dbConf ||Model__.defaultDBConf;
	this.table = tablename||"";
	this.table=MO_TABLE_PERX+this.table;
	this.fields="*";
	this.strwhere="";
	this.strgroupby="";
	this.strorderby="";
	this.pagekey=pk;
	this.pagekeyorder="yes";
	this.stron="";
	this.strjoin="";
	this.strlimit=-1;
	this.strpage=1;
	this.data={};
	this.strcname="";
	this.pk=pk||"id";
	this.pagestr="";
	this.rc=0;
	this.pageurl_="";
	this.id="#"+Model__.list.length;
	this.rs__=null;
	this.object_cache=null;
	this.connectionIndex=-1;
	this.dbConf=null;
	if(Model__.connectionsIndex[dbConf]===undefined){
		Model__.connections.push([new ActiveXObject("adodb.connection"),Mo.C(dbConf),dbConf]);	
		this.connectionIndex = 	Model__.connections.length-1;
		Model__.connectionsIndex[dbConf] = this.connectionIndex;
		this.dbConf = Model__.connections[this.connectionIndex][1];
		try{
			Model__.debugs.push("connect to database(" + dbConf +")");
			if(this.dbConf["DB_Type"]=="ACCESS"){
				Model__.connections[this.connectionIndex][0].open("provider=microsoft.jet.oledb.4.0; data source=" + F.mappath(this.dbConf["DB_Path"]));
			}else if(this.dbConf["DB_Type"]=="SQLSERVER"){
				Model__.connections[this.connectionIndex][0].open(F.format("provider=sqloledb.1;Persist Security Info=false;data source={0};User ID={1};pwd={2};Initial Catalog={3}",this.dbConf["DB_Server"],this.dbConf["DB_Username"],this.dbConf["DB_Password"],this.dbConf["DB_Name"]));
			}
			Model__.debugs.push("database(" + dbConf +") connect successfully");
		}catch(ex){
			Model__.connections.pop();
			this.dbConf=null;
			Model__.debugs.push("database(" + dbConf +") connect failed");
		}
	}else{
		this.connectionIndex = 	Model__.connectionsIndex[dbConf];
		this.dbConf = Model__.connections[this.connectionIndex][1];
	}
}
__Model__.prototype.pageurl=function(url){
	this.pageurl_ = url || "";
	return this;
};
__Model__.prototype.select=function(fields){
	this.fields = fields || "*";
	return this;
};
__Model__.prototype.where=function(where){
	if(where==undefined)return this;
	if(arguments.length<=0)return this;
	var strwhere="("+arguments[0]+")",sp="";
	for(var i=1;i<arguments.length;i++){
		sp = arguments[i].substr(0,1);
		strwhere =	"(" + strwhere + (sp=="|"?" or ":" and ") + (sp=="|" ?  arguments[i].substr(1):arguments[i]) +")";
	}
	strwhere = strwhere.substr(1);
	strwhere = strwhere.substr(0,strwhere.length-1);
	this.strwhere = strwhere;
	return this;
};
__Model__.prototype.orderby=function(orderby){
	this.strorderby = orderby||"";
	return this;
};
__Model__.prototype.groupby=function(groupby){
	this.strgroupby = groupby||"";
	return this;
};
__Model__.prototype.limit=function(page,limit,pagekeyorder,pagekey){
	this.strlimit = limit||-1;
	this.strpage = page||1;
	this.strpage = parseInt(this.strpage);
	this.strlimit = parseInt(this.strlimit);
	if(this.strpage<=0)this.strpage=1;
	if(this.strlimit<=0)this.strlimit=-1;
	return this;
};
__Model__.prototype.max=function(filed){
	var k = filed||this.pk;
	if(this.dbConf["DB_Type"]=="SQLSERVER"){
		return this.query("select isnull(max(" + k + "),0) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
	}
	return this.query("select iif(isnull(max(" + k + ")),0,max(" + k + ")) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
};
__Model__.prototype.min=function(filed){
	var k = filed||this.pk;
	if(this.dbConf["DB_Type"]=="SQLSERVER"){
		return this.query("select isnull(min(" + k + "),0) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
	}
	return this.query("select iif(isnull(min(" + k + ")),0,min(" + k + ")) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
};
__Model__.prototype.count=function(filed){
	var k = filed||this.pk;
	return this.query("select count(" + k + ") from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
};
__Model__.prototype.sum=function(filed){
	var k = filed||this.pk;
	if(this.dbConf["DB_Type"]=="SQLSERVER"){
		return this.query("select isnull(sum(" + k + "),0) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
	}
	return this.query("select iif(isnull(sum(" + k + ")),0,sum(" + k + ")) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
};
__Model__.prototype.increase=function(name,n){
	n=n||1;
	n = parseInt(n)
	this.query("update " + this.table + " set " + name + " = " + name + " + (" + n + ")" + (this.strwhere!=""?(" where " + this.strwhere):""));
	return this;
};
__Model__.prototype.toogle=function(name,n){
	n=n||1;
	n = parseInt(n)
	this.query("update " + this.table + " set " + name + " = " + n + " - " + name + " " + (this.strwhere!=""?(" where " + this.strwhere):""));
	return this;
};

__Model__.prototype.join=function(table,jointype){
	jointype = jointype ||"inner join ";
	this.strjoin = jointype + MO_TABLE_PERX + table;
	return this;
};
__Model__.prototype.on=function(str){
	str=str||"";
	this.stron=str;
	return this;
};
__Model__.prototype.cname=function(str){
	str=str||"";
	this.strcname=str;
	return this;
};

__Model__.prototype.query=function(){
	if(arguments.length==1){
		Model__.debugs.push(arguments[0]);
		return Model__.connections[this.connectionIndex][0].execute(arguments[0]);	
	}
	this.dispose();
	this.rs__=new ActiveXObject("adodb.recordset");
	var where_="",order_="",where2_="",groupby="",join="",on="",cname="";
	try{this.rs__.close()}catch(ex){}
	if(this.strwhere!=""){
		where_=" where " + this.strwhere + "";
		if(this.strpage>1 && this.strlimit!=-1)where2_=" and (" + this.strwhere + ")";
	}
	if(this.strgroupby!="") groupby=" group by " + this.strgroupby;
	if(this.strjoin!="")join=" " + this.strjoin + " ";
	if(this.stron!="")on=" on " + this.stron + " ";
	if(this.strcname!="")cname = " " + this.strcname+" ";
	this.countsql = "select count(" + this.pk + ") from " + this.table + cname + join + on + where_ + groupby;
	if (this.strorderby!="") order_=" order by " + this.strorderby;
	var sql="";
	if(this.pagekeyorder=="" || this.strlimit==-1){
		sql="select " + this.fields + " from " + this.table + cname + join + on + where_ + groupby+ order_;
	}else{
		if(this.strpage>1)where_ +=" " + (where_!=""?"and":"where") + " " + this.pagekey + " not in(select top " + this.strlimit * (this.strpage-1) + " " + this.pagekey + " from " +this.table + cname + join + on + where_ + groupby+ order_ +")"	;
		sql="select top " + this.strlimit + " " + this.fields + " from " + this.table + cname + join + on + where_ + groupby+ order_;	
	}
	Model__.debugs.push(sql);
	this.rs__.open(sql,Model__.connections[this.connectionIndex][0],1,1);
	if(this.strlimit>0){
		Model__.debugs.push(this.countsql);
		this.rc = Model__.connections[this.connectionIndex][0].execute(this.countsql)(0).value;
	}
	return this;
};

__Model__.prototype.fetch=function(){
	if(this.object_cache!=null){
		this.object_cache.Reset();
		return this.object_cache;
	}
	if(this.strlimit!=-1 && this.rc>0){
		this.rs__.pagesize = this.strlimit;
		if(this.pagekeyorder=="")this.rs__.absolutepage = this.strpage;
	}
	this.object_cache = new __Obj__(this.rs__,this.strlimit);
	try{this.rs__.close();}catch(ex){}
	this.rs__ = null;
	this.object_cache.pagesize = this.strlimit;
	this.object_cache.recordcount = this.rc;
	this.object_cache.currentpage = this.strpage;
	return this.object_cache;
};
__Model__.prototype.read=function(name){
	name = name ||"";
	var obj = this.fetch();
	if(!obj.Eof()){
		return obj.Read().getter__(name);
	}
	return {}.getter__(name);
};
__Model__.prototype.getjson=function(){return this.fetch().getjson();};
__Model__.prototype.assign=function(name,asobject){
	if (asobject!==true)asobject=false;
	if(name && !asobject){
		Mo.Assign(name,this.fetch());
	}else{
		var obj = this.fetch();
		if(!obj.Eof()){
			var d_ = obj.Read();
			if(asobject){
				Mo.Assign(name,d_);
			}else{
				for(var i in d_){
					if(Model__.isobject(d_[i]))continue;
					Mo.Assign(i,d_[i]);	
				}
			}
		}
	}
	return this;
};
__Model__.prototype.insert=function(){
	var data=null;
	if(arguments.length==1){
		 if((typeof arguments[0]=="object") && arguments[0]["table"]!=undefined) data=arguments[0];
	}
	if(arguments.length>0 && arguments.length % 2==0){
		data = Record__();
		for(var i=0;i<arguments.length-1;i+=2){
			data.set(arguments[i],arguments[i+1],typeof arguments[i+1]);
		}
	}
	if(data==null){
		data = Record__();
		data.frompost(this.pk);
	}	
	var d_ = this.parseData(data["table"]);
	if(d_[0]!="" && d_[1]!=""){
		var sql = "insert into " + this.table + "(" + d_[0] + ") values(" + d_[1] + ")";
		this.query(sql);
	}
	return this;
};
__Model__.prototype.update=function(){
	var data=null;
	if(arguments.length==1){
		 if((typeof arguments[0]=="object") && arguments[0]["table"]!=undefined) data=arguments[0];
	}
	if(arguments.length>0 && arguments.length % 2==0){
		data = Record__();
		for(var i=0;i<arguments.length-1;i+=2){
			data.set(arguments[i],arguments[i+1],typeof arguments[i+1]);
		}
	}
	if(data==null){
		data = Record__();
		data.frompost(this.pk);
		if(this.strwhere=="" && data.pk!=""){
			this.strwhere = this.pk + " = " + data.pk;
		}
	}
	var d_ = this.parseData(data["table"]);
	if(d_[2]!=""){
		var sql = "update " + this.table + " set " + d_[2] + (this.strwhere!=""?(" where " + this.strwhere):"");
		this.query(sql);
	}
	return this;
};

__Model__.prototype.Delete=function(){
	this.query("delete from " + this.table +(this.strwhere!=""?(" where " + this.strwhere):""));
	return this;
};
__Model__.prototype.dispose=function(){
	if(this.rs__!=null){
		try{this.rs__.close();}catch(ex){}
		this.rs__ = null;
	}
	if(this.object_cache!=null){
		this.object_cache.dispose();
		this.object_cache = null;
	}
	return this;
};
__Model__.prototype.parseData = function(table){
	var fields=[],values=[],update=[];
	for(var i in table){
		if(!table.hasOwnProperty(i))continue;
		if(table[i]["value"]!=undefined){
			fields.push("["+i+"]");
			var v=table[i]["value"];
			if(typeof table[i]["value"]=="string"){
				v = ("'" + table[i]["value"].replace(/\'/igm,"''") + "'");
			}
			values.push(v);
			update.push("["+i+"]=" + v);
		}
	}
	return [fields.join(","),values.join(","),update.join(",")];
};
</script>
