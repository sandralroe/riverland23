component
	entityname="filebrowser"
	extends="mura.bean.bean"
	displayname="Mura File Manager"
	table="m_filebrowser"
	public="true"
  {
		property name="filebrowserid" default="" required=true fieldtype="id" orderno="-100000" rendertype="textfield" displayname="filebrowserid" html=false datatype="char" length="35" nullable=false pos="0";

		private function getBaseFileDir( siteid,resourcePath ) {
			arguments.resourcePath == "" ? "User_Assets" : arguments.resourcePath;

			var pathRoot = "";
			var m=getBean('$').init(arguments.siteid);
			var currentSite = application.settingsManager.getSite(arguments.siteid);

			if(arguments.resourcePath == "Site_Files") {
				pathRoot = currentSite.getIncludePath();
				pathRoot = conditionalExpandPath(pathRoot);
			}
			else if(arguments.resourcePath == "Application_Root") {
				pathRoot = expandPath("/muraWRM");
			}
			else {
				pathRoot = currentSite.getAssetDir() & getBean('configBean').getFileDelim() & 'assets';
			}

			return pathRoot;
		}

		private function getBaseResourcePath( siteid,resourcePath,complete=1 ) {
			arguments.resourcePath == "" ? "User_Assets" : arguments.resourcePath;

			var pathRoot = "";
			var m=getBean('$').init(arguments.siteid);
			var currentSite = application.settingsManager.getSite(arguments.siteid);

			if(arguments.resourcePath == "Site_Files") {
				pathRoot = currentSite.getAssetPath(complete=arguments.complete);
			} else if (arguments.resourcePath == "Application_Root") {
				pathRoot = currentSite.getRootPath(complete=arguments.complete);
			} else {
				pathRoot = currentSite.getFileAssetPath(complete=arguments.complete) & '/assets';
			}

			return pathRoot;
		}

		private any function checkPerms( siteid,context,resourcePath )  {
			var m=getBean('$').init(arguments.siteid);
			var permission = {message: '',success: 0};

			// context: upload,edit,write,delete,rename,addFolder,browse
			// resourcePath: User_Assets,Site_Files,Application_Root

			if (!(m.getBean('permUtility').getModulePerm('00000000000000000000000000000000000',arguments.siteid) || m.getBean('permUtility').getModulePerm('00000000000000000000000000000000018',arguments.siteid))) {
				permission.message = "Permission Denied";
				return permission;
			}

			if(arguments.resourcePath != 'User_Assets' && !m.getCurrentUser().isSuperUser()){
				permission.message = "Permission Denied";
				return permission;
			}

			permission.success = 1;
			return permission;
		}


		remote any function resize( resourcePath,file,dimensions ) {

			var m=getBean('$').init(arguments.siteid);

			if(!m.validateCSRFTokens(context='resize')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'editimage',resourcePath);
			var response = { success: 0 };

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			if(isJSON(arguments.file)) {
				arguments.file = deserializeJSON(arguments.file);
			}
			if(isJSON(arguments.dimensions)) {
				arguments.dimensions = deserializeJSON(arguments.dimensions);
			}

			response.args = arguments;

			var currentSite = application.settingsManager.getSite(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var tempDir = m.globalConfig().getTempDir();
			var timage = replace(createUUID(),"-","","all");
			var delim = rereplace(m.getBean('fileWriter').pathFormat(baseFilePath),".*\/","");
			var filePath = baseFilePath & rereplace(arguments.file.url,".*?#delim#","");
		
			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}


			var sourceImage = getImageObject(filePath);
			var response = {};

			if(arguments.dimensions.aspect eq "within") {
				if(!isNumeric(arguments.dimensions.width) || !isNumeric(arguments.dimensions.height) || arguments.dimensions.width < 1 || arguments.dimensions.height < 1) {
					var rb = getResourceBundle(arguments.siteid);
					response.message = rb['filebrowser.dimensionsrequired'];
					return response;
				}
				ImageScaleToFit(sourceImage,int(arguments.dimensions.width),int(arguments.dimensions.height));
			}
			else if(arguments.dimensions.aspect eq "height") {
				if(!isNumeric(arguments.dimensions.height) || arguments.dimensions.height < 1) {
					var rb = getResourceBundle(arguments.siteid);
					response.message = rb['filebrowser.dimensionsrequired'];
					return response;
				}
				ImageResize(sourceImage,'',int(arguments.dimensions.height));
			}
			else if(arguments.dimensions.aspect eq "width") {
				if(!isNumeric(arguments.dimensions.width) || arguments.dimensions.width < 1) {
					var rb = getResourceBundle(arguments.siteid);
					response.message = rb['filebrowser.dimensionsrequired'];
					return response;
				}
				ImageResize(sourceImage,int(arguments.dimensions.width),'');
			}
			else {
				if(!isNumeric(arguments.dimensions.width) || !isNumeric(arguments.dimensions.height) || arguments.dimensions.width < 1 || arguments.dimensions.height < 1) {
					var rb = getResourceBundle(arguments.siteid);
					response.message = rb['filebrowser.dimensionsrequired'];
					return response;
				}
				ImageResize(sourceImage,int(arguments.dimensions.width),int(arguments.dimensions.height));
			}

			var sourceImageInfo = readImageInfo(sourceImage,filePath);
			var destination = replace(filePath,".#arguments.file.ext#","-resize-#randrange(10000,99999)#.#arguments.file.ext#");

			ImageWrite(sourceImage,tempDir & timage & "." & arguments.file.ext);
			fileMove(tempDir & timage & "." & arguments.file.ext,filePath);

			response.info = readImageInfo(sourceImage,filePath);
			response.info.url=arguments.file.url;

			m.event('fileInfo',response.info).announceEvent('onAfterImageManipulation');

			structDelete(response.info,'source');

			response.success = 1;
			return response;
		}

		remote any function saveImage() {
			var m=getBean('$').init(arguments.siteid);

			if(!m.validateCSRFTokens(context='saveImage')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'save',resourcePath);
			var response = { success: 0 };

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			if(isJSON(arguments.file)) {
				arguments.file = deserializeJSON(arguments.file);
			}

			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var tempDir = m.globalConfig().getTempDir();
			var tfile = replace(createUUID(),"-","","all");
			var delim = rereplace(m.getBean('fileWriter').pathFormat(baseFilePath),".*\/","");
			var allowedExtensions = m.getBean('configBean').getFMAllowedExtensions();
			var filePath = baseFilePath & arguments.dir;

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			if(getBean('configBean').getCompiler()=='Adobe'){
				var item = fileUpload(tempDir,'croppedImage','',"Overwrite",false);
			} else {
				var item = fileUpload(tempDir,'croppedImage','',"Overwrite");
			}
			
			if(listFindNoCase(allowedExtensions,item.serverfileext)) {
					if(fileExists(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile)) {
						fileDelete(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile );
					}
					
					fileMove(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile,conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile );
			}
			else {
				fileDelete(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile);
				response.success = 0;
				return response;
			}

			if(isdefined('arguments.file.url')){
				var sourceImage=getImageObject(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile);
				response.info = readImageInfo(sourceImage,filePath);
				response.info.url=arguments.file.url;
				m.event('fileInfo',response.info).announceEvent('onAfterImageManipulation');
			}
			response.success = 1;
			return response;
		}

		remote any function duplicate( siteid,directory,filename,resourcePath )  {
			var m=getBean('$').init(arguments.siteid);

			if(!m.validateCSRFTokens(context='duplicate')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'duplicate',resourcePath);
			var response = { success: 0 };

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var tempDir = m.globalConfig().getTempDir();
			var tfile = replace(createUUID(),"-","","all");

/*
			var currentSite = application.settingsManager.getSite(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var delim = rereplace(m.getBean('fileWriter').pathFormat(baseFilePath),".*\/","");

			var source = baseFilePath & rereplace(arguments.file.url,".*?#delim#","");
			var destination = replace(source,".#arguments.file.ext#","-copy1.#arguments.file.ext#");
			var version = 1;

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(source))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(destination))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}
*/
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var ext = "." & rereplacenocase(arguments.filename,".*\.","");
			var version = 1;

			var newfilename = replace(arguments.filename,".#ext#","-copy#version#.#ext#");
			var source = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;
			var destination = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & replace(arguments.filename,"#ext#","-copy#version##ext#");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,source)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,destination)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			while(fileExists(destination) && version < 200) {
				version++;
				destination = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & replace(arguments.filename,"#ext#","-copy#version##ext#");
			}

			if(version >= 199) {
				throw("VERSION CREATION ISSUE; MAXIUMUM 200");
				return;
			}

			fileCopy(source,tempDir & tfile & ext);
			fileMove(tempDir & tfile & ext,destination);

			announceAssetEvent(destination,'onAfterAssetSave',m,arguments.resourcepath);

			response.success = 1;
			return response;
		}

		remote any function rotate( resourcePath,file,direction ) {

			var m=getBean('$').init(arguments.siteid);

			if(!m.validateCSRFTokens(context='rotate')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'editimage',resourcePath);
			var response = { success: 0 };

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			if(isJSON(arguments.file)) {
				arguments.file = deserializeJSON(arguments.file);
			}

			var currentSite = application.settingsManager.getSite(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var tempDir = m.globalConfig().getTempDir();
			var timage = replace(createUUID(),"-","","all");
			var delim = rereplace(m.getBean('fileWriter').pathFormat(baseFilePath),".*\/","");
			var filePath = baseFilePath & rereplace(arguments.file.url,".*?#delim#","");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			var sourceImage = getImageObject(filePath);
			var response = {};

			var rotation = 90;
			if(arguments.direction eq "counterclock") {
				rotation = -90;
			}

			var sourceImageInfo = readImageInfo(sourceImage,filePath);
			ImageRotate(sourceImage,int(sourceImageInfo.width/2),int(sourceImageInfo.height/2),rotation);

			ImageWrite(sourceImage,tempDir & timage & "." & arguments.file.ext);
			fileMove(tempDir & timage & "." & arguments.file.ext,filePath);

			response.info = readImageInfo(sourceImage,filePath);
			response.info.url=arguments.file.url;
			m.event('fileInfo',response.info).announceEvent('onAfterImageManipulation');

			structDelete(response.info,'source');

			response.success = 1;
			return response;

		}

		remote any function processCrop( resourcePath,file,crop,size ) {

			var m=getBean('$').init(arguments.siteid);

			if(!m.validateCSRFTokens(context='processCrop')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'editimage',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var currentSite = application.settingsManager.getSite(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var tempDir = m.globalConfig().getTempDir();
			var timage = replace(createUUID(),"-","","all");
			var response = {};

			if(isJSON(arguments.file)) {
				arguments.file = deserializeJSON(arguments.file);
			}
			if(isJSON(arguments.crop)) {
				arguments.crop = deserializeJSON(arguments.crop);
			}
			if(isJSON(arguments.size)) {
				arguments.size = deserializeJSON(arguments.size);
			}

			var delim = rereplace(m.getBean('fileWriter').pathFormat(baseFilePath),".*\/","");
			var filePath = baseFilePath & rereplace(arguments.file.url,".*?#delim#","");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			var sourceImage = getImageObject(filePath);

			ImageScaleToFit(sourceImage,size.width,size.height,"highestPerformance");
			ImageWrite(sourceImage,tempDir & timage & "." & arguments.file.ext);
			var workImage = getImageObject(tempDir & timage & "." & arguments.file.ext);
			sourceImage = getImageObject(filePath);

			var workImageInfo = readImageInfo(workImage,tempDir & timage & "." & arguments.file.ext);
			var sourceImageInfo = readImageInfo(sourceImage,filePath);
			var aspect = 1;

			if(workImageInfo.width != sourceImageInfo.width) {
				aspect = floor(sourceImageInfo.width/workImageInfo.width*1000)/1000;
			}
			else if(workImageInfo.height != sourceImageInfo.height) {
				aspect = floor(sourceImageInfo.height/workImageInfo.height*1000)/1000;
			}

			ImageCrop(sourceImage,arguments.crop.x*aspect,arguments.crop.y*aspect,arguments.crop.width*aspect,arguments.crop.height*aspect);
			ImageWrite(sourceImage,tempDir & timage & "." & arguments.file.ext);
			fileMove(tempDir & timage & "." & arguments.file.ext,filePath);
			workImage = getImageObject(filePath);

			response.info = readImageInfo(workImage,filePath);
			response.info.url=arguments.file.url;

			m.event('fileInfo',response.info).announceEvent('onAfterImageManipulation');

			structDelete(response.info,'source');

			response.aspect = aspect;

			response.success = 1;
			return response;
		}


		remote any function ckeditor_quick_upload( siteid,directory,formData,resourcePath ) {

			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

			var sentCSRF = arguments.ckcsrftoken;
			var cookieCSRF = cookie.ckcsrftoken;

			if(cookieCSRF != cookieCSRF) {
				return serializeJSON({
					"uploaded": 0,
					"error": {
						"message": "Not supported."
					}
				});
			}

			arguments.siteid == "" ? "default" : arguments.siteid;
			var m=getBean('m').init(arguments.siteid);

			arguments.directory = arguments.directory == "" ? "" : arguments.directory;
			arguments.directory = rereplace(arguments.directory,"\\",application.configBean.getFileDelim(),"all");

			// hasrestrictedfiles

			var permission = checkPerms(arguments.siteid,'upload',resourcePath);
			var response = { success: 0,failed: [],saved: []};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return serializeJSON({
					"uploaded": 0,
					"error": {
						"message": "Not allowed."
					}
				});
			}

			var currentSite = application.settingsManager.getSite(arguments.siteid);
			var pathRoot = currentSite.getAssetPath() & '/assets#arguments.directory#';

			var allowedExtensions = m.getBean('configBean').getFMAllowedExtensions();
			var tempDir = m.globalConfig().getTempDir();

			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			if(getBean('configBean').getCompiler()=='Adobe'){
				var item = fileUpload(tempDir,'',"MakeUnique");
			} else {
				var item = fileUpload(tempDir,'','',"Overwrite");
			}
			//creating an alternate name to imageTIMESTAMP.extension format
			//example ----> image20200917082201.png  <-----
			var dotDelimArray = listToArray(item.serverfile,'.');
			var newFileName = dotDelimArray[1]  & dateTimeFormat( item.timecreated,'yyyymmddhhnnss'  ) & '.'  & dotDelimArray[arrayLen(dotDelimArray)];

			if(listFindNoCase(allowedExtensions,item.serverfileext)) {
				if(fileExists(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile)) {
					fileDelete(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile );
				}
				if(!directoryExists(conditionalExpandPath(filePath))){
					directoryCreate(conditionalExpandPath(filePath));
				}
				//moving and renaming file
				var newFilePath=conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & newFileName;
				fileMove(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile, newFilePath );

				announceAssetEvent(newFilePath,'onAfterAssetSave',m,arguments.resourcepath);

			}
			else {
				fileDelete(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile);
				response.success = 0;
				return serializeJSON({
					"uploaded": 0,
					"error": {
						"message": "File type not allowed."
					}
				});
			}

            /*if(isdefined('arguments.file.url')) {
				var sourceImage=getImageObject(conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & item.serverfile);
				response.info = readImageInfo(sourceImage,filePath);
				response.info.url=arguments.file.url;
				m.event('fileInfo',response.info).announceEvent('onAfterImageManipulation');
			}*/

			var fileurl=getBaseResourcePath(arguments.siteid,arguments.resourcePath) & replace(arguments.directory,"\","/","all") & m.globalConfig().getFileDelim() & newFileName;
			response.success = 1;

			if(response.success) {
				// this is the only one that counts
				return serializeJSON({
					"uploaded": 1,
					"fileName": item.serverfile,
					"url": fileurl
				});
			}
			else {
				return serializeJSON({
					"uploaded": 0,
					"error": {
						"message": "Upload failed."
					}
				});
			}
		}

		remote any function updatepermissions( groups,haspermissions,currentFile,resourcepath ) {
			arguments.siteid == "" ? "default" : arguments.siteid;

			if(isJSON(arguments.currentFile)) {
				arguments.currentFile = deserializeJSON(arguments.currentFile);
			}
			if(isJSON(arguments.groups)) {
				arguments.groups = deserializeJSON(arguments.groups);
			}

			var m=getBean('m').init(arguments.siteid);
			var response = { success: 0};
			var path = currentFile.subfolder & application.configBean.getFileDelim() & currentFile.fullName;

     		if(!m.validateCSRFTokens(context='updatepermissions')){
				throw(type="invalidTokens");
			}

			if(!isS2() and !isUserInGroup('Admin',getBean('settingsManager').getSite(arguments.siteID).getPrivateUserPoolID(),0)) {
				return serializeJSON({
					"success": 0,
					"error": {
						"message": "Not allowed."
					}
				});
			}

			response.response = application.permUtility.setFolderPermissionsByGroup(groups,haspermissions,siteid,path);
			response.success = 1;

			return response;
		}

		remote any function grouppermissions( currentFile ) {
			arguments.siteid == "" ? "default" : arguments.siteid;

			if(isJSON(arguments.currentFile)) {
				arguments.currentFile = deserializeJSON(arguments.currentFile);
			}
		
			var m=getBean('m').init(arguments.siteid);
			var response = { success: 0};

			//Permissions are always stored with forward slash "/"
			var path = arguments.currentFile.subfolder & "/" & arguments.currentFile.fullName;

     		if(!m.validateCSRFTokens(context='grouppermissions')){
				throw(type="invalidTokens");
			}


			if(!isS2() and !isUserInGroup('Admin',getBean('settingsManager').getSite(arguments.siteID).getPrivateUserPoolID(),0)) {
				return serializeJSON({
					"success": 0,
					"error": {
						"message": "Not allowed."
					}
				});
			}
			response.hasfolderpermission = 0;

			var permlist = application.permUtility.getGroupList({siteid=arguments.siteid});
			var grouplist = permlist.privategroups;
			var memberlist = permlist.publicgroups;
			response.groups = [];
			response.grouplist = grouplist;
			response.memberlist = memberlist;

			response.args = arguments;
			response.path = path;

			for(var row in grouplist) {
				var perm = application.permUtility.getFolderPermissionsByGroup(row.userid,arguments.siteid,path);
				var folderpermission = {};

				folderpermission.userid = row.userid;
				folderpermission.path = path;
				folderpermission.groupname = row.groupname;
				if(structKeyExists(perm,'return')) {
					folderpermission.perm = perm.return;
				}
				else {
					folderpermission.perm = 'editor';
				}

				if(perm.hasperm or structKeyExists(perm,'qExists') and perm.qExists.recordcount) {
					response.hasfolderpermission = 1;
				}

				ArrayAppend(response.groups,folderpermission);
			}
			
			for(var row in memberlist) {
				var perm = application.permUtility.getFolderPermissionsByGroup(row.userid,arguments.siteid,path);

				var folderpermission = {};
				folderpermission.userid = row.userid;
				folderpermission.path = path;
				folderpermission.groupname = row.groupname;
				if(structKeyExists(perm,'return')) {
					folderpermission.perm = perm.return;
				}
				else {
					folderpermission.perm = 'editor';
				}
				if(structKeyExists(perm,'hasperm') and perm.hasperm) {
					response.hasfolderpermission = 1;
				}
	
				ArrayAppend(response.groups,folderpermission);
			}
			return response;
		}


		remote any function move( siteid,directory,destination,filename,resourcePath )  {

			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

     		if(!m.validateCSRFTokens(context='move')){
				throw(type="invalidTokens");
			}

			arguments.directory = arguments.directory == "" ? "" : arguments.directory;
			arguments.directory = rereplace(arguments.directory,"\\",application.configBean.getFileDelim(),"all");
			response.success = 0;

			var permission = checkPerms(arguments.siteid,'move',resourcePath);
			var response = { success: 0};

			response.args = arguments;

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);

			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var destinationPath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.destination,"\.{1,}","\.","all");
			var tempDir = m.globalConfig().getTempDir();

			if(!DirectoryExists(filePath) || !DirectoryExists(destinationPath)) {
				response.message = "File does not exist, or destination does not exist";
				return response;
			}

			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}
			if(!isPathLegal(arguments.siteid,arguments.resourcepath, conditionalExpandPath(destinationPath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			var oldFilePath=filePath & m.globalConfig().getFileDelim() & filename;

			fileMove(oldFilePath,tempDir & arguments.filename);

			var newFilePath=destinationPath & m.globalConfig().getFileDelim() & arguments.filename;

			fileMove(tempDir & m.globalConfig().getFileDelim() & filename,newFilePath);

			announceAssetEvent(oldFilePath,'onAfterAssetDate',m,arguments.resourcepath);
			announceAssetEvent(newFilePath,'onAfterAssetSave',m,arguments.resourcepath);

			return response;
		}

		remote any function childdir( siteid,directory,resourcePath )  {

			arguments.siteid == "" ? "default" : arguments.siteid;
			arguments.directory = arguments.directory == "" ? "" : arguments.directory;
			arguments.directory = rereplace(arguments.directory,"\\",application.configBean.getFileDelim(),"all");

			// hasrestrictedfiles

			var permission = checkPerms(arguments.siteid,'edit',resourcePath);
			var response = { success: 0,failed: [],saved: []};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			response.valid = 0;
			response.folders = [];

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);

			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");

			response.success = 1;

			if(!DirectoryExists(filePath)) {
				return response;
			}

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			var dirlist = directoryList(filePath,false,'name','','',"dir");

			if(ArrayLen(dirlist)) {
				response.folders = dirlist;
			}

			response.valid = 1;
			return response;
		}

		function ensureUnique(filename){
			var pass=0;

			var fileParts=listToArray(filename,".");
			var fileExt="";

			if(arrayLen(fileParts) > 1){
				fileExt=fileParts[arrayLen(fileParts)];
				arrayDeleteAt(fileParts,arrayLen(fileParts));
			}

			while(fileExists(filename)){
				pass++;
				filename=arrayToList(fileParts,'.') & pass & "." & fileExt;
			}

			return filename;
		}

		remote any function upload( siteid,directory,formData,resourcePath )  {

			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);
			var fileWriter=getBean('fileWriter');

     		if(!m.validateCSRFTokens(context='upload')){
				throw(type="invalidTokens");
			}

			arguments.directory = arguments.directory == "" ? "" : arguments.directory;
			arguments.directory = rereplace(arguments.directory,"\\",application.configBean.getFileDelim(),"all");

			// hasrestrictedfiles

			var permission = checkPerms(arguments.siteid,'upload',resourcePath);
			var response = { success: 0,failed: [],saved: []};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var allowedExtensions = m.getBean('configBean').getFMAllowedExtensions();
			var tempDir = m.globalConfig().getTempDir();

			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath))){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			response.uploaded = fileUploadAll(tempDir,'',"MakeUnique");
			response.allowedExtensions = allowedExtensions;
			response.success = 1;

			for(var i = 1; i lte ArrayLen(response.uploaded);i++ ) {
				var item = response.uploaded[i];
				var valid = false;
				if(m.currentUser().isSuperUser() || listFindNoCase(allowedExtensions,item.serverfileext)) {
					try {
						local.newitempath=conditionalExpandPath(filePath) & m.globalConfig().getFileDelim() & replace(item.serverfile," ","-","all");					
						local.newitempath=ensureUnique(local.newitempath);

						fileMove(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile,local.newitempath );
						//hack to ensure svg files to have the correct content type on s3
						if(listFirst(local.newitempath,':')=='s3' && listLast(local.newitempath,'.')=='svg'){
							try{
								storeSetMetadata(
									arguments.filepath,
									{
										"Content-Type"='image/svg+xml'
									}
								);
								storeSetACL(
									arguments.filepath,
									[{
										group='all',
										permission='read'
									}]
								);
							} catch (any e){}
						}
						ArrayAppend(response.saved,item);
						announceAssetEvent(local.newitempath,'onAfterAssetSave',m,arguments.resourcepath);
					}
					catch( any e ) {
						logError(e);
						throw( message = "Unable to move file",type="customExp");
						//ArrayAppend("Unable to move file",item);
					}
				}
				else {
					fileDelete(item.serverdirectory & m.globalConfig().getFileDelim() & item.serverfile);
					ArrayAppend(response.failed,item);
					response.success = 0;
				}
			}


			return response;
		}

		remote any function edit( siteid,directory,filename,filter="",pageIndex=1,resourcepath )  {
			arguments.siteid == "" ? "default" : arguments.siteid;
			arguments.pageindex == isNumeric(arguments.pageindex) ? arguments.pageindex : 1;

			var permission = checkPerms(arguments.siteid,'edit',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var path = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,path)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			try {
				var fileContent = fileRead(path);
			}
			catch( any e ) {
				logError(e);
				throw( message = "Unable to edit file",type="customExp");
			}

			response['content'] = fileContent;

			response.success = 1;
			return response;

		}

		remote any function update( siteid,directory,filename,filter="",resourcepath,content )  {
			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

     		if(!m.validateCSRFTokens(context='update')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'write',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var path = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,path)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			var complete=(m.siteConfig('isremote') || (isdefined('url.completepath') && isBoolean(url.completepath) && url.completepath));
			var info={
				url=getBaseResourcePath(arguments.siteid,arguments.resourcePath,complete) & replace(arguments.directory,"\","/","all")
			};

			m.event('fileInfo',info).announceEvent('onAfterImageManipulation');

			try {
				fileWrite(path,arguments.content);
				announceAssetEvent(path,'onAfterAssetSave',m,arguments.resourcepath);
			}
			catch( any e ) {
				logError(e);
				throw( message = "Unable to update file",type="customExp");
			}

			response.success = 1;
			return response;
		}

		remote any function delete( siteid,directory,filename,filter="",pageIndex=1,resourcePath )  {
			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

     		if(!m.validateCSRFTokens(context='delete')){
				throw(type="invalidTokens");
			}

			arguments.pageindex == isNumeric(arguments.pageindex) ? arguments.pageindex : 1;

			var permission = checkPerms(arguments.siteid,'delete',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var path = conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,path)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			try {

				var info = getFileInfo ( path );

				if( info.type == "directory") {
					var list=directoryList(path,false,'query');

					if(list.recordcount) {
							response.message = "Directory is not empty.";
							throw( message = response.message,type="customExp");
							return response;
					} else {
						directoryDelete(path);
					}
				}
				else {
					fileDelete(path);
					announceAssetEvent(path,'onAfterAssetDelete',m,arguments.resourcepath);
				}

			}
			catch( customExp e ) {
				throw( message = response.message,type="customExp");
			}
			catch( any e ) {
				throw( message = "Unable to delete file",type="customExp");
			}

			response.success = 1;
			return response;
		}

		remote any function rename( siteid,directory,filename,name,resourcePath )  {
			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

     		if(!m.validateCSRFTokens(context='rename')){
				throw(type="invalidTokens");
			}

			var permission = checkPerms(arguments.siteid,'rename',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			var ext = "." & rereplacenocase(arguments.filename,".*\.","");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}


			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.name & ext)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			try {
				if(FileExists(conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename)){

					var oldFilePath=conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;
					var newFilePath=conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.name & ext;
					filemove(oldFilePath,newFilePath);

					announceAssetEvent(oldFilePath,'onAfterAssetDelete',m,arguments.resourcepath);
					announceAssetEvent(newFilePath,'onAfterAssetSave',m,arguments.resourcepath);

				} else if(DirectoryExists(conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename)){
					var frompath=conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;
					var topath=conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.name;
					var list=directoryList(frompath,true,'query');
					var f=1;
					if(list.recordcount){
						for(f=1;f<=list.recordcount;f++){
							if(list.type[f]=='file'){
								announceAssetEvent(list.name[f],'onAfterAssetDelete',m,arguments.resourcepath);
							}
						}
					}
					directoryRename(frompath,topath);
					list=directoryList(topath,true,'query');
					if(list.recordcount){
						for(f=1;f<=list.recordcount;f++){
							if(list.type[f]=='file'){
								announceAssetEvent(list.name[f],'onAfterAssetSave',m,arguments.resourcepath);
							}
						}
					}
				}
			}
			catch( any e ) {
				throw( message = "Unable to rename file",type="customExp");
			}
			response.success = 1;
			return response;
		}

		remote any function addFolder( siteid,directory,name,filter="",pageIndex=1,resourcePath )  {
			arguments.siteid == "" ? "default" : arguments.siteid;

			var m=getBean('m').init(arguments.siteid);

     		if(!m.validateCSRFTokens(context='addfolder')){
				throw(type="invalidTokens");
			}

			arguments.pageindex == isNumeric(arguments.pageindex) ? arguments.pageindex : 1;

			var permission = checkPerms(arguments.siteid,'addFolder',resourcePath);
			var response = { success: 0};

			if(!permission.success) {
				response.permission = permission;
				response.message = permission.message;
				return response;
			}

			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = baseFilePath  & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.name)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			try {
				directorycreate(conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.name);
			}
			catch( any e ) {
				throw( message = "Unable to add directory",type="customExp");
			}

			return true;
		}

		private any function getResourceBundle(siteid) {
			arguments.siteid == "" ? "default" : arguments.siteid;
			var m=getBean('$').init(arguments.siteid);
			var sessionData=getSession();
			param name="sessionData.rb" default="en_US";
			var rb = application.rbFactory.getKeyStructure(sessionData.rb,'filebrowser');

			return rb;
		}

		function getImageObject(filepath=''){
			if(len(arguments.filepath)){
				lock name="imageNew#hash(arguments.filepath)#" timeout="10" {
					return imageNew(arguments.filePath);
				}
			} else {
				return imageNew();
			}
		}

		function readImageInfo(imageObject,source='default'){
			lock name="imageInfo#hash(arguments.source)#" timeout="10" {
				return imageInfo(arguments.imageObject);
			}
		}

		remote any function getImageInfo(siteid,directory,filename,resourcePath,subfolder){
			var response={};


			var m = application.serviceFactory.getBean('m').init(arguments.siteid);
			var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
			var filePath = '';

			if(len(arguments.subfolder)) {
				filePath = baseFilePath & rereplace(arguments.subfolder,"\.{1,}","\.","all");
			}
			else {
				filePath = baseFilePath & m.globalConfig().getFileDelim() & rereplace(arguments.directory,"\.{1,}","\.","all");
			}

			var ext = rereplacenocase(arguments.filename,".[^\.]*","");

//			return [arguments,filePath,baseFilePath];

			if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename)){
				throw(message="Illegal file path",errorcode ="invalidParameters");
			}

			try {
				var fullpath=conditionalExpandPath(filePath) & application.configBean.getFileDelim() & arguments.filename;
				var iinfo = readImageInfo(getImageObject(fullpath),fullpath);
				if( isStruct(iinfo) ) {
					response['height'] = iinfo.height;
					response['width'] = iinfo.width;
					response['success']=1;
				}
			} catch(any e){
				response['success']=0;
				writeLog(type="Error", log="exception", text="file browser Request Error");
				logError(e);
			}

			return response;
		}

	remote any function browse( siteid,directory,filterResults="",pageIndex=1,sortOn="",sortDir="",resourcePath,itemsPerPage=25,settings=0,filterDepth=0,ignoreFolders=0,imagesOnly=0,completepath=false )  {

		arguments.siteid == "" ? "default" : arguments.siteid;
		arguments.pageindex == isNumeric(arguments.pageindex) ? arguments.pageindex : 1;

		if(structKeyExists(url,'completepath')) {
			arguments.completepath = url.completepath;
		}

		var m=getBean('$').init(arguments.siteid);
		var currentSite = application.settingsManager.getSite(arguments.siteid);
		var permission = checkPerms(arguments.siteid,'browse',resourcePath);
		var response = { success: 0};
		var recurseFolder = filterDepth == true && len(arguments.filterResults) ? true : false;

		if(!permission.success) {
			response.permission = permission;
			response.message = permission.message;
			return response;
		}

		if(arguments.settings) {
			// list of allowable editable files and files displayed as "images"
			var editfilelist = listToArray(m.globalConfig().getValue(property='filebrowsereditlist',defaultValue="txt,cfm,cfc,hbs,html,htm,cfml,min.js,js,min.css,css,json,xml.cfm,js.cfm,less,properties,scss,xml,yml")); // settings.ini.cfm: filebrowsereditlist
			var imagelist = listToArray(m.globalConfig().get(property='filebrowserimagelist',defaultValue="gif,jpg,jpeg,png,svg,webp")); // settings.ini.cfm: filebrowserimagelist
			var ratios = listToArray(m.globalConfig().get(property='filebrowseraspectratios',defaultValue="4:3:1.3333,2:3:0.6666,1:1:1"));

			var aspectratios = [];

			for(var x = 1;x<=ArrayLen(ratios);x++) {
				aspectratios[x] = ListToArray(ratios[x],":");
			}

			var rb = getResourceBundle(arguments.siteid);
			response.settings = {
				editfilelist=editfilelist,
				imagelist=imagelist,
				rb=rb,
				aspectratios=aspectratios
			};
		}

		// m.siteConfig().getFileDir() ... OS file path (no siteid)
		// m.siteConfig().getFileAssetPath() ... includes siteid (urls)

		var m = application.serviceFactory.getBean('m').init(arguments.siteid);

		var baseFilePath = getBaseFileDir( arguments.siteid,arguments.resourcePath );
		var filePath = baseFilePath & rereplace(arguments.directory,"\.{1,}","\.","all");
		var expandedFilePath = conditionalExpandPath(filePath);
		var expandedBaseFilePath=conditionalExpandPath(baseFilePath);
	
		if(!isPathLegal(arguments.siteid,arguments.resourcepath,conditionalExpandPath(filepath))){
			throw(message="Illegal file path",errorcode ="invalidParameters");
		}

		if(!directoryExists(expandedFilePath)){
			expandedFilePath=conditionalExpandPath(baseFilePath);
			arguments.directory='';
		}

		var frow = {};

		response['resourcepath']=arguments.resourcepath;
		response['items'] = [];
		response['links'] = {};
		response['folders'] = [];
		response['itemsperpage'] = arguments.itemsPerPage;

		response['directory'] = arguments.directory == "" ? "" : arguments.directory;
		response['directory'] = rereplace(response['directory'],"\\","\/","all");
		response['directory'] = rereplace(response['directory'],"$\\","");

		// move to getBaseResourcePath() --> getFileAssetPath()
		var complete=(m.siteConfig('isremote') || (isdefined('arguments.completepath') && isBoolean(arguments.completepath) && arguments.completepath));
		var preAssetPath = getBaseResourcePath(siteid=arguments.siteid,resourcePath=arguments.resourcePath,complete=complete);
		var assetPath = preAssetPath & response['directory'];

		// recurseFolder
		var directoryPermissions = getDirectoryPerm( m,siteid,expandedFilePath,baseFilePath,resourcePath,recurseFolder );
		
		// FILTER DIRECTORY
		var rsDirectory = directoryList(expandedFilePath,recurseFolder,"query");

		response['startindex'] = 1 + response['itemsperpage'] * pageIndex - response['itemsperpage'];
		response['endindex'] = response['startindex'] + response['itemsperpage'] - 1;

		var sqlString = "SELECT * from sourceQuery where 1=1";

		var qObj = new query();
		qObj.setName("files");
		qObj.setDBType("query");
		qObj.setAttributes(sourceQuery=rsDirectory);

		if(len(arguments.filterResults)) {
			sqlString &= " and type='File' AND UPPER(name) LIKE :filtername";
			qObj.addParam( name="filtername",value="%#ucase(arguments.filterResults)#%",cfsqltype="cf_sql_varchar" );
		}
		else if(arguments.ignoreFolders) {
			sqlString &= " and type='File'";
		}

		if(len(arguments.sortOn)) {
			sqlString &= " ORDER by type ASC,";

			switch(arguments.sortOn) {
				case  "size":
					sqlString &= " size";
					break; 
				case  "modified":
					sqlString &= " datelastmodified";
					break; 
				default:
					sqlString &= " name";
					break; 
			}
			switch(arguments.sortDir) {
				case  "desc":
					sqlString &= " DESC";
					break; 
				default:
					sqlString &= " ASC";
					break; 
			}
		}
		else {
			sqlString &= " ORDER by type,name";
		}

		qObj.setSQL( sqlString );

		var rsExecute = qObj.execute();
		var rsFiles = rsExecute.getResult();
		var rsPrefix = rsExecute.getPrefix();

		queryAddColumn(rsFiles,'subfolder',[]);

		for(var i = 1;i <= rsFiles.recordcount;i++) {
			rsFiles['subfolder'][i] = replace(replaceNoCase(rsFiles['directory'][i],expandedBaseFilePath,""),"\","/","all");
		}
		
		response['endindex'] = response['endindex'] > rsFiles.recordCount ? rsFiles.recordCount : response['endindex'];

		//response['res'] = rsFiles;
		response['totalpages'] = ceiling(rsFiles.recordCount / response['itemsperpage']);
		response['pageindex'] = arguments.pageindex;
		response['totalitems'] = rsFiles.recordCount;
		//response['pre'] = serializeJSON(rsPrefix);
			//writeDump(response);abort;
//			response['sql'] = rsExecute.getSQL();

		for(var x = response['startindex'];x <= response['endindex'];x++) {
			frow = {};
			frow['fullname'] = rsFiles['name'][x];
			frow['ext'] = rereplace(frow['fullname'],".*\.","");
			frow['isfolder'] = rsFiles['type'][x] == 'Dir' ? 1 : 0;

			frow['isfile'] = rsFiles['type'][x] == 'File' ? 1 : 0;
			//frow['subfolder'] = processSubFolder(rsFiles['subfolder'][x],conditionalExpandPath(baseFilePath),frow['isfile']);
			frow['subfolder'] = rsFiles['subfolder'][x];

			// skip if it fails permissions
			if(!hasAccessPermission(frow,directoryPermissions)) {
				continue;
			}

			frow['size'] = int(rsFiles['size'][x]/1000);
			frow['name'] = rereplace(frow['fullname'],"\.[^.]*$","");
			frow['type'] = rsFiles['type'][x];
			frow['isimage'] = listFindNoCase(m.globalConfig().get(property='filebrowserimagelist',defaultValue="gif,jpg,jpeg,png,webp"),frow['ext']);
			frow['info'] = {};
			if(frow['isfile']) {
				frow['ext'] = rereplace(frow['fullname'],".*\.","");
			}
			frow['lastmodified'] = rsFiles['datelastmodified'][x];
			frow['lastmodifiedshort'] = LSDateFormat(rsFiles['datelastmodified'][x],m.getShortDateFormat());
			frow['url'] = preAssetPath & frow['subfolder'] & "/" & frow['fullname'];

			if(frow['isfile'] && arguments.imagesOnly && !listContains('gif,jpg,jpeg,png,webp',frow['ext'])) {
				// skip
			}
			else {
				ArrayAppend(response['items'],frow,true);
			}
		}

		var apiEndpoint=m.siteConfig().getApi(type="json", version="v1").getEndpoint();

		var baseurl=apiEndpoint & "/filebrowser/browse?directory=#esapiEncode("url",arguments.directory)#&resourcepath=#esapiEncode("url",arguments.resourcepath)#&pageIndex=";
		if(response.totalpages > 1) {
			if(response.pageindex < response.totalpages) {
				response['links']['next'] = baseurl & response.pageindex+1;
				response['links']['last'] = baseurl & response.totalpages;
			}
			if(response.pageindex > 1) {
				response['links']['first'] =baseurl & 1;
				response['links']['previous'] = baseurl & (response.pageindex-1);
			}
		}

		response.success = 1;
		return response;
	}

	function processSubFolder(subfolder,baseFilePath,isFile) {
		baseFilePath = replaceNoCase(baseFilePath,"/muraWRM","");
		baseFilePath = replace(baseFilePath,"\","/","all");
		var resp = reReplaceNoCase(subfolder,".*#baseFilePath#",'');
		resp = replace(resp,"\","/","all");
		return resp;
	}
	

	function hasAccessPermission(filedata,directoryPermissions) {
		var path = arguments.filedata['subfolder'];

		if(filedata['isfolder']) {
			path = path & "/" & arguments.filedata['fullname'];
		}
		/*
		dump(path);
		dump(arguments.directoryPermissions);
		dump(structKeyExists(arguments.directoryPermissions,path));
		*/

		if(structKeyExists(arguments.directoryPermissions,path)) {
			if(arguments.directoryPermissions[path]) {
				return true;
			}
			else {
				return false;
			}
		}
		else {
			return true;
		}
	}


	function getDirectoryPerm( m,siteid,expandedFilePath,baseFilePath,resourcePath,recurseFolder ) {
		var response = {};

		if(m.getCurrentUser().isSuperUser() || m.getCurrentUser().isAdminUser()){
			return response;
		}

		var full = {};
		var i = 0;
		var permstruct = {};
		var usrGroups = application.usermanager.readMemberships(application.usermanager.getCurrentUserID());
		var subfolder = replaceNoCase(expandedFilePath,baseFilePath,'');
		var path = replace(subfolder,"\","/","all");
		var perm = application.permUtility.getFolderPermissions(arguments.siteid,path,permstruct,usrGroups,recurseFolder);
		response[path] = perm.permission == 'editor' ? 1 : 0;

		var rsDirectoriesAll = directoryList(path=expandedFilePath,recurse=recurseFolder,listinfo="query",sort="directory",type="dir");
		var rs = new Query(
			name="rsCheck",
			dbtype="query",
			rsDirectoriesAll=rsDirectoriesAll,
			sql = "SELECT *
			FROM rsDirectoriesAll
			WHERE
				directory not like '%node_modules%'
			AND
				directory not like '%.git%'"
		);
		var rsDirectories=rs.execute().getResult();

		rs = new Query(
			name="rsCheck",
			dbtype="query",
			rsDirectoriesAll=rsDirectoriesAll,
			sql = "SELECT *
			FROM rsDirectoriesAll
			WHERE
				directory like '%node_modules%'
			OR
				directory like '%.git%'"
		);
		var rsDirectoriesEx=rs.execute().getResult();
		
		for(var dir in rsDirectoriesEx) {
			response[path] = 0;
		}

		for(var dir in rsDirectories) {
			i++;
			subfolder = replaceNoCase(dir.directory,baseFilePath,'');
			path = subfolder & "/" & dir.name;
			if(find("node_modules",path)) {
				response[path] = 0;
				continue;
			}
			perm = application.permUtility.getFolderPermissions(arguments.siteid,path,permstruct,usrGroups);

			response[path] = perm.permission == 'editor' ? 1 : 0;
		}
	
		return response;
	}

	function isPathLegal(siteid,resourcePath, path){
		var currentUser=getCurrentUser();
		if(arguments.resourcepath != 'User_Assets' && !currentUser.isSuperUser()){
			return false;
		}
		if(find("../",arguments.path)){
			return false;
		}

		var expandedRootPath=replaceNoCase(conditionalExpandPath(getBaseFileDir( arguments.siteid,arguments.resourcePath )), "\", "/", "ALL");
		var rootPath=replaceNoCase(getBaseFileDir( arguments.siteid,arguments.resourcePath ), "\", "/", "ALL");

		arguments.path=replaceNoCase(arguments.path, "\", "/", "ALL");

		var s3assets=getBean('configBean').get('s3assets');

		if(len(s3assets)){
			expandedRootPath=replaceNoCase(rootPath,s3assets,"/s3assets/");
			arguments.path=replaceNoCase(arguments.path,s3assets,"/s3assets/");
		}

		var result = (
			len(arguments.path) >= len(expandedRootPath) && lcase(left(arguments.path,len(expandedRootPath))) == lcase(expandedRootPath)
			|| len(arguments.path) >= len(rootPath) && lcase(left(arguments.path,len(rootPath))) == lcase(rootPath)
		);

		if(!result){
			writeDump("ILLEGAL PATH");
			writeDump(lcase(left(arguments.path,len(rootPath)) ));
			writeDump(lcase(rootPath));
			WriteDump(arguments);
			abort;
		}

		return result;

	}

	function conditionalExpandPath(path){
		if(isDefined('server.separator.file') and server.separator.file == "\"){
			return expandPath(arguments.path);
		} else {
			var expandedPath=expandPath(arguments.path);
			if(directoryExists(expandedPath)){
				return expandedPath;
			} else {
				return arguments.path;
			}
		}
	}

	function announceAssetEvent(filepath,eventName,m,resourcepath){
		var pathArray=listToArray(Replace(arguments.filepath, "\", "/", "ALL"),"/");
		var assetsDirIdx=arrayFind(pathArray,'assets');
		var fileInfo={
			path=arguments.filepath
		};
		//Only file actions under the assets directory should be announce
		if(assetsDirIdx && arrayFind(pathArray,arguments.m.event('siteid'))){
			pathArray=arraySlice(pathArray,assetsDirIdx+1,arrayLen(pathArray)-assetsDirIdx);
			fileInfo.url=getBaseResourcePath(siteid=arguments.m.event('siteid'),resourcepath=arguments.resourcepath) & "/" & arrayToList(pathArray,"/");
			//dump(fileInfo);abort;
			arguments.m.event('fileInfo',fileInfo).announceEvent(arguments.eventName);
		}
	}

	function isS2() {
		var sessionData=getSession();
		return listFindNoCase(sessionData.mura.memberships,'S2');
	}


}
