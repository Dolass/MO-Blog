<script language="jscript" runat="server">
function MoEnumerator(obj){
	this.index = -1;
	this.container = obj;
	this.Current=null;
	this.MoveNext=function() {
		this.index++;
		if (this.index < this.container.length){
			this.Current = this.container[this.index];
			return true;
		}
		return false;
	};
	this.Reset=function()
	{
		this.index = -1;
	};
}

function object(){return new Object();}
function Mo___(ds,pagesize){
	return new __Obj__(ds,pagesize);	
}
Mo___.FromJsArray = function(obj){
	var data = new __Obj__();
	data.FromJson(obj);
	return data;
};
function __Obj__(ds,pagesize){
	this.LIST__=[];
	this.index=-1;
	this.pagesize=pagesize||-1;
	this.recordcount=0;
	this.currentpage=1;
	this.GetEnumerator=function(){
		return new MoEnumerator(this.LIST__);
	};
	if(ds!=undefined)this.AddDataSet(ds,pagesize);
}
__Obj__.prototype.dispose=function(){
	while(this.LIST__.length>0){
		F.dispose(this.LIST__.pop());
	}
};
__Obj__.prototype.AddJson=function(obj){
	this.LIST__.push(obj);
	
};
__Obj__.prototype.FromJson=function(obj){
	this.LIST__=obj;
	
};
__Obj__.prototype.AddJsonString=function(obj){
	var json = F.json(obj);
	if(json!=null)this.LIST__.push(json);
	
};
__Obj__.prototype.Add=function(rs){
	var tmp__=new Object();
	for(var i=0;i<rs.fields.count;i++){
		tmp__[rs.fields(i).Name]=rs.fields(i).value;
	}
	this.LIST__.push(tmp__);
	
};
__Obj__.prototype.AddDataSet=function(rs,pagesize){
	if(pagesize==undefined)pagesize=-1;
	var ps = rs.AbsolutePosition;
	var k=0;
	while(!rs.eof && (k<pagesize || pagesize==-1)){
		k++;
		var tmp__=new Object();
		for(var i=0;i<rs.fields.count;i++){
			tmp__[rs.fields(i).Name]=rs.fields(i).value;
		}
		this.LIST__.push(tmp__);
		rs.MoveNext();
	}
	try{
		rs.AbsolutePosition=ps;
	}catch(ex){}
	
};
__Obj__.prototype.AddNew=function(){
	this.LIST__.push(new Object());
	return this.LIST__.length-1;
};

__Obj__.prototype.Set=function(key,value,index){
	if(index==undefined)index=this.LIST__.length-1;
	if(index<0 || index> this.LIST__.length-1)return;
	this.LIST__[index][key]=value;
};
__Obj__.prototype.Reset = function(){
	this.index=-1;
};
__Obj__.prototype.Eof = function(){
	return this['LIST__'].length==0 || this.index+1>=this['LIST__'].length;	
};
__Obj__.prototype.Read = function(name){
	name = name ||"";
	this.index++;
	if(name=="" || name==undefined){
		return this['LIST__'][this.index];
	}else{
		return this['LIST__'][this.index].getter__(name);
	}
};
__Obj__.prototype.assign=function(name){
	Mo.Assign(name,this);
	return this;
};
__Obj__.prototype.getjson=function(dateformat){
	var ret="[";
	dateformat = dateformat || "yyyy-MM-dd HH:mm:ss";
	while(!this.Eof()){
		var D = this.Read();	
		ret+="{"
		for(var i in D){
			if(!D.hasOwnProperty(i))continue;
			var val = D.getter__(i)
			var ty = typeof val;
			ret+="\"" + i + "\":";
			if(ty=="number"){
				ret+=val+",";
			}else if(ty=="date"){
				ret+="\"" + F.formatdate(val,dateformat) + "\",";
			}else if(ty=="string"){
				ret+="\"" + F.jsEncode(val) + "\",";
			}else{
				if(!isNaN(val)){
					ret+=val+",";
				}else{
					ret+="\"" +val + "\",";
				}
			}
		}
		if(ret.substr(ret.length-1,1)==",")ret = ret.substr(0,ret.length-1);
		ret+="},";
	}
	if(ret.substr(ret.length-1,1)==",")ret = ret.substr(0,ret.length-1);
	ret+="]";
	return ret;
};
Object.prototype.isset__=function(key){
	return this[key]!=undefined;
};
Object.prototype.getter__=function(key){
	if(key==undefined)key="";
	return this[key]!=undefined?this[key]:"";
};
</script>