<script language="jscript" runat="server">
function Record__(){
	return new __Record__(arguments);	
}
function __Record__(args){
	this.table={};
	this.pk="";
	if(args.length % 2==0){
		for(var i=0;i<args.length-1;i+=2){
			this.set(args[i],args[i+1]);
		}
	}
}
__Record__.prototype.frompost=function(pk){
	pk = pk ||"";
	F.post();
	for(var i in F.post__){
		if(i.length>2 && i.substr(i.length-2)==":i")continue;
		if(!F.post__.hasOwnProperty(i))continue;
		if(i.toLowerCase()!=pk.toLowerCase()){
			this.set(i,F.post__[i]);
		}else{
			this.pk = F.post__[i];
		}
	}
	return this;
};
__Record__.prototype.set=function(name,value,type){
	type=type||"string";
	delete this.table[name];
	this.table[name]={"value":value,"type":type}
	return this;
};
__Record__.prototype.get=function(name){
	if(this.table[name]!==undefined)return this.table[name].value;
	return "";
};
__Record__.prototype.remove=function(){
	for(var i=0;i<arguments.length;i++){
		delete this.table[arguments[i]];
	}
	return this;
};

__Record__.prototype.clear=function(){
	delete this.table;
	this.table={};
	return this;
};
__Record__.prototype.assign=function(name){
	var obj = {};
	for(var i in this.table){
		if(!this.table.hasOwnProperty(i))continue;
		obj[i]=	this.table[i].value;
	}
	Mo.assign(name,obj);
	return this;
};
</script>
