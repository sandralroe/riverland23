/* license goes here */
component extends="controller" output="false" {
	variables.moduleid='00000000000000000000000000000000014';
	
	public function setChangesetManager(changesetManager) output=false {
		variables.changesetManager=arguments.changesetManager;
	}

	public function before(rc) output=false {
		if ( (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('#variables.moduleid#',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)) ) {
			secure(arguments.rc);
		}
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.startdate";
		param default="" name="arguments.rc.stopdate";
		param default=1 name="arguments.rc.page";
		param default="" name="arguments.rc.keywords";
		param default="" name="arguments.rc.categoryid";
		param default="" name="arguments.rc.tags";
	}

	public function list(rc) output=false {
		var feed=variables.changesetManager.getFeed(argumentCollection=arguments.rc);
		feed.setSiteID(arguments.rc.siteid);
		if ( isDate(rc.startdate) ) {
			feed.addParam(column='publishdate',datatype='date',criteria=arguments.rc.startdate,condition=">=");
		}
		if ( isDate(rc.stopdate) ) {
			arguments.rc.stopdate = DateAdd("d", 1, arguments.rc.stopdate);
			feed.addParam(column='publishdate',datatype='date',criteria=arguments.rc.stopdate,condition="<=");
			if ( !isDate(rc.startdate) ) {
				feed.addParam(column='publishdate',datatype='date',criteria=dateAdd('yyyy',100,now()),condition=">=");
			}
		}
		if ( len(rc.keywords) ) {
			feed.addParam(column='name',criteria=arguments.rc.keywords,condition="contains");
		}
		if ( len(rc.tags) ) {
			cfquery( name="local.rstags" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("select changesetid from tchangesettagassign where tag in (");
				cfqueryparam( list=true, cfsqltype="cf_sql_varchar", value=arguments.rc.tags );

				writeOutput(")");
			}
			if ( local.rstags.recordcount ) {
				feed.addParam(column='changesetid',criteria=valuelist(local.rstags.changesetid),condition="in");
			} else {
				feed.addParam(column='changesetid',criteria='none');
			}
		}
		if ( len(rc.categoryid) ) {
			cfquery( name="local.rscats" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("select changesetid from tchangesetcategoryassign where categoryid in (");
				cfqueryparam( list=true, cfsqltype="cf_sql_varchar", value=arguments.rc.categoryid );

				writeOutput(")");
			}
			if ( local.rscats.recordcount ) {
				feed.addParam(column='changesetid',criteria=valuelist(local.rscats.changesetid),condition="in");
			} else {
				feed.addParam(column='changesetid',criteria='none');
			}
		}
		arguments.rc.changesets=feed.getIterator();
		arguments.rc.changesets.setNextN(20);
		arguments.rc.changesets.setPage(arguments.rc.page);
	}

	public function publish(rc) output=false {
		variables.changesetManager.publish(rc.changesetID);
		variables.fw.redirect(action="cChangesets.edit",append="changesetID,siteID",path="./");
	}

	public function rollback(rc) output=false {
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));
		if ( rc.$.validateCSRFTokens(context=arguments.rc.changesetid) && isEditor ) {
			variables.changesetManager.rollback(rc.changesetID);
		}
		variables.fw.redirect(action="cChangesets.edit",append="changesetID,siteID",path="./");
	}

	public function assignments(rc) output=false {
		arguments.rc.siteAssignments=variables.changesetManager.getAssignmentsIterator(arguments.rc.changesetID,arguments.rc.keywords,'00000000000000000000000000000000000');
		arguments.rc.componentAssignments=variables.changesetManager.getAssignmentsIterator(arguments.rc.changesetID,arguments.rc.keywords,'00000000000000000000000000000000003');
		arguments.rc.formAssignments=variables.changesetManager.getAssignmentsIterator(arguments.rc.changesetID,arguments.rc.keywords,'00000000000000000000000000000000004');
		if ( application.configBean.getValue(property='variations',defaultValue=false) ) {
			arguments.rc.variationAssignments=variables.changesetManager.getAssignmentsIterator(arguments.rc.changesetID,arguments.rc.keywords,'00000000000000000000000000000000099');
		}
		arguments.rc.changeset=variables.changesetManager.read(arguments.rc.changesetID);
	}

	public function removeitem(rc) output=false {
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));
		if ( rc.$.validateCSRFTokens(context=arguments.rc.changesetid) && isEditor ) {
			variables.changesetManager.removeItem(rc.changesetID,rc.contenthistID);
		}
		variables.fw.redirect(action="cChangesets.assignments",append="changesetID,siteID,keywords",path="./");
	}

	public function edit(rc) output=false {
		arguments.rc.changeset=variables.changesetManager.read(arguments.rc.changesetID);
	}

	public function save(rc) output=false {
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));
		if ( rc.$.validateCSRFTokens(context=arguments.rc.changesetid) && isEditor ) {
			arguments.rc.changeset=variables.changesetManager.read(arguments.rc.changesetID).set(arguments.rc).save();
			arguments.rc.changesetID=arguments.rc.changeset.getChangesetID();
		}
		if ( isDefined('arguments.rc.changeset') && !arguments.rc.changeset.hasErrors() ) {
			variables.fw.redirect(action="cChangesets.list",append="changesetID,siteID",path="./");
		}
	}

	public function delete(rc) output=false {
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));
		if ( rc.$.validateCSRFTokens(context=arguments.rc.changesetid) && isEditor ) {
			arguments.rc.changeset=variables.changesetManager.read(arguments.rc.changesetID).delete();
		}
		variables.fw.redirect(action="cChangesets.list",append="changesetID,siteID",path="./");
	}

}
