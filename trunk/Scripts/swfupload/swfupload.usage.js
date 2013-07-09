if (typeof(SWFUpload) === "function") {
	SWFUpload.handler = {};
	SWFUpload.handler.stoped=false;
	SWFUpload.handler.onlyOne=false;
	SWFUpload.prototype.initSettings = (function (oldInitSettings) {
		return function () {
			if (typeof(oldInitSettings) === "function") {
				oldInitSettings.call(this, []);
			}
			this.processer={};
			this.ensureDefault = function (settingName, defaultValue) {
				this.settings[settingName] = (this.settings[settingName] == undefined) ? defaultValue : this.settings[settingName];
			};
			this.ensureDefault("auto",false);
			this.ensureDefault("file_check_handler",null);
			this.ensureDefault("file_queue_start_handler",null);
			delete this.ensureDefault;
			this.processer.totalBytes=0;
			this.processer.uploadTotalBytes=0;
			this.processer.uploadFileBytes=0;
			this.processer.speed={
				lasttime:null,lastbytes:0,value:0,start:null,end:null,time_used:0
			};
			this.processer.user_file_queued_handler = this.settings.file_queued_handler;
			this.processer.user_upload_start_handler = this.settings.upload_start_handler;
			this.processer.user_upload_error_handler = this.settings.upload_error_handler;
			this.processer.user_upload_progress_handler = this.settings.upload_progress_handler;
			this.processer.user_upload_success_handler = this.settings.upload_success_handler;
			
			this.settings.file_queued_handler = SWFUpload.handler.fileQueuedHandler;
			this.settings.upload_start_handler = SWFUpload.handler.uploadStartHandler;
			this.settings.upload_error_handler = SWFUpload.handler.uploadErrorHandler;
			this.settings.upload_progress_handler = SWFUpload.handler.uploadProgressHandler;
			this.settings.upload_success_handler = SWFUpload.handler.uploadSuccessHandler;
			this.settings.upload_complete_handler = SWFUpload.handler.uploadCompleteHandler;
			this.processer.start_upload=SWFUpload.prototype.startUpload;
			SWFUpload.prototype.startUpload=SWFUpload.handler.startUpload;
		};
	})(SWFUpload.prototype.initSettings);
	
	SWFUpload.handler.startUpload=function(A,B){
		if(this.Status().busy){
			if(typeof this.settings.upload_start_error_handler=="function")this.settings.upload_start_error_handler.apply(this,['busy']);	
		}
		if(this.Status().queued>0){
			this.setButtonDisabled();
			SWFUpload.handler.stoped=false;
			this.processer.speed.start=new Date();
			this.processer.start_upload.apply(this,[A]);
			if(B===true)SWFUpload.handler.onlyOne=true;
		}else{
			if(typeof this.settings.upload_start_error_handler=="function")this.settings.upload_start_error_handler.apply(this,['empty']);
		}
	};
	
	SWFUpload.handler.uploadStartHandler = function (file) {
		this.processer.speed.lasttime = new Date();
		this.processer.speed.lastbytes = 0;
		this.processer.speed.start = new Date();
		if (typeof this.processer.user_upload_start_handler === "function") return this.processer.user_upload_start_handler.call(this, file);
	};
	
	SWFUpload.handler.fileQueuedHandler = function (file) {
		this.processer.totalBytes+=file.size;
		if (typeof this.processer.user_file_queued_handler === "function") return this.processer.user_file_queued_handler.call(this, file);
	};
	
	SWFUpload.handler.uploadErrorHandler = function (file, errorCode, message) {
		if(errorCode==SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED)SWFUpload.handler.stoped=true;
		if (typeof this.processer.user_upload_error_handler === "function") return this.processer.user_upload_error_handler.call(this, file, errorCode, message);
	};
	SWFUpload.handler.uploadProgressHandler = function (file, bytesComplete, bytesTotal) {
		if(this.processer.speed.lasttime==null){
			this.processer.speed.lasttime = new Date();
			this.processer.speed.lastbytes = bytesComplete;
		}else{
			var time = 	(new Date())-this.processer.speed.lasttime;
			var bytes = bytesComplete-this.processer.speed.lastbytes;
			if(time>0 && bytes>=0){
				bytes = (bytes/time) * 1000;
				this.processer.speed.value = bytes;
			}
		}
		this.processer.speed.end=new Date();
		var time_used=0;
		if(this.processer.speed.end!=null && this.processer.speed.start!=null)time_used = (this.processer.speed.end-this.processer.speed.start)
		this.processer.speed.time_used=time_used;
		this.processer.uploadTotalBytes=this.processer.uploadFileBytes+bytesComplete;
		if (typeof this.processer.user_upload_progress_handler === "function") return this.processer.user_upload_progress_handler.call(this, file, bytesComplete, bytesTotal,this.processer.uploadTotalBytes,this.processer.totalBytes,this.processer.speed.value,time_used);
	};
	
	SWFUpload.handler.uploadSuccessHandler = function (file, serverData) {
		this.processer.speed.end=new Date();
		var time_used=0;
		if(this.processer.speed.end!=null && this.processer.speed.start!=null)time_used = (this.processer.speed.end-this.processer.speed.start)
		this.processer.uploadFileBytes+=file.size;
		if (typeof this.processer.user_upload_success_handler === "function") return this.processer.user_upload_success_handler.call(this, file, serverData,time_used);
	};
	SWFUpload.handler.uploadCompleteHandler = function (file) {
		if(this.Status().queued>0 && !SWFUpload.handler.stoped && !SWFUpload.handler.onlyOne){
			this.processer.start_upload.apply(this);
		}else{
			this.setButtonDisabled(false);
			SWFUpload.handler.onlyOne = false;
		}
		if (typeof this.processer.user_upload_complete_handler === "function") return this.processer.user_upload_complete_handler.call(this, file, true);
	};
}