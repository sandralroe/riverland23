//  license goes here 
/**
 * This provides content html exporting functionality
 */
component extends="mura.baseobject" output="false" hint="This provides content html exporting functionality" {
	variables.configBean="";
	variables.settingsManager="";
	variables.contentManager="";
	variables.utility="";

	public function init(configBean, settingsManager, contentManager, utility, filewriter, contentServer) {
		variables.configBean=arguments.configBean;
		variables.settingsManager=arguments.settingsManager;
		variables.contentManager=arguments.contentManager;
		variables.utility=arguments.utility;
		variables.filewriter=arguments.filewriter;
		variables.contentServer=arguments.contentServer;
		return this;
	}

	public function export(required string siteid, required string exportDir) {
		var $=getBean("MuraScope").init(arguments.siteID);
		var localval="";
		request.exportedfiles={};
		cfsetting( requestTimeout="7500");
		if ( listFind("/,\",right(arguments.exportDir,1)) ) {
			arguments.exportDir=left(arguments.exportDir, len(arguments.exportDir)-1 );
		}
		if ( directoryExists("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/") ) {
			variables.fileWriter.deleteDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/");
		}
		if ( len($.globalConfig("context")) ) {
			variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig("context")#");
		}
		variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig("context")#/#arguments.siteID#");
		localval = "#$.globalConfig('webroot')#/#arguments.siteid#/css/";
		localval = localval & " to " & "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/css/";
		variables.fileWriter.copyDir("#$.globalConfig('webroot')#/#arguments.siteid#/css/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/css/");
		variables.fileWriter.copyDir("#$.globalConfig('webroot')#/#arguments.siteid#/flash/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/flash/");
		variables.fileWriter.copyDir("#$.globalConfig('webroot')#/#arguments.siteid#/images/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/images/");
		variables.fileWriter.copyDir("#$.globalConfig('webroot')#/#arguments.siteid#/js/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/js/");
		variables.fileWriter.copyDir("#$.globalConfig('assetDir')#/#arguments.siteid#/assets/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/assets/");
		//  Add jquery to the export 
		variables.fileWriter.copyDir("#$.globalConfig('assetDir')#/#arguments.siteid#/jquery/", "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/jquery/");
		variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes");
		variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes");
		// <cfset variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#")>
		variables.fileWriter.copyDir(expandPath("#$.siteConfig('themeIncludePath')#/"), "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#/");
		variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/cache");
		variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/cache/file");
		if ( directoryExists("#$.siteConfig('themeIncludePath')#/css") ) {
			variables.fileWriter.copyDir(expandPath("#$.siteConfig('themeIncludePath')#/css/"), "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#/css/");
		}
		if ( directoryExists("#$.siteConfig('themeIncludePath')#/flash") ) {
			variables.fileWriter.copyDir(expandPath("#$.siteConfig('themeIncludePath')#/flash/"), "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#/flash/");
		}
		if ( directoryExists("#$.siteConfig('themeIncludePath')#/images") ) {
			variables.fileWriter.copyDir(expandPath("#$.siteConfig('themeIncludePath')#/images/"), "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#/images/");
		}
		if ( directoryExists("#$.siteConfig('themeIncludePath')#/js") ) {
			variables.fileWriter.copyDir(expandPath("#$.siteConfig('themeIncludePath')#/js/"), "#arguments.exportDir##$.globalConfig('context')#/#arguments.siteID#/includes/themes/#$.siteConfig('theme')#/js/");
		}
		localval = expandPath("#$.siteConfig('themeIncludePath')#/images/");
		traverseSite('00000000000000000000000000000000END', arguments.siteid, arguments.exportDir);
	}

	public function traverseSite(required string contentid, required string siteid, required string exportDir, required string sortBy="orderno", required string sortDirection="asc") {
		var rs = "";
		var contentBean = "";
		var it=getBean('contentIterator');
		rs=variables.contentManager.getNest(arguments.contentid,arguments.siteid,arguments.sortBy,arguments.sortDirection);
		it.setQuery(rs);
		while ( it.hasNext() ) {
			contentBean=it.next();
			if ( contentBean.getHasKids() ) {
				traverseSite(contentBean.getContentID(), contentBean.getSiteID(), arguments.exportDir,contentBean.getSortBy(), contentBean.getSortDirection());
			}
			exportNode(contentBean,arguments.exportDir);
		}
	}

	public function exportNode(required any contentBean, required string exportDir) output=false {
		var fileOutput = "";
		var rsFile = "";
		var filepath = "";
		var basepath = "";
		var servlet = "";
		var nextn = "";
		var rsSection = "";
		var rsFiles = "";
		var filedir = "";
		var i = "";
		var $=getBean("MuraScope").init(arguments.contentBean.getSiteID());
		var newdir="";
		if ( listFind("/,\",right(arguments.exportDir,1)) ) {
			arguments.exportDir=left(arguments.exportDir, len(arguments.exportDir)-1 );
		}
		request.muraValidateDomain=false;
		request.muraExportHtml = true;
		request.siteid = arguments.contentBean.getSiteID();
		if ( !listFindNoCase("Link,File",arguments.contentBean.getType()) ) {
			request.currentFilename = arguments.contentBean.getFilename();
			request.currentFilenameAdjusted=request.currentFilename;
			request.contentBean=arguments.contentBean;
			request.servletEvent = new mura.servletEvent();
			structDelete(request.servletEvent.getAllValues(),"crumbdata");
			fileOutput=variables.contentServer.doRequest(request.servletEvent);
			if ( variables.configBean.getSiteIDInURLS() ) {
				filePath = "#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getSiteID()#/#arguments.contentBean.getFilename()#/index.html";
			} else {
				filePath = "#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getFilename()#/index.html";
			}
			if ( variables.configBean.getSiteIDInURLS() ) {
				newdir="#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getSiteID()#/#arguments.contentBean.getFilename()#";
			} else {
				newdir="#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getFilename()#";
			}
			if ( !directoryExists(newdir) ) {
				variables.fileWriter.createDir(newdir);
			}
			if ( fileExists(filepath) ) {
				cffile( file=filepath, action="delete" );
			}
			variables.fileWriter.writeFile(file = "#filepath#",output = "#fileOutput#");
		}
		if ( len(arguments.contentBean.getFileID()) && !structKeyExists(request.exportedfiles,hash(arguments.contentBean.getFileID())) ) {
			if ( arguments.contentBean.getType() == "File" ) {
				variables.fileWriter.createDir("#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getSiteID()#/cache/file/#arguments.contentBean.getFileID()#");
				variables.fileWriter.copyFile(source="#$.globalConfig('fileDir')#/#arguments.contentBean.getSiteID()#/cache/file/#arguments.contentBean.getFileID()#.#arguments.contentBean.getFileEXT()#", destination="#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getSiteID()#/cache/file/#arguments.contentBean.getFileID()#/#arguments.contentBean.getAssocFilename()#");
			}
			if ( listFindNoCase("jpg,jpeg,gif,png,webp",arguments.contentBean.getFileEXT()) ) {
				cfdirectory( filter="#arguments.contentBean.getFileID()#*", directory="#$.globalConfig('fileDir')#/#arguments.contentBean.getSiteID()#/cache/file", name="rsFiles", action="list" );

				if(rsFiles.recordcount){
					for(var i=1;i<=rsFiles.recordcount;i++){
						variables.fileWriter.copyFile(source="#$.globalConfig('fileDir')#/#arguments.contentBean.getSiteID()#/cache/file/#rsFiles.name[i]#", destination="#arguments.exportDir##$.globalConfig('context')#/#arguments.contentBean.getSiteID()#/cache/file/#rsFiles.name[i]#");
					}
				}

			}
			request.exportedfiles[hash(arguments.contentBean.getFileID())]=true;
		}
		if ( listFindNoCase("Folder,Gallery",arguments.contentBean.getType()) ) {
			rsSection=contentBean.getKidsQuery();
			nextN=application.utility.getNextN(rsSection,arguments.contentBean.getNextN(),1);
			if ( nextN.numberofpages > 1 ) {
				for ( i=2 ; i<=nextN.numberofpages ; i++ ) {
					request.currentFilename = arguments.contentBean.getFilename();
					request.servletEvent = new mura.servletEvent();
					request.servletEvent.setValue("startrow",(i*nextN.recordsperpage)-nextN.recordsperpage+1);
					request.servletEvent.setValue("nextNID",arguments.contentBean.getContentID());
					fileOutput=variables.contentServer.doRequest(request.servletEvent);
					if ( variables.configBean.getSiteIDInURLS() ) {
						filePath = "#arguments.exportDir##variables.configBean.getContext()#/#arguments.contentBean.getSiteID()#/#arguments.contentBean.getFilename()#/index#i#.html";
					} else {
						filePath = "#arguments.exportDir##variables.configBean.getContext()#/#arguments.contentBean.getFilename()#/index#i#.html";
					}
					if ( fileExists(filepath) ) {
						cffile( file=filepath, action="delete" );
					}
					variables.fileWriter.writeFile(file = "#filepath#",output = "#fileOutput#");
				}
			}
		}
		request.startRow=1;
		request.muraExportHtml = false;
	}

}
