/* license goes here */
component persistent="false" accessors="true" output="false" extends="mura.baseobject" hint="This provides content comment service level logic functionality" {

	property name='contentManager';
	property name='configBean';
	property name='debug';

	public any function init(required contentManager, required configBean) {
		setContentManager(arguments.contentManager);
		setConfigBean(arguments.configBean);
		setDebug(getConfigBean().getDebuggingEnabled());
		return this;
	}


	public any function getComments(
		string siteid='default'
		, string commentid
		, string contentid
		, string parentid
		, string remoteid
		, string ip
		, string email
		, string name
		, boolean isapproved
		, boolean isspam
		, boolean isdeleted
		, string sortby='entered'
		, string sortdirection='asc'
		, boolean returnCountOnly=false
		, numeric maxItems=1000
	) {
		var local = {};
		var qComments = new Query(datasource=getConfigBean().getReadOnlyDatasource());
		var rsComments = '';
		var dbtype=getConfigBean().getDbType();

		local.qryStr='';

		if(dbtype eq "mssql" and arguments.maxItems){
			local.qryStr='SELECT top ' & arguments.maxItems
				& ' * FROM tcontentcomments
				WHERE 0=0 ';
		} else if(dbtype eq "oracle" and arguments.maxItems){
			local.qryStr='select * from (
				SELECT * FROM tcontentcomments
				WHERE 0=0 ';
		} else {
			local.qryStr='SELECT *
				FROM tcontentcomments
				WHERE 0=0 ';
		}
		// siteid
		if ( StructKeyExists(arguments, 'siteid') ) {
			local.qryStr &= ' AND siteid = ( :siteid ) ';
			qComments.addParam(name='siteid', value=arguments.siteid, cfsqltype='cf_sql_varchar');
		}

		// commentid
		if ( StructKeyExists(arguments, 'commentid') ) {
			local.qryStr &= ' AND commentid = ( :commentid ) ';
			qComments.addParam(name='commentid', value=arguments.commentid, cfsqltype='cf_sql_varchar');
		}

		// keywords
		if ( StructKeyExists(arguments, 'keywords') ) {
			local.qryStr &= ' AND (comments like ( :comments ) ';
			qComments.addParam(name='comments', value="%#arguments.keywords#%", cfsqltype='cf_sql_varchar');
			local.qryStr &= ' OR name like ( :name )) ';
			qComments.addParam(name='name', value="%#arguments.keywords#%", cfsqltype='cf_sql_varchar');
		}

		//contentid
		if ( StructKeyExists(arguments, 'contentid') and len(arguments.contentid)) {
			local.qryStr &= ' AND contentid = ( :contentid ) ';
			qComments.addParam(name='contentid', value=arguments.contentid, cfsqltype='cf_sql_varchar');
		}

		// parentid
		if ( StructKeyExists(arguments, 'parentid') ) {
			local.qryStr &= ' AND parentid = ( :parentid ) ';
			qComments.addParam(name='parentid', value=arguments.parentid, cfsqltype='cf_sql_varchar');
		}

		// remoteid
		if ( StructKeyExists(arguments, 'remoteid') ) {
			local.qryStr &= ' AND remoteid = ( :remoteid ) ';
			qComments.addParam(name='remoteid', value=arguments.remoteid, cfsqltype='cf_sql_varchar');
		}

		// ip
		if ( StructKeyExists(arguments, 'ip') ) {
			local.qryStr &= ' AND ip = ( :ip ) ';
			qComments.addParam(name='ip', value=arguments.ip, cfsqltype='cf_sql_varchar');
		}

		// email
		if ( StructKeyExists(arguments, 'email') ) {
			local.qryStr &= ' AND email = ( :email ) ';
			qComments.addParam(name='email', value=arguments.email, cfsqltype='cf_sql_varchar');
		}

		// name
		if ( StructKeyExists(arguments, 'name') ) {
			local.qryStr &= ' AND name = ( :name ) ';
			qComments.addParam(name='name', value=arguments.name, cfsqltype='cf_sql_varchar');
		}

		// isapproved
		if ( StructKeyExists(arguments, 'isapproved') ) {
			local.qryStr &= ' AND isapproved = ( :isapproved ) ';
			qComments.addParam(name='isapproved', value=arguments.isapproved, cfsqltype='cf_sql_integer');
		}

		// isspam
		if ( StructKeyExists(arguments, 'isspam') ) {
			local.qryStr &= ' AND isspam = ( :isspam ) ';
			qComments.addParam(name='isspam', value=arguments.isspam, cfsqltype='cf_sql_integer');
		}

		// isdeleted
		if ( StructKeyExists(arguments, 'isdeleted') ) {
			local.qryStr &= ' AND isdeleted = ( :isdeleted ) ';
			qComments.addParam(name='isdeleted', value=arguments.isdeleted, cfsqltype='cf_sql_integer');
		}

		// startdate
		if ( StructKeyExists(arguments, 'startdate') && isDate(arguments.startdate) ) {
			local.qryStr &= ' AND entered >= :startdate ';
			qComments.addParam(name='startdate', value=arguments.startdate, cfsqltype='cf_sql_date');
		}

		// enddate
		if ( StructKeyExists(arguments, 'enddate') && isDate(arguments.enddate) ) {
			local.qryStr &= ' AND entered <= :enddate ';
			qComments.addParam(name='enddate', value=createODBCDateTime(createDateTime(year(arguments.enddate), month(arguments.enddate), day(arguments.enddate), 23, 59, 59)), cfsqltype='cf_sql_timestamp');
		}

		// categoryID
		if ( StructKeyExists(arguments, 'categoryID') && len(arguments.categoryID) ) {
			local.qryStr &= ' AND contentID in ( select distinct contentID from tcontentcategoryassign where categoryID in ( :categoryID ) ) ';
			qComments.addParam(name='categoryID', value=arguments.categoryID, cfsqltype='cf_sql_varchar', list='true');
		}

		local.qryStr &= ' ORDER BY ' & arguments.sortby & ' ' & arguments.sortdirection;


		if(dbType eq "nuodb" and arguments.maxItems){
			local.qryStr=local.qryStr & ' fetch ' & arguments.maxItems;
		}

		if(listFindNoCase("mysql,postgresql", dbType) and arguments.maxItems){
			local.qryStr=local.qryStr & ' limit ' & arguments.maxItems;
		}

		if(dbType eq "oracle" and arguments.maxItems){
			local.qryStr=local.qryStr & ' ) where ROWNUM <=  ' & arguments.maxItems;
		}

		//rsComments = qComments.setSQL(local.qryStr).execute().getResult(); // breaks in ACF9: https://github.com/stevewithington/MuraComments/issues/2 .. using workaround instead
		qComments.setSQL(local.qryStr);
		rsComments = qComments.execute().getResult();

		if ( arguments.returnCountOnly ) {
			return rsComments.recordcount;
		} else {
			return rsComments;
		}
	}


	public any function getCommentsIterator() {
		var local = {};
		local.rsComments = getComments(argumentCollection=arguments);
		local.iterator = getBean('contentCommentIterator');
		local.iterator.setQuery(local.rsComments);
		return local.iterator;
	}


	public boolean function approve(required string commentid) {
		var commentBean = getCommentBeanByCommentID(arguments.commentid);

		try {
			getContentManager().approveComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}

		try {
			commentBean.notifySubscribers();
		} catch(any e) {
			logError(e);
		}

		return true;
	}

	public boolean function markAsSpam(required string commentid) {
		var commentBean = getCommentBeanByCommentID(arguments.commentid);

		try {
			getContentManager().markCommentAsSpam(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}

		return true;
	}

	public boolean function unmarkAsSpam(required string commentid) {
		var commentBean = getCommentBeanByCommentID(arguments.commentid);

		try {
			getContentManager().unmarkCommentAsSpam(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}

		return true;
	}


	public any function getCommentBeanByCommentID(required string commentid) {
		return getContentManager().getCommentBean().setCommentID(arguments.commentID).load();
	}


	public boolean function unapprove(required string commentid) {
		try {
			getContentManager().unapproveComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}
		return true;
	}


	public boolean function delete(required string commentid) {
		try {
			getContentManager().deleteComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}
		return true;
	}

	public boolean function undelete(required string commentid) {
		try {
			getContentManager().undeleteComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}
		return true;
	}

	private any function handleError(required any error) {
		if ( getDebug() ) {
			WriteDump(arguments.error);
			abort;
		} else {
			return false;
		}
	}

	public string function dspCategoriesNestSelect(string siteID, string parentID, string categoryID, numeric nestLevel, numeric useID, string elementName){
		var rsList = getBean('categoryManager').getCategories(arguments.siteID, arguments.parentID, "");
		var row = "";
		var o = "";
		var elemID = "";
		var elemClass = "";
		var classList = "categories";
		var elemChecked = "";

		if (rsList.recordCount) {
			if (arguments.useID) {
				elemID = ' id="mura-nodes"';
			}
			if (arguments.nestLevel eq 0) {
				classList = listAppend(classList, "checkboxTree", " ");
			}
			elemClass = ' class="' & classList & '"';
			o &= "<ul#elemID##elemClass#>";

			for (row =1; row lte rsList.recordcount; row=row+1) {
				o &= "<li>";
				if (rsList.isOpen[row] eq 1) {
					if (listfind(arguments.categoryID, rslist.categoryID[row])) {
						elemChecked = " checked";
					} else {
						elemChecked = "";
					}
					o &= '<input type="checkbox" name="#esapiEncode('html_attr',arguments.elementName)#" class="checkbox" value="#esapiEncode('html_attr',rsList.categoryID[row])#"#elemChecked#/> ';
				}
				o &= esapiEncode('html',rsList.name[row]);
				if (rsList.hasKids[row]) {
					o &= dspCategoriesNestSelect(arguments.siteID, rsList.categoryID[row], arguments.categoryID, ++arguments.nestLevel, 0, arguments.elementName);
				}
				o &= "</li>";
			}
			o &= "</ul>";
		}
		return o;
	}

	public boolean function purgeDeletedComments(string siteid) {
		var local = {};
		var qDeleted = new Query(datasource=getConfigBean().getReadOnlyDatasource());
		var purged = true;

		local.qryStr = '
			DELETE
			FROM tcontentcomments
			WHERE 0=0
				AND isdeleted = 1
		';

		// siteid
		if ( StructKeyExists(arguments, 'siteid') ) {
			local.qryStr &= ' AND siteid = ( :siteid ) ';
			qDeleted.addParam(name='siteid', value=arguments.siteid, cfsqltype='cf_sql_varchar');
		}

		qDeleted.setSQL(local.qryStr);

		try {
			qDeleted.execute().getResult();
		} catch(any e) {
			purged = false;
		}

		return purged;
	}

}
