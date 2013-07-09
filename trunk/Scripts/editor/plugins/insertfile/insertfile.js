/*******************************************************************************
* KindEditor - WYSIWYG HTML Editor for Internet
* Copyright (C) 2006-2011 kindsoft.net
*
* @author Roddy <luolonghao@gmail.com>
* @site http://www.kindsoft.net/
* @licence http://www.kindsoft.net/license.php
*******************************************************************************/
function DoSearchAttachment(first){
	if(first!==true)first = false;
	if((typeof window.___attachment___)=="object"){
		if(window.___attachment___.length<=0)return;
		var obj = null;
		try{obj=document.getElementById("attachment_list");}catch(ex){}
		if(obj==null)return;
		while(obj.lastChild){obj.removeChild(obj.lastChild);}
		var j=0;
		if(!first){
			var searchtext = document.getElementById("keTitle").value;
			if(searchtext=="")return;
			for(var i=0;i<window.___attachment___.length;i++){
				if(window.___attachment___[i].name.toLowerCase().indexOf(searchtext.toLowerCase())>=0){j++;
					var att=window.___attachment___[i];
					var div = document.createElement("div");
					div.innerHTML=[j+"-" + att.name,
					"&nbsp; &nbsp; <a href=\"javascript:void(0)\" onclick=\"document.getElementById('keTitle').value='" + att.name + "';document.getElementById('keUrl').value='/?m=home&a=attachment&id=" + att.id + "';\">选择</a>",
					].join("");
					obj.appendChild(div);
				}
			}
		}else{
			for(var i=0;i<window.___attachment___.length && j<6;i++){
				j++;
				var att=window.___attachment___[i];
				var div = document.createElement("div");
				div.innerHTML=[j+"-" + att.name,
				"&nbsp; &nbsp; <a href=\"javascript:void(0)\" onclick=\"document.getElementById('keTitle').value='" + att.name + "';document.getElementById('keUrl').value='/?m=home&a=attachment&id=" + att.id + "';\">选择</a>",
				].join("");
				obj.appendChild(div);
			}			
		}
	}
}
KindEditor.plugin('insertfile', function(K) {
	var self = this, name = 'insertfile',
		allowFileUpload = K.undef(self.allowFileUpload, true),
		allowFileManager = K.undef(self.allowFileManager, false),
		formatUploadUrl = K.undef(self.formatUploadUrl, true),
		uploadJson = K.undef(self.uploadJson,'/?m=admin&a=upload&auto=true'),
		extraParams = K.undef(self.extraFileUploadParams, {}),
		filePostName = K.undef(self.filePostName, 'filedata'),
		lang = self.lang(name + '.');
	self.plugin.fileDialog = function(options) {
		var fileUrl = K.undef(options.fileUrl, 'http://'),
			fileTitle = K.undef(options.fileTitle, ''),
			clickFn = options.clickFn;
		var html = [
			'<div style="padding:20px;">',
			'<div class="ke-dialog-row">',
			'<label for="keUrl" style="width:60px;">' + lang.url + '</label>',
			'<input type="text" id="keUrl" name="url" class="ke-input-text" style="width:160px;" /> &nbsp;',
			'<input type="button" class="ke-upload-button" value="' + lang.upload + '" /> &nbsp;',
			'<span class="ke-button-common ke-button-outer">',
			'<input type="button" class="ke-button-common ke-button" name="viewServer" value="' + lang.viewServer + '" />',
			'</span>',
			'</div>',
			//title
			'<div class="ke-dialog-row">',
			'<label for="keTitle" style="width:60px;">' + lang.title + '</label>',
			'<input type="text" id="keTitle" class="ke-input-text" name="title" value="" style="width:160px;" /> <a href="javascript:void(0)" onclick="DoSearchAttachment();">'+ lang.search +'</a></div>',
			'<div id="attachment_list" style="height:120px; overflow-y:scroll">输入关键字可以搜索附件</div></div>',
			//form end
			'</form>',
			'</div>'
			].join('');
		var dialog = self.createDialog({
			name : name,
			width : 450,
			height:280,
			title : self.lang(name),
			body : html,
			yesBtn : {
				name : self.lang('yes'),
				click : function(e) {
					var url = K.trim(urlBox.val()),
						title = titleBox.val();
					if (url == 'http://' || K.invalidUrl(url)) {
						urlBox[0].focus();
						return;
					}
					if (K.trim(title) === '') {
						title = url;
					}
					clickFn.call(self, url, title);
				}
			}
		}),
		div = dialog.div;

		var urlBox = K('[name="url"]', div),
			viewServerBtn = K('[name="viewServer"]', div),
			titleBox = K('[name="title"]', div);

		if (allowFileUpload) {
			var uploadbutton = K.uploadbutton({
				button : K('.ke-upload-button', div)[0],
				fieldName : filePostName,
				url : K.addParam(uploadJson, 'dir=file'),
				extraParams : extraParams,
				afterUpload : function(data) {
					dialog.hideLoading();
					if (data.error === 0) {
						var url ="/?m=home&a=attachment&id=" +data.max;
						if (formatUploadUrl) {
							url = K.formatUrl(url, 'absolute');
						}
						urlBox.val(url);
						titleBox.val(data.src);
						if (self.afterUpload) {
							self.afterUpload.call(self, url, data, name);
						}
					} else {
						alert(data.message);
					}
				},
				afterError : function(html) {
					dialog.hideLoading();
					self.errorDialog(html);
				}
			});
			uploadbutton.fileBox.change(function(e) {
				dialog.showLoading(self.lang('uploadLoading'));
				uploadbutton.submit();
			});
		} else {
			K('.ke-upload-button', div).hide();
		}
		viewServerBtn.hide();
		urlBox.val(fileUrl);
		titleBox.val(fileTitle);
		urlBox[0].focus();
		urlBox[0].select();
	};
	self.clickToolbar(name, function() {
		self.plugin.fileDialog({
			clickFn : function(url, title) {
				var html = '下载地址：<a href="' + url + '" data-ke-src="' + url + '" target="_blank">' + title + '</a>';
				self.insertHtml(html).hideDialog().focus();
			}
		});
		Ajax({
			url:"/?m=admin&a=attachment_list_json",
			dataType:"json",
			succeed:function(o){
				window["___attachment___"]=o;
				DoSearchAttachment(true);
			}
		});
	});
});
