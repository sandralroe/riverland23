<!---
* --------------------------------------------------------------------------------
*
*        Application: newsight Zip Component
*          File Name: Zip.cfc
* CFC Component Name: Zip
*            Support: ColdFusion MX 6.0, ColdFusion MX 6.1, ColdFusion MX 7
*         Created By: Artur Kordowski - info@newsight.de
*            Created: 16.06.2005
*        Description: A collections of functions that supports the Zip and GZip functionality by using the
*                     Java Zip file API.
*
*    Version History: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      16.06.2005     0.1 Beta    A. Kordowski    Beta status reached.
*                      27.06.2005     1.0         A. Kordowski    Component complete.
*                      07.08.2005     1.1         A. Kordowski    Fixed some bugs. Add GZip functionality. New functions
*                                                                 gzipAddFile() and gzipExtract().
*                      02.10.2005     1.2         A.Kordowski     Fixed bug for ColdFusion MX 6.
*
*           Comments: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      27.06.2005     0.1 Beta    A. Kordowski    Thanks a lot to Warren Sung for testing the Component with
*                                                                 ColdFusion MX 6.1 on Linux Debian 3.1.
*                      27.06.2005     0.1 Beta    A. Kordowski    Component tested with ColdFusion MX 7 on Windows XP Professional.
*                      29.06.2005     1.0         A. Kordowski    Created documentation.
*                      01.07.2005     1.0         A. Kordowski    Release component.
*                      08.08.2005     1.1         A. Kordowski    Update documentation.
*
*               Docs: http://livedocs.newsight.de/com/Zip/
*
*             Notice: For comments, bug reports or suggestions to optimise this component, feel free to send
*                     a E-Mail: info@newsight.de
*
*            License: THIS IS A OPEN SOURCE COMPONENT. YOU ARE FREE TO USE THIS COMPONENT IN ANY APPLICATION,
*                     TO COPY IT OR MODIFY THE FUNCTIONS FOR YOUR OWN NEEDS, AS LONG THIS HEADER INFORMATION
*                     REMAINS IN TACT AND YOU DON'T CHARGE ANY MONEY FOR IT. USE THIS COMPONENT AT YOUR OWN
*                     RISK. NO WARRANTY IS EXPRESSED OR IMPLIED, AND NO LIABILITY ASSUMED FOR THE RESULT OF
*                     USING THIS COMPONENT.
*
*                     THIS COMPONENT IS LICENSED UNDER THE CREATIVE COMMONS ATTRIBUTION-SHAREALIKE LICENSE.
*                     FOR THE FULL LICENSE TEXT PLEASE VISIT: http://creativecommons.org/licenses/by-sa/2.5/
*
* --------------------------------------------------------------------------------
--->

