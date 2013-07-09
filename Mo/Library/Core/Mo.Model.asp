<script language="jscript" runat="server">
//var conn__=null;
var Model__List=[];
var Model__Debug=[];
function Model__(tablename,pk){
	Model__List.push(new __Model__(tablename,pk));
	return Model__List[Model__List.length-1];	
}
Model__.connection = null;
Model__.db = {};
Model__.isobject=function(src){var ty=(typeof src);return (ty=="function" || ty=="object");};
Model__.dispose=function(){
	while(Model__List.length>0){
		var M = Model__List.pop();
		M.dispose();
		M = null;
	}
	try{Model__.connection.close();}catch(ex){}
	Model__.connection = null;
	Model__.db = null;
};
Model__.debug=function(){
	for(var i in Model__Debug){
		if(typeof Model__Debug[i]!="string")continue;
		F.echo(Model__Debug[i]+"<br />")	;
	}	
};
function __Model__(tablename,pk,dbConf){
	Model__.db["DB_Type"] = "ACCESS";
	dbConf = dbConf ||"DB";
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
	this.id="#"+Model__List.length;
	this.rs__=null;
	this.object_cache=null;
	if(Model__.connection==null){
		Model__.connection = new ActiveXObject("adodb.connection");	
		Model__.db = Mo.C(dbConf);
		try{
			if(Model__.db["DB_Type"]=="ACCESS"){
				Model__.connection.open("provider=microsoft.jet.oledb.4.0; data source=" + F.mappath(Model__.db["DB_Path"]));
			}else if(Model__.db["DB_Type"]=="SQLSERVER"){
				Model__.connection.open(F.format("provider=sqloledb.1;Persist Security Info=false;data source={0};User ID={1};pwd={2};Initial Catalog={3}",Model__.db["DB_Server"],Model__.db["DB_Username"],Model__.db["DB_Password"],Model__.db["DB_Name"]));
			}
		}catch(ex){
			Model__.connection=null;
			Model__.db=null;
		}
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
	if(Model__.db["DB_Type"]=="SQLSERVER"){
		return this.query("select isnull(max(" + k + "),0) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
	}
	return this.query("select iif(isnull(max(" + k + ")),0,max(" + k + ")) from " + this.table + (this.strwhere!=""?(" where " + this.strwhere):""))(0).value;	
};
__Model__.prototype.min=function(filed){
	var k = filed||this.pk;
	if(Model__.db["DB_Type"]=="SQLSERVER"){
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
	if(Model__.db["DB_Type"]=="SQLSERVER"){
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
	if(Model__.connection==null)return this;
	if(arguments.length==1){
		Model__Debug.push(arguments[0]);
		return Model__.connection.execute(arguments[0]);	
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
	Model__Debug.push(sql);
	this.rs__.open(sql,Model__.connection,1,1);
	if(this.strlimit>0){
		Model__Debug.push(this.countsql);
		this.rc = Model__.connection.execute(this.countsql)(0).value;
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
