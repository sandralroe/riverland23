<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides file CRUD logic">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="pluginManager" type="any" required="yes"/>
		<cfargument name="fileWriter" required="true" default=""/>

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.pluginManager=arguments.pluginManager />
		<cfset variables.fileWriter=arguments.fileWriter>
		<cfif variables.configBean.getFileStoreAccessInfo() neq ''>
			<cfset variables.s3=new s3(
							listFirst(variables.configBean.getFileStoreAccessInfo(),'^'),
							listGetAt(variables.configBean.getFileStoreAccessInfo(),2,'^'),
							"#application.configBean.getFileDir()#/s3cache/",
							variables.configBean.getFileStoreEndPoint())>
			<cfif listLen(variables.configBean.getFileStoreAccessInfo(),"^") eq 3>
				<cfset variables.bucket=listLast(variables.configBean.getFileStoreAccessInfo(),"^") />
			<cfelse>
				<cfset variables.bucket="sava" />
			</cfif>
		<cfelse>
			<cfset variables.s3=""/>
			<cfset variables.bucket=""/>
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="getS3" output="false">
		<cfreturn variables.s3 />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="fileObj" type="any" required="yes"/>
		<cfargument name="contentid" type="any" required="yes"/>
		<cfargument name="siteid" type="any" required="yes"/>
		<cfargument name="filename" type="any" required="yes"/>
		<cfargument name="contentType" type="string" required="yes"/>
		<cfargument name="contentSubType" type="string" required="yes"/>
		<cfargument name="fileSize" type="numeric" required="yes"/>
		<cfargument name="moduleID" type="string" required="yes"/>
		<cfargument name="fileExt" type="string" required="yes"/>
		<cfargument name="fileObjSmall" type="any" required="yes"/>
		<cfargument name="fileObjMedium" type="any" required="yes"/>
		<cfargument name="fileID" type="any" required="yes" default="#createUUID()#"/>
		<cfargument name="fileObjSource" type="any" default=""/>
		<cfargument name="credits" type="string" required="yes" default=""/>
		<cfargument name="caption" type="string" required="yes" default=""/>
		<cfargument name="alttext" type="string" required="yes" default=""/>
		<cfargument name="remoteid" type="string" required="yes" default=""/>
		<cfargument name="remoteURL" type="string" required="yes" default=""/>
		<cfargument name="remotePubDate" type="string" required="yes" default=""/>
		<cfargument name="remoteSource" default=""/>
		<cfargument name="remoteSourceURL" type="string" required="yes" default=""/>
		<!---<cfargument name="gpsaltitude" type="string" required="yes" default=""/>
		<cfargument name="gpsaltiuderef" type="string" required="yes" default=""/>
		<cfargument name="gpslatitude" type="string" required="yes" default=""/>
		<cfargument name="gpslatituderef" type="string" required="yes" default=""/>
		<cfargument name="gpslongitude" type="string" required="yes" default=""/>
		<cfargument name="gpslongituderef" type="string" required="yes" default=""/>
		<cfargument name="gpsimgdirection" type="string" required="yes" default=""/>
		<cfargument name="gpstimestamp" type="string" required="yes" default=""/>--->
		<cfargument name="exif" type="string" required="yes" default=""/>

		<cfset var ct=arguments.contentType & "/" & arguments.contentSubType />
		<cfset var pluginEvent = new mura.event(arguments) />
		<cfset var fileBean=getBean('file')>

		<cfset arguments.fileExt=lcase(arguments.fileExt)>
		<cfset fileBean.set(arguments)>
		<cfset pluginEvent.setValue('fileBean',fileBean)>
		<cfset variables.pluginManager.announceEvent("onBeforeFileCache",pluginEvent)>


		<cfswitch expression="#variables.configBean.getFileStore()#">
			<cfcase value="fileDir">
				<cfif isBinary(arguments.fileObj)>

					<cfset variables.fileWriter.writeFile(mode="774", file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#.#arguments.fileExt#", output="#arguments.fileObj#")>

					<cfif listFindNoCase("png,gif,jpg,jpeg,webp",arguments.fileExt)>
						<cfif isBinary(arguments.fileObjSource)>
							<cfset variables.fileWriter.writeFile(mode="774", file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_source.#arguments.fileExt#", output="#arguments.fileObjSource#")>
						</cfif>
						<cfif isBinary(arguments.fileObjSmall)>
							<cfset variables.fileWriter.writeFile(mode="774", file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_small.#arguments.fileExt#", output="#arguments.fileObjSmall#")>
						</cfif>
						<cfif isBinary(arguments.fileObjMedium)>
							<cfset variables.fileWriter.writeFile(mode="774", file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_medium.#arguments.fileExt#", output="#arguments.fileObjMedium#")/>
						</cfif>
					<cfelseif arguments.fileExt eq 'flv'>
						<cfif isBinary(arguments.fileObjSmall)>
							<cfset variables.fileWriter.writeFile(mode="774", file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_small.jpg", output="#arguments.fileObjSmall#")>
						</cfif>
						<cfif isBinary(arguments.fileObjMedium)>
							<cfset variables.fileWriter.writeFile( mode="774",  file="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_medium.jpg", output="#arguments.fileObjMedium#")>
						</cfif>
					</cfif>
				<cfelse>
					<cfset variables.fileWriter.moveFile(mode="774", destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#.#arguments.fileExt#", source="#arguments.fileObj#")>

					<cfif listFindNoCase("png,gif,jpg,jpeg,webp",arguments.fileExt)>
						<cfif len(arguments.fileObjSource) AND FileExists(arguments.fileObjSource)>
							<cfset variables.fileWriter.moveFile(mode="774", destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_source.#arguments.fileExt#", source="#arguments.fileObjSource#")>
						</cfif>
						<cfif len(arguments.fileObjSmall) AND FileExists(arguments.fileObjSmall)>
							<cfset variables.fileWriter.moveFile(mode="774", destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_small.#arguments.fileExt#", source="#arguments.fileObjSmall#")>
						</cfif>
						<cfif len(arguments.fileObjMedium) AND FileExists(arguments.fileObjMedium)>
							<cfset variables.fileWriter.moveFile(mode="774", destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_medium.#arguments.fileExt#", source="#arguments.fileObjMedium#")/>
						</cfif>
					<cfelseif arguments.fileExt eq 'flv'>
						<cfif len(arguments.fileObjSmall) AND FileExists(arguments.fileObjSmall)>
							<cfset variables.fileWriter.moveFile(mode="774", destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_small.jpg", source="#arguments.fileObjSmall#")>
						</cfif>
						<cfif len(arguments.fileObjMedium) AND FileExists(arguments.fileObjMedium)>
							<cfset variables.fileWriter.writeFile( mode="774",  destination="#application.configBean.getFileDir()#/#arguments.siteid#/cache/file/#arguments.fileID#_medium.jpg", source="#arguments.fileObjMedium#")>
						</cfif>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="s3">
				<cfset variables.s3.putFileOnS3(arguments.fileObj,ct,variables.bucket,'#arguments.siteid#/#arguments.fileid#.#arguments.fileExt#') />
				<cfset var s3_path = "#arguments.siteid#/cache/file/">
				<cfset variables.s3.putFileOnS3(arguments.fileObj,ct,variables.bucket,'#s3_path##arguments.fileid#.#arguments.fileExt#') />
				<cfif arguments.fileExt eq 'jpg' or arguments.fileExt eq 'jpeg' or arguments.fileExt eq 'png' or arguments.fileExt eq 'gif' or arguments.fileExt eq 'webp'>
					<cfif isBinary(fileObjSmall)><cfset variables.s3.putFileOnS3(arguments.fileObjSmall,ct,variables.bucket,'#s3_path##arguments.fileid#_small.#arguments.fileExt#') /></cfif>
					<cfif isBinary(fileObjMedium)><cfset variables.s3.putFileOnS3(arguments.fileObjMedium,ct,variables.bucket,'#s3_path##arguments.fileid#_medium.#arguments.fileExt#') /></cfif>
					<cfelseif arguments.fileExt eq 'flv'>
					<cfif isBinary(fileObjSmall)><cfset variables.s3.putFileOnS3(arguments.fileObjSmall,'image/jpeg',variables.bucket,'#s3_path##arguments.fileid#_small.jpg') /></cfif>
					<cfif isBinary(fileObjMedium)><cfset variables.s3.putFileOnS3(arguments.fileObjMedium,'image/jpeg',variables.bucket,'#s3_path##arguments.fileid#_medium.jpg') /></cfif>
					</cfif>
			</cfcase>
		</cfswitch>

		<cfset fileBean.save(processFile=false)>

		<cfset variables.pluginManager.announceEvent("onFileCache", pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onAfterFileCache",pluginEvent)>

		<cfif listFindNoCase('jpg,jpeg,png,webp',fileBean.getFileExt()) and isDefined('request.newImageIDList')>
			<cfset request.newImageIDList=listAppend(request.newImageIDList,fileid)>
		</cfif>

		<cfreturn fileid />
	</cffunction>

	<cffunction name="deleteVersion" output="false">
		<cfargument name="fileID" type="any" required="yes"/>

		<cfquery>
			update tfiles set deleted=1 where fileid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#">
		</cfquery>
	</cffunction>

	<cffunction name="deleteAll" output="false">
		<cfargument name="contentID" type="string" required="yes"/>
		<cfset var rs='' />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select contentHistID, fileID, siteid from tcontent
			where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#">
			and fileID is not null
		</cfquery>

		<cfset deleteIfNotUsed(valueList(rs.fileID),valueList(rs.contentHistID),rs.siteid)>
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			SELECT fileID, contentID, siteID, moduleID, filename, fileSize, contentType, contentSubType, fileExt,image, created, alttext, caption, credits FROM tfiles where fileid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#">
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="readAll" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			SELECT * FROM tfiles where fileid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#">
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="readMeta" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			SELECT fileID, contentID, siteID, moduleID, filename, fileSize, contentType, contentSubType, fileExt, created, alttext, caption, credits  FROM tfiles where fileid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#">
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="readSmall" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			SELECT fileID, contentID, siteID, moduleID, filename, fileSize, contentType, contentSubType, fileExt, imageSmall, created, alttext, caption, credits  FROM tfiles where fileid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#"> and imageSmall is not null
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="readMedium" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			SELECT fileID, contentID, siteID, moduleID, filename, fileSize, contentType, contentSubType, fileExt, imageMedium, created  FROM tfiles where fileid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#"> and imageMedium is not null
		</cfquery>

		<cfreturn rs />

	</cffunction>

	<cffunction name="deleteIfNotUsed" output="false">
		<cfargument name="fileID" type="any" required="yes"/>
		<cfargument name="baseID" type="any" required="yes"/>
		<cfargument name="siteid" type="any" default=""/>

		<cfset var rs1 = "" />
		<cfset var rs2 = "" />
		<cfset var rs3 = "" />
		<cfset var rs4 = "" />
		<cfset var rs5 = "" />
		<cfset var rs6 = "" />
		<cfset var contentGateway=getBean('contentGateway')>

		<cfif len(arguments.siteid)>
			<cfset arguments.siteid=getBean('settingsManager').getSite(arguments.siteid).getFilePoolID()>
		</cfif>

		<cfif len(arguments.fileID)>
			<cfset var fileIDList="">
			<cfset var item="">
			<cfloop list="#arguments.fileid#" item="item">
				<cfif isValid('UUID',item)>
					<cfset fileIDList=listAppend(fileIDList, item)>
				</cfif>
			</cfloop>
			<cfset arguments.fileID=fileIDList>
		</cfif>
		
		<cfif len(arguments.fileID)>
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs1')#">
				SELECT fileId FROM tcontent where
				fileid in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.fileID#">)
				and contenthistId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
			</cfquery>

			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs2')#">
				SELECT attributeValue FROM tclassextenddata where
				stringValue in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.fileID#">)
				and baseId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
			</cfquery>
 
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs4')#">
				SELECT photoFileID FROM tusers where
				photoFileID in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.fileID#">)
				and userId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
			</cfquery>

			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs4')#">
				SELECT placeholderImgID FROM tsettings where
				placeholderImgID in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.fileID#">)
			</cfquery>
			
			<cfset var checkLooseContentForIds=variables.configBean.getValue(property="checkLooseContentForFileIds", defaultValue=true)>

			<cfif checkLooseContentForIds>
				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs3')#">
					SELECT attributeValue FROM tclassextenddatauseractivity where
					<cfset local.started=false>
					(<cfloop list="#arguments.fileid#" index="local.f">
						<cfif local.started>or </cfif>
						tclassextenddatauseractivity.attributeValue like <cfqueryparam  cfsqltype="cf_sql_varchar" value="%#contentGateway.serializeJSONParam(local.f)#%">
						<cfset local.started=true>
						</cfloop>
					)
					and baseId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
				</cfquery>

				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs5')#">
					SELECT contentid FROM tcontent where
					1=1
					<cfif len(arguments.siteid)>
					and tcontent.siteid = <cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.siteid#">
					</cfif>
					and tcontent.contenthistId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
					<cfset local.started=false>
					and (<cfloop list="#arguments.fileid#" index="local.f">
						<cfif local.started>or </cfif>
						tcontent.body like <cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="%#local.f#%">
						<cfset local.started=true>
						</cfloop>
					)
				</cfquery>
			</cfif>

			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs6')#">
				SELECT contentid FROM tcontentobjects where
				<cfset local.started=false>
				(<cfloop list="#arguments.fileid#" index="local.f">
					<cfif local.started>or </cfif>
					tcontentobjects.params like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#contentGateway.serializeJSONParam(local.f)#%">
					<cfset local.started=true>
					</cfloop>
				)
				and tcontentobjects.contenthistId not in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.baseID#">)
			</cfquery>

			<cfif not rs1.recordcount and not rs2.recordcount and not rs4.recordcount and not rs6.recordcount 
				and (
					not checkLooseContentForIds or not rs3.recordcount and not rs5.recordcount
				)>
				<cfset deleteVersion(arguments.fileID) />
			</cfif>
		</cfif>

	</cffunction>

	<cffunction name="purgeDeleted" output="false">
		<cfargument name="siteid" default="">
		<cfset var rs="">

		<cflock type="exclusive" name="purgingDeletedFile#application.instanceID#" timeout="1000">
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
				select fileID from tfiles where deleted=1
				<cfif len(arguments.siteID)>
				and siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
				</cfif>
			</cfquery>

			<cfloop query="rs">
				<cfset deleteCachedFile(rs.fileID)>
			</cfloop>

			<cfquery>
				delete from tfiles where deleted=1
				<cfif len(arguments.siteID)>
				and siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
				</cfif>
			</cfquery>
		</cflock>
	</cffunction>

	<cffunction name="restoreVersion" output="false">
		<cfargument name="fileID">
		<cfquery>
		update tfiles set deleted=0 where fileID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileID#">
		</cfquery>
		</cffunction>

	<cffunction name="deleteCachedFile">
		<cfargument name="fileID" type="string" required="yes"/>
		<cfset var rsFile=readMeta(arguments.fileID) />
		<cfset var data=arguments />
		<cfset var filePath="#application.configBean.getFileDir()#/#rsfile.siteID#/cache/file/"/>
		<cfset var rsDir=""/>
		<cfset data.siteID=rsFile.siteID />
		<cfset data.rsFile=rsFile />
		<cfset var pluginEvent = new mura.event(data) />

		<cfset variables.pluginManager.announceEvent("onFileCacheDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeFileCacheDelete",pluginEvent)>

		<cfswitch expression="#variables.configBean.getFileStore()#">
			<cfcase value="fileDir">
				<cfdirectory action="list" name="rsDIR" directory="#filepath#" filter="#arguments.fileid#*">
				<cfloop query="rsDir">
					<cffile action="delete" file="#filepath##rsDir.name#">
				</cfloop>
			</cfcase>

			<cfcase value="s3">
				<cfset variables.s3.deleteS3File(variables.bucket,'#rsFile.siteID#/#arguments.fileid#.#rsFile.fileExt#') />
				<cfif listFindNoCase("png,gif,jpg,jpeg,webp",rsFile.fileExt)>
					<cfset variables.s3.deleteS3File(variables.bucket,'#rsFile.siteID#/#arguments.fileid#_small.#rsFile.fileExt#') />
					<cfset variables.s3.deleteS3File(variables.bucket,'#rsFile.siteID#/#arguments.fileid#_medium.#rsFile.fileExt#') />
				<cfelseif rsFile.fileEXT eq "flv">
					<cfset variables.s3.deleteS3File(variables.bucket,'#rsFile.siteID#/#arguments.fileid#_small.jpg') />
					<cfset variables.s3.deleteS3File(variables.bucket,'#rsFile.siteID#/#arguments.fileid#_medium.jpg') />
				</cfif>
			</cfcase>

		</cfswitch>

		<cfset variables.pluginManager.announceEvent("onAfterFileCacheDelete",pluginEvent)>
	</cffunction>

</cfcomponent>
