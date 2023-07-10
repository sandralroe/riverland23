//  license goes here 
/**
 * This provides file service level logic functionality
 */
component extends="mura.baseobject" output="false" hint="This provides file service level logic functionality" {

	public function init(required any fileDAO, required any configBean, required any settingsManager) output=false {
		variables.configBean=arguments.configBean;
		variables.fileDAO=arguments.fileDAO;
		variables.settingsManager=arguments.settingsManager;
		if ( listLen(variables.configBean.getFileStoreAccessInfo(),"^") == 3 ) {
			variables.bucket=listLast(variables.configBean.getFileStoreAccessInfo(),"^");
		} else {
			variables.bucket="sava";
		}
		variables.imageProcessor=new processImgCfimage(arguments.configBean,arguments.settingsManager);
		return this;
	}

	public function create(required any fileObj, required any contentid, required any siteid, required any filename, required string contentType, required string contentSubType, required numeric fileSize, required string moduleID, required string fileExt, required any fileObjSmall, required any fileObjMedium, required any fileID="#createUUID()#", required any fileObjSource="", required string credits="", required string caption="", required string alttext="", required string remoteID="", required string remoteURL="", required string remotePubDate="", remoteSource="", required string remoteSourceURL="", required string exif="") output=false {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		return variables.fileDAO.create(argumentCollection=arguments);
	}

	public function deleteAll(required string contentID) output=false {
		variables.fileDAO.deleteAll(arguments.contentID);
	}

	public function deleteVersion(required any fileID) output=false {
		variables.fileDAO.deleteVersion(arguments.fileID);
	}

	public function deleteIfNotUsed(required any fileID, required any contentHistID, siteid='') output=false {
		variables.fileDAO.deleteIfNotUsed(arguments.fileID,arguments.contentHistID, arguments.siteid);
	}

	public function readMeta(required any fileID) output=false {
		return variables.fileDAO.readMeta(arguments.fileID);
	}

	public function read(required any fileID) output=false {
		return variables.fileDAO.read(arguments.fileID);
	}

	public function readAll(required any fileID) output=false {
		return variables.fileDAO.readAll(arguments.fileID);
	}

	public function readSmall(required any fileID) output=false {
		return variables.fileDAO.readSmall(arguments.fileID);
	}

	public function readMedium(required any fileID) output=false {
		return variables.fileDAO.readMedium(arguments.fileID);
	}

	public function renderFile(string fileID, required string method="inline", required string size="") output=true {
		var rsFileData="";
		var delim="";
		var theFile="";
		var theFileLocation="";
		var pluginManager=getBean("pluginManager");
		var fileCheck="";
		if ( !len(arguments.method) ) {
			arguments.method="inline";
		}
		if ( !isValid("UUID",arguments.fileID) || find(".",arguments.size) ) {
			getBean("contentServer").render404();
		}
		switch ( variables.configBean.getFileStore() ) {
			case  "database":
				rsFileData=read(arguments.fileid);
				if ( !rsFileData.recordcount ) {
					getBean("contentServer").render404();
				}
				arguments.siteID=rsFileData.siteid;
				arguments.rsFile=rsFileData;
				var pluginEvent = new mura.event(arguments);
				pluginManager.announceEvent("onBeforeFileRender",pluginEvent);
				cfheader( name="Content-Disposition", value='#arguments.method#;filename="#rsfileData.filename#"' );
				cfheader( name="Content-Length", value=arrayLen(rsFileData.image) );
				if ( variables.configBean.getCompiler() == 'Adobe' ) {
					new mura.content.file.renderAdobe("#rsfileData.contentType#/#rsfileData.contentSubType#",rsFileData.image);
				} else {
					new mura.content.file.renderLucee("#rsfileData.contentType#/#rsfileData.contentSubType#",rsFileData.image);
				}
				pluginManager.announceEvent("onAfterFileRender",pluginEvent);
				break;
			case  "filedir":
				rsFileData=readMeta(arguments.fileid);
				if ( !rsFileData.recordcount ) {
					getBean("contentServer").render404();
				}
				arguments.siteID=rsFileData.siteid;
				arguments.rsFile=rsFileData;
				var pluginEvent = new mura.event(arguments);
				pluginManager.announceEvent("onBeforeFileRender",pluginEvent);
				if ( listFindNoCase('png,jpg,jpeg,gif,webp',rsFileData.fileExt) && len(arguments.size) ) {
					theFileLocation="#variables.configBean.getFileDir()#/#variables.settingsManager.getSite(rsFile.siteid).getFilePoolID()#/cache/file/#arguments.fileID#_#arguments.size#.#rsFileData.fileExt#";
					if ( !fileExists(theFileLocation) ) {
						theFileLocation="#variables.configBean.getFileDir()#/#variables.settingsManager.getSite(rsFile.siteid).getFilePoolID()#/cache/file/#arguments.fileID#.#rsFileData.fileExt#";
					}
				} else {
					theFileLocation="#variables.configBean.getFileDir()#/#variables.settingsManager.getSite(rsFile.siteid).getFilePoolID()#/cache/file/#arguments.fileID#.#rsFileData.fileExt#";
				}
				streamFile(theFileLocation,rsfileData.filename,"#rsfileData.contentType#/#rsfileData.contentSubType#",arguments.method,rsfileData.created);
				pluginManager.announceEvent("onAfterFileRender",pluginEvent);
				break;
			case  "S3":
				rsFileData=readMeta(arguments.fileid);
				if ( !rsFileData.recordcount ) {
					getBean("contentServer").render404();
				}
				arguments.siteID=rsFileData.siteid;
				arguments.rsFile=rsFileData;
				var pluginEvent = new mura.event(arguments);
				pluginManager.announceEvent("onBeforeFileRender",pluginEvent);
				renderS3(fileid=arguments.fileid,method=arguments.method,size="normal");
				pluginManager.announceEvent("onAfterFileRender",pluginEvent);
				break;
		}
	}

	public function renderSmall(string fileID, required string method="inline") output=true {
		var rsFile="";
		var theFile="";
		var theFileLocation="";
		var fileCheck="";
		if ( !isValid("UUID",arguments.fileID) ) {
			getBean("contentServer").render404();
		}
		switch ( variables.configBean.getFileStore() ) {
			case  "database":
				rsFile=readSmall(arguments.fileid);
				if ( !rsFile.recordcount ) {
					getBean("contentServer").render404();
				}
				cfheader( name="Content-Disposition", value='#arguments.method#;filename="#rsfile.filename#"' );
				cfheader( name="Content-Length", value=arrayLen(rsFile.imageSmall) );
				if ( variables.configBean.getCompiler() == 'Adobe' ) {
					new mura.content.file.renderAdobe("#rsfile.contentType#/#rsfile.contentSubType#",rsFile.imageSmall);
				} else {
					new mura.content.file.renderLucee("#rsfile.contentType#/#rsfile.contentSubType#",rsFile.imageSmall);
				}
				break;
			case  "filedir":
				rsFile=readMeta(arguments.fileid);
				if ( !rsFile.recordcount ) {
					getBean("contentServer").render404();
				}
				theFileLocation="#variables.configBean.getFileDir()#/#variables.settingsManager.getSite(rsFile.siteid).getFilePoolID()#/cache/file/#arguments.fileID#_small.#rsFile.fileExt#";
				streamFile(theFileLocation,rsFile.filename,"#rsFile.contentType#/#rsFile.contentSubType#",arguments.method,rsFile.created);
				break;
			case  "S3":
				renderS3(fileid=arguments.fileid,method=arguments.method,size="_small");
				break;
		}
	}

	public function renderMedium(string fileID, required string method="inline") output=true {
		var rsFile="";
		var theFile="";
		var theFileLocation="";
		var fileCheck="";
		if ( !isValid("UUID",arguments.fileID) ) {
			getBean("contentServer").render404();
		}
		switch ( variables.configBean.getFileStore() ) {
			case  "database":
				rsFile=readMedium(arguments.fileid);
				if ( !rsFile.recordcount ) {
					getBean("contentServer").render404();
				}
				cfheader( name="Content-Disposition", value='#arguments.method#;filename="#rsfile.filename#"' );
				cfheader( name="Content-Length", value=arrayLen(rsFile.imageMedium) );
				if ( variables.configBean.getCompiler() == 'Adobe' ) {
					new mura.content.file.renderAdobe("#rsfile.contentType#/#rsfile.contentSubType#",rsFile.imageMedium);
				} else {
					new mura.content.file.renderLucee("#rsfile.contentType#/#rsfile.contentSubType#",rsFile.imageMedium);
				}
				break;
			case  "filedir":
				rsFile=readMeta(arguments.fileid);
				if ( !rsFile.recordcount ) {
					getBean("contentServer").render404();
				}
				theFileLocation="#variables.configBean.getFileDir()#/#variables.settingsManager.getSite(rsFile.siteid).getFilePoolID()#/cache/file/#arguments.fileID#_medium.#rsFile.fileExt#";
				streamFile(theFileLocation,rsFile.filename,"#rsFile.contentType#/#rsFile.contentSubType#",arguments.method,rsFile.created);
				break;
			case  "S3":
				renderS3(fileid=arguments.fileid,method=arguments.method,size="_medium");
				break;
		}
	}

	/**
	 * deprecated in favor of streamFile
	 */
	public function renderMimeType(required string mimeType="", required any file="") output=true {
		switch ( variables.configBean.getCompiler() ) {
			case  "adobe":
				new mura.content.file.renderAdobe(arguments.mimeType,arguments.file);
				break;
			default:
				new mura.content.file.renderLucee(arguments.mimeType,arguments.file);
				break;
		}
	}

	public struct function Process(file, siteID) {
		var fileStruct=variables.imageProcessor.process(arguments.file,arguments.siteID);
		if ( !structKeyExists(fileStruct,"fileObjSource") ) {
			fileStruct.fileObjSource="";
		}
		return fileStruct;
	}

	public function renderS3(required string fileid, string method="inline", string size="", string bucket="#variables.bucket#", boolean debug="false") output=true {
		local.rsFile	= readMeta(arguments.fileid);
		local.theFile 	= structNew();
		local.sizeList 	= "_small^_medium";
		local.methodList = "inline^attachment";

		if ( not listFindNoCase(local.sizeList, arguments.size, "^") ) {
			local.size = "";
		} else {
			local.size = arguments.size;
		};

		if ( not listFindNoCase(local.methodList, arguments.method, "^") ) {
			local.method = "inline";
		} else {
			local.method = arguments.method;
		};
		try {
			var theURL="http://" & "#variables.configBean.getFileStoreEndPoint()#/#arguments.bucket#/#local.rsFile.siteid#/cache/file/#arguments.fileid##local.size#.#local.rsFile.fileExt#";
			var httpService=getHttpService();
			httpService.setMethod('get');
			httpService.setGetasbinary('yes');
			httpService.setURL(theURL);
			local.theFile=httpService.send().getPrefix();
		} catch (any cfcatch) {}

		if ( arguments.debug ) {
			writeDump( var=local, label="fileManager.renderS3().local" );
			abort;
		}
		if ( structKeyExists(local.rsFile, "filename") ) {
			cfheader( name="Content-Disposition", value='#local.method#;filename="#local.rsFile.filename#"' );
		}
		if ( structKeyExists(local.theFile, "fileContent") && isArray(local.theFile.fileContent) ) {
			cfheader( name="Content-Length", value=arrayLen(local.theFile.fileContent) );
			if ( structKeyExists(local.rsFile, "contentType") && structKeyExists(local.rsFile, "contentSubType") ) {
				if ( variables.configBean.getCompiler() == 'adobe' ) {
					new mura.content.file.renderAdobe("#local.rsFile.contentType#/#local.rsFile.contentSubType#",local.theFile.fileContent);
				} else {
					new mura.content.file.renderLucee("#local.rsFile.contentType#/#local.rsFile.contentSubType#",local.theFile.fileContent);
				}
			}
		}
	}

	function upload(fileField) output=false {
		cffile( filefield=arguments.fileField, nameconflict="makeunique", destination=variables.configBean.getTempDir(), action="upload", result="local.results" );
		if ( listFindNoCase('jpg,jpeg',local.results.clientFileExt) ) {
			try {
				cfimage( source='#local.results.serverDirectory#/#local.results.serverFile#', name="local.imageObj" );
				local.results.exif=ImageGetEXIFMetadata(local.imageObj);
			} catch (any cfcatch) {
				local.results.exif={};
			}
		} else {
			local.results.exif={};
		}
		return local.results;
	}

	function allowMetaData(metadata) output=false {
		return _allowMetaData(metadata);
	}

	
	function _allowMetaData(metadata) output=false {
		var key="";
		var keyValue="";
		var keyTest="";
		for ( key in arguments.metadata ) {
			if ( isSimpleValue(key) ) {
				keyTest=arguments.metadata['#key#'];
				if ( !isDefined("keyText") ) {
					arguments.metadata['#key#']="";
					keyTest=arguments.metadata['#key#'];
				}
				if ( isStruct(keyTest) && !allowMetaData(keyTest) ) {
					return false;
				} else if ( isSimpleValue(keyTest) && (findNoCase('cf',keyTest)) ) {
					return false;
				}
			} else if ( isStruct(key) && !allowMetaData(key) ) {
				return false;
			}
		}
		return true;
	}

	function getDomainFromHREF(href){
		return reReplace(
				arguments.href,
				"^\w+://([^\/:]+)[\w\W]*$",
				"\1",
				"one"
				);
	}
	
	function convertPortIfDockerInternal(href){
		var domain=getDomainFromHREF(arguments.href);
		var serverPort=getBean('configBean').getServerPort();

		if(request.muraInDocker && domain=='localhost'){
			arguments.href=replaceNoCase(arguments.href,'localhost#serverPort#',"localhost:8888");
			arguments.href=replace(arguments.href,'https://','http://');//probably not needed
		} 
		
		return arguments.href;
	}

	function emulateUpload(required string filePath, required string destinationDir="#variables.configBean.getTempDir()#") output=false {
		var local = structNew();
		//  create a URLconnection to the file to emulate uploading 
		local.filePath=replace(arguments.filePath,'\','/','all');
		local.results=structNew();

		/*
		var filePath=replace(
					replace(
						replace( 
							getValue(getValue('fileField')), 
							site.getFileAssetPath(complete=true) & "/assets/", 
							site.getFileDir() & "/assets/"
						),
						"../",
						"",
						"all"
					),
					"~/",
					"",
					"all"
				);
		*/
		
		try{
			var urlObj=createObject("java","java.net.URL").init(replace(replace(local.filePath,'../','','all'),'~/','','all'));
			var isURL=true;
		}catch(any e){
			var isURL=false;
		}
		
		if(isURL) {
			if(urlObj.getProtocol() != 'file'
				&& getBean('contentServer').bindToDomain(isAdmin=true,domain=urlObj.getHost()) != "--none--"){
				var path=listToArray(urlObj.getPath(),'/');
				var sitesDirIdx=arrayFind(path,'sites');
				if(sitesDirIdx && arrayLen(path) > sitesDirIdx){
					var siteidIdx=sitesDirIdx+1;
					var siteid=path[siteidIdx];
					var firstRealPathIdx=siteidIdx+1;
					var remaining=arrayLen(path)-siteidIdx;
					local.filePath=application.Mura.getBean('settingsManager').getSite(siteid).getFileDir() & "/" & arrayToList(arraySlice(path,firstRealPathIdx,remaining),'/');
				}
			}
		}
		
		if ( find("://",local.filePath) && !(find("s3://",local.filePath) || find("file://",local.filePath)) ) {
			local.isLocalFile=false;
			var httpService=getHttpService();
			httpService.setMethod('get');
			httpService.setGetasbinary('yes');
			/*
				If in docker the external port may not match internal port
				and this can cause an issue if the url is to localhost or 127.0.0.1
			*/
			var emulatedurl=convertPortIfDockerInternal(local.filepath);
			logText("Emulating upload for url: #emulatedurl#");
			httpService.setURL(convertPortIfDockerInternal(emulatedurl));
			httpService.addParam(name="accept-encoding", type="header", value="no-compression");
			/*
				If the url belongs to a site served by this 
				Mura instance send session cookies
			*/
			if(
				isDefined('cookie.cfid') 
				&& isDefined('cookie.cftoken')
				&& getBean('contentServer').bindToDomain(isAdmin=true,domain=getDomainFromHREF(local.filepath)) != "--none--"
			){
				httpService.addParam(name="cfid", type="cookie", value=cookie.cfid);
				httpService.addParam(name="cftoken", type="cookie", value=cookie.cftoken);
			}

			local.remoteGet=httpService.send().getPrefix();
			local.results.contentType=listFirst(local.remoteGet.mimeType ,"/");
			local.results.contentSubType=listLast(local.remoteGet.mimeType ,"/");
			local.results.fileSize=len(local.remoteGet.fileContent);
			if(isDefined('local.remoteGet.responseheader') && structkeyExists(local.remoteGet.responseheader,'Content-Disposition')){
				//inline; filename="itemeditorimage_5ca3c248dc580.png"
				logText("Result has Content-Disposition");
				local.headerArray=listToArray(local.remoteGet.responseheader['Content-Disposition'],';');
				for(local.i in local.headerArray){
					local.iArray=listToArray(local.i,'=');
					if(arrayLen(local.iArray)==2){
						local.filePath=local.iArray[2];
						if(len(local.filePath) > 1 && left(local.filePath,1)=='"'){
							local.filePath=right(local.filePath,len(local.filePath)-1);
						}
						if(len(local.filePath) > 1 && right(local.filePath,1)=='"'){
							local.filePath=left(local.filePath,len(local.filePath)-1);
						}
					}
				}
			} else {
				logText("Result does not have Content-Disposition");
			}
		} else if (find("data:image/",local.filePath)) { //base64 images
			logText("Emulating upload for base64 image");
			local.isLocalFile=false;
			//get extension
			var start = find('/',local.filePath) + 1;
			var end = find(';',local.filePath);
			var fileExt = mid(local.filePath,start, end - start);
			try {
				var image = imageReadBase64(local.filePath);
				cfimage( source='#image#', name="local.imageObj", destination="#arguments.destinationDir#/nameless.#fileExt#", action='write', overwrite="true", isBase64="yes" );
				return emulateUpload("#arguments.destinationDir#/nameless.#fileExt#");
			} catch (any e) {
				logError(e);
				return {};
			}
		} else {
			local.isLocalFile=true;
			local.filePath=replaceNoCase(local.filePath,"file:///","");
			local.filePath=replaceNoCase(local.filePath,"file://","");
			
			logText("Emulating upload for local file: #local.filePath#");

			if ( !fileExists(local.filePath) ) {
				return {};
			}
			if ( application.CFVersion >= 10 ) {
				local.getFileType = fileGetMimeType(local.filePath,false);
				local.getFileInfo = getFileInfo(local.filePath);
				local.results.contentType=listFirst(local.getFileType ,"/");
				local.results.contentSubType=listLast(local.getFileType ,"/");
				local.results.fileSize=local.getFileInfo.size;
			} else {
				if ( !findNoCase("windows",server.os.name) ) {
					local.connection=createObject("java","java.net.URL").init("file://" & local.filePath).openConnection();
				} else {
					local.connection=createObject("java","java.net.URL").init("file:///" & local.filePath).openConnection();
				}
				local.connection.connect();
				local.results.contentType=listFirst(local.connection.getContentType() ,"/");
				local.results.contentSubType=listLast(local.connection.getContentType() ,"/");
				local.results.fileSize=local.connection.getContentLength();
				local.connection.getInputStream().close();
				
			}
		}
	
		local.results.serverFileExt=listLast(local.filePath ,".");
		local.results.serverDirectory=arguments.destinationDir;
		local.results.serverFile=replace(listLast(local.filePath ,"/")," ","-","all");
		local.results.clientFile=local.results.serverFile;
		local.results.serverFileName=listDeleteAt(local.results.serverFile,listLen(local.results.serverFile ,"."),".");
		local.results.clientFileName=listDeleteAt(local.results.clientFile,listLen(local.results.clientFile ,"."),".");
		local.results.clientFileExt=listLast(local.filePath ,".");
		if ( listFind("/,\",right(local.results.serverDirectory,1)) ) {
			local.results.serverDirectory=left(local.results.serverDirectory, len(local.results.serverDirectory)-1 );
		}
		local.fileuploaded=false;
		local.filecreateattempt=1;
		while ( not local.fileuploaded ) {
			if ( !fileExists("#local.results.serverDirectory#/#local.results.serverFile#") ) {
				if ( local.isLocalFile ) {
					if ( listFindNoCase('jpg,jpeg,webp',local.results.clientFileExt) ) {
						try {
							cfimage( source=local.filePath, name="local.imageObj" );
							local.results.exif=ImageGetEXIFMetadata(local.imageObj);
						} catch (any e) {
							logError(e);
							local.results.exif={};
						}
					} else {
						local.results.exif={};
					}
					cffile( source=local.filePath, destination="#local.results.serverDirectory#/#local.results.serverFile#", action="copy" );
				} else {
					cffile( output=local.remoteGet.fileContent, file="#local.results.serverDirectory#/#local.results.serverFile#", action="write" );
					if ( listFindNoCase('jpg,jpeg,webp',local.results.clientFileExt) ) {
						try {
							cfimage( source="#local.results.serverDirectory#/#local.results.serverFile#", name="local.imageObj" );
							local.results.exif=ImageGetEXIFMetadata(local.imageObj);
						} catch (any e) {
							logError(e);
							local.results.exif={};
						}
					} else {
						local.results.exif={};
					}
				}
				local.fileuploaded=true;
			} else {
				local.results.serverFile=local.results.serverFileName & local.filecreateattempt & "." & local.results.serverFileExt;
				local.filecreateattempt=local.filecreateattempt+1;
			}
		}
		return local.results;
	}

	function isPostedFile(fileField) output=false {
		return (structKeyExists(form,arguments.fileField) && listFindNoCase("tmp,upload",listLast(form['#arguments.fileField#'],"."))) || listFindNoCase("tmp,upload",listLast(arguments.fileField,"."));
	}

	/**
	 * requestHasRestrictedFiles
	 * 
	 * @returns
	 * 0 : NO restricted files found
	 * 1 : Restricted files found
	 * 2|FileSize : Image file size is too big
	 *
	 * @scope 
	 * @allowedExtensions 
	 */
	function requestHasRestrictedFiles(scope="#form#", allowedExtensions="#getBean('configBean').getFMAllowedExtensions()#") {

		var temptext='';
		var classExtensionManager=getBean('configBean').getClassExtensionManager();
		var allowedImageExtensions=getBean('configBean').getAllowedImageExtensions();
		var maxUploadFileSize=application.configBean.getValue('maxuploadfilesize');

		if(!len(arguments.allowedExtensions)){
			return 0;
		}

		if(structKeyExists(arguments.scope,'siteid')){
			var siteid=arguments.scope.siteid;
		} else {
			var siteid=getSession().siteid;
		}

		if(isdefined('arguments.scope.type') && arguments.scope.type=='Link'){
			arguments.scope=structCopy(arguments.scope);
			structDelete(arguments.scope,'body');
		}

		for (var i in arguments.scope){
			if(structKeyExists(arguments.scope,'#i#') && isSimpleValue(arguments.scope['#i#']) ){
				if(isPostedFile(i)){

					temptext=listLast(getPostedClientFileName(i),'.');

					if(len(tempText) && len(tempText) < 5 && !listFindNoCase(arguments.allowedExtensions,temptext)){
						return 1;
					}
					
					//if image type
					if (listFindNoCase(allowedImageExtensions, temptext)){
						
						var path = listLast(arguments.scope['#i#'],',');
						temptext = getFileInfo(path).size;
						if (temptext > maxUploadFileSize){
							temptext = numberFormat(temptext / 1024,'9');
							return "2|#temptext#kb";
						}
					}
				}

				if(isValid('url',arguments.scope['#i#']) && right(arguments.scope['#i#'],1) != '/'){

					if(i neq 'newfile' && !classExtensionManager.isFileAttribute(i,siteid)){
						break;
					}

					tempText=arguments.scope['#i#'];

					//if it contains a protocol
					if(reFindNoCase("(https://||http://)", tempText)){

						//strip it out
						tempText=reReplaceNoCase(tempText, "(http://||https://)", "");

						//and then on continue if the url contains a list longer than one
						if(listLen(tempText,'/') ==1) {
							break;
						}
					}

					tempText=listFirst(arguments.scope['#i#'],'?');
					tempText=listLast(tempText,'/');
					tempText=listLast(tempText,'.');

					/*
					if(i=='body'){
						writeDump(var=tempText,abort=1);
					}
					*/

					if(len(tempText) < 5 && !listFindNoCase(arguments.allowedExtensions,temptext)){
						return 1;
					}
				}

			}
		}

		return 0;
	}

	/**
	* I get posted files from request
	*/
	function getPostedClientFileName(required string fieldName) output=false {
		try {
			if ( variables.configBean.getCompiler() == 'Adobe' ) {
				var tmpPartsArray = Form.getPartsArray();
				if ( IsDefined("tmpPartsArray") ) {
					for ( local.tmpPart in tmpPartsArray ) {
						if ( local.tmpPart.isFile() && local.tmpPart.getName() == arguments.fieldName ) {
							return local.tmpPart.getFileName();
						}
					}
				}
			} else {
				return GetPageContext().formScope().getUploadResource(arguments.fieldname).getName();
			}
		} catch (any e) {
			logError(e);
		}
		return "";
	}

	function purgeDeleted(siteid="") output=false {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		variables.fileDAO.purgeDeleted(arguments.siteID);
	}

	function restoreVersion(fileID) output=false {
		variables.fileDAO.restoreVersion(arguments.fileID);
	}

	function cleanFileCache(siteID) output=false {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		var rsDB="";
		var rsDIR="";
		var rsCheck="";
		var filePath="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/";
		var check="";
		var startTime=now();
		//  Allow function to be escaped for huge file directories 
		if ( variables.configBean.getValue('skipCleanFileCache') ) {
			return;
		}

		rsDB=queryExecute(
			"select fileID from tfiles where siteID= :siteid",
			{
				siteid={cfsqltype="cf_sql_varchar", value=arguments.siteID}
			}
		);

		cfdirectory( directory=filePath, name="rsDIR", action="list" );
	
		if(rsDir.recordcount){
			for(var i=1;i <= rsDir.recordcount;i++){
				if ( !find('.svn',rsDir.name[i]) ) {
					rsCheck=queryExecute(
						"select * from rsDB where fileID= :fileid",
						{
							fileid={cfsqltype="cf_sql_varchar", value=left(rsDIR.name[i],35)}
						},
						{
							dbType="query"
						}
					);
					if(
						structKeyExists(application.appBundleRestore,'#arguments.siteid#') 
						&& application.appBundleRestore['#arguments.siteid#'] gt startTime
					){
						return;
					} else if ( !rsCheck.recordcount ) {
						cffile( file='#filepath##rsDir.name[i]#', action="delete" );
					}
				}
					
			}
		}

		cfdirectory( directory=filePath, name="rsDIR", action="list" );
		
		rsCheck=queryExecute(
			"select * from rsDIR where name like '%\_H%' ESCAPE '\'",
			{},
			{
				dbType="query"
			}
		);
		
		if(
			structKeyExists(application.appBundleRestore,'#arguments.siteid#') 
			&& application.appBundleRestore['#arguments.siteid#'] gt startTime
		){
			return;
		} else if ( rsCheck.recordcount ) {
			for(var i=1;i<=rsCheck.recordcount;i++){
				if(
					structKeyExists(application.appBundleRestore,'#arguments.siteid#') 
					&& application.appBundleRestore['#arguments.siteid#'] gt startTime
				){
					return;
				} else if ( listLen(rsCheck.name[i],"_") > 1){
					check=listGetAt(rsCheck.name[i],2,"_");
					if(len(check) > 1){
						check=mid(check,2,1);
						if(isNumeric(check)){
							cffile(action="delete", file="#filepath##rsCheck.name[i]#");
						}
						
					}	
				}
			}

		}
	}

	/**
	* Retrieves all image file data for a single site.
	*/
	query function getImageFilesQuery(required string siteID, required string fields="fileID, fileEXT") output=false {
		var rsDB=queryExecute(
			"select #arguments.fields# from tfiles where siteID= :siteid and fileEXT in ('jpg','jpeg','png','gif','webp')",
			{siteid={cfsqltype="cf_sql_varchar", value=arguments.siteID}},
			getQueryAttrs(readOnly=true)
		);
		return rsDB;
	}

	/**
	* Deletes custom cached images from the image cache based on age.
	*/
	function deleteCustomImageCache(siteID, numeric threshold="1") output=false {
		var cacheFilePath=application.configBean.getFileDir() & "/" & arguments.siteID & "/cache/file/";
		var check = "";
		var rsDir="";
		var thresholdDate = dateAdd("d", -arguments.threshold, now());
		
		cfdirectory( directory=cacheFilePath, name="rsDIR", action="list" );
		
		var rsCustomImages=executeQuery(
			"select * from rsDIR where name like '%_H%' and dateLastModified < :thresholdDate",
			{
				thresholdDate={cfsqltype="cf_sql_timestamp", value=thresholdDate}
			},
			{dbType="query"}
		);
		
		if(rsCustomImages.recordcount){
			for(var i=1;i <= rsCustomImages.recordcount;i++){
				if(isNumeric(replaceNoCase(listGetAt(rsCustomImages.name[i], 2, "_"), "w", "", "one"))){
					cffile(action="delete",file="#cacheFilePath##rsCustomImages.name[i]#");
				}
			}
		}

	}

	/**
	* Rebuilds either the entire image cache or a specific image size for a single site.
	*/
	function rebuildImageCache(siteID, size="") output=false {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		var cacheFilePath=application.configBean.getFileDir() & "/" & arguments.siteID & "/cache/file/";
		var currentSite=variables.settingsManager.getSite(arguments.siteID);
		var currentSource="";
		var imageSize="";
		var rsDB=getImageFilesQuery(arguments.siteid);
		var rsImageSizes="";
		var sizeList=arguments.size;
		//  Size not provided, rebuild all image sizes for site. 
		if ( !len(sizeList) ) {
			rsImageSizes=currentSite.getCustomImageSizeQuery();
			sizeList=listAppend("small,medium,large", valueList(rsImageSizes.name));
		}
		//  Determine source file and rebuild image file cache. 
		if(rsDB.recordcount){
			for(var i=1;i<=rsDB.recordcount;i++){
				currentSource=cacheFilePath & rsDB.fileID[i] & "_source." & rsDB.fileEXT[i];
				if(!fileExists(currentSource)){
					currentSource=cacheFilePath & rsDB.fileID[i] & "." & rsDB.fileEXT[i];
				}
				if(fileExists(currentSource)){
					for ( imageSize in sizeList ) {
						cropAndScale(fileID=rsDB.fileID[i],size=imageSize,siteid=arguments.siteid);
					}
				}
			}
		}

		if ( !len(arguments.size) ) {
			deleteCustomImageCache(arguments.siteID);
		}
	}

	function streamFile(filePath, filename, mimetype, required string method="inline", required lastModified="#now()#", required boolean deleteFile="false") output=false {
		var local=structNew();
		if ( findNoCase("video",arguments.mimetype) ) {
			arguments.method = "attachment";
		}
	
		try {
			if ( structkeyexists(cgi, "http_if_modified_since") ) {
				if ( parsedatetime(cgi.http_if_modified_since) > arguments.lastModified ) {
					cfheader( statustext="Not modified", statuscode=304 );
					abort;
				}
			}
		} catch (any cfcatch) {}
		
		cfheader( name="Last-Modified", value=gethttptimestring(arguments.lastModified) );
		
		local.fileCheck = FileOpen(arguments.filepath, "readBinary");
		cfheader( name="Content-Length", value=listFirst(local.fileCheck.size,' ') );
		FileClose(local.fileCheck);

		cfheader( name="Content-Disposition", value='#arguments.method#;filename="#arguments.filename#"' );
		cfcontent( deletefile=arguments.deleteFile, file=arguments.filePath, type=arguments.mimetype );
	}

	function getCustomImage(required Image, Height="AUTO", Width="AUTO", size="", siteID="") {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		return variables.imageProcessor.getCustomImage(argumentCollection=arguments);
	}

	function createHREFForImage(siteID, fileID="", fileExt="", required size="undefined", required direct="#this.directImages#", required boolean complete="false", height="", width="", secure="false", useProtocol="true") output=false {
		var imgSuffix="";
		var returnURL="";
		var begin="";
		if ( !len(arguments.fileid) ) {
			arguments.fileid=variables.settingsManager.getSite(arguments.siteid).getPlaceholderImgId();
			arguments.fileExt=variables.settingsManager.getSite(arguments.siteid).getPlaceholderImgExt();
		}
		if ( !len(arguments.fileExt) ) {
			arguments.fileEXT=getBean("fileManager").readMeta(arguments.fileID).fileEXT;
		}
		if ( !ListFindNoCase('jpg,jpeg,png,gif,svg,webp', arguments.fileEXT) ) {
			return '';
		}
		if ( !structKeyExists(arguments,"siteID") ) {
			var sessionData=getSession();
			arguments.siteID=sessionData.siteID;
		}
		var site=variables.settingsManager.getSite(arguments.siteid);
		if ( isValid('URL', application.configBean.getAssetPath()) ) {
			var begin=application.configBean.getAssetPath() & "/" & site.getFilePoolID();
		} else {
			var begin=site.getFileAssetPath(argumentCollection=arguments);
		}
		if ( request.muraExportHtml ) {
			arguments.direct=true;
		}
		if ( arguments.direct && listFindNoCase("fileDir,s3",application.configBean.getFileStore()) ) {
			if ( arguments.fileEXT == 'svg' ) {
				returnURL=begin & "/cache/file/" & arguments.fileID & "." & arguments.fileEXT;
			} else {
				if ( arguments.size == 'undefined' ) {
					if ( (isNumeric(arguments.width) || isNumeric(arguments.height)) ) {
						arguments.size ='Custom';
					} else {
						arguments.size ='Large';
					}
				}
				if ( arguments.size != 'Custom' ) {
					arguments.width="auto";
					arguments.height="auto";
				} else {
					if ( !isNumeric(arguments.width) ) {
						arguments.width="auto";
					}
					if ( !isNumeric(arguments.height) ) {
						arguments.height="auto";
					}
					if ( isNumeric(arguments.height) || isNumeric(arguments.width) ) {
						arguments.size="Custom";
					}
					if ( arguments.size == "Custom" && arguments.height == "auto" && arguments.width == "auto" ) {
						arguments.size="small";
					}
				}
				if ( listFindNoCase('small,medium,large,source',arguments.size) ) {
					if ( arguments.size == "large" ) {
						imgSuffix="";
					} else {
						imgSuffix="_" & lcase(arguments.size);
					}
					returnURL=begin & "/cache/file/" & arguments.fileID & imgSuffix & "." & arguments.fileEXT;
				} else if ( arguments.size != 'custom' ) {
					returnURL = getCustomImage(image="#application.configBean.getFileDir()#/#site.getFilePoolID()#/cache/file/#arguments.fileID#.#arguments.fileExt#",size=arguments.size,siteID=site.getFilePoolID());
					if ( len(returnURL) ) {
						returnURL = begin & "/cache/file/" & returnURL;
					}
				} else {
					if ( !len(arguments.width) ) {
						arguments.width="auto";
					}
					if ( !len(arguments.height) ) {
						arguments.height="auto";
					}
					returnURL = begin & "/cache/file/" & getCustomImage(image="#application.configBean.getFileDir()#/#site.getFilePoolID()#/cache/file/#arguments.fileID#.#arguments.fileExt#",height=arguments.height,width=arguments.width,siteID=site.getFilePoolID());
				}
			}
		} else {
			if ( arguments.size == "large" || arguments.fileExt == 'svg' ) {
				imgSuffix="file";
			} else {
				imgSuffix=arguments.size;
			}
			returnURL=site.getWebPath(argumentCollection=arguments) & "#application.configBean.getIndexPath()#/_api/render/#imgSuffix#/?fileID=" & arguments.fileID & "&fileEXT=" &  arguments.fileEXT;
		}
		return returnURL;
	}

	function cropAndScale(fileID, size, x, y, height, width, siteid) output=false {
		arguments.siteid=variables.settingsManager.getSite(arguments.siteid).getFilePoolID();
		var rsMeta=readMeta(arguments.fileID);
		var site=variables.settingsManager.getSite(rsMeta.siteID);
		var file="";
		var source="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#_source.#rsMeta.fileExt#";
		var cropper=structNew();
		var customImageSize="";
		arguments.action="cropAndScale";
		var pluginEvent =new mura.event(arguments);
		var pluginManager=getBean("pluginManager");
		arguments.size=lcase(arguments.size);
		pluginManager.announceEvent("onBeforeImageManipulation",pluginEvent);
		if ( !fileExists(source) ) {
			var source2="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#.#rsMeta.fileExt#";
			if ( fileExists(source2) ) {
				fileCopy(source2,source);
			}
		}
		if ( rsMeta.recordcount && IsImageFile(source) ) {
			pluginEvent.setValue('siteid',rsMeta.siteID);
			if ( arguments.size == "large" ) {
				var file="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#.#rsMeta.fileExt#";
			} else {
				var file="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#_#arguments.size#.#rsMeta.fileExt#";
			}
			if ( fileExists(file) ) {
				fileDelete(file);
			}
			cropper=imageRead(source);
			/* 
			This a workaround to ensure jpegs can be process 
			https://luceeserver.atlassian.net/browse/LDEV-1874
		*/
			if ( listFindNoCase('jpg,jpeg,webp',rsMeta.fileExt) ) {
				var origCropper=cropper;
				cropper = imageNew("", origCropper.width, origCropper.height, "rgb");
				imagePaste(cropper, origCropper, 0, 0);
			}
			if ( isDefined('arguments.x') ) {
				imageCrop(cropper,arguments.x,arguments.y,arguments.width,arguments.height);
				ImageWrite(cropper,file,variables.configBean.getImageQuality());
				if ( listFindNoCase('small,medium,large',arguments.size) ) {
					variables.imageProcessor.resizeImage(
					image=file,
					height=invoke(site,"get#arguments.size#ImageHeight"),
					width=invoke(site,"get#arguments.size#ImageWidth")
				);
				} else {
					customImageSize=getBean('imageSize').loadBy(name=arguments.size,siteID=arguments.siteID);
					if ( customImageSize.exists() ) {
						variables.imageProcessor.resizeImage(
						image=file,
						height=customImageSize.getHeight(),
						width=customImageSize.getWidth()
					);
					} else {
						//  Assume it's an adhoc custom size with HX_WX name 
						customImageSize.setName(arguments.size);
						customImageSize.parseName();
						file="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#_#ucase(arguments.size)#.#rsMeta.fileExt#";
						variables.imageProcessor.resizeImage(
						image=file,
						height=customImageSize.getHeight(),
						width=customImageSize.getWidth()
					);
					}
				}
			} else {
				ImageWrite(cropper,file,variables.configBean.getImageQuality());
				if ( listFindNoCase('small,medium,large',arguments.size) ) {
					variables.imageProcessor.resizeImage(
					image=file,
					height=invoke(site,"get#arguments.size#ImageHeight"),
					width=invoke(site,"get#arguments.size#ImageWidth")
				);
				} else {
					customImageSize=getBean('imageSize').loadBy(name=arguments.size,siteID=arguments.siteID);
					if ( customImageSize.exists() ) {
						variables.imageProcessor.resizeImage(
					image=file,
					height=customImageSize.getHeight(),
					width=customImageSize.getWidth()
				);
					} else {
						//  Assume it's an adhoc custom size with HX_WX name 
						customImageSize.setName(arguments.size);
						customImageSize.parseName();
						file="#application.configBean.getFileDir()#/#arguments.siteID#/cache/file/#arguments.fileID#_#ucase(arguments.size)#.#rsMeta.fileExt#";
						variables.imageProcessor.resizeImage(
						image=file,
						height=customImageSize.getHeight(),
						width=customImageSize.getWidth()
					);
					}
				}
			}
			cropper=imageRead(file);
			pluginManager.announceEvent("onAfterImageManipulation",pluginEvent);
			return ImageInfo(cropper);
		}
	}

	function rotate(fileID, degrees="90") {
		var rsMeta=readMeta(arguments.fileID);
		var source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#arguments.fileID#_source.#rsMeta.fileExt#";
		var myImage="";
		arguments.action="rotate";
		var pluginEvent =new mura.event(arguments);
		var pluginManager=getBean("pluginManager");
		if ( rsMeta.recordcount && IsImageFile(source) ) {
			pluginEvent.setValue('siteid',rsMeta.siteID);
			getBean("pluginManager").announceEvent("onBeforeImageManipulation",pluginEvent);

			myImage=imageRead(source);
			ImageRotate(myImage,arguments.degrees);
			imageWrite(myImage,source,variables.configBean.getImageQuality());
			arguments.action="rate";
			pluginEvent =new mura.event(arguments);
			getBean("pluginManager").announceEvent("onAfterImageManipulation",pluginEvent);
		}
	}

	function flip(fileID, transpose="horizontal") {
		var rsMeta=readMeta(arguments.fileID);
		var source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#arguments.fileID#_source.#rsMeta.fileExt#";
		var myImage="";
		arguments.action="flip";
		var pluginEvent =new mura.event(arguments);
		var pluginManager=getBean("pluginManager");
		if ( rsMeta.recordcount && IsImageFile(source) ) {
			pluginEvent.setValue('siteid',rsMeta.siteID);
			pluginManager.announceEvent("onBeforeImageManipulation",pluginEvent);

			myImage=imageRead(source);
			ImageFlip(myImage,arguments.transpose);
			imageWrite(myImage,source,variables.configBean.getImageQuality());
			pluginManager.announceEvent("onAfterImageManipulation",pluginEvent);
		}
	}

	function touchSourceImage(fileID) output=false {
		var rsMeta=readMeta(arguments.fileID);
		var source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#rsMeta.fileID#_source.#rsMeta.fileExt#";
		if ( rsMeta.recordcount && !fileExists(source) ) {
			getBean('fileWriter').copyFile(source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#rsMeta.fileID#.#rsMeta.fileExt#", destination=source);
		}
	}

	function readSourceImage(fileID) output=false {
		var rsMeta=readMeta(arguments.fileID);
		var source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#rsMeta.fileID#_source.#rsMeta.fileExt#";
		if ( rsMeta.recordcount && !fileExists(source) ) {
			getBean('fileWriter').copyFile(source="#application.configBean.getFileDir()#/#rsMeta.siteID#/cache/file/#rsMeta.fileID#.#rsMeta.fileExt#", destination=source);
		}
		source=imageRead(source);
		return source;
	}
}
