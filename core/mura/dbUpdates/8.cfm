<cfscript>
	try{
		dbUtility.setTable("tcontent").alterColumn(column='inheritObjects',dataType='varchar',length='50');
	} catch(any e){};

	getBean('altURL').checkSchema();
	getBean('entityTagAssign').checkSchema();
	getBean('entityCategoryAssign').checkSchema();

	dbUtility.setTable("tcontent")
		.addColumn(column="canonicalURL",dataType="varchar",length=255)
		.addColumn(column="isTemplate",dataType="tinyint");

	/*alter table MURAX.Tclassextendattributes add (new_column varchar2(255)); 
		update MURAX.Tclassextendattributes set new_column = dbms_lob.substr(label,255,1); 
		alter table MURAX.Tclassextendattributes drop column label; 
		alter table MURAX.Tclassextendattributes rename column new_column to LABEL; */
	if(getDbType()=='Oracle'){
		try{
			dbUtility.setTable("tclassextendattributes")
				.addColumn(column="label",dataType="varchar",length=255);
		} catch(any e){};
	}

	getBean('proxy').checkSchema();
	getBean('proxyEvent').checkSchema();
	getBean('proxyCredential').checkSchema();
	getBean('lambda').checkSchema();
	getBean('lambdaenv').checkSchema();
	getBean('oauthProvider').checkSchema();
	getBean('oauthSetting').checkSchema();

	try{
		dbUtility.setTable("tusers").alterColumn(column='remoteid',dataType='varchar',length='255');
	} catch(any e){};

	try{
		if(getValue(property='unique_user_index',defaultValue=false)){
			dbUtility.setTable('tusers')
			.addIndex('groupname')
			.addIndex('type')
			.addIndex('subtype')
			.dropIndex('remoteid')
			.dropIndex('username')
			.dropIndex('siteid')
			.addUniqueIndex('username,remoteid,siteid');
		} else {
			dbUtility.setTable("tusers")
			.addIndex('groupname')
			.addIndex('type')
			.addIndex('subtype')
			.dropIndex('username,remoteid,siteid')
			.addIndex('remoteid')
			.addIndex('username')
			.addIndex('siteid');
		}
	} catch(any e){
		logError(e);
	};
		
	getBean('moduleTemplate').checkSchema();
</cfscript>

<cfquery name="rsCheck">
	select siteID from tsettings where siteid not in(
		select siteid from tcontent where type='Module' and moduleID='00000000000000000000000000000000017'
	)
</cfquery>

<cfif rsCheck.recordcount>
	<cfloop query="rsCheck">
		<cfquery>
		INSERT INTO tcontent
		(
			SiteID
			,ModuleID
			,ParentID
			,ContentID
			,ContentHistID
			,Type
			,subType
			,Active
			,Title
      		,Display
			,Approved
			,IsNav
			,forceSSL
		) VALUES  (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsCheck.siteid#">
			,'00000000000000000000000000000000017'
			,'00000000000000000000000000000000END'
			,'00000000000000000000000000000000017'
			,'#createUUID()#'
			,'Module'
			,'default'
			,1
			,'Module Template Access'
			,1
			,1
			,1
			,0
		)
		</cfquery>
	</cfloop>
</cfif>

<cfquery name="rsCheck">
	select siteID from tsettings where siteid not in(
		select siteid from tcontent where type='Module' and moduleID='00000000000000000000000000000000018'
	)
</cfquery>

<cfif rsCheck.recordcount>
	<cfloop query="rsCheck">
		<cfquery>
		INSERT INTO tcontent
		(
			SiteID
			,ModuleID
			,ParentID
			,ContentID
			,ContentHistID
			,Type
			,subType
			,Active
			,Title
      		,Display
			,Approved
			,IsNav
			,forceSSL
		) VALUES  (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsCheck.siteid#">
			,'00000000000000000000000000000000018'
			,'00000000000000000000000000000000END'
			,'00000000000000000000000000000000018'
			,'#createUUID()#'
			,'Module'
			,'default'
			,1
			,'File Manager Access'
			,1
			,1
			,1
			,0
		)
		</cfquery>
	</cfloop>
</cfif>

<cfquery name="rsCheck">
	select siteID from tsettings where siteid not in(
		select siteid from tcontent where type='Module' and moduleID='00000000000000000000000000000000019'
	)
</cfquery>

<cfif rsCheck.recordcount>
	<cfloop query="rsCheck">
		<cfquery>
		INSERT INTO tcontent
		(
			SiteID
			,ModuleID
			,ParentID
			,ContentID
			,ContentHistID
			,Type
			,subType
			,Active
			,Title
      		,Display
			,Approved
			,IsNav
			,forceSSL
		) VALUES  (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsCheck.siteid#">
			,'00000000000000000000000000000000019'
			,'00000000000000000000000000000000END'
			,'00000000000000000000000000000000019'
			,'#createUUID()#'
			,'Module'
			,'default'
			,1
			,'Approval Chain Manager Access'
			,1
			,1
			,1
			,0
		)
		</cfquery>
	</cfloop>
</cfif>

<cfquery name="rsCheck">
	select siteID from tsettings where siteid not in(
		select siteid from tcontent where type='Module' and moduleID='00000000000000000000000000000000020'
	)
</cfquery>

<cfif rsCheck.recordcount>
	<cfloop query="rsCheck">
		<cfquery>
		INSERT INTO tcontent
		(
			SiteID
			,ModuleID
			,ParentID
			,ContentID
			,ContentHistID
			,Type
			,subType
			,Active
			,Title
      		,Display
			,Approved
			,IsNav
			,forceSSL
		) VALUES  (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsCheck.siteid#">
			,'00000000000000000000000000000000020'
			,'00000000000000000000000000000000END'
			,'00000000000000000000000000000000020'
			,'#createUUID()#'
			,'Module'
			,'default'
			,1
			,'API Proxies'
			,1
			,1
			,1
			,0
		)
		</cfquery>
	</cfloop>
</cfif>

