MuraFileBrowser = {

	config: {
			resourcepath: "User_Assets",
			directory: "",
			height: 600,
			selectMode: 0,
			endpoint: '',
			completepath: false,
			displaymode: 2, // 1: grid, 2: list
			selectCallback() {}
	}
	
	, prettify( tgt ) {
	
	}
	
	, render( config ) {
		var self = this;
		var target =  "_" + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
	
		var folderState=window.sessionStorage.getItem('mura_fbfolder');
		
		if(folderState){
				try{
					folderState=JSON.parse(folderState);
					if(folderState.resourcepath != MuraFileBrowser.config.resourcepath || folderState.siteid != Mura.siteid){
						window.sessionStorage.setItem( 'mura_fbfolder','');
					}
				}catch(e){}
		}
	
		this.config=Mura.extend(config,this.config);
		this.endpoint =  Mura.apiEndpoint + "filebrowser/";
		this.container = Mura("#MuraFileBrowserContainer");
		this.container.append("<div id='" + target + "'><component :is='currentView'></component></div>");
		this.target = target;
		this.main(); // Delegating to main()
		
		Mura.loader()
			.loadcss(
	//      Mura.corepath + '/vendor/codemirror/codemirror.css',
				Mura.corepath + '/vendor/cropper/cropper.min.css'
			)
			.loadjs(
				Mura.adminpath + '/assets/js/vue.min.js',
				Mura.corepath + '/vendor/cropper/cropper.min.js',
				// Mura.corepath + '/vendor/codemirror/addon/formatting/formatting.js',
				// Mura.corepath + '/vendor/codemirror/mode/htmlmixed/htmlmixed.js',
			function() {
				self.mountbrowser();
			 } ) ;
	
			 this.getURLVars();
	}
	
	, main( config ) {
		var self = this;
	}
	
	, onError(msg) {
		console.log( msg );
	}
	
	, getURLVars() {
			var vars = {};
			var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
					vars[key] = value;
			});
	
			if(vars['CKEditorFuncNum'])
				this.callback = vars['CKEditorFuncNum'];
	}
	
	, validate() {
		return true;
	}

	, getGroups(currentFile,onSuccess,onError) {      
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'grouppermissions',
			{
				resourcePath:this.config.resourcepath,
				currentFile:currentFile
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess(response);
			},
			//fail
			function(response) {
				onError(response);
			}
		);
	
	} 


	, updatePermissions(groups,haspermissions,currentFile,onSuccess,onError) {      
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'updatepermissions',
			{
				resourcePath:this.config.resourcepath,
				groups:groups,
				haspermissions:haspermissions,
				currentFile:currentFile
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess(response);
			},
			//fail
			function(response) {
				onError(response);
			}
		);
	
	} 

	, moveFile( currentFile,source,destination,onSuccess ) {
	
		//var baseurl = this.endpoint + "/move?directory=" + source + "&destination=" + destination + "&resourcepath=" + this.config.resourcepath + "&filename=" + currentFile.fullname;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'move',
			{
				directory:source,
				destination:destination,
				resourcepath:this.config.resourcepath,
				filename:currentFile.fullname,
				completepath:this.config.completepath
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess(response);
			},
			//fail
			function(response) {
				this.onError(response);
			}
		);
	
	}
	
	, getChildDirectory( dir,onSuccess,fileViewer) {
		var baseurl = this.endpoint + "/childdir?directory=" + dir + "&resourcepath=" + this.config.resourcepath + "&completepath=" + this.config.completepath;
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.get( baseurl )
			.then(
				//success
				function(response) {
					onSuccess(response);
				},
				//fail
				function(response) {
					this.onError(response);
				}
			);
	}
	
	
	, getEditFile( directory,currentFile,onSuccess) {
		var dir = directory == undefined ? "" : directory;
		var baseurl = this.endpoint + "/edit?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath+ "&completepath=" + this.config.completepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.get( baseurl )
			.then(
				//success
				function(response) {
					onSuccess(response);
				},
				//fail
				function(response) {
					this.onError(response);
				}
			);
	}
	
	, doDeleteFile( directory,currentFile,onSuccess,onError) {
		var dir = directory == undefined ? "" : directory;
		//var baseurl = this.endpoint + "/delete?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'delete',
			{
				directory:dir,
				resourcepath:this.config.resourcepath,
				filename:currentFile.fullname
			},
			'post'
		)
			.then(
				//success
				function(response) {
					onSuccess(response);
				},
				//fail
				function(response) {
					this.onError(response);
				}
			);
	}
	
	, doDuplicateFile( directory,currentFile,onSuccess,onError) {
		var dir = directory == undefined ? "" : directory;
		//var baseurl = this.endpoint + "/duplicate?directory=" + dir + "&resourcepath=" + this.config.resourcepath;
		this.isDisplayContext = "";
	
		if(!this.validate()) {
			return error("No Access");
		}

		Mura.getEntity('filebrowser').invokeWithCSRF(
			'duplicate',
			{
				directory:dir,
				resourcepath:this.config.resourcepath,
				filename:currentFile.fullname,
				completepath:this.config.completepath
			},
			'post'
		).then(
				//success
				function(response) {
					onSuccess();
				},
				//fail
				function(response) {
					return;
					this.onError(response);
				}
		);
	}
	
	, doUpdateContent( directory,currentFile,content,onSuccess,onError) {
		var dir = directory == undefined ? "" : directory;
		//var baseurl = this.endpoint + "/update?directory=" + dir + "&filename=" + currentFile.fullname + "&resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'update',
			{
				directory:dir,
				resourcepath:this.config.resourcepath,
				filename:currentFile.fullname,
				content:content,
				completepath:this.config.completepath
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess(response);
			},
			//fail
			function(response) {
				this.onError(response);
			}
		);
	}
	
	, doRenameFile( directory,currentFile,onSuccess,onError) {
		var dir = directory == undefined ? "" : directory;
		//var baseurl = this.endpoint + "/rename?directory=" + dir + "&filename=" + currentFile.fullname + "&name=" + currentFile.name + "&resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'rename',
			{
				directory:dir,
				resourcepath:this.config.resourcepath,
				filename:currentFile.fullname,
				name:currentFile.name,
				completepath:this.config.completepath
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess();
			},
			//fail
			function(response) {
				this.onError();
			}
		);
	}
	
	, doNewFolder( directory,newfolder,onSuccess ) {
		var dir = directory == undefined ? "" : directory;
		//var baseurl = this.endpoint + "/addfolder?directory=" + dir + "&name=" + newfolder + "&resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'addfolder',
			{
				directory:dir,
				resourcepath:this.config.resourcepath,
				name:newfolder,
				completepath:this.config.completepath
			},
			'post'
		).then(
			//success
			function(response) {
				onSuccess();
			},
			//fail
			function(response) {
				onError();
			}
		);
	}
	
	, loadDirectory( directory,pageindex,onSuccess,onError,filterResults,filterDepth,sortOn,sortDir,itemsper ) {
		var self = this;
	
		var dir = directory == undefined ? "" : directory;
	
		var baseurl = this.endpoint + "browse?directory=" + dir + "&resourcepath=" + this.config.resourcepath + "&completepath=" + this.config.completepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		if(pageindex) {
			baseurl += "&pageindex=" + pageindex;
		}
	
		if(itemsper) {
			baseurl += "&itemsperpage=" + itemsper;
		}

		baseurl += "&sorton=" + sortOn;
		baseurl += "&sortdir=" + sortDir;

		if(filterResults.length) {
			baseurl += "&filterResults=" + filterResults;
		}
	
		if(filterDepth == 1) {
			baseurl += "&filterDepth=" + 1;
		}
	
		Mura.get( baseurl )
			.then(
				//success
				function(response) {
					onSuccess(response);
				},
				//fail
				function(response) {
					onError(response);
				}
			);
	}
	
	, loadBaseDirectory( onSuccess,onError,directory ) {
		var self = this;
	
		var dir = directory ? directory : this.config.directory;
	
		var baseurl = this.endpoint + "/browse" + "?resourcepath=" + this.config.resourcepath + "&directory=" + dir + "&settings=1&completepath=" + this.config.completepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		Mura.get( baseurl )
			.then(
				//success
				function(response) {
					onSuccess(response);
				},
				//fail
				function(response) {
					onError(response);
				}
			);
	}
	
	, doUpload( formData,success,fail ) {
		var self = this;
		//var baseurl = this.endpoint + "/upload" + "?resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		formData.append('resourcepath',this.config.resourcepath);
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'upload',
			formData,
			'post'
		).then(
			function doSuccess( response ) {
				success( response );
			},
			function doonError( response ) {
				this.onError(response);
			}
		);
	}
	, rotate( currentFile,direction,success,error) {
		var self = this;
		//var baseurl = this.endpoint + "rotate" + "?resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		var formData = {};
	
		formData.file = JSON.parse(JSON.stringify(currentFile));
		formData.direction = direction;
		formData.resourcepath=this.config.resourcepath;
		formData.completepath=this.config.competepath;
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'rotate',
			formData,
			'post'
		).then(
			function doSuccess( response ) {
				success( response );
			},
			function doonError( response ) {
				this.onError(response);
			}
		);
	
	}
	
	, performResize( currentFile,dimensions,success,error ) {
		var self = this;
		//var baseurl = this.endpoint + "resize" + "?resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		var formData = {};
	
		formData.file = JSON.parse(JSON.stringify(currentFile));
		formData.dimensions = dimensions;
		formData.resourcepath=this.config.resourcepath;
		formData.completepath=this.config.competepath;
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'resize',
			formData,
			'post'
		).then(
			function doSuccess( response ) {
				success( response );
			},
			function doonError( response ) {
				this.onError(response);
			}
		);
	}
	
	, doSaveImage( currentFile,formData,success,error ) {
		var self = this;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		formData.append('file',JSON.stringify(currentFile));
		formData.append('resourcepath',this.config.resourcepath);
		formData.append('completepath',this.config.completepath);
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'saveImage',
			formData,
			'post'
		).then(
			function doSuccess( response ) {
				success( response );
			},
			function doonError( response ) {
				this.onError(response);
			}
		);
	}
	
	
	, performCrop( currentFile,success,error ) {
		var self = this;
		//var baseurl = this.endpoint + "processCrop" + "?resourcepath=" + this.config.resourcepath;
	
		if(!this.validate()) {
			return error("No Access");
		}
	
		var formData = {};
	
		// bounding container
		var container = document.getElementById('imagediv');
		// crop rect
		var cropRect = document.getElementById('croprectangle');
		// crop rect bounds
		var rect = cropRect.getBoundingClientRect();
		// original image dimensions
		var source = {
				width: currentFile.info.width,
				height: currentFile.info.height
		};
	
		// size of container
		var size = {
			width: container.clientWidth,
			height: container.clientHeight
		};
		// crop rect size
		var crop = {
				x: 0,
				y: 0,
				width: 0,
				height: 0
		};
	
		crop.x = cropRect.offsetLeft;
		crop.y = cropRect.offsetTop;
		crop.width = rect.width;
		crop.height = rect.height;
	
		formData.file = JSON.parse(JSON.stringify(currentFile));
		formData.crop = crop;
		formData.size = size;
	
		formData.resourcepath=this.config.resourcepath;
		formData.completepath=this.config.completepath;
	
		Mura.getEntity('filebrowser').invokeWithCSRF(
			'processCrop',
			formData,
			'post'
		).then(
			function doSuccess( response ) {
				success( response );
			},
			function doonError( response ) {
				this.onError(response);
			}
		);
	}
	
	, crop( canvas,clear ) {
	
		if(clear == true) {
			var cropRect = document.getElementById('croprectangle');
			if(cropRect)
				cropRect.parentNode.removeChild(cropRect);
			return;
		}
	
		var corners = {
				x: 0,
				y: 0,
				startX: 0,
				startY: 0
		};
		var element = null;
	
		function setCornerPosition(e) {
				var ev = e || window.event; //Moz || IE
				var rect = canvas.getBoundingClientRect();
	
				if (ev.pageX) { //Moz
						if(e.target != document.getElementById('imagediv')) {
							corners.x = e.offsetX + e.target.offsetLeft;
							corners.y = e.offsetY + e.target.offsetTop;
						}
						else {
							corners.x = ev.offsetX;
							corners.y = ev.offsetY;
						}
				} else if (ev.clientX) { //IE
						corners.x = ev.offsetX;
						corners.y = ev.offsetY;
				}
			};
	
			canvas.onmousemove = function (e) {
				if (element !== null) {
					setCornerPosition(e);
	//        element.pointer = 'none';
					element.style.width = Math.abs(corners.x - corners.startX) + 'px';
					element.style.height = Math.abs(corners.y - corners.startY) + 'px';
					element.style.left = (corners.x - corners.startX < 0) ? corners.x + 'px' : corners.startX + 'px';
					element.style.top = (corners.y - corners.startY < 0) ? corners.y + 'px' : corners.startY + 'px';
				}
			}
	
			canvas.onmouseup = function( e ) {
				element = null;
				canvas.style.cursor = "default";
			}
	
			canvas.onmousedown = function (e) {
				if (element !== null) {
				}
				else {
					var cropRect = document.getElementById('croprectangle');
					if(cropRect)
						cropRect.parentNode.removeChild(cropRect);
	
					setCornerPosition(e);
					corners.startX = corners.x;
					corners.startY = corners.y;
	
					var rect = canvas.getBoundingClientRect();
	
					element = document.createElement('div');
					element.className = 'rectangle';
					element.id = 'croprectangle';
					element.style.width = Math.abs(corners.x - corners.startX) + 'px';
					element.style.height = Math.abs(corners.y - corners.startY) + 'px';
					element.style.left = (corners.x - corners.startX < 0) ? corners.x + 'px' : corners.startX + 'px';
					element.style.top = (corners.y - corners.startY < 0) ? corners.y + 'px' : corners.startY + 'px';
	
					canvas.appendChild(element);
					canvas.style.cursor = "crosshair";
				}
		}
	}
	
	, mountbrowser() {
		var self = this;
	
		Vue.directive('click-outside', {
			bind: function (el, binding, vnode) {
				el.clickOutsideEvent = function (event) {
					// here I check that click was outside the el and his childrens
					if (!(el == event.target || el.contains(event.target))) {
						// and if it did, call method provided in attribute value
						vnode.context[binding.expression](event);
					}
				};
				document.body.addEventListener('click', el.clickOutsideEvent)
			},
			unbind: function (el) {
				document.body.removeEventListener('click', el.clickOutsideEvent)
			},
		});
	
		Vue.component('contextmenu', {
			props: ["currentFile","menuy","menux","settings"],
			template: `
			<div id="newContentMenu" class="addNew fileviewer-menu" v-bind:style="{  'white-space': 'initial !important' }">
					<ul id="newContentOptions" :style="{ 'white-space': 'initial !important' }">
						<li v-if="checkIsFile() && checkSelectMode()"><a href="#" @click.prevent="selectFile()"><i class="mi-check"></i>{{settings.rb.filebrowser_select}}</a></li>
						<li v-if="checkIsFile() && checkFileEditable()"><a href="#" @click.prevent="editFile()"><i class="mi-pencil"></i>{{settings.rb.filebrowser_edit}}</a></li>
						<li v-if="checkIsFile() && checkImageType()"><a href="#" @click.prevent="viewFile()"><i class="mi-image"></i>{{settings.rb.filebrowser_view}}</a></li>
						<li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="moveFile()"><i class="mi-move"></i>{{settings.rb.filebrowser_move}}</a></li>
						<li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="duplicateFile()"><i class="mi-copy"></i>{{settings.rb.filebrowser_duplicate}}</a></li>
						<li v-if="checkIsFile() || checkImageType()"><a href="#" @click.prevent="copyUrl()"><i class="mi-copy"></i>{{settings.rb.filebrowser_copyurl}}</a></li>
						<li><a href="#" @click.prevent="renameFile()"><i class="mi-edit"> {{settings.rb.filebrowser_rename}}</i></a></li>
						<li v-if="!checkIsFile() && checkIsAdmin() && checkIsUserArea()"><a href="#" @click="setPermissions()"><i class="mi-users"> {{settings.rb.filebrowser_permissions}}</i></a></li>
						<li v-if="checkIsFile()"><a href="#" @click="downloadFile()"><i class="mi-download"> {{settings.rb.filebrowser_download}}</i></a></li>
						<li class="delete"><a href="#" @click.prevent="deleteFile()"><i class="mi-trash"> {{settings.rb.filebrowser_delete}}</i></a></li>
					</ul>
				</div>
			`,
			data() {
					return {
						posx: 0,
						posy: 0
					};
			}
			, computed: {
	
			}
			, mounted() {
		//It is necessary to change the overflow property of the modal
		//because the contextmenu stays inside the modal and is not possible
		//to see all  options and we want to avoid that
		//******only when you deploy site bundle******
		if (document.getElementById('MuraFileBrowserContainer')){
		  if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')){
			var modal = document.getElementsByClassName('ui-dialog')[0];
			modal.style.overflow = 'initial';
		  }
		}
		if(window.gridMode) {
		  var a              = document.getElementById('fileitem-'+window.index);
		  var div            = a.parentElement.parentElement.parentElement;
		  div.style.overflow = 'visible';
		  var menu           = this.$el;
		  menu.className     = 'addNew fileviewer-menu-grid';
		  div.appendChild(menu);
		  var menuHeight = menu.getBoundingClientRect().height;
		  var divBottom  = div.getBoundingClientRect().bottom;
		  if( (divBottom + menuHeight ) > window.innerHeight ) {
			menu.style.bottom = '0px';
		  }else {
			menu.style.top = div.getBoundingClientRect().height + 'px';
		  }

		}else {
		  var a        = document.getElementById('fileitem-'+window.index);
		  var td       = a.parentElement;
		  var tr       = td.parentElement;
		  tr.className = 'fileviewer-selected-row';
		  window.tr    = tr;
		  var menu     = this.$el;
		  td.appendChild(menu);
		  var tdBottom   = td.getBoundingClientRect().bottom;
		  var menuHeight = menu.getBoundingClientRect().height;
		  var trHeight   = tr.getBoundingClientRect().height;
		  
		  if( (tdBottom + menuHeight ) > window.innerHeight ) {
			var bottom = trHeight ;
			menu.style.marginBottom = '0';
			menu.style.bottom =  bottom + 'px';
		  }else {
			var height = trHeight;
			menu.style.top =  height + 'px';

		  }
		}
			}
			, methods: {
				compstyle() {
					this.posx = this.menux;
					this.posy = this.menuy;
					return ;
				}
				, getTop() {
					return this.menuy + window.pageYOffset;
				}
			 , selectFile() {
					if(MuraFileBrowser.config.selectMode == 1) {
						window.opener.CKEDITOR.tools.callFunction(self.callback,fileViewer.currentFile.url);
						window.close();
					}
					else {
						return MuraFileBrowser.config.selectCallback( fileViewer.currentFile );
					}
				}
				,copyUrl() {
					var url = fileViewer.currentFile.url;
					var obj = document.createElement('textarea');
					obj.id = "::urlcopy";
	//        obj.style.cssText = 'display: none';
					document.getElementById("MuraFileBrowserContainer").appendChild(obj);
					var temp = document.getElementById("::urlcopy");
					temp.value = url;
					temp.select();
					document.execCommand("copy");
					temp.remove();
					fileViewer.isDisplayContext = "";
	//        console.log("Copied the text: " + temp.value);
	
	
				}
				, setPermissions() {
					fileViewer.isDisplayWindow = "PERM";
				}
				, moveFile() {
					fileViewer.isDisplayWindow = "MOVE";
				}
				, editFile() {
					fileViewer.editFile(this.successEditFile);
				}
				, duplicateFile() {
					fileViewer.isDisplayWindow = '';
					fileViewer.duplicateFile(fileViewer.refresh, fileViewer.displayError);
				}
				, viewFile() {
					fileViewer.isDisplayWindow = "VIEW";
					fileViewer.viewFile();
				}
				, successEditFile( response ) {
					this.currentFile.content = response.data.content;
					fileViewer.isDisplayWindow = "EDIT";
				}
				, renameFile() {
					fileViewer.isDisplayWindow = "RENAME";
				}
				, downloadFile() {
						window.open(fileViewer.currentFile.url, '_blank');
				}
				, deleteFile() {
					fileViewer.isDisplayWindow = "DELETE";
				}
				, checkSelectMode() {
						return fileViewer.checkSelectMode();
				}
				, checkFileEditable() {
						return fileViewer.checkFileEditable();
				}
				, checkImageType() {
					return fileViewer.checkImageType();
				}
				, checkIsFile() {
					return fileViewer.checkIsFile();
				}
				, checkIsAdmin() {
					return fileViewer.isAdmin;
				}
				, checkIsUserArea() {
					return fileViewer.checkIsUserArea();
				}
			}
		});
	
		Vue.component('actionwindow', {
			props: ["isDisplayWindow","foldertree","currentFile","currentIndex","error","settings"],
			template: `
				<div>
					<div id="actionwindow-wrapper" class="editwindow" v-if="isDisplayWindow=='EDIT'">
						<editwindow :settings="settings" v-if="isDisplayWindow=='EDIT'" :currentFile="currentFile"></editwindow>
					</div>
					<div v-else id="actionwindow-wrapper">
						<renamewindow :settings="settings" v-if="isDisplayWindow=='RENAME'" :currentFile="currentFile"></renamewindow>
						<permwindow :settings="settings" v-if="isDisplayWindow=='PERM'" :foldertree="foldertree" :currentFile="currentFile"></permwindow>
						<movewindow :settings="settings" v-if="isDisplayWindow=='MOVE'" :foldertree="foldertree" :currentFile="currentFile"></movewindow>
						<addfolderwindow :settings="settings" v-if="isDisplayWindow=='ADDFOLDER'" :currentFile="currentFile"></addfolderwindow>
						<downloadwindow :settings="settings" v-if="isDisplayWindow=='DOWNLOAD'" :currentFile="currentFile"></downloadwindow>
						<deletewindow :settings="settings" v-if="isDisplayWindow=='DELETE'" :foldertree="foldertree" :currentFile="currentFile"></deletewindow>
						<errorwindow :settings="settings" v-if="isDisplayWindow=='ERROR'" :currentFile="currentFile" :error="error"></errorwindow>
					</div>
				</div>
			`,
			data() {
					return {};
			},
			methods: {
			}
		});

		Vue.component('permwindow', {
			props: ['groups','currentFile','groupperms','hasfolderpermission','loading','isperm','settings'],
			template: `
				<div class="ui-dialog dialog-info actionwindow-formwrapper" id="permissionswindow">
					<div class="block block-constrain">
						<div class="block-content">
							<div class="mura-header">
								<h1>{{settings.rb.filebrowser_permissions}}</h1>
								<label>{{settings.rb.filebrowser_forfolder}}: <span>{{currentFile.name}}</span></label>
							</div>
							<div v-if="isperm" class="mura-control-group" id="permissionswrapper">
								<div v-bind:class="{ isContainerDisabled: this.hasfolderpermission }">
									<label class="radio inline">
										<input type="radio" v-model="hasfolderpermission" :value="0" name="hasfolderpermission" :checked="hasfolderpermission"> {{settings.rb.filebrowser_inherit}}
									</label>
								</div>
								<div v-bind:class="{ isContainerDisabled: !this.hasfolderpermission }">
									<label class="radio inline">
										<input type="radio" v-model="hasfolderpermission" :value="1" name="hasfolderpermission" :checked="hasfolderpermission"> {{settings.rb.filebrowser_custom}}
									</label>
									<div v-if="hasfolderpermission" id="permissionscontainer">
										<table class="mura-table-grid">
											<thead>
												<tr>
													<th>
													{{settings.rb.filebrowser_allow}}
													</th>
													<th>
													{{settings.rb.filebrowser_deny}}
													</th>
													<th class="var-width">
													{{settings.rb.filebrowser_group}}
													</th>
												</tr>
											</thead>
											<tbody>
												<tr v-for="group in groups">
													<td>
														<input type="radio" :id="group.userid" v-model="group.perm" value="editor" :name="group.userid" :checked="group.perm == 'editor'">
													</td>
													<td>
														<input type="radio" :id="group.userid" v-model="group.perm" value="deny" :name="group.userid" :checked="group.perm == 'deny'">
													</td>
													<td class="var-width">
														{{group.groupname}}
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>               
							<div class="buttonset">
								<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
								<button v-if="isperm" @click="updatePermissions()"><i class="mi-check"></i>{{settings.rb.filebrowser_save}}</button>
							</div>
						</div>
					</div>
				</div>
			`,
			data() {
					return {
						filename: ''
					};
			},
			methods: {
				updatePermissions() {
					fileViewer.spinnermodal = 1;
					MuraFileBrowser.updatePermissions(this.groups,this.hasfolderpermission,this.currentFile,this.permissionsUpdated,this.error);   
					fileViewer.isDisplayWindow = '';
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
				, setGroups(response) {
					this.loading = 0;
					this.hasfolderpermission = parseInt(response.hasfolderpermission);

					fileViewer.spinnermodal = 0;
					this.groups = response.groups;
					this.members = response.members;
				}
				, permissionsUpdated( response ) {
					fileViewer.spinnermodal = 0;
					fileViewer.isDisplayWindow = '';
				}
				, error( response ) {
					fileViewer.spinnermodal = 0;
					this.isperm = 0;
				}
			},
			mounted() {
				this.loading = 1;
				this.isperm = 1;
				fileViewer.spinnermodal = 1;
				this.groups = [];
				this.hasfolderpermission = 0;
				fileViewer.isDisplayContext = 0;
				MuraFileBrowser.getGroups(this.currentFile,this.setGroups,this.error);
			}
		});
		
		Vue.component('movewindow', {
			props: ["currentFile","foldertree","settings"],
			template: `
			<div class="ui-dialog dialog-info actionwindow-formwrapper actionwindow-long">
				<div class="block block-constrain">
					<div class="block-content">
						<div class="mura-header">
							<h1>{{settings.rb.filebrowser_movefile}}</h1>
						</div>
						<div class="mura-control-group">
							<label>{{settings.rb.filebrowser_name}}: <span>{{currentFile.fullname}}</span></label>
							<label>{{settings.rb.filebrowser_location}}: <span>{{this.$root.resourcepath}}</span>{{currentFile.subfolder}}</label>
						</div>
						<div class="mura-control-group">
							<label>
								{{settings.rb.filebrowser_moveto}}:
								<span><a @click="setDirDepth(-1)" class="folder-item">{{this.$root.resourcepath}}</a></span><span v-for="(item,index) in sourcefolders" @click="setDirDepth(index)">/<a class="folder-item">{{item}}</a></span>
								<span>
									<select v-if="childFolders.length" v-model="folderName">
										<option v-if="item.length" v-for="item in childFolders" :value="item">/{{item}}</option>
									</select>
								</span>
							</label>
						</div>
	<!--
						<div class="mura-control-group">
							<label>
							{{settings.rb.filebrowser_destination}}:
								<input type="text" v-model="destinationFolder" style="width: 80%"></input>
								<span class="small">{{invalid}}</span>
							</label>
						</div>
	-->
						<div class="buttonset">
							<button @click="moveFile()"><i class="mi-check"></i>{{settings.rb.filebrowser_move}}</button>
							<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
						</div>
					</div>
				</div>
			</div>
			`,
			data() {
					return {
						resourcename: '',
						folderName: '',
						sourcefolders: [],
						childFolders: [],
						invalid: ''
					};
			},
			watch: {
				/*
				destinationFolder(val) {
					// delay for typing
					setTimeout(() => {
						var tf = this.destinationFolder;
	
						if(val == tf && this.folderPath != '')
							MuraFileBrowser.getChildDirectory(this.destinationFolder,this.updateDirectory,fileViewer);
						}, 1000);
				}
				,
				*/
				folderName(val) {
					if(this.folderPath != '') {
						this.sourcefolders.push(this.folderName);
	
						var destination = "";
	
						for(i in this.sourcefolders) {
							destination += "/" + this.sourcefolders[i];
						}
						this.childFolders = [];
						MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
					}
				}
			},
			methods: {
				moveFile() {
					var source = this.currentFile.subfolder;
					var destination = "";
		
					for(i in this.sourcefolders) {
						destination += "/" + this.sourcefolders[i];
					}
	
					fileViewer.spinnermodal = 1;
					MuraFileBrowser.moveFile(this.currentFile,source,destination,this.fileMoved);
				}
				, fileMoved() {
					fileViewer.isDisplayWindow = '';
					fileViewer.refresh();
				}
				, updateDirectory(result) {
					console.log('updateDirectory');
					console.log(result);
					if(parseInt(result.data.valid)) {
						this.invalid = "";
						this.childFolders = result.data.folders;
					}
					else {
						this.childFolders = [];
						this.invalid = "(This does not appear to be a valid directory)";
					}
				}
				, setDirDepth(val) {
					val +=1;
					this.sourcefolders.length = val;
					var destination = "";
	
					for(i in this.sourcefolders) {
						destination += "/" + this.sourcefolders[i];
					}
					this.childFolders = [];
					MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
			},
			mounted() {
				this.sourcefolders = this.currentFile.subfolder.split('/');
				this.filename = this.currentFile.name;
				fileViewer.isDisplayContext = 0;
	
				var destination = "";

				for(i in this.sourcefolders) {
					destination += "/" + this.sourcefolders[i];
				}

				this.sourcefolders = this.sourcefolders.filter(function (el) {
					return el !== '';
				});
	
				MuraFileBrowser.getChildDirectory(destination,this.updateDirectory,fileViewer);
				switch(MuraFileBrowser.config.resourcepath) {
					case "Site_Files":
						this.resourcename = "Site Files";
						break;
					case "Application_Root":
						this.resourcename = "Application Root";
						break;
					default:
						this.resourcename = "User Assets";
				}
	
	
			}
		});
	
		Vue.component('renamewindow', {
			props: ["currentFile","settings"],
			template: `
				<div class="ui-dialog dialog-info actionwindow-formwrapper">
					<div class="block block-constrain">
						<div class="block-content">
							<div class="mura-header">
								<h1 v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_renamefolder}}</h1>
								<h1 v-else>{{settings.rb.filebrowser_renamefile}}</h1>
							</div>
							<div class="mura-control-group">
								<label v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_foldername}}: <span>{{currentFile.name}}</span></label>
								<label v-else>{{settings.rb.filebrowser_filename}}: <span>{{currentFile.name}}</span><span v-if="currentFile.ext != currentFile.name">.{{currentFile.ext}}</span></label>
								<label v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_newname}}: <span><input type="text" @keyup="cleanName" v-model="filename"></input></span></label>
								<label v-else>{{settings.rb.filebrowser_newname}}: <span><input type="text" @keyup="cleanName" v-model="filename"></input></span><span v-if="currentFile.ext != currentFile.name">.{{currentFile.ext}}</span></label>
							</div>
							<div class="buttonset">
								<button @click="updateRename()"><i class="mi-check"></i>{{settings.rb.filebrowser_save}}</button>
								<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
							</div>
						</div>
					</div>
				</div>
			`,
			data() {
					return {
						filename: ''
					};
			},
			methods: {
				cleanName( a ) {
					this.filename = this.filterName( this.filename );
				},
				filterName( str ) {
					str = str.replace(/[^a-zA-Z\d-/\s\.\w/]+/gi, '-');
					str = str.replace(/-{2,}/g, '-')
					return str;
				},
				updateRename() {
					this.cleanName();
					this.currentFile.name = this.filename.trim();
					if(this.currentFile.name.slice(-1) === '-') {
						this.currentFile.name = this.currentFile.name.slice(0,-1);
						this.currentFile.name.trim();
					}
					fileViewer.renameFile();
	
					fileViewer.isDisplayWindow = '';
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
			},
			mounted() {
				this.filename = this.currentFile.name;
				fileViewer.isDisplayContext = 0;
			}
		});
	
		Vue.component('errorwindow', {
			props: ['error','settings'],
			template: `
				<div class="ui-dialog dialog-warning actionwindow-formwrapper">
					<div class="block block-constrain">
						<div class="block-content">
							<div class="mura-header">
								<h1>{{settings.rb.filebrowser_error}}</h1>
							</div>
							<h4>{{error}}</h4>
							<div class="buttonset">
								<button @click="cancel()"><i class="mi-close"></i>{{settings.rb.filebrowser_close}}</button>
							</div>
						</div>
					</div>
				</div>
			`,
			data() {
					return {
						filename: ''
					};
			},
			methods: {
				cancel() {
					fileViewer.isDisplayWindow = '';
				}
			}
		});
	
		Vue.component('addfolderwindow', {
			props: ["currentFile","settings"],
			template: `
				<div class="ui-dialog dialog-info actionwindow-formwrapper">
					<div class="block block-constrain">
						<div class="block-content">
							<div class="mura-header">
								<h1>{{settings.rb.filebrowser_addfolder}}</h1>
							</div>
							<div class="mura-control-group">
								<label>{{settings.rb.filebrowser_foldername}}: <span><input type="text" @keyup="cleanName" v-model="foldername"></input></span></label>
							</div>
							<div class="buttonset">
								<button @click="newFolder()"><i class="mi-check"></i>{{settings.rb.filebrowser_save}}</button>
								<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
							</div>
						</div>
					</div>
				</div>
			`,
			data() {
					return {
						foldername: ''
					};
			},
			methods: {
				cleanName( a ) {
					this.foldername = this.filterName( this.foldername );
				},
				filterName( str ) {
					str = str.replace(/[^a-zA-Z\d-/\s\.\w/]+/gi, '-');
					str = str.replace(/-{2,}/g, '-')
					return str;
				},
				newFolder() {
					this.cleanName();
					this.foldername = this.foldername.trim();
					if(this.foldername.slice(-1) === '-') {
						this.foldername= this.foldername.slice(0,-1);
						this.foldername = this.foldername.trim();
					}
					fileViewer.newFolder(this.foldername);
	
					fileViewer.isDisplayWindow = '';
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
			},
			mounted() {
	
			}
		});
	
		Vue.component('gallerywindow', {
			props: ["currentFile","currentIndex","total","settings"],
			template: `
			<div class="fileviewer-modal" v-if="currentFile.ext.toLowerCase()=='svg' || currentFile.info.width">
				<div class="fileviewer-gallery" v-click-outside="closewindow">
					<div class="fileviewer-image" :style="{ 'background-image': 'url(' + encodeURI(currentFile.url) + '?' + Math.ceil(Math.random()*100000) + ')' }"></div>
					<div class="actionwindow-left" @click="lastimage"><i class="mi-caret-left"></i></div>
					<div class="actionwindow-right" @click="nextimage"><i class="mi-caret-right"></i></div>
					<div class="fileviewer-gallery-menu mura-actions">
						<label class="fileinfo"> {{currentFile.subfolder}}/{{currentFile.fullname}} ({{currentFile.size}}kb <span v-if="checkImageType()">{{currentFile.info.width}}x{{currentFile.info.height}}</span>)</label>
						<div class="form-actions">
							<a v-if="checkImageType() && checkSelectMode()" class="btn mura-primary" @click="selectFile()"><i class="mi-check"></i>{{settings.rb.filebrowser_select}}</a>
							<a v-if="checkImageType() && currentFile.ext.toLowerCase() !='svg'" class="btn mura-primary" @click="editImage()"><i class="mi-crop"></i>{{settings.rb.filebrowser_editimage}}</a>
							<a v-if="checkFileEditable()" class="btn mura-primary" @click="editFile()"><i class="mi-pencil"></i>{{settings.rb.filebrowser_edit}}</a>
							<a class="btn mura-primary" @click="renameFile()"><i class="mi-edit"></i>{{settings.rb.filebrowser_rename}}</a>
							<a v-if="checkIsFile()" class="btn mura-primary" @click="downloadFile()"><i class="mi-download"></i>{{settings.rb.filebrowser_download}}</a>
							<a class="btn" @click="deleteFile()"><i class="mi-trash"></i>{{settings.rb.filebrowser_delete}}</a>
							<a class="btn" @click="closewindow()"><i class="mi-times"></i>{{settings.rb.filebrowser_close}}</a>
						</div>
					</div>
				</div>
			</div>
			`,
			data() {
					return {};
			}
			, mounted() {
	
				if(fileViewer.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
					var dir = "";
				 
					for(var i=0;i<fileViewer.foldertree.length;i++) {
						dir = dir + "/" + fileViewer.foldertree[i];
					}

					var dirRegex = /.*\//i;
					var depth = fileViewer.currentFile.url.match(dirRegex);
	
					Mura.getEntity('filebrowser').invoke(
						'getImageInfo',
						{
							directory:dir,
							subfolder:fileViewer.currentFile.subfolder,
							resourcepath:MuraFileBrowser.config.resourcepath,
							filename:fileViewer.currentFile.fullname
						}).then(function(info){
							fileViewer.currentFile.info=info;
						})
				}
		
				this.$root.isDisplayContext = 0;
			 
			}
			, methods: {
				lastimage() {
					fileViewer.previousFile(1);
				}
				, nextimage() {
					fileViewer.nextFile(1);
				}
				, closewindow( event ) {
					this.$root.isDisplayWindow = "";
				}
				, renameFile() {
					fileViewer.isDisplayWindow = "RENAME";
				}
				, editImage() {
					fileViewer.isDisplayWindow = "EDITIMAGE";
				}
							, selectFile() {
									 if(MuraFileBrowser.config.selectMode == 1) {
											 window.opener.CKEDITOR.tools.callFunction(self.callback,fileViewer.currentFile.url);
											 window.close();
									 }
									 else {
											 return MuraFileBrowser.config.selectCallback( fileViewer.currentFile );
									 }
							 }
				, downloadFile() {
						window.open(fileViewer.currentFile.url, '_blank');
				}
				, deleteFile() {
					fileViewer.isDisplayWindow = "DELETE";
				}
				, checkSelectMode() {
						return fileViewer.checkSelectMode();
				}
				, checkFileEditable() {
						return fileViewer.checkFileEditable();
				}
				, checkImageType() {
					return fileViewer.checkImageType();
				}
				, checkIsFile() {
					return fileViewer.checkIsFile();
				}
	
			}
		});
	
		Vue.component('imageeditwindow', {
			props: ["currentFile","currentIndex","total","settings"],
			template: `
			<div class="fileviewer-modal">
				<imageeditmenu class="fileviewer-gallery" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex" v-click-outside="closewindow"></imageeditmenu>
			</div>
			`, data() {
				return {
				};
			}
			, mounted() {
			}
			, methods: {
				closewindow( event ) {
					this.$root.isDisplayWindow = "";
				}
			}
		});
	
		Vue.component('imageeditmenu', {
			props: ["currentFile","currentIndex","imageEditTarget","settings"],
			template: `
				 <div>
				 <div v-if="this.editmode  == 'RESIZE'" class="fileviewer-image" id="imagediv" :style="{ 'background-image': 'url(' + encodeURI(currentFile.url) + '?' + Math.ceil(Math.random()*100000) + ')' }"></div>
				 <div v-if="this.editmode == ''" class="fileviewer-image-edit"><img style="min-height: 100%" id="fileviewer-image-editable" :src="currentFile.url"></div>
					<div class="fileviewer-edit-menu mura-actions">
						<label class="fileinfo">{{currentFile.fullname}} ({{currentFile.size}}kb {{currentFile.info.width}}x{{currentFile.info.height}})</label>
						<!-- MAIN -->
						<div class="form-actions" v-if="editmode==''">
	
							<a class="btn mura-primary" @click="resize()"><i class="mi-expand"></i>{{settings.rb.filebrowser_resize}}</a>
							<a class="btn mura-primary" @click="saveImage()"><i class="mi-check"></i>{{settings.rb.filebrowser_confirm}}</a>
							<a class="btn" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</a>
	
							<div class="form-actions-toolbar">
	
								<div class="btn-group d-flex flex-nowrap">
									<a class="btn mura-primary" :title="settings.rb.filebrowser_zoomin" @click="zoomIn()"><i class="mi-search-plus"></i></a>
									<a class="btn mura-primary" :title="settings.rb.filebrowser_zoomout" @click="zoomOut()"><i class="mi-search-minus"></i></a>
									<a class="btn mura-primary" :title="settings.rb.filebrowser_rotateright" @click="rotateRight()"><i class="mi-rotate-right"></i></a>
									<a class="btn mura-primary" :title="settings.rb.filebrowser_rotateleft" @click="rotateLeft()"><i class="mi-rotate-left"></i></a>
								</div>
	
								<div class="btn-group d-flex flex-nowrap">
									<a class="btn mura-primary" :title="settings.rb.filebrowser_move" @click="moveMode()"><i class="mi-move"></i></a>
									<a class="btn mura-primary" :title="settings.rb.filebrowser_crop" @click="cropMode()"><i class="mi-crop"></i></a>
								</div>
	
								<div class="btn-group d-flex flex-nowrap">
									<label v-for="aspect in settings.aspectratios" class="btn mura-primary" :title="titleaspectratios(settings.rb.filebrowser_aspectratio,aspect[0],aspect[1])" :class="{ 'active': cropaspect == aspect[2] }">
										<input type="radio" class="sr-only" id="cropaspect1" name="cropaspect" v-model="cropaspect" :value="aspect[2]">
										<span class="docs-tooltip" data-toggle="tooltip" title="" :data-original-title="titleaspectratios(settings.rb.filebrowser_aspectratio,aspect[0],aspect[1])">
											{{aspect[0]}}:{{aspect[1]}}
											</label>
										</span>
									</label>
									<label class="btn mura-primary" :title="settings.rb.filebrowser_aspectratiofixed" :class="{ 'active': cropaspect == fixedwidth }">
										<input type="radio" class="sr-only" id="cropaspect5" name="cropaspect" v-model="cropaspect" :value="fixedwidth">
										<span class="docs-tooltip" data-toggle="tooltip" title="" :data-original-title="settings.rb.filebrowser_aspectratiofixed">
										{{settings.rb.filebrowser_fixed}}
										</span>
									</label>
									<label class="btn mura-primary" :title="settings.rb.filebrowser_aspectratiofree" :class="{ 'active': cropaspect == NaN }">
										<input type="radio" class="sr-only" id="cropaspect5" name="cropaspect" v-model="cropaspect" value="NaN">
										<span class="docs-tooltip" data-toggle="tooltip" title="" :data-original-title="settings.rb.filebrowser_aspectratiofree">
										{{settings.rb.filebrowser_free}}
										</span>
									</label>
								</div>
							</div> <!-- /.form-actions-toolbar -->
	
						</div>
						<!-- RESIZE -->
						<div class="form-actions" v-if="editmode=='RESIZE'">
							<label>{{settings.rb.filebrowser_width}}: <input class="numeric" :disabled="resizedimensions.aspect == 'height'" name="resize-width" @keyup="changedAspectWidth" v-model="resizedimensions.width"></label>
							<label>{{settings.rb.filebrowser_height}}: <input class="numeric" :disabled="resizedimensions.aspect == 'width'" name="resize-height" @keyup="changedAspectHeight" v-model="resizedimensions.height"></label>
							<label>{{settings.rb.filebrowser_aspect}}:
								<select name="resize-aspect" v-model="resizedimensions.aspect" @change="changedAspect">
									<option value="none">{{settings.rb.filebrowser_resizenone}}</option>
									<option value="height">{{settings.rb.filebrowser_resizeheight}}</option>
									<option value="width">{{settings.rb.filebrowser_resizewidth}}</option>
									<option value="within">{{settings.rb.filebrowser_resizewithin}}</option>
								</select>
							</label>
							<a class="btn mura-primary" @click="confirmResize()"><i class="mi-check"></i>{{settings.rb.filebrowser_confirm}}</a>
							<a class="btn" @click="cancelResize()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</a>
						</div>
					</div>
					<div class="preview-window" v-if="this.showpreview">
						<div class="preview-mast"></div>
						<div class="preview-image">
						</div>
					</div>
				</div>
			`
			, data() {
					return {
						editmode: '',
						resizedimensions: {
							width: 0,
							height: 0,
							backup: 0,
							aspect: 'none',
						},
						showpreview: 0,
						cropaspect: "4:3",
						fixedwidth: 1
					};
			}
			, watch: {
				cropaspect( val ) {
					this.setAspectRatio(val);
				}
			}
			, mounted() {
				this.resizedimensions.width = this.currentFile.info.width;
				this.resizedimensions.height = this.currentFile.info.height;
				this.$root.isDisplayContext = 0;
				this.editmode = '';
				this.fixedwidth = Math.ceil( this.currentFile.info.width / this.currentFile.info.height * 10000 ) / 10000;
				this.initCropper();
	
			}
			, methods: {
				titleaspectratios(title,a,b) {
					return title + ":" + a + "/" + b;
				}
				, updateData( data ) {
					this.imageEditCropMode = data;
				}
				, changedAspect() {
				}
				, changedAspectWidth() {
					if(this.resizedimensions.aspect == 'width' && this.resizedimensions.width > 0) {
						this.resizedimensions.height = Math.ceil(this.resizedimensions.width/this.currentFile.info.width * this.currentFile.info.height);
					}
				}
				, changedAspectHeight() {
					if(this.resizedimensions.aspect == 'height' && this.resizedimensions.height > 0) {
						this.resizedimensions.width = Math.ceil(this.resizedimensions.height/this.currentFile.info.height * this.currentFile.info.width);
					}
				}
				, destroyCropper() {
					imageEditTarget.destroy();
				}
				, initCropper() {
					const image = document.getElementById('fileviewer-image-editable');
					var initaspect = this.cropaspect;
	
					imageEditTarget = new Cropper(image, {
						aspectRatio: initaspect,
						crop(event) {
							/*
							console.log(event.detail.x);
							console.log(event.detail.y);
							console.log(event.detail.width);
							console.log(event.detail.height);
							console.log(event.detail.rotate);
							console.log(event.detail.scaleX);
							console.log(event.detail.scaleY);
							*/
		//          fileViewer.$refs.imageeditmenuref.updateData(event.detail.width);
						},
					});
				}
				, saveImage() {
					var self = this;
					var dir = "";
	
					for(var i=0;i<fileViewer.foldertree.length;i++) {
						dir = dir + "/" + fileViewer.foldertree[i];
					}
	
					imageEditTarget.getCroppedCanvas().toBlob(function(blob) {
						var newImg = document.createElement('img'),url = URL.createObjectURL(blob);
	
						newImg.onload = function() {
							// no longer need to read the blob so it's revoked
							URL.revokeObjectURL(url);
						};
	
						var formData = new FormData();
						formData.append('croppedImage', blob, self.currentFile.fullname);
						formData.append('dir', dir);
	
						newImg.src = url;
						MuraFileBrowser.doSaveImage( self.currentFile,formData,self.fileSaved );
					});
				}
				, fileSaved() {
					this.$root.isDisplayWindow = "VIEW";
					this.editmode = '';
					fileViewer.refresh();
				}
				, zoomIn() {
					imageEditTarget.zoom(0.1);
				}
				, zoomOut() {
					imageEditTarget.zoom(-0.1);
				}
				, setAspectRatio( val ) {
					imageEditTarget.setAspectRatio(val);
				}
				, rotateLeft() {
					imageEditTarget.rotate(-15);
				}
				, rotateRight() {
					imageEditTarget.rotate(15);
				}
				, resize() {
					this.editmode = "RESIZE";
					this.destroyCropper();
				}
				, cropMode() {
						imageEditTarget.setDragMode('crop');
				}
				, moveMode() {
					imageEditTarget.setDragMode('move');
				}
				, closewindow( event ) {
					this.$root.isDisplayWindow = "";
				}
				, cancel( event ) {
					this.destroyCropper();
					this.$root.isDisplayWindow = "VIEW";
					this.editmode = '';
				}
				, confirmResize() {
					MuraFileBrowser.performResize(this.currentFile,this.resizedimensions,this.resizeComplete);
				}
				, resizeComplete() {
					this.$root.refresh();
					this.$root.isDisplayWindow = "";
				}
				, cancelResize( event ) {
					this.editmode = '';
					this.$nextTick(function () {
						this.initCropper();
					});
				}
			}
		});
	
		Vue.component('deletewindow', {
			props: ["currentFile","foldertree","settings"],
			template: `
			<div class="ui-dialog dialog-warning actionwindow-formwrapper">
				<div class="block block-constrain">
					<div class="block-content">
						<div class="mura-header">
							<h1 v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_deletefolder}}</h1>
							<h1 v-else>{{settings.rb.filebrowser_deletefile}}</h1>
						</div>
						<div class="mura-control-group">
							<label v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_areyousurefolder}}?</label>
							<label v-else>{{settings.rb.filebrowser_areyousurefile}}?</label>
						</div>
						<div class="mura-control-group">
							<label v-if="parseInt(currentFile.isfolder)">{{settings.rb.filebrowser_folder}}: <span>{{this.$root.resourcepath}}</span><span v-for="(item, index) in foldertree">/{{item}}</span>/<span>{{currentFile.fullname}}</span></label>
							<label v-else>{{settings.rb.filebrowser_file}}: <span>{{this.$root.resourcepath}}</span><span>{{currentFile.subfolder}}/{{currentFile.fullname}}</span></label>
							<label>{{settings.rb.filebrowser_modified}}: <span>{{currentFile.lastmodified.substring(0, currentFile.lastmodified.lastIndexOf(" ") )}}</span></label>
						</div>
						<div class="buttonset">
							<button @click="doDelete()"><i class="mi-check"></i>{{settings.rb.filebrowser_delete}}</button>
							<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
						</div>
					</div>
				</div>
			</div>
			`,
			data() {
					return {};
			},
			methods: {
				doDelete() {
					fileViewer.deleteFile(  fileViewer.refresh, fileViewer.displayError );
					fileViewer.isDisplayWindow = '';
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
			},
			mounted() {
				fileViewer.isDisplayContext = 0;
			}
		});
	
		Vue.component('editwindow', {
			props: ["currentFile","settings"],
			template: `
			<div class="ui-dialog dialog-nobg actionwindow-formwrapper">
				<div class="block block-constrain">
					<div class="block-content">
						<div class="mura-header">
							<h1>{{settings.rb.filebrowser_editfile}}</h1>
						</div>
						<div class="mura-control-group">
							<label>{{settings.rb.filebrowser_filename}}: <span>{{currentFile.name}}.{{currentFile.ext}}</span></label>
						</div>
						<textarea id="contenteditfield" class="editwindow" v-model="filecontent"></textarea>
						<div class="buttonset">
							<button @click="updateContent()"><i class="mi-check"></i>{{settings.rb.filebrowser_update}}</button>
							<button class="mura-secondary" @click="cancel()"><i class="mi-ban"></i>{{settings.rb.filebrowser_cancel}}</button>
						</div>
					</div>
				</div>
			</div>
			`,
			data() {
					return {
						filecontent: ''
					};
			},
			methods: {
				updateContent() {
					fileViewer.updateContent(this.filecontent);
					fileViewer.isDisplayWindow = '';
				}
				, cancel() {
					fileViewer.isDisplayWindow = '';
				}
				, selectAll() {
					editor.commands["selectAll"](this.editor);
				},
				autoFormat() {
					/*
					editor.setCursor(0,0);
					CodeMirror.commands["selectAll"](editor);
					editor.autoFormatRange(editor.getCursor(true), editor.getCursor(false));
					editor.setSize(500, 500);
					editor.setCursor(0,0);
					*/
				}
			}
			, mounted() {
				this.filecontent = this.currentFile.content;
				/*
						editor = CodeMirror.fromTextArea(document.getElementById('contenteditfield'), {
						value: this.currentFile.content,
						mode:  "html",
						extraKeys: {"Ctrl-Space": "autocomplete"},
						lineNumbers: true,
						autoCloseTags: true,
						indentWithTabs: true,
						theme: 'monokai'
					}
				);
	
				editor.getDoc().setValue(this.currentFile.content);
				this.autoFormat();
				ed = this;
				editor.on('change', function(cm) {
					ed.filecontent = cm.getValue();
				});
	*/
			}
		});
	
		Vue.component('appbar', {
			props: ["links","isbottomnav","response","itemsper","location","showbar","displaymode","sortOn","sortDir","settings"],
			template: `
				<div :class="[showbar ? 'filewindow-appbar' : 'filewindow-hideappbar']">
						<modemenu :settings="settings" v-if="location" :displaymode="displaymode" :sortOn="sortOn" :sortDir="sortDir"></modemenu>
						<pagemenu :settings="settings" v-if="isbottomnav" :response="response"></pagemenu>
						<navmenu :settings="settings" :links="links" :response="response" :itemsper="itemsper"></navmenu>
				</div>
			`,
			data() {
				return {
				}
			},
			computed: {
	
			},
			methods: {
				applyPage(goto) {
						var pageindex = 1;
	
						if(goto == 'last') {
							pageindex = parseInt(fileViewer.response.totalpages);
						}
						else if(goto == 'next') {
							pageindex = parseInt(fileViewer.response.pageindex) + 1;
						}
						else if(goto == 'previous') {
							pageindex = parseInt(fileViewer.response.pageindex) - 1;
						}
	
						this.$parent.refresh('',pageindex)
				}
				, applyItemsPer() {
					this.$parent.itemsper = this.itemsper;
				}
			}
	
		});
	
		Vue.component('modemenu', {
			props: ["links","isbottomnav","response","itemsper","displaymode","sortDir","sortOn","settings"],
			template: `
				<div class="filewindow-modemenu">
					<div class="btn-group btn-group-toggle" data-toggle="buttons">
						<a class="btn btn-secondary" v-bind:class="{ highlight: viewmode == 1 }" @click="switchMode(1)">
							<i class="mi-th" :title="settings.rb.filebrowser_gridview"></i>
						</a>
						<a class="btn btn-secondary" v-bind:class="{ highlight: viewmode == 2 }" @click="switchMode(2)">
							<i class="mi-bars" :title="settings.rb.filebrowser_listview"></i>
						</a>
					</div>
					<a @click="newFolder" class="btn btn-secondary btn-new-folder">
						<i class="mi-folder-open" :title="settings.rb.filebrowser_addfolder"></i>
					</a>
					<input class="filebrowser-filter" :placeholder="settings.rb.filebrowser_search" v-model="filterResults" v-on:input="filterChange">
					<label :title="settings.rb.filebrowser_includesubfolders" id="filebrowser-filter-switch" class="css-input switch switch-sm switch-primary inline"><input type="checkbox" value="1" name="filebrowser-filter-depth" v-model="filterDepth" v-on:change="filterChange"><span></span><span class="subfolders-label" id="filebrowser-filter-switch-label">{{settings.rb.filebrowser_includesubfolders}}</span></label>
				<!--	<div class="filebrowser-grid-sorting" v-if="displaymode == 1">
						<select name="sortOn" v-model="sortOn" @change="sortChange" class="itemsper">
							<option value="name">{{settings.rb.filebrowser_name}}</option>
							<option value="size">{{settings.rb.filebrowser_size}}</option>
							<option value="modified">{{settings.rb.filebrowser_modified}}</option>
						</select>
						<select name="sortDir" v-model="sortDir" @change="sortChange" class="itemsper">
							<option value="ASC">&#9660;</option>
							<option value="DESC">&#9650;</option>
						</select>
					</div> -->
				 </div>
			`,
			data() {
					return {
						viewmode: this.$root.displaymode,
						filterResults: '',
						filterDepth: 0,
						timeout: undefined
					};
			},
			methods: {
				switchMode(mode) {
	
					var fdata = {
						displaymode: JSON.parse(JSON.stringify(mode))
					}
	
					Mura.createCookie('mura_fbdisplaymode',JSON.stringify(fdata),1000);
	
					this.$root.displaymode = this.viewmode = mode;
				}
				, newFolder() {
					fileViewer.isDisplayWindow = 'ADDFOLDER';
				}
				, sortChange() {
					var sortObj = {
						sortDir: this.sortDir,
						sortOn: this.sortOn
					};
					Mura.createCookie('mura_fbsort',JSON.stringify(sortObj),1000);
					this.$root.sortOn = this.sortOn;
					this.$root.sortDir = this.sortDir;
					this.$root.refresh();
				}				
				, filterChange(e,value) {
					// dropdown change for recursive
					if(e.type == 'change') {
						this.$root.filterResults = this.filterResults;
						this.$root.filterDepth = this.filterDepth;
						if(this.$root.filterResults != '') {
							window.clearTimeout(this.timeout);
							this.timeout = window.setTimeout(this.$root.refresh, 1);
						}
					}
					else {
					// timeout to allow for typing and not fire immediately
					if(this.timeout)
							window.clearTimeout(this.timeout);   
							this.$root.filterResults = this.filterResults;
							this.$root.filterDepth = this.filterDepth;
							this.timeout = window.setTimeout(this.$root.refresh, 500);
						}
					}
			}
		});

		
	
		Vue.component('pagemenu', {
			props: ["links","isbottomnav","response","itemsper","settings"],
			template: `
				<div v-if="response.totalpages" class="filewindow-pageindex">
					{{settings.rb.filebrowser_page}} {{response.pageindex}} {{settings.rb.filebrowser_of}} {{response.totalpages}}
				</div>
			`,
			mounted() {
			},
			methods: {
			}
		});


		Vue.component('navmenu', {
			props: ["links","isbottomnav","response","itemsper","settings"],
			template: `
				<div class="filewindow-navmenu">
					<ul class="pagination" v-if="response.totalitems>=10">
						<li class="paging" v-if="links && (links.previous || links.next)">
							<a href="#" v-if="links.first" @click.prevent="applyPage('first')">
								<i class="mi-angle-double-left"></i>
							</a>
							<a v-else class="disabled">
								<i class="mi-angle-double-left"></i>
							</a>
						</li>
						<li class="paging" v-if="links && (links.previous || links.next)">
							<a href="#" v-if="links.previous" @click.prevent="applyPage('previous')">
								<i class="mi-angle-left"></i>
							</a>
							<a v-else class="disabled">
								<i class="mi-angle-left"></i>
							</a>
						</li>
						<li class="paging" v-if="links && (links.previous || links.next)">
							<a href="#" v-if="links.next" @click.prevent="applyPage('next')">
								<i class="mi-angle-right"></i>
							</a>
							<a v-else class="disabled">
								<i class="mi-angle-right"></i>
							</a>
						</li>
						<li class="paging paging-last" v-if="links && (links.previous || links.next)">
							<a href="#" v-if="links.last" @click.prevent="applyPage('last')">
								<i class="mi-angle-double-right"></i>
							</a>
							<a v-else class="disabled">
								<i class="mi-angle-double-right"></i>
							</a>
						</li>
	
						<li><label class="itemsper-label">{{settings.rb.filebrowser_perpage}} </label></li>
						<li>
							<select class="itemsper" @change="applyItemsPer" v-model="itemsper">
								<option value='25' :selected="itemsper == 25 ? 'selected' : null">25</option>
								<option value='50' :selected="itemsper == 50 ? 'selected' : null">50</option>
								<option value='100' :selected="itemsper == 100 ? 'selected' : null">100</option>
								<option value='9999' :selected="itemsper == 9999 ? 'selected' : null">All</option>
							</select>
						</li>
	
					</ul>
				</div>
			`,
			data() {
				var selects = document.getElementsByClassName('itemsper');
				if(selects.length > 0) {
					if (selects[0].value !== '25') {
						this.$root.itemsper = parseInt(selects[0].value);
						this.$root.refresh();
					}
				}
				return {}
			},
			mounted() {
			},
			methods: {
				applyPage(goto) {
						var pageindex = 1;
	
						if(goto == 'last') {
							pageindex = parseInt(fileViewer.response.totalpages);
						}
						else if(goto == 'next') {
							pageindex = parseInt(fileViewer.response.pageindex) + 1;
						}
						else if(goto == 'previous') {
							pageindex = parseInt(fileViewer.response.pageindex) - 1;
						}
	
						this.$root.refresh('',pageindex)
				}
				, applyItemsPer() {
					this.$root.itemsper = this.itemsper;
					this.$root.refresh();
				}
			}
	
		});
	
		Vue.component('listmode', {
			props: ['files','folders','foldertree','currentFile','settings'],
			template: `
				<div class="listmode-wrapper">
					<table class="mura-table-grid">
						<thead>
							<tr>
								<th class="actions">
									<a v-if="foldertree.length" class="folder-back" href="#" @click.prevent="back()">
										&nbsp;
										<i class="mi-arrow-circle-o-left"></i>
									</a>
								</th>
								<th class="var-width sort-grey"><a :class="sorton_name" @click.prevent="sortOn('name')">{{settings.rb.filebrowser_filename}}</a></th>
								<th class="sort-grey"><a :class="sorton_size" @click.prevent="sortOn('size')">{{settings.rb.filebrowser_size}}</a></th>
								<th class="sort-grey"><a :class="sorton_modified" @click.prevent="sortOn('modified')">{{settings.rb.filebrowser_modified}}</a></th>
							</tr>
						</thead>
						<tbody>
							<tr v-if="files.length==0">
								<td class="actions"></td>
								<td class="var-width">{{settings.rb.filebrowser_noresults}}</td>
								<td></td>
								<td></td>
							</tr>
							<tr v-for="(file,index) in files">
								<td class="actions">
									<a href="#" :id="'fileitem-'+index" class="show-actions" @click.prevent="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
									<div class="actions-menu hide">
										<ul class="actions-list">
											<li class="edit"><a @contextmenu="openMenu($event,file,index)"><i class="mi-pencil"></i>{{settings.rb.filebrowser_view}}</a></li>
										</ul>
									</div>
								</td>
								<td class="var-width">
									<a v-if="parseInt(file.isfile)" href="#" @click.prevent="viewFile(file,index)"><i v-if="parseInt(file.isimage)" class="mi-picture"></i><i v-else class="mi-file"></i> {{file.fullname}}</a>
									<a v-else href="#" @click.prevent="refresh(file.name)"><i class="mi-folder"></i> {{file.fullname}}</a>
								</td>
								<td>
									<div v-if="parseInt(file.isfile)">
										{{file.size}}kb
									</div>
									<div v-else>
										--
									</div>
								</td>
								<td>
										{{file.lastmodifiedshort}}
								</td>
							</tr>
	
						</tbody>
					</table>
				</div>`,
			data() {
				return {
					menux: 0,
					menuy: 0,
					sorton_name: '',
					sorton_size: '',
					sorton_modified: ''
				}
			}
			, mounted() {
				this.setSortClass();
			}
			, methods: {
				refresh( directory,index ) {
					this.$root.refresh( directory,index );
				}
				, displayError( e ) {
					this.$root.displayError( e );
				}
				,sortOn(field) {
					var cSort = Mura.readCookie( 'mura_fbsort');
					var cSortJSON = {};
					if(cSort) {
						var cSortJSON = JSON.parse(cSort);
						if(cSortJSON.sortOn == field) {
							if(cSortJSON.sortDir && cSortJSON.sortDir == 'ASC') {
								cSortJSON.sortDir = 'DESC';
							}
							else {
								cSortJSON.sortDir = 'ASC';
							}
						}
					}
					else {
						cSortJSON.sortDir = 'DESC';
					}

					cSortJSON.sortOn = field;

					this.$root.sortOn = cSortJSON.sortOn;
					this.$root.sortDir = cSortJSON.sortDir;
					Mura.createCookie('mura_fbsort',JSON.stringify(cSortJSON),1000);
					this.setSortClass();
					this.$root.refresh();
				},
				setSortClass() {
					var cSort = Mura.readCookie( 'mura_fbsort');
					var cSortJSON = {};
					this.sorton_name = '';
					this.sorton_size = '';
					this.sorton_modified = '';

					if(cSort) {
						cSortJSON = JSON.parse(cSort);
						switch(cSortJSON.sortOn) {
							case 'size':
								this.sorton_size = "sorted-highlight-" + cSortJSON.sortDir.toLowerCase();
								break;
							case 'modified':
								this.sorton_modified = "sorted-highlight-" + cSortJSON.sortDir.toLowerCase();
								break;
							default:
								this.sorton_name = "sorted-highlight-" + cSortJSON.sortDir.toLowerCase();
								break;
						}
					}				
				},
				back( ) {
					this.$root.back( );
				}
				, viewFile( file,index ) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
	
					if(this.checkImageType(file,index)) {
						fileViewer.isDisplayWindow = "VIEW";
					}
					else if(this.checkFileEditable(file,index)) {
						fileViewer.editFile(this.successEditFile);
					}
				}
				, successEditFile( response ) {
					this.currentFile.content = response.data.content;
					fileViewer.isDisplayWindow = "EDIT";
				}
				, isViewable(file,index){
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
					return fileViewer.isViewable();
				}
				, checkFileEditable(file,index) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
					return fileViewer.checkFileEditable();
				}
				, checkImageType(file,index) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
					return fileViewer.checkImageType();
				}
				, checkIsFile() {
					return fileViewer.checkIsFile();
				}
				, openMenu(e,file,index,ref) {
					if (typeof window.tr !== 'undefined' ) {
						window.tr.className = '';
					}
					window.index    = index;
					window.gridMode = false;
					// listmode actions menu
					this.$root.isDisplayContext = 0;
	
					var offsetLeft = 33;
					var offsetTop = 10;
	
					// offset positioning relative to parent
					if (document.getElementById('MuraFileBrowserContainer')){
						if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')){
							offsetTop += 70;
							offsetLeft += Math.floor(document.getElementById('MuraFileBrowserContainer').getBoundingClientRect().left);
						}
					}
	
					var parentLeft = Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().left);
					var parentTop =  Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().top);
	
					var left = parentLeft - offsetLeft;
					var top = parentTop - offsetTop;
	
						
					this.$root.isDisplayWindow = '';
					this.$root.currentFile = file;
					this.$root.currentFile.index = index;
					this.$root.currentIndex = index;
					this.menux = left;
					this.menuy = top;
					this.$emit("doDisplayContext",{menux: this.menux,menuy: this.menuy,display: 1});

					e.preventDefault();
				}
			}
		});
	
		Vue.component('gridmode', {
			props: ['files','folders','foldertree','isDisplayContext','currentFile'],
			template: `
				<div class="gridmode-wrapper">
					<div v-if="foldertree.length" class="fileviewer-back fileviewer-item" @click="back()">
						<div class="fileviewer-item-icon">
							<i class="mi-arrow-circle-o-left"></i>
						</div>
					</div>
					<div v-for="(file,index) in files">
						<!-- files -->
						<div class="fileviewer-item" v-if="parseInt(file.isfile)">
							<div class="fileviewer-item-image">
								<!-- image -->
								<div v-if="parseInt(file.isimage)" class="fileviewer-item-icon" :style="{ 'background-image': 'url(' + encodeURI(file.url) + '?' + Math.ceil(Math.random()*100000) + ')' }" @click.prevent="viewFile(file,index)"></div>
								<!-- file with icon -->
								<div v-else class="fileviewer-item-icon" :class="['fileviewer-item-icon-' + file.type]" @click="openMenu($event,file,index)">
									<i class="mi-file"></i>
								</div>
							</div>
							<div class="fileviewer-item-meta" @click="openMenu($event,file,index)">
								<div class="fileviewer-item-label">
									{{file.fullname}}
								</div>
								<div class="fileviewer-item-meta-details">
									<div v-if="parseInt(file.isfile)" class="fileviewer-item-meta-size">
										{{file.size}}kb
									</div>
									<div class="fileviewer-item-meta-date">
										{{file.lastmodifiedshort}}
									</div>
								</div>
								<div class="fileviewer-item-actions">
									<a href="#" :key="'fileitem-'+index" :id="'fileitem-'+index" class="show-actions" @click.stop="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
								</div>
							</div>
						</div>
						<!-- folders -->
						<div class="fileviewer-item" v-else>
							<div class="fileviewer-item-icon" @click="refresh(file.name)">
								<i class="mi-folder-open"></i>
							</div>
							<div class="fileviewer-item-meta">
								<div class="fileviewer-item-label">
									{{file.fullname}}
								</div>
								<div class="fileviewer-item-meta-details">
									<div v-if="parseInt(file.isfile)" class="fileviewer-item-meta-size">
										{{file.size}}kb
									</div>
								</div>
								<div class="fileviewer-item-actions">
									<a href="#" :id="'fileitem-'+index" class="show-actions" @click.stop.prevent="openMenu($event,file,index)"><i class="mi-ellipsis-v"></i></a>
								</div>
							</div>
						</div>
					</div>
					<div class="clearfix"></div>
				</div>`,
			data() {
				return {
						menux: 0,
						menuy: 0,
						offsetx: 0,
						offsety: 0
				}
			}
			, mounted() {
			}
			, methods: {
				refresh( directory,index ) {
					this.$root.refresh( directory,index );
				}
				, back( ) {
					this.$root.back( );
				}
	
				, viewFile( file,index ) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
	
					if(this.checkImageType(file,index)) {
						fileViewer.isDisplayWindow = "VIEW";
					}
					else if(this.checkFileEditable(file,index)) {
						fileViewer.editFile(this.successEditFile);
					}
				}
				, checkFileEditable(file,index) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
					return fileViewer.checkFileEditable();
				}
				, checkImageType(file,index) {
					this.$root.currentFile = file;
					this.$root.currentIndex = index;
					return fileViewer.checkImageType();
				}
				, checkIsFile() {
					return fileViewer.checkIsFile();
				}
				, successEditFile( response ) {
					this.currentFile.content = response.data.content;
					fileViewer.isDisplayWindow = "EDIT";
				}
				, openMenu(e,file,index) {
					window.gridMode = true;
					window.index    = index;
					e.preventDefault();
					// gridmode
					var offsetLeft = 0;
					var offsetTop = 10;
	
					// offset positioning relative to parent
					if (document.getElementById('MuraFileBrowserContainer')){
						if (document.getElementById('MuraFileBrowserContainer').parentNode == document.getElementById('alertDialogMessage')){
							offsetTop += 70;
							offsetLeft += Math.floor(document.getElementById('MuraFileBrowserContainer').getBoundingClientRect().left);
						}
					}
	
					this.menux = Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().left) - 28 - offsetLeft;
					this.menuy =  Math.floor(document.getElementById('fileitem-'+index).getBoundingClientRect().top) - offsetTop;
	
					this.$root.currentFile = file;
					this.$root.currentIndex = index;

					this.$emit("doDisplayContext",{menux: this.menux,menuy: this.menuy,display: 1});
							
					this.$root.isDisplayWindow = '';
					this.$root.currentFile = file;
					this.$root.currentFile.index = index;
					this.$root.currentIndex = index;
		  this.$root.isDisplayContext = 0;
  
		  this.$nextTick(function () {
			this.$root.isDisplayContext = 1;
		  })
  
		  this.$root.isDisplayWindow = '';
		  this.$root.currentFile = file;
		  this.$root.currentFile.index = index;
		  this.$root.currentIndex = index;
  
		  e.preventDefault();
				}
	
			}
		});
	
		Vue.component('filewindow', {
			props: ['files','folders','foldertree','currentFile','settings','displaymode'],
			template: `
				<div class="filewindow-wrapper" id="mura-filewindow-wrapper">
					<gridmode v-on:doDisplayContext="displayContext" v-if="displaymode==1" :settings="settings" :currentFile="currentFile" :foldertree="foldertree" :files="files" :folders="folders"></gridmode>
					<listmode v-on:doDisplayContext="displayContext" v-if="displaymode==2" :settings="settings" :currentFile="currentFile" :foldertree="foldertree" :files="files" :folders="folders"></listmode>
					<contextmenu :settings="settings" v-click-outside="hideContext" :currentFile="this.$parent.currentFile" :menux="menux" :menuy="menuy" v-if="isDisplay"></contextmenu>
				</div>`,
			data() {
				return {
					menux: 0,
					menuy: 0,
					isDisplay: 0
				}
			},
			methods: {
				displayContext(args) {
					this.menux = args.menux;
					this.menuy = args.menuy;

					if(!this.isDisplay || args.display == 1) {
						this.isDisplay=1;
					}
					else {
						this.isDisplay=0;
					}
				},
				hideContext() {
					this.isDisplay=0;
				}
			}
		});
	
		Vue.component('spinner', {
			template: `
				<div id="spinner">
	
				</div>`,
			data() {
				return {};
			}
			, mounted() {
				if($("#spinner")){
					$("#spinner").spin(spinnerArgs);
				}
				if($('.ui-dialog-title').length){
					$('.mura-modal-only').remove();
				}
			}
			, destroyed:  function() {
				$("#spinner").spin(!1);
			}
			, methods: {
	
			}
		});
	
		const IS_START = 0, IS_SAVE = 1, IS_SUCCESS = 2, IS_FAIL = 3;
	
		var fileViewer = new Vue({
			el: "#" + self.target,
			template: `
				<div class="fileviewer-wrapper">
					<spinner v-if="spinnermodal"></spinner>
					{{message}}
					<gallerywindow v-if="isDisplayWindow=='VIEW'" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex"></gallerywindow>
					<imageeditwindow v-if="isDisplayWindow=='EDITIMAGE'" :settings="settings" :currentFile="currentFile" :currentIndex="currentIndex"></imageeditwindow>
					<actionwindow v-if="isDisplayWindow != ''" :foldertree="foldertree" :settings="settings" :isDisplayWindow="isDisplayWindow" :currentIndex="currentIndex" :currentFile="currentFile" :error="error"></actionwindow>
					<div class="mura-header">
						<h1 class="mura-modal-only">{{settings.rb.filebrowser_filemanager}}</h1>
						<ul class="breadcrumb">
							<li @click="setDirDepth(-1)"><a><i class="mi-home"></i>{{resourcepath}}</a></li>
							<li v-for="(item,index) in foldertree" @click="setDirDepth(index)"><a><i class="mi-folder-open"></i>{{item}}</a></li>
						</ul>
					</div>
					<div class="fileviewer-droptarget">
						<form enctype="multipart/form-data" novalidate v-if="isStart || isSave">
							<input type="file" multiple :name="uploadField" :disabled="isSave" @drop="filesDropped($event);" @change="filesChanged($event.target.name, $event.target.files);" accept="*.*" class="file-input-field">
							<p v-if="isStart" class="upload-icon"><i class="mi-upload"></i>
								{{settings.rb.filebrowser_draghere}}
							</p>
							<p v-if="isSave" class="download-icon">
								{{settings.rb.filebrowser_uploading}} ({{fileCount}})
							</p>
						</form>
					</div>
					<appbar v-if="response.links" :showbar=1 :settings="settings" :location=1 :links="response.links" :itemsper="itemsper" :response="response" :displaymode="displaymode" :sortOn="sortOn" :sortDir="sortDir"></appbar>
					<filewindow :settings="settings" :currentFile="currentFile" :isDisplayContext="isDisplayContext" :foldertree="foldertree" :files="files" :folders="folders" :displaymode="displaymode"></filewindow>
					<appbar v-if="response.links" :showbar=showfooter :settings="settings" :location=0 :links="response.links" :itemsper="itemsper" :response="response" :isbottomnav="true" :sortOn="sortOn" :sortDir="sortDir"></appbar>
				</div>`
			,
			data: {
				currentView: 'fileviewer',
				currentState: null,
				currentFile: null,
				currentIndex: 0,
				currentUser: null,
				isAdmin: null,
				foldertree: [],
				fileCount: 0,
				files: [],
				folders: [],
				groups: [],
				spinnermodal: 0,
				error: "",
				showfooter: 0,
				settings: { rb: {} },
				displaymode: this.config.displaymode,
				uploadedFiles: [],
				isDisplayContext: 0,
				isDisplayWindow: '',
				uploadField: "uploadFiles",
				filterResults: '',
				filterDepth: 0,
				sortOn: 'name',
				sortDir: 'DESC',
				itemsper: 25,
				message: '',
				editfilelist: self.editfilelist,
				resourcepath: this.config.resourcepath.replace('_',' '),
				response: {pageindex: 0}
			},
			ready() {
			},
			computed: {
				isStart() {
					return this.currentState === IS_START;
				},
				isSave() {
					return this.currentState === IS_SAVE;
				},
				isSuccess() {
					return this.currentState === IS_SUCCESS;
				},
				isonError() {
					return this.currentState === IS_FAIL;
				}
			},
			methods: {
				updateDelete() {
						self.updateDelete(currentFile);
				}
				, updateContent( content ) {
					var dir = "";
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}
	
					self.doUpdateContent( dir,this.currentFile,content,this.refresh );
				}
				, renameFile() {
					var dir = "";
	
					dir +=  this.currentFile.subfolder;

					self.doRenameFile( dir,this.currentFile,this.refresh );
				}
				, newFolder(foldername) {
					var dir = "";
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}

					self.doNewFolder( dir,foldername,this.refresh );
				}
				, updateEdit() {
						self.updateEdit(currentFile);
				}
				, displayResults(response) {
	
					this.response = response.data
					this.files = response.data.items;
					this.folders = response.data.folders;
	
					if(response.data.settings) {
						this.settings = response.data.settings;
					}
					this.$nextTick(function () {
						this.spinnermodal = 0;
					});
	
					this.showfooter = this.response.totalpages-1;
	
				}
				, displayError( e ) {
					if(e.message) {
						this.message = message;
					}
				}
				, previousFile( img ) {
					img = img ? img : 0;
					index = this.currentIndex;
	
					index--;
	
					if(index+1 <= 0) {
						return;
					}
	
					if(!parseInt(this.files[index].isfile)) {
						return;
					}
	
					if(img && this.checkImageType() || !img) {
						this.currentFile = this.files[index];
						this.currentIndex = index;
	
						if(this.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
							var dir = "";
			
							for(var i=0;i<this.foldertree.length;i++) {
								dir = dir + "/" + this.foldertree[i];
							}
	
							Mura.getEntity('filebrowser').invoke(
								'getImageInfo',
								{
									directory:dir,
									subfolder:fileViewer.currentFile.subfolder,
									resourcepath:MuraFileBrowser.config.resourcepath,
									filename:fileViewer.currentFile.fullname
								}).then(function(info){
									fileViewer.currentFile.info=info;
								})
						}
	
						return;
					}
					else {
						this.previousFile(img);
					}
	
				}
				, nextFile( img ) {
					img = img ? img : 0;
					index = this.currentIndex;
	
					index++;
	
					if(index >= this.files.length) {
						return;
					}
	
					if(img && this.checkImageType() || !img) {
						this.currentFile = this.files[index];
	
						if(this.currentFile.ext.toLowerCase()!='svg' && typeof fileViewer.currentFile.info.width == 'undefined'){
							var dir = "";
			
							for(var i=0;i<this.foldertree.length;i++) {
								dir = dir + "/" + this.foldertree[i];
							}

							var dirRegex = /.*\//i;
							var depth = fileViewer.currentFile.url.match(dirRegex);
	
							Mura.getEntity('filebrowser').invoke(
								'getImageInfo',
								{
									directory:dir,
									subfolder:fileViewer.currentFile.subfolder,
									resourcepath:MuraFileBrowser.config.resourcepath,
									filename:fileViewer.currentFile.fullname
								}).then(function(info){
									fileViewer.currentFile.info=info;
								})
						}
	
						this.currentIndex = index;
						return;
					}
					else {
						this.nextFile(img);
					}
				}
				, upload() {
				}
				, uploadReset() {
					this.currentState = IS_START;
					this.uploadedFiles = [];

					var uploader=document.querySelector('input[type="file"][name="uploadFiles"]');

					if(uploader){
						uploader.value=[];
					}
					
					this.error = null;
				}
				, setDirDepth( depth ) {
						this.foldertree = this.foldertree.slice(0,depth+1);
						this.refresh();
				}
				, editFile( onSuccess,onError ) {
					var dir = "";
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}
	
					self.getEditFile(dir,this.currentFile,onSuccess);
	
				}
				, viewFile( direction ) {
				}
				, deleteFile( onSuccess, onError) {
					var dir = "";
	
//					for(var i=0;i<this.foldertree.length;i++) {
//						dir = dir + "/" + this.foldertree[i];
//					}

					dir +=  this.currentFile.subfolder;

					self.doDeleteFile(dir,this.currentFile,onSuccess,onError);
	
				}
				, duplicateFile( onSuccess, onError) {
					var dir = "";
					this.isDisplayWindow = "";
					dir +=  this.currentFile.subfolder;
					self.doDuplicateFile(dir,this.currentFile,onSuccess,onError);
				}
				, refresh( folder,pageindex,displaywindow ) {
					if(displaywindow) {
						this.isDisplayWindow = "";
						this.$nextTick(function () {
							this.$root.isDisplayWindow = displaywindow;
						});
					}
					else
						this.isDisplayWindow = '';
	
					if(folder && folder.length)
						this.foldertree.push(folder);
	
					var dir = "";
	
					isNaN(pageindex) ? 0 : pageindex;
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}
					this.isDisplayContext = "";
					this.spinnermodal = 1;
	
					var fdata = {
						siteid: Mura.siteid,
						foldertree: JSON.parse(JSON.stringify(this.foldertree)),
						itemsper: this.itemsper,
						resourcepath: MuraFileBrowser.config.resourcepath,
						sortDir: this.sortDir,
						sortOn: this.sortOn
					}
	
					window.sessionStorage.setItem( 'mura_fbfolder',JSON.stringify(fdata));
	
					self.loadDirectory(dir,pageindex,this.displayResults,this.displayError,this.filterResults,this.filterDepth,this.sortOn,this.sortDir,this.itemsper,displaywindow);
				}
				, back() {
					this.foldertree.splice(-1);
					var folder = this.foldertree.length ? "" : this.foldertree[this.foldertree.length-1];
					this.refresh();
				}
				, closeMenu( e ) {
					this.isDisplayContext = 0;
					e.preventDefault();
				}
				, filesDropped(event) {
					event.preventDefault();

					var fieldName = event.target.name;
					var fileList = event.dataTransfer.files;

					this.uploadedFiles = fileList;

					const formData = new FormData();
	
					var dir = "";
	
					if (!fileList.length) return;
	
					// append the files to FormData
	
					this.fileCount = fileList.length;
	
					Array
						.from(Array(fileList.length).keys())
						.map(x => {
							formData.append(fieldName, fileList[x], fileList[x].name);
						});
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}
	
					formData.append("directory",dir);
	
					// save it
					this.save(formData);
				}

				,filesChanged(fieldName, fileList) {
					this.uploadedFiles = fileList;

					const formData = new FormData();
	
					var dir = "";
	
					if (!fileList.length) return;
	
					// append the files to FormData
	
					this.fileCount = fileList.length;
	
					Array
						.from(Array(fileList.length).keys())
						.map(x => {
							formData.append(fieldName, fileList[x], fileList[x].name);
						});
	
					for(var i=0;i<this.foldertree.length;i++) {
						dir = dir + "/" + this.foldertree[i];
					}
	
					formData.append("directory",dir);
	
					// save it
					this.save(formData);
				}

				, save( formData ) {
						this.currentState = IS_SAVE;
	
						self.doUpload( formData,this.saveComplete );
				}
				, saveComplete( ) {
					this.uploadReset();
					this.refresh();
				}
				, checkSelectMode() {
					return MuraFileBrowser.config.selectMode;
				}
				, isViewable() {
						var editlist = this.settings.editfilelist;
						var imagelist = this.settings.imagelist;
						for(var i = 0;i<editlist.length;i++) {
							if(this.currentFile.ext.toLowerCase() == editlist[i]) {
								return true;
							}
						}
						for(var i = 0;i<imagelist.length;i++) {
							if(this.currentFile.ext.toLowerCase() == imagelist[i]) {
								return true;
							}
						}
						return false;
				}
				, checkFileEditable() {
					var editlist = this.settings.editfilelist;
	
					for(var i = 0;i<editlist.length;i++) {
						if(this.currentFile.ext.toLowerCase() == editlist[i]) {
							return true;
						}
					}
					return false;
				}
				, checkImageType() {
					var imagelist = this.settings.imagelist;
						for(var i = 0;i<imagelist.length;i++) {
							if(this.currentFile.ext.toLowerCase() == imagelist[i]) {
								return true;
							}
						}
						return false;
				}
				, checkIsUserArea() {
					return self.config.resourcepath != "Application_Root";
				}
				, checkIsFile() {
	
					if(Math.floor(this.currentFile.isfile)) {
						return true;
					}
					return false;
				}
			},
			mounted() {
					this.uploadReset();
					this.$nextTick(function () {
						this.spinnermodal = 1;
					});
					this.selectMode = self.config.selectMode;

					var sThis = this;

					Mura.getCurrentUser(
						
					).then(
						//success
						function(user) {
							sThis.currentUser = user;
							if(user.isSuperUser()) {
								sThis.isAdmin = true;
							}
						},
						//fail
						function(response) {
							sAdmin = false;
						}
					);

					var dir = "";
	
					var cFolder = window.sessionStorage.getItem( 'mura_fbfolder');
					if(cFolder) {
						try{
							var cFolderJSON = JSON.parse(cFolder);
	
							if(cFolderJSON.itemsper)
								this.itemsper = cFolderJSON.itemsper;
	
							if(cFolderJSON.resourcepath != self.config.resourcepath || cFolderJSON.siteid != mura.siteid) {
								var fdata = {
									siteid: Mura.siteid,
									foldertree: [],
									itemsper: this.itemsper,
									sortDir: this.sortDir,
									sortOn: this.sortOn,
									resourcepath: self.config.resourcepath
								}
								window.sessionStorage.setItem( 'fbFolderTree',JSON.stringify(fdata),1);
							}
							else if(cFolderJSON.foldertree) {
								this.$root.foldertree = cFolderJSON.foldertree;
	
								for(var i=0;i<this.foldertree.length;i++) {
									dir = dir + "/" + this.foldertree[i];
								}
							}
						} catch(e){
							console.log("error reading storage json:" + cFolderJSON);
							window.sessionStorage.setItem( 'fbFolderTree','',1);
						}
					}
	
	// displaymode cookie
					var cDisplay = Mura.readCookie( 'mura_fbdisplaymode' );
	
					if(cDisplay) {
						var fbDisplayJSON = JSON.parse(cDisplay);
	
						if(fbDisplayJSON.displaymode)
							this.$root.displaymode = this.viewmode = fbDisplayJSON.displaymode;
					}
	
					self.loadBaseDirectory(this.displayResults,this.displayError,dir);
	
					window.addEventListener('mouseup', function(event) {
	//        fileViewer.isDisplayContext = 0;
					});
					var vm = this;
			}
		});
	}
	
	};
	