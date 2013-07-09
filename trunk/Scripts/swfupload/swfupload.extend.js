if (typeof(SWFUpload) === "function") {
	SWFUpload.extend("CheckFiles");
	SWFUpload.extend("SetFileStatus");
	SWFUpload.extend("SetPostParam");
	SWFUpload.extend("RemovePostParam");
	SWFUpload.extendCallback("fileChecked","file_check_handler");
	SWFUpload.extendCallback("fileQueueStart","file_queue_start_handler");
}

//上传处理函数
var HANDLERS={};
HANDLERS.stoped=false;

//上传开始出错时调用
HANDLERS.upload_start_error_handler = function(err){
	if(err=="busy")Util("Upload_Processer","正在上传其他 文件，请稍候！");	
	if(err=="empty")Util("Upload_Processer","您没有选择任何文件，请先选择需要上传的文件！");	
};

//队列文件开始时运行（可以执行一些清理或初始化工作）
HANDLERS.file_queue_start_handler = function(length){
	
};

//队列文件出错时运行
HANDLERS.file_queue_error_handler = function(file, errorCode, message){
	var errorName='';
	switch (errorCode)
	{
		case SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED:
			errorName = "只能同时上传 "+this.settings.file_upload_limit+" 个文件，超过限制数的文件已忽略";
			break;
		case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
			errorName = "选择的文件超过了当前大小限制："+this.settings.file_size_limit +"，文件已被忽略";
			break;
		case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
			errorName = "零大小文件，文件已被忽略";
			break;
		case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
			errorName = "文件扩展名必需为："+this.settings.file_types_description+" ("+this.settings.file_types+")";
			break;
		default:
			errorName = "未知错误";
			break;
	}	
	alert((file!=null?file.name+" ":"")+errorName);
};
//文件成功队列后运行
HANDLERS.file_queued_handler = function(file){};

//文件队列结束后执行
HANDLERS.file_dialog_complete_handler = function(){
	//if(this.Status().queued>0)Util("fileUploaded","已成功添加" + this.Status().queued + "个文件。");
	this.startUpload();	
};

//单个文件上传前运行（可以执行单文件初始化以及post参数的设置和移除等）
//这里设置了两个post参数
HANDLERS.upload_start_handler = function(file){
	//this.SetPostParam("fileid",file.id);
	//this.SetPostParam("filesize",file.size);
};

HANDLERS.upload_error_handler = function(file, errorCode, message,serverdata,args){
	if(errorCode==SWFUpload.UPLOAD_ERROR.FILE_CANCELLED){
		//Util("m_"+file.id,"已取消上传！")
	}else if(errorCode==SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED){
		HANDLERS.stoped=true;
		//Util("fileUploaded","上传已停止。");
		//Util("m_"+file.id,"已停止上传");
	}else{
		Util("Upload_Processer","上传失败！原因：" +message);
	}
};

HANDLERS.upload_progress_handler = function(file, bytesComplete, bytesTotal,uploadTotalBytes,totalBytes,speed,timeused){
	var percent = (bytesComplete*100/bytesTotal).toFixed(2)
	Util("Upload_Processer","进度：" + percent + "%，速度：" + Util.formatBytes(speed) + "/秒，已用时：" + Util.timeString(parseFloat(timeused/1000),true));
	if(bytesComplete>=bytesTotal)Util("Upload_Processer","进度：100%，正在保存文件...");
};

//上传成功后调用，这里使用json作为返回数据
HANDLERS.upload_success_handler = function(file, serverData,timeused){
	var File = null;
	try{
		eval("File = (" + serverData + ");");
	}catch(ex){}
	if(!File)return"";
	if(File.err){
		this.SetFileStatus(file.id,SWFUpload.FILE_STATUS.ERROR);
		this.uploadError(file,500,File.msg);
		return "";
	}
	Util("Upload_Processer","上传成功。用时：" + Util.timeString(parseFloat(timeused/1000),true))
	Uploaded.apply(File,[]);
};
HANDLERS.upload_complete_handler = function(file,usageextend){
	if(usageextend!==true && !HANDLERS.stoped)this.startUpload();	
};

HANDLERS.file_check_handler = function(file,args){};

HANDLERS.debug_handler = function(msg){alert(msg);};


//组件
var Util=function(selecter,html){
	var obj = Util.$(selecter);
	if(html!=undefined)obj.innerHTML=html;
	return obj;
};
Util.C=function(tagname,id,html){
	var obj = document.createElement(tagname);
	if(id!=undefined)obj.id=id;
	if(html!=undefined)obj.innerHTML=html;
	return obj;
};
Util.D=function(chd){
	if(!chd.parentNode)return null;
	return chd.parentNode.removeChild(chd);
};
Util.$=function(selecter){
	if(typeof selecter!="string"){
		return selecter;
	}
	try{
		return document.getElementById(selecter);
	}catch(ex){
		return null;
	}
};
Util.formatBytes=function(bytes) {
	var s = ['Byte', 'KB', 'MB', 'GB', 'TB', 'PB'];
	var e = Math.floor(Math.log(bytes)/Math.log(1024));
	return (bytes/Math.pow(1024, Math.floor(e))).toFixed(2)+" "+s[e];
};

Util.timeString=function(used,cn){
	if(cn!==true)cn=false;
	var hours = Math.floor(used/3600);
	used = used - hours * 3600;
	var minutes = Math.floor(used/60);
	var seconds = (used % 60).toFixed(2);
	var ret = seconds+(cn?"秒":"");
	if(minutes>0){
		ret = minutes + (cn?"分":":") + ret;
	}
	if(hours>0){
		ret = hours + (cn?"小时":":") + ret;
	}
	return ret;
};