<cfcomponent displayname = "Zip Component"
             hint        = "This provides a collections of functions that supports the Zip and GZip functionality by using the Java Zip file API."
			 output		 = "false"
			 extends	 = "mura.baseobject">

	<cfscript>
		/* Create Objects */
		variables.ioFile = CreateObject("java","java.io.File");
		variables.ioInput = CreateObject("java","java.io.FileInputStream");
		variables.ioOutput = CreateObject("java","java.io.FileOutputStream");
		variables.ioBufOutput = CreateObject("java","java.io.BufferedOutputStream");
		variables.zipFile = CreateObject("java","java.util.zip.ZipFile");
		variables.zipEntry = CreateObject("java","java.util.zip.ZipEntry");
		variables.zipInput = CreateObject("java","java.util.zip.ZipInputStream");
		variables.zipOutput = CreateObject("java","java.util.zip.ZipOutputStream");
		variables.gzInput = CreateObject("java","java.util.zip.GZIPInputStream");
		variables.gzOutput = CreateObject("java","java.util.zip.GZIPOutputStream");
		variables.objDate = CreateObject("java","java.util.Date");
		/* Set Variables */
		this.os = Server.OS.Name;

		if(FindNoCase("Windows", this.os)) {
			this.slash = "\";
		} else {
			this.slash = "/";
		}

	</cfscript>

	<!--- -------------------------------------------------- --->
	<!--- AddFiles --->
	<cffunction name="AddFiles" output="no" returntype="boolean" hint="Add files to a new or an existing Zip file archive.">
		<!--- Function Arguments --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to add files.">
		<cfargument name="files" required="no" type="string" hint="| (Chr(124)) delimited list of files to add to the Zip file. Required if argument 'directory' is not set.">
		<cfargument name="directory" required="no" type="string" hint="Absolute pathname of directory to add to the Zip file. Required if argument 'files' is not set.">
		<cfargument name="filter" required="no" type="string"  default="" hint="File extension filter. One filter can be applied. Only if argument 'directory' is set.">
		<cfargument name="recurse" required="no" type="boolean" default="no" hint="Get recursive files of subdirectories. Only if argument 'directory' is set.">
		<cfargument name="compression" required="no" type="numeric" default="9"  hint="Compression level (0 through 9, 0=minimum, 9=maximum).">
		<cfargument name="savePaths" required="no" type="boolean" default="no" hint="Save full path info.">
		<cfargument name="sinceDate" required="no" type="string" default=""  hint="Filter for files created since this datetime">
		<cfargument name="hiddenFiles" required="no" type="boolean" default="no" hint="Whether to include .svn or .git files.">
		<cfargument name="excludeDirs" required="yes" type="string"  default="" hint="| (Chr(124)) delimited list of dirs to not zip.">
		
		<cfscript>
			/* Default variables */
			var i = 0;
			var l = 0;
			var buffer = RepeatString(" ",1024).getBytes();
			var entryPath = "";
			var entryFile = "";
			var skip="no";
			//var files =[];

			arguments.excludeDirs=PathFormat(arguments.excludeDirs);

			try
			{
				/* Initialize Zip file */
				variables.ioOutput.init(PathFormat(arguments.zipFilePath));
				variables.zipOutput.init(variables.ioOutput);
				variables.zipOutput.setLevel(arguments.compression);

				/* Get files list array */
				if(IsDefined("arguments.files"))
					files = ListToArray(PathFormat(arguments.files), "|");

				else if(IsDefined("arguments.directory"))
				{
					files = FilesList(arguments.directory, arguments.filter, arguments.recurse, arguments.sinceDate, arguments.hiddenFiles, arguments.excludeDirs);
					arguments.directory = PathFormat(arguments.directory);
				}

				if(arrayLen(files)){
				/* Loop over files array */
				for(i=1; i LTE ArrayLen(files); i=i+1)
				{
					if(FileExists(files[i]))
					{
						path = files[i];

						// Get entry path and file
						entryPath = GetDirectoryFromPath(path);
						entryFile = GetFileFromPath(path);

						// Remove drive letter from path
						if(arguments.savePaths EQ "yes" AND Right(ListFirst(entryPath, this.slash), 1) EQ ":")
							entryPath = ListDeleteAt(entryPath, 1, this.slash);

						// Remove directory from path
						else if(arguments.savePaths EQ "no")
						{
							if(IsDefined("arguments.directory"))  entryPath = ReplaceNoCase(entryPath, arguments.directory, "", "ALL");
							else if(IsDefined("arguments.files")) entryPath = "";
						}

						// Remove slash at first
						if(Len(entryPath) GT 1 AND Left(entryPath, 1) EQ this.slash)      entryPath = Right(entryPath, Len(entryPath)-1);
						else if(Len(entryPath) EQ 1 AND Left(entryPath, 1) EQ this.slash) entryPath = "" ;

						//  Skip if entry with the same name already exsits
						try
						{
							variables.ioFile.init(path);
							variables.ioInput.init(variables.ioFile.getPath());

							variables.zipEntry.init(ZipPathFormat(entryPath & entryFile));
							variables.zipOutput.putNextEntry(variables.zipEntry);

							l = variables.ioInput.read(buffer);

							while(l GT 0)
							{
								variables.zipOutput.write(buffer, 0, l);
								l = variables.ioInput.read(buffer);
							}

							variables.zipOutput.closeEntry();
							variables.ioInput.close();
						}

						catch(java.util.zip.ZipException ex)
						{ skip = "yes"; }
					}
				}
			}

				/* Close Zip file */
				variables.zipOutput.close();

				/* Return true */
				return true;
			}

			catch(Any expr)
			{
				/* Close Zip file */
				variables.zipOutput.close();

				/* Return false */
				return false;
			}

		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- DeleteFiles --->
	<cffunction name="DeleteFiles" output="no" returntype="boolean" hint="Delete files from an existing Zip file archive.">

		<!--- Function Arguments --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to delete files from.">
		<cfargument name="files" required="yes" type="string" hint="| (Chr(124)) delimited list of files to delete from Zip file.">

		<cfscript>

			/* NOTICE: There is no function in the Java API to delete entrys from a Zip file.
			           So we have to create a workaround for this function. At first we create
					   a new temporary Zip file and save there all entrys, excluded the delete
					   files. Then we delete the orginal Zip file and rename the temporary Zip
					   file. */

			/* Default variables */
			var l = 0;
			var buffer = RepeatString(" ",1024).getBytes();
			var entries="";
			var entry="";
			var inStream="";
			var zipTemp="";
			var zipRename="";
			/* Convert to the right path format */
			arguments.zipFilePath = PathFormat(arguments.zipFilePath);

			try
			{
				/* Open Zip file and get Zip file entries */
				variables.zipFile.init(arguments.zipFilePath);
				entries = variables.zipFile.entries();

				/* Create a new temporary Zip file */
				variables.ioOutput.init(PathFormat(arguments.zipFilePath & ".temp"));
				variables.zipOutput.init(variables.ioOutput);

				/* Loop over Zip file entries */
				while(entries.hasMoreElements())
				{
					entry = entries.nextElement();

					if(NOT entry.isDirectory())
					{
						/* Create a new entry in the temporary Zip file */
						if(NOT ListFindNoCase(arguments.files, entry.getName(), "|"))
						{
							// Set entry compression
							variables.zipOutput.setLevel(entry.getMethod());

							// Create new entry in the temporary Zip file
							variables.zipEntry.init(entry.getName());
							variables.zipOutput.putNextEntry(variables.zipEntry);

							inStream = variables.zipFile.getInputStream(entry);
							l        = inStream.read(buffer);

							while(l GT 0)
							{
								variables.zipOutput.write(buffer, 0, l);
								l = inStream.read(buffer);
							}

							// Close entry
							variables.zipOutput.closeEntry();
						}
					}
				}

				/* Close the orginal Zip and the temporary Zip file */
				variables.zipFile.close();
				variables.zipOutput.close();

				/* Delete the orginal Zip file */
				variables.ioFile.init(arguments.zipFilePath).delete();

				/* Rename the temporary Zip file */
				zipTemp   = variables.ioFile.init(arguments.zipFilePath & ".temp");
				zipRename = variables.ioFile.init(arguments.zipFilePath);
				zipTemp.renameTo(zipRename);

				/* Return true */
				return true;
			}

			catch(Any expr)
			{
				/* Close the orginal Zip and the temporary Zip file */
				variables.zipOutput.close();
				variables.zipFile.close();

				/* Delete the temporary Zip file, if exists */
				if(FileExists(arguments.zipFilePath & ".temp"))
					variables.ioFile.init(arguments.zipFilePath & ".temp").delete();

				/* Return false */
				return false;
			}

		</cfscript>

	</cffunction>

	<cffunction name="Extract" output="false">
		<cfargument name="zipFilePath" required="yes"type="string" hint="Pathname of the Zip file to extract.">
		<cfargument name="extractPath" required="no" type="string" default="#ExpandPath(".")#" hint="Pathname to extract the Zip file to.">
		<cfargument name="extractFiles" required="no" type="string" hint="| (Chr(124)) delimited list of files to extract.">
		<cfargument name="useFolderNames" required="no" type="boolean" default="yes" hint="Create folders using the pathinfo stored in the Zip file.">
		<cfargument name="overwriteFiles" required="no" type="boolean" default="no" hint="Overwrite existing files.">
		<cfargument name="extractDirs" required="no" type="string" hint="| (Chr(124)) delimited list of dirs to extract.">
		<cfargument name="excludeDirs" required="no" type="string" hint="| (Chr(124)) delimited list of dirs to not extract.">
		<cfargument name="extractDirsToTop" required="no"  type="string" >
		<cfargument name="threads"  required="yes" default="2" >
		<cfset var threadIndex=1>
		<cfset var threadlist="">
		<cfset var executionid=createUUID()>
		
		<cfloop from="1" to="#arguments.threads#" index="threadIndex">
			<cfset var context=duplicate(arguments)>
			<cfset context.threadIndex=threadIndex>
			<cfif threadIndex gt 1>
				<cfset var threadName="zipExtract#executionid#_#threadIndex#">
				<cfthread action="run" name="#threadName#" context="#context#">
					<cftry>
						<cfset this.ExtractThread(argumentCollection=context)>
						<cfcatch>
							<cfif isDefined('application.Mura')>
								<cfset application.Mura.logError(cfcatch)>
							<cfelse>
								<cfset writeLog(type="Error", log="exception", text=serializeJSON(cfcatch))>
							</cfif>
						</cfcatch>
					</cftry>
				</cfthread>
				<cfset threadlist=listAppend(threadlist,"#threadName#")>
			<cfelse>
				<cftry>
					<cfset this.ExtractThread(argumentCollection=context)>
					<cfcatch>
						<cfif isDefined('application.Mura')>
							<cfset application.Mura.logError(cfcatch)>
						<cfelse>
							<cfset writeLog(type="Error", log="exception", text=serializeJSON(cfcatch))>
						</cfif>
					</cfcatch>
				</cftry>
			</cfif>

		</cfloop>		
		
		<cfif listLen(threadlist)>
			<cfthread action="join" name="#threadlist#"></cfthread>
		</cfif>

		<cfset getBean("fileWriter").chmod(path=arguments.extractPath)>

	</cffunction>


	<!--- -------------------------------------------------- --->
	<!--- Extract --->
	<cffunction name="ExtractThread" output="no" returntype="boolean" hint="Extracts a specified Zip file into a specified directory.">

		<!--- Function Arguments --->
		<cfargument name="zipFilePath" required="yes"type="string" hint="Pathname of the Zip file to extract.">
		<cfargument name="extractPath" required="no" type="string" default="#ExpandPath(".")#" hint="Pathname to extract the Zip file to.">
		<cfargument name="extractFiles" required="no" type="string" hint="| (Chr(124)) delimited list of files to extract.">
		<cfargument name="useFolderNames" required="no" type="boolean" default="yes" hint="Create folders using the pathinfo stored in the Zip file.">
		<cfargument name="overwriteFiles" required="no" type="boolean" default="no" hint="Overwrite existing files.">
		<cfargument name="extractDirs" required="no" type="string" hint="| (Chr(124)) delimited list of dirs to extract.">
		<cfargument name="excludeDirs" required="no" type="string" hint="| (Chr(124)) delimited list of dirs to not extract.">
		<cfargument name="extractDirsToTop"   required="no" type="string" >
		<cfargument name="threads" required="yes" default="1" >
		<cfargument name="threadIndex" required="yes" default="1" >

		<cfscript>
			/* Default variables */
			var l = 0;
			var entries = "";
			var entry = "";
			var name = "";
			var path = "";
			var filePath = "";
			var buffer = RepeatString(" ",1024).getBytes();
			var rsdir = "";
			var extractStruct = structNew();
			var excludeStruct = structNew();
			var i ="";
			var entryHash= "";
			var started = false;
			var delim = FindNoCase("Windows", this.os) ? '\' : '/';
			var lastChr="";
			var lenPath=0;
			var inStream="";
			var skip="no";
			var currentIndex=1;
			var modIndex=arguments.threads;

			var zipFileInstance = CreateObject("java","java.util.zip.ZipFile");
			var ioFileInstance = CreateObject("java","java.io.File");
			var ioInputInstance = CreateObject("java","java.io.FileInputStream");
			var ioOutputInstance = CreateObject("java","java.io.FileOutputStream");
			var ioBufOutputInstance = CreateObject("java","java.io.BufferedOutputStream");
	
			</cfscript>

			<cfset rsdir=List(arguments.zipFilePath)>

			<cfif IsDefined("arguments.extractDirs") and len(arguments.extractDirs)>
				<cfquery name="rsdir" dbtype="query">
				select * from rsdir where
				<cfloop list="#arguments.extractDirs#" index="i" delimiters="|">
				<cfif started>or</cfif>
				<cfif right(i,1) neq delim>
				entry like '#PathFormat(i)##delim#%'
				<cfelse>
				entry like '#PathFormat(i)#%'
				</cfif>
				<cfset started=true>
				</cfloop>
				</cfquery>
				<cfloop query="rsDir">
					<cfset extractStruct["#hash(PathFormat(rsdir.entry))#"]=true>
				</cfloop>
			</cfif>

			<cfif IsDefined("arguments.excludeDirs") and len(arguments.excludeDirs)>
				<cfset started=false>
				<cfquery name="rsdir" dbtype="query">
				select * from rsdir where
				<cfloop list="#arguments.excludeDirs#" index="i" delimiters="|">
				<cfif started>or</cfif>
				<cfif right(i,1) neq delim>
				entry like '#PathFormat(i)##delim#%'
				<cfelse>
				entry like '#PathFormat(i)#%'
				</cfif>
				<cfset started=true>
				</cfloop>
				</cfquery>
				<cfloop query="rsDir">
					<cfset excludeStruct["#hash(PathFormat(rsdir.entry))#"]=true>
				</cfloop>
			</cfif>

			<cfscript>
			/* Convert to the right path format */
			arguments.zipFilePath = PathFormat(arguments.zipFilePath);
			arguments.extractPath = PathFormat(arguments.extractPath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.extractPath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ this.slash)
				arguments.extractPath = arguments.extractPath & this.slash;

			try
			{
				
				zipFileInstance.init(arguments.zipFilePath);

				/* Zip file entries */
				entries = zipFileInstance.entries();

				/* Loop over Zip file entries */
				while(entries.hasMoreElements())
				{
					entry = entries.nextElement();
					entryHash = hash(pathFormat(entry.getName()));

					if(NOT entry.isDirectory()
						AND
						(
							not structKeyExists(excludeStruct,entryHash)

							and (
									(
										not IsDefined("arguments.extractDirs") or not len(arguments.extractDirs)
									)

								OR
									structKeyExists(extractStruct,entryHash)
							)
						)
					)
					{

						if(currentIndex >= arguments.threadIndex && !(modIndex mod arguments.threads)){
							name = entry.getName();

							if(isDefined("arguments.extractDirs") and isDefined("arguments.extractDirsToTop") and yesNoFormat(arguments.extractDirsToTop)){
								name=right(name,len(name)-len(arguments.extractDirs));
							}

							/* Create directory only if 'useFolderNames' is 'yes' */
							if(arguments.useFolderNames EQ "yes")
							{
								lenPath = Len(name) - Len(GetFileFromPath(PathFormat(name)));

								if(lenPath) {
									path = extractPath & Left(PathFormat(name), lenPath);
								}	else {
									path = extractPath;
								}       

								if(NOT DirectoryExists(path)){
									ioFileInstance.init(path);
									ioFileInstance.mkdirs();
								}
							}

							/* Set file path */
							if(arguments.useFolderNames EQ "yes"){
								filePath = arguments.extractPath & PathFormat(name);
							} else  { 
								filePath = arguments.extractPath & GetFileFromPath(PathFormat(name));
							}

							/* Extract files. Files would be extract when following conditions are fulfilled:
							If the 'extractFiles' list is not defined,
							or the 'extractFiles' list is defined and the entry filename is found in the list,
							or the file already exists and 'overwriteFiles' is 'yes'. */
							if((NOT IsDefined("arguments.extractFiles")
								OR (IsDefined("arguments.extractFiles") AND ListFindNoCase(arguments.extractFiles, GetFileFromPath(PathFormat(name)), "|")))
							AND (NOT FileExists(filePath) OR (FileExists(filePath) AND arguments.overwriteFiles EQ "yes")))
							{
								// Skip if entry contains special characters
								try
								{
									ioOutputInstance.init(filePath);
									ioBufOutputInstance.init(ioOutputInstance);

									var inStream = zipFileInstance.getInputStream(entry);
									var l = inStream.read(buffer);

									while(l GTE 0)
									{
										ioBufOutputInstance.write(buffer, 0, l);
										l = inStream.read(buffer);
									}

									inStream.close();
									ioBufOutputInstance.close();
									ioOutputInstance.close();
									if(isDefined('application.Mura')){
										application.Mura.logText("zip thread #arguments.threadIndex#: #filePath#");
									}
								}

								catch(Any fileError)
								{
									if(isDefined('application.Mura')){
										application.Mura.logError(fileError);
									} else {
										writeLog(type="Error", log="exception", text=serializeJSON(fileError))
									}
									skip = "yes"; 
								}
							}
						}
						if(currentIndex >= arguments.threadIndex){
							modIndex++;
						}
						currentIndex++;
					}
				}

				zipFileInstance.close();

				/* Return true */
				return true;
			}

			catch(Any error)
			{
				zipFileInstance.close();
				if(isDefined('application.Mura')){
					application.Mura.logError(fileError);
				} else {
					writeLog(type="Error", log="exception", text=serializeJSON(error))
				}
				/* Return false */
				return false;
			}

		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- List --->
	<cffunction name="List" output="no" hint="List the content of a specified Zip file.">

		<!--- Function Arguments --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to list the content.">

		<cfscript>

			/* Default variables */
			var i = 0;
			var entries = "";
			var entry = "";
			var cols = "entry,date,size,packed,ratio,crc";
			var query = QueryNew(cols);
			var qEntry="";
			var qDate="";
			var qSize=0;
			var qPacked="";
			var qCrc="";
			var zipFileInstance = CreateObject("java","java.util.zip.ZipFile");
			var objDateInstance = CreateObject("java","java.util.Date");
			cols = ListToArray(cols);

			/* Open Zip file */
			zipFileInstance.init(arguments.zipFilePath);

			/* Zip file entries */
			entries = zipFileInstance.entries();

			/* Fill query with data */
			while(entries.hasMoreElements())
			{
				entry = entries.nextElement();

				if(NOT entry.isDirectory())
				{
					QueryAddRow(query, 1);

					qEntry = PathFormat(entry.getName());
					qDate = objDateInstance.init(entry.getTime());
					qSize = entry.getSize();
					qPacked = entry.getCompressedSize();
					qCrc = entry.getCrc();

					if(qSize GT 0) qRatio = Round(Evaluate(100-((qPacked*100)/qSize))) & "%";
					else           qRatio = "0%";

					for(i=1; i LTE ArrayLen(cols); i=i+1)
						QuerySetCell(query, cols[i], Trim(Evaluate("q#cols[i]#")));
				}
			}

			/* Close the Zip File */
			zipFileInstance.close();

			/* Return query */
			return query;

		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- gzipAddFile --->
	<cffunction name="gzipAddFile" output="no" returntype="boolean" hint="Create a new GZip file archive.">

		<!--- Function Arguments --->
		<cfargument name="GzipFilePath" required="yes" type="string" hint="Pathname of the GZip file to create.">
		<cfargument name="filePath" required="yes" type="string" hint="Pathname of a file to add to the GZip file archive.">

		<cfscript>

			/* Default variables */
			var l = 0;
			var buffer = RepeatString(" ",1024).getBytes();
			var gzFileName = "";
			var outputFile = "";
			var lastChr="";
			/* Convert to the right path format */
			arguments.GzipFilePath = PathFormat(arguments.GzipFilePath);
			arguments.filePath = PathFormat(arguments.filePath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.GzipFilePath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ this.slash)
				arguments.GzipFilePath = arguments.GzipFilePath & this.slash;

			try
			{

				/* Set output gzip file name */
				gzFileName = getFileFromPath(arguments.filePath) & ".gz";
				outputFile = arguments.GzipFilePath & gzFileName;

				variables.ioInput.init(arguments.filePath);
				variables.ioOutput.init(outputFile);
				variables.gzOutput.init(variables.ioOutput);

				l = variables.ioInput.read(buffer);

				while(l GT 0)
				{
					variables.gzOutput.write(buffer, 0, l);
					l = variables.ioInput.read(buffer);
				}

				/* Close the GZip file */
				variables.gzOutput.close();
				variables.ioOutput.close();
				variables.ioInput.close();

				/* Return true */
				return true;
			}

			catch(Any expr)
			{ return false; }

		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- gzipExtract --->
	<cffunction name="gzipExtract" output="no" returntype="boolean" hint="Extracts a specified GZip file into a specified directory.">

		<!--- Function Arguments --->
		<cfargument name="GzipFilePath" required="yes" type="string" hint="Pathname of the GZip file to extract.">
		<cfargument name="extractPath"  required="no"  type="string" default="#ExpandPath(".")#" hint="Pathname to extract the GZip file to.">

		<cfscript>

			/* Default variables */
			var l = 0;
			var buffer = RepeatString(" ",1024).getBytes();
			var gzFileName = "";
			var outputFile = "";
			var lastChr="";
			/* Convert to the right path format */
			arguments.GzipFilePath = PathFormat(arguments.GzipFilePath);
			arguments.extractPath  = PathFormat(arguments.extractPath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.extractPath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ this.slash)
				arguments.extractPath = arguments.extractPath & this.slash;

			try
			{
				/* Set output file name */
				gzFileName = getFileFromPath(arguments.GzipFilePath);
				outputFile = arguments.extractPath & Left(gzFileName, Len(gzFileName)-3);

				/* Initialize gzip file */
				variables.ioOutput.init(outputFile);
				variables.ioInput.init(arguments.GzipFilePath);
				variables.gzInput.init(variables.ioInput);

				while(l GTE 0)
				{
					variables.ioOutput.write(buffer, 0, l);
					l = variables.gzInput.read(buffer);
				}

				/* Close the GZip file */
				variables.gzInput.close();
				variables.ioInput.close();
				variables.ioOutput.close();

				/* Return true */
				return true;
			}

			catch(Any expr)
			{ return false; }

		</cfscript>

	</cffunction>

	<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
	<!--- Private functions for this component --->
	<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

	<!--- -------------------------------------------------- --->
	<!--- FilesList --->
	<cffunction name="FilesList" access="private" output="no" returntype="array" hint="Create an array with the file names of specified directory.">

		<!--- Function Arguments --->
		<cfargument name="directory" required="yes" type="string" hint="Absolute pathname of directory to get files list.">
		<cfargument name="filter" required="no" type="string"  default="" hint="File extension filter. One filter can be applied.">
		<cfargument name="recurse" required="no" type="boolean" default="no" hint="Get recursive files of subdirectories.">
		<cfargument name="sinceDate" required="no" type="string" default="" hint="Filter for files created since this datetime">
		<cfargument name="hiddenFiles" required="no" type="boolean" default="no" hint="Whether to include .svn or .git files.">
		<cfargument name="excludeDirs" required="yes" type="string"  default="" hint="| (Chr(124)) delimited list of dirs to not zip.">
		<cfset var i = 0>
		<cfset var n = 0>
		<cfset var dir   = "">
		<cfset var array = ArrayNew(1)>
		<cfset var subdir="">
		<cfdirectory action = "list"
					 name = "dir"
		             directory = "#PathFormat(arguments.directory)#"
					 filter = "#arguments.filter#">

		<cfif isDate(arguments.sinceDate)>
			<cfquery name="dir" dbtype="query">
			SELECT * FROM dir
			WHERE
			dateLastModified >= #createODBCDateTime(arguments.sinceDate)#
			</cfquery>
		</cfif>

		<cfif len(arguments.excludeDirs)>
			<cfquery name="dir" dbtype="query">
			SELECT * FROM dir
			WHERE
			type = 'File'
			or
			(	type='Dir'
				and name not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" separator="|" value="#PathFormat(arguments.excludeDirs)#">)
			)
			</cfquery>
		</cfif>


		<cfscript>

			if(dir.recordcount){
				/* Loop over directory query */
				for(i=1; i LTE dir.recordcount; i=i+1)
				{
					if(arguments.hiddenFiles or left(dir.name[i],1) neq "."){
						path = PathFormat(arguments.directory & this.slash & dir.name[i]);

						/* Add file to array */
						if(dir.type[i] eq "file")
							ArrayAppend(array, path);

						/* Get files from sub directorys and add them to the array */
						else if(dir.type[i] EQ "dir" AND arguments.recurse EQ "yes")
						{
							subdir = FilesList(path, arguments.filter, arguments.recurse);

							for(n=1; n LTE ArrayLen(subdir); n=n+1)
								ArrayAppend(array, subdir[n]);
						}
					}
				}
			}

			/* Return array */
			return array;

		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- PathFofrmat --->
	<cffunction name="PathFormat" access="private" output="no" hint="Convert path into Windows or Unix format.">

		<!--- Function Arguments --->
		<cfargument name="path" required="yes" type="string" hint="The path to convert.">

		<cfif FindNoCase("Windows", this.os)>
			<cfset arguments.path = Replace(arguments.path, "/", "\", "ALL")>
		<cfelse>
			<cfset arguments.path = Replace(arguments.path, "\", "/", "ALL")>
		</cfif>

		<cfreturn arguments.path>

	</cffunction>

	<cffunction name="ZipPathFormat" access="private" output="no" hint="Convert path into Windows or Unix format.">
		<!--- Function Arguments --->
		<cfargument name="path" required="yes" type="string" hint="The path to convert.">
		<cfset arguments.path = Replace(arguments.path, "\", "/", "ALL")>

		<cfreturn arguments.path>

	</cffunction>

</cfcomponent>
