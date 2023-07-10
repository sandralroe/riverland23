//  license goes here 
/**
 * This provides a CRUD utility for the host file system
 */
component extends="mura.baseobject" output="false" hint="This provides a CRUD utility for the host file system" {
	variables.useMode=true;

	public function init(required useMode="#variables.useMode#", required tempDir="#application.configBean.getTempDir()#") output=false {
		if ( findNoCase(server.os.name,"Windows") ) {
			variables.useMode=false;
		} else {
			if ( isBoolean(arguments.useMode) ) {
				variables.useMode=arguments.useMode;
			} else {
				variables.useMode=application.configBean.getValue("useFileMode");
			}
		}
		variables.tempDir=arguments.tempDir;
		if ( isNumeric(application.configBean.getValue("defaultFileMode")) ) {
			variables.defaultFileMode=application.configBean.getValue("defaultFileMode");
		} else {
			variables.defaultFileMode=775;
		}
		return this;
	}

	public function copyFile(source, destination, required mode="#variables.defaultFileMode#") output=false {
		lock name="mfw#hash(arguments.source)#" type="exclusive" timeout="5" {
			try {
				if ( variables.useMode ) {
					cffile( mode=arguments.mode, source=arguments.source, destination=arguments.destination, action="copy" );
				} else {
					cffile( source=arguments.source, destination=arguments.destination, action="copy" );
				}
			} catch (any cfcatch) {
				sleep(RandRange(500, 1000));
				if ( fileExists(arguments.destination) ) {
					fileDelete(arguments.destination);
				}
				if ( variables.useMode ) {
					cffile( mode=arguments.mode, source=arguments.source, destination=arguments.destination, action="copy" );
				} else {
					cffile( source=arguments.source, destination=arguments.destination, action="copy" );
				}
			}
		}
		return this;
	}

	public function moveFile(source, destination, required mode="#variables.defaultFileMode#") output=false {
		lock name="mfw#hash(arguments.source)#" type="exclusive" timeout="5" {
			//if(not listFirst(expandPath(arguments.file),':') eq 's3'){
			if ( variables.useMode ) {
				cffile( mode=arguments.mode, source=arguments.source, destination=arguments.destination, action="copy" );
				try {
					cffile( file=arguments.source, action="delete" );
				} catch (any cfcatch) {
				}
			} else {
				cffile( source=arguments.source, destination=arguments.destination, action="copy" );
				try {
					cffile( file=arguments.source, action="delete" );
				} catch (any cfcatch) {
				}
			} 
			/* } else {
				cffile( source=arguments.source, destination=arguments.destination, action="copy", acl="private" );
				try {
					cffile( file=arguments.source, action="delete" );
				} catch (any cfcatch) {
				}
			*/
		}
		return this;
	}

	public function renameFile(source, destination, required mode="#variables.defaultFileMode#") output=false {
		lock name="mfw#hash(arguments.source)#" type="exclusive" timeout= "5" {
			if ( variables.useMode ) {
				cffile( mode=arguments.mode, source=arguments.source, destination=arguments.destination, action="rename" );
			} else {
				cffile( source=arguments.source, destination=arguments.destination, action="rename" );
			}
		}
		return this;
	}

	public function writeFile(file, output, required addNewLine="true", required mode="#variables.defaultFileMode#", charset) {
		var newfile = "";
		var x = "";
		var counter = 0;
		if ( isDefined('arguments.output.mode') ) {
			newfile = FileOpen(arguments.file, "write");
			while ( !fileIsEOF( arguments.output )) {
				x = FileRead(arguments.output, 10000);
				if ( isDefined('arguments.charset') ) {
					FileWrite(newfile, x, arguments.charset);
				} else {
					FileWrite(newfile, x);
				}
				counter = counter + 1;
			}
			FileClose(arguments.output);
			FileClose(newfile);
			if ( fileExists(arguments.output.path) ) {
				FileDelete(arguments.output.path);
			} else if ( fileExists(arguments.output.path & "/" & arguments.output.name) ) {
				FileDelete(arguments.output.path & "/" & arguments.output.name);
			}
		} else {
			if ( variables.useMode ) {
				cffile( mode=arguments.mode, output=arguments.output, file=arguments.file, addnewline=arguments.addNewLine, action="write" );
			} else {
				cffile( output=arguments.output, file=arguments.file, addnewline=arguments.addNewLine, action="write" );
			}
		}
		return this;
	}

	public function uploadFile(filefield, required destination="#variables.tempDir#", required nameConflict="makeunique", required attributes="normal", required mode="#variables.defaultFileMode#", accept="") output=false {
		touchDir(arguments.destination,arguments.mode);
		if ( variables.useMode ) {
			cffile( mode=arguments.mode, fileField=arguments.fileField, accept=arguments.accept, nameConflict=arguments.nameConflict, destination=arguments.destination, action="upload", result="upload", attributes=arguments.attributes );
		} else {
			cffile( fileField=arguments.fileField, accept=arguments.accept, nameConflict=arguments.nameConflict, destination=arguments.destination, action="upload", result="upload", attributes=arguments.attributes );
		}
		return upload;
	}

	public function appendFile(file, output, required mode="#variables.defaultFileMode#") output=false {
		lock name="mfw#hash(arguments.file)#" type="exclusive" timeout="5" {
			if ( variables.useMode ) {
				cffile( mode=arguments.mode, output=arguments.output, file=arguments.file, action="append" );
			} else {
				cffile( output=arguments.output, file=arguments.file, action="append" );
			}
		}
		return this;
	}

	public function createDir(directory, required mode="#variables.defaultFileMode#") output=false {
		if ( variables.useMode ) {
			cfdirectory( mode=arguments.mode, directory=arguments.directory, action="create" );
		} else {
			cfdirectory( directory=arguments.directory, action="create" );
		}
		return this;
	}

	public function touchDir(directory, required mode="#variables.defaultFileMode#") output=false {
		if ( !DirectoryExists(arguments.directory) ) {
			createDir(arguments.directory,arguments.mode);
		}
		return this;
	}

	public function renameDir(directory, newDirectory, required mode="#variables.defaultFileMode#") output=false {
		if ( variables.useMode ) {
			cfdirectory( mode=arguments.mode, directory=arguments.directory, action="rename", newDirectory=arguments.newDirectory );
		} else {
			cfdirectory( directory=arguments.directory, action="rename", newDirectory=arguments.newDirectory );
		}
		return this;
	}

	public function deleteDir(directory, required recurse="true") output=false {
		cfdirectory( directory=arguments.directory, recurse=arguments.recurse, action="delete" );
		return this;
	}

	public function copyDir(required baseDir="", required destDir="", required excludeList="", required sinceDate="", required excludeHiddenFiles="true") output=false {
		var rsAll = "";
		var rs = "";
		var i="";
		var errors=arrayNew(1);
		var copyItem="";
		arguments.baseDir=pathFormat(conditionalExpandPath(arguments.baseDir));
		arguments.destDir=pathFormat(conditionalExpandPath(arguments.destDir));
		arguments.excludeList=pathFormat(arguments.excludeList);
		if ( arguments.baseDir != arguments.destDir ) {
			cfdirectory( directory=arguments.baseDir, recurse=true, name="rsAll", action="list" );
			//  filter out Subversion hidden folders 
			rsAll=fixQueryPaths(rsAll);

			var sql="SELECT * FROM rsAll WHERE 1=1";
		
			if ( arguments.excludeHiddenFiles ) {
				sql & " " & "and directory NOT LIKE '%/.svn%'
				and directory NOT LIKE '%/.git%'
				and name not like '.%'";
			}
			if ( len(arguments.excludeList) ) {
				for ( i in arguments.excludeList ) {
					sql & " " & "and directory NOT LIKE '%#i#%'";
				}
			}
			if ( isDate(arguments.sinceDate) ) {
				sql & " " & "and dateLastModified >= #createODBCDateTime(arguments.sinceDate)#";
			}
			
			rsAll=queryExecute(
				sql,
				{},
				{dbType="query"}
			);

			copyItem=arguments.destDir;
			try {
				createDir(directory=copyItem);
			} catch (any cfcatch) {
				//arrayAppend(errors,copyItem);
			}
		
			rs=queryExecute(
				"select * from rsAll where lower(type) = 'dir'",
				{},
				{dbType="query"}
			);

			if(rs.recordcount){
				for(var i=1;i<=rs.recordcount;i++){
					copyItem="#replace('#rs.directory[i]#/',arguments.baseDir,arguments.destDir)##rs.name[i]#/";
					try{
						createDir(directory=copyItem);
					} catch(any e){
						//arrayAppend(errors,copyItem);
					}
				}
			}

			rs=queryExecute(
				"select * from rsAll where lower(type) = 'file'",
				{},
				{dbType="query"}
			);

			if(rs.recordcount){
				for(var i=1;i<=rs.recordcount;i++){
					copyItem="#replace('#rs.directory[i]#/',arguments.baseDir,arguments.destDir)#";
					if(fileExists("#copyItem#/#rs.name[i]#")){
						cffile(action="delete",file="#copyItem#/#rs.name[i]#");
					}
					
					try{
						copyFile(source="#rs.directory[i]#/#rs.name[i]#", destination=copyItem, sinceDate=arguments.sinceDate);
					} catch(any e){
						//arrayAppend(errors,""#copyItem#/#rs.name[i]#"");
					}
				}
			}

		}
		return errors;
	}

	public function getFreeSpace(file, unit="gb") output=false {
		var space=createObject("java", "java.io.File").init(arguments.file).getFreeSpace();
		if ( arguments.unit == "bytes" ) {
			return space;
		} else if ( arguments.unit == "kb" ) {
			return space /1024;
		} else if ( arguments.unit == "mb" ) {
			return space /1024 / 1024;
		} else {
			return space /1024 / 1024 / 1024;
		}
	}

	public function getTotalSpace(file, unit="gb") output=false {
		var space=createObject("java", "java.io.File").init(arguments.file).getTotalSpace();
		if ( arguments.unit == "byte" ) {
			return space;
		} else if ( arguments.unit == "kb" ) {
			return space /1024;
		} else if ( arguments.unit == "mb" ) {
			return space /1024 / 1024;
		} else {
			return space /1024 / 1024 / 1024;
		}
	}

	public function getUsableSpace(file, unit="gb") output=false {
		var space=createObject("java", "java.io.File").init(arguments.file).getUsableSpace();
		if ( arguments.unit == "byte" ) {
			return space;
		} else if ( arguments.unit == "kb" ) {
			return space /1024;
		} else if ( arguments.unit == "mb" ) {
			return space /1024 / 1024;
		} else {
			return space /1024 / 1024 / 1024;
		}
	}

	public function chmod(path, required mode="#variables.defaultFileMode#") output=false {
		if ( variables.useMode && application.configBean.getJavaEnabled() ) {
			try {
				if ( directoryExists(arguments.path) ) {
					createObject("java","java.lang.Runtime").getRuntime().exec("chmod -R #arguments.mode# #arguments.path#");
				} else {
					createObject("java","java.lang.Runtime").getRuntime().exec("chmod #arguments.mode# #arguments.path#");
				}
			} catch (any cfcatch) {
			}
		}
	}

	/**
	 * Convert path into Windows or Unix format.
	 */
	public function PathFormat(required string path) output=false {
		arguments.path = Replace(arguments.path, "\", "/", "ALL");
		return arguments.path;
	}

	public function fixQueryPaths(rsDir, path="directory") output=false {
		if(isQuery(rsDir)){
			for(var i=1;i<=rsDir.recordcount;i++){
				querySetCell(rsDir,arguments.path,pathFormat(rsDir[arguments.path][i]),i);
			}
		}

		return rsDir;
	}

	public function getDirectoryList(directory, filter="*", type="all") output=false {
		var rs="";
		cfdirectory( filter=arguments.filter, directory=arguments.directory, name="rs", type=arguments.type, action="list" );
		return rs;
	}

	function conditionalExpandPath(path){
			if(find(":",arguments.path)){
				return path;
			} else {
				if(directoryExists(path)){
					return path;
				} else{
					var expandedPath=expandPath(arguments.path);
					if(directoryExists(expandedPath)){
						return expandedPath;
					} else {
						return arguments.path;
					}
				}
			}
		}
		
		/*
		function setStoreMetaData(filepath,metadata,permissions){
			if(listFirst(arguments.filepath,':') =='s3'){
				if(isdefined('arguments.metadata') && isStruct(arguments.metadata)){
					var fileMetaData=storeGetMetadata(arguments.filepath);
					structAppend(fileMetaData,arguments.metadata);
					storeSetMetadata(arguments.filepath,fileMetaData);
				}
				if(isDefined('arguments.permissions') && isArray(arguments.permissions)){
					storeSetACL(arguments.filepath,arguments.permissions);
				}
			}

			return this;
		}
		*/

}
