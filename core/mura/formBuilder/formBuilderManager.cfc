//  license goes here 
/**
 * This provides form service level logic functionality
 */
component extends="mura.baseobject" displayname="FormBuilderManager" output="false" hint="This provides form service level logic functionality" {
	variables.fields		= StructNew();

	public FormBuilderManager function init(required any configBean) output=false {
		variables.configBean = configBean;
		variables.filePath = "#expandPath("/muraWRM")##variables.configBean.getAdminDir()#/core/utilities/formbuilder/templates";
		variables.templatePath = "/muraWRM#variables.configBean.getAdminDir()#/core/utilities/formbuilder/templates";
		variables.fields["en_US"] = StructNew();
		return this;
	}

	public function createJSONForm(uuid formID="#createUUID()#") output=false {
		var formStruct	= StructNew();
		var formBean		= new formBean(formID=formID);
		formStruct['datasets']	= StructNew();
		formStruct['form']		= formBean.getAsStruct();
		return serializeJSON( formStruct );
	}

	public function getFormBean(uuid formID="#createUUID()#", boolean asJSON="false") output=false {
		var formBean		= new formBean(formID=arguments.formID);
		if ( arguments.asJSON ) {
			return formBean.getasJSON();
		} else {
			return formBean;
		}
	}

	public function getFieldBean(required uuid formID, uuid fieldID="#createUUID()#", string fieldType="field-textfield", boolean asJSON="false") output=false {
		var fieldBean		= new fieldBean(formID=arguments.formID,fieldID=arguments.fieldID,isdirty=1);
		var fieldTypeBean	= "";
		var mmRBF			= application.rbFactory;
		var fieldTypeName	= rereplace(arguments.fieldType,".[^\-]*-","");
		var sessionData=getSession();
		fieldTypeBean	= getFieldTypeBean( fieldType=fieldType,asJSON=arguments.asJSON );
		fieldBean.setFieldType( fieldTypeBean );
		fieldBean.setLabel( mmRBF.getKeyValue(sessionData.rb,'formbuilder.new') & " " & mmRBF.getKeyValue(sessionData.rb,'formbuilder.field.#fieldTypeName#') );
		if ( arguments.asJSON ) {
			return fieldBean.getasJSON();
		} else {
			return fieldBean;
		}
	}

	public function getDatasetBean(required uuid datasetID, uuid fieldID="#createUUID()#", boolean asJSON="false", any modelBean) output=false {
		var datasetBean		= new datasetBean(datasetID=arguments.datasetID,fieldID=arguments.fieldID);
		var mBean			= "";
		if ( !StructKeyExists( arguments,"modelBean" ) || isSimpleValue(arguments.modelBean) ) {
			mBean	= new datarecordBean(datasetID=arguments.datasetID);
		} else {
			mBean	= arguments.modelBean;
		}
		datasetBean.setModel( mBean );
		if ( arguments.asJSON ) {
			return datasetBean.getasJSON();
		} else {
			return datasetBean;
		}
	}

	public function getFieldTypeBean(uuid fieldTypeID="#createUUID()#", string fieldType="field-textfield", boolean asJSON="false") output=false {
		var aFieldTemplate		= ListToArray(rereplace(arguments.fieldType,"[^[:alnum:]|-]","","all"),"-");
		var displayName			= lcase( aFieldTemplate[1] );
		var typeName				= lcase( aFieldTemplate[2] );
		var fieldTypeBean		= new fieldtypeBean(fieldTypeID=arguments.fieldTypeID,fieldtype=typeName,displayType=displayName);
		switch ( fieldTypeBean.getFieldType() ) {
			case  "dropdown":
			case  "checkbox":
			case  "radio":
			case  "multientity":
				fieldTypeBean.setIsData( 1 );
				break;
			case  "textarea":
			case  "htmleditor":
				fieldTypeBean.setIsLong( 1 );
				break;
		}
		if ( arguments.asJSON ) {
			return fieldTypeBean.getasJSON();
		} else {
			return fieldTypeBean;
		}
	}

	public function getFieldTemplate(required string fieldType, string locale="en", boolean reload="false") output=false {
		var fieldTemplate		= lcase( rereplace(arguments.fieldType,"[^[:alnum:]|-]","","all") & ".cfm" );
		var filePath				= "#variables.filePath#/#fieldTemplate#";
		var templatePath			= "#variables.templatePath#/#fieldTemplate#";
		var strField				= "";
		var mmRBF				= application.rbFactory;
		var sessionData=getSession();
		if ( !StructKeyExists( variables.fields,arguments.locale) ) {
			variables.fields[arguments.locale] = StructNew();
		}
		if ( arguments.reload || !StructKeyExists( variables.fields[arguments.locale],fieldTemplate) ) {
			if ( !fileExists( filePath ) ) {
				return mmRBF.getKeyValue(sessionData.rb,'formbuilder.missingfieldtemplatefile') & ": " & fieldTemplate;
			}
			savecontent variable="strField" {
				include templatePath;
			}
			variables.fields[arguments.locale][arguments.fieldType] = trim(strField);
		}
		return variables.fields[arguments.locale][arguments.fieldType];
	}

	public function getDialog(required string dialog, string locale="en_US", boolean reload="false") output=false {
		var dialogTemplate		= lcase( rereplace(arguments.dialog,"[^[:alnum:]|-]","","all") & ".cfm" );
		var filePath				= "#variables.filePath#/#dialogTemplate#";
		var templatePath			= "#variables.templatePath#/#dialogTemplate#";
		var strField				= "";
		var mmRBF				= application.rbFactory;
		var sessionData=getSession();
		if ( !StructKeyExists( variables.fields,arguments.locale) ) {
			variables.fields[arguments.locale] = StructNew();
		}
		if ( arguments.reload || !StructKeyExists( variables.fields[arguments.locale],dialogTemplate) ) {
			if ( !fileExists( filePath ) ) {
				return mmRBF.getKeyValue(sessionData.rb,'formbuilder.missingfieldtemplatefile') & ": " & dialogTemplate;
			}
			savecontent variable="strField" {
				include templatePath;
			}
			variables.fields[arguments.locale][arguments.dialog] = trim(strField);
		}
		return variables.fields[arguments.locale][arguments.dialog];
	}

	public struct function renderFormJSON(required string formJSON) output=false {
		var formStruct		= StructNew();
		var dataStruct		= StructNew();
		var returnStruct	= StructNew();
		var formBean			= "";
		var fieldBean		= "";
		var mmRBF			= application.rbFactory;
		var sessionData=getSession();
		if ( !isJSON( arguments.formJSON ) ) {
			throw( message=mmRBF.getKeyValue(sessionData.rb,"formbuilder.mustbejson") );
		}
		formStruct = deserializeJSON(arguments.formJSON);
		return formStruct;
	}

	public struct function processDataset(required any $, required struct dataset) output=false {
		var returnStruct	= StructNew();
		var srcData			= "";
		var mmRBF			= application.rbFactory;
		var dataArray		= ArrayNew(1);
		var x				= "";
		var dataOrder		= ArrayNew(1);
		var dataRecords		= StructNew();
		var dataBean			= "";
		var rsData			= "";
		var primaryKey		= "";
		var rowid			= "";
		var sessionData=getSession();
		var httpService="";
		if ( !StructKeyExists( arguments.dataset,"datasetID" ) ) {
			throw( message=mmRBF.getKeyValue(sessionData.rb,"formbuilder.invaliddataset") );
		}
		switch ( arguments.dataset.sourcetype ) {
			case  "manual":
			case  "entered":
				return arguments.dataset;
				break;
			case  "remote":

				httpService=getHttpService();
					httpService.setMethod('get');
					httpService.setURL(dataset.source);
					srcData=httpService.send().getPrefix();
				if ( isJSON(srcData.filecontent) ) {
					arguments.dataset = deserializeJSON(srcData.filecontent);
					if ( isDefined('arguments.dataset.data') ) {
						arguments.dataset=arguments.dataset.data;
					}
				}
				return arguments.dataset;
				break;
			case  "muraorm":
				dataBean = $.getBean( arguments.dataset.source );
				primaryKey = dataBean.getPrimaryKey();
				rsData = dataBean
					.loadby( siteid = $.event('siteid'))
					.getFeed()
					.getQuery();

				/* toScript ERROR: Unimplemented cfloop condition:  query="#rsData#" 

								<cfloop query="#rsData#">
					<cfset rowid = rsdata[primaryKey] />
					<cfset ArrayAppend( arguments.dataset.datarecordorder,rowid )>
					<cfset arguments.dataset.datarecords[rowid] = $.getBean('utility').queryRowToStruct( rsData,currentrow )>
					<cfset arguments.dataset.datarecords[rowid]['value'] = rowid>
					<cfset arguments.dataset.datarecords[rowid]['datarecordid'] = rowid>
					<cfset arguments.dataset.datarecords[rowid]['datasetid'] = dataset.datasetid>
					<cfset arguments.dataset.datarecords[rowid]['isselected'] = 0>
				</cfloop>

				*/

				return arguments.dataset;
				break;
			case  "object":
				arguments.dataset = new '#$.siteConfig().getAssetMap()#.#replacenocase(dataset.source,".cfc","")#'().getData($,arguments.dataset);
				return arguments.dataset;
				break;
			case  "dsp":
				var filepath=$.siteConfig().lookupDisplayObjectFilePath(filePath=dataset.source);
				if ( len(filepath) ) {
					include filepath;
				}
				return arguments.dataset;
				break;
			default:
				return arguments.dataset;
				break;
		}
	}

	public function getForms(required any $, required any siteid, string excludeformid="") output=false {
		var rs="";
		cfquery( password=variables.configBean.getReadOnlyDbPassword(), name="rs", datasource=variables.configBean.getReadOnlyDatasource(), username=variables.configBean.getReadOnlyDbUsername() ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

			writeOutput("select contentid,title from tcontent
			where type='Form'
			and siteid=");
			cfqueryparam( cfsqltype="cf_sql_varchar", value=arguments.siteid );

			writeOutput(" and active=1");
			if ( len(arguments.excludeformid) ) {

				writeOutput(" and contentid !=");
				cfqueryparam( cfsqltype="cf_sql_varchar", value=arguments.excludeformid );
			}

			writeOutput(" order by title");
		}
		return rs;
	}

	public function renderNestedForm(required any $, required any siteid, required any formid, string prefix="") {
		var renderedForm = arguments.$.dspObject_Include(
						thefile='formbuilder/dsp_form.cfm',
						formid=arguments.formid,
						siteid=arguments.siteid,
						isNested=true,
						prefix=arguments.prefix
					);
		return renderedForm;
	}

	function generateFormObject($,event,contentBean,extends) {

		var content = "";
		var siteid = arguments.$.event('siteid');

		if(structKeyExists(arguments,"contentbean"))
			content = arguments.contentBean;
		else
			content = $.getBean('content');

		var objectname = rereplacenocase( content.getValue('filename'),"[^[:alnum:]]","","all" );
		var formStruct = deserializeJSON( content.getValue('body') );

		if( !structKeyExists(formStruct.form,'formattributes') || !structKeyExists(formStruct.form.formattributes,'muraormentities') || formStruct.form.formattributes.muraormentities neq 1 )
			return;

		var extendpath = "mura.formbuilder.entityBean";

		if( structKeyExists(arguments,"extends") and len(arguments.extends) ) {
			extendpath = arguments.extends;
		}
		var field = "";

		if(!directoryExists(#expandPath("/muraWRM/" & siteid)# & "/includes/model")) {
			directoryCreate(#expandPath("/muraWRM/" & siteid)# & "/includes/model");
		}
		if(!directoryExists(#expandPath("/muraWRM/" & siteid)# & "/includes/model/core")) {
			directoryCreate(#expandPath("/muraWRM/" & siteid)# & "/includes/model/core");
		}
		if(!directoryExists(#expandPath("/muraWRM/" & siteid)# & "/includes/model/core/formbuilder")) {
			directoryCreate(#expandPath("/muraWRM/" & siteid)# & "/includes/model/core/formbuilder");
		}
		if(!directoryExists(#expandPath("/muraWRM/" & siteid)# & "/includes/model/beans")) {
			directoryCreate(#expandPath("/muraWRM/" & siteid)# & "/includes/model/beans");
		}
		if(!directoryExists(#expandPath("/muraWRM/" & siteid)# & "/includes/archive")) {
			directoryCreate(#expandPath("/muraWRM/" & siteid)# & "/includes/archive");
		}

		var exists = fileExists( "#expandPath("/muraWRM/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc" );

		var param = "";
		var fieldcount = 0;

		var fieldorder = [];
		var listview = "";

		for(var i = 1;i <= ArrayLen(formStruct.form.pages);i++) {
			fieldorder.addAll(formStruct.form.pages[i]);
		}

		var fieldlist = formStruct.form.fields;

		// start CFC
		var con = 'component contentid="#content.getContentID()#"  extends="#extendpath#" table="fb_#lcase(objectname)#" entityName="#lcase(objectname)#Entity" displayName="#objectname#Entity" rendertype="form"';

		for(var i = 1;i <= ArrayLen(fieldorder);i++) {
			field = fieldlist[ fieldorder[i] ];
			if(field.fieldtype.fieldtype == 'textfield' and listLen(listview) < 5)
				listview = listAppend(listview,field.name);
		}

		if(listLen(listview) > 0) {
			con = con & ' listview="#listview#" ';
		}

		con = con & '{#chr(13)##chr(13)#// ** Not update safe! Edit extending bean in /model/beans **#chr(13)##chr(13)#';
		con = con & '	property name="#lcase(objectname)#id" fieldtype="id";#chr(13)#';

		var datasets = formStruct.datasets;

		for(var i = 1;i <= ArrayLen(fieldorder);i++) {
			field = fieldlist[ fieldorder[i] ];

			if( field.fieldtype.fieldtype != "section" && field.fieldtype.fieldtype != "textblock" && field.fieldtype.fieldtype != "matrix") {
				fieldcount++;
				param = '	property name="#field.name#"';
				param = param & ' displayname="#field.label#"';
				param = param & ' orderno="#fieldcount#"';

				if(structKeyExists(field,'isrequired') && field.isrequired == true)
					param = param & ' required="true"';

				if(structKeyExists(field,'validatetype') && len(field.validatetype) > 0) {
					param = param & ' validate="#field.validatetype#"';

					if(field.validatetype == 'regex' && structKeyExists(field,'validateregex') && len(field.validateregex) > 0)
						param = param & ' validateparams="#field.validateregex#"';
				}

				if(structKeyExists(field,'size') && isNumeric(field.size) && field.size > 0) {
					param = param & ' length="#field.size#"';
				}
				else if(field.fieldtype.fieldtype == "textfield" || field.fieldtype.fieldtype == "hidden") {
					param = param & ' length="250"';
				}

				param = param & '#getDataType($,field,datasets,objectname)#';

				con = con & "#param#;#chr(13)#";
			}
			else if( field.fieldtype.fieldtype == "matrix" ) {
				var matrix = createMatrixParams($,field,datasets,objectname,fieldcount);
				fieldcount = matrix.fieldcount;
				con = con & matrix.params;
			}
		}

		con = con & "#chr(13)##chr(13)#";

		// close CFC
		con = con & "#chr(13)#}";

		fileWrite( "#expandPath("/muraWRM/" & siteid)#/includes/model/core/formbuilder/#lcase(objectname)#Entity.cfc",con );

		if( !exists ) {
		// start update safe CFC
			var con = 'component contentid="#content.getContentID()#" extends="#siteid#.includes.model.core.formbuilder.#lcase(objectname)#Entity" table="fb_#lcase(objectname)#" entityName="#lcase(objectname)#" displayName="#objectname#" rendertype="form"';
			con = con & '{#chr(13)##chr(13)#// ** update safe ** #chr(13)##chr(13)#}';

			fileWrite( "#expandPath("/muraWRM/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc",con );
		}

		if(structKeyExists(application.objectMappings,objectname))
		try {
			StructDelete(application.objectMappings,objectname);
		}
		catch(any e) {

		}

		try {
		$.globalConfig().registerBean( "#siteid#.includes.model.beans.#lcase(objectname)#",siteid );
		$.getBean(objectname).checkSchema();
		}
		catch(any e) {
			removeFormObject( objectname,$.event('siteid') );
			rethrow;
		}

	}


	function destroyFormObject(contentBean) {

		var content = arguments.contentBean;
		var siteid = arguments.contentBean.getSiteID();

		var objectname = rereplacenocase( content.getValue('filename'),"[^[:alnum:]]","","all" );
		if(getServiceFactory().containsBean(objectname)){
			getBean('dbUtility').dropTable(table=getBean(objectname).getTable());
			getServiceFactory().removeBean(objectname);
		}
		var fullFilePath="#expandPath("/muraWRM/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc";
		if(fileExists( fullFilePath )){
			fileDelete(fullFilePath);
		}
		fullFilePath="#expandPath("/muraWRM/" & siteid)#/includes/model/core/formbuilder/#lcase(objectname)#Entity.cfc";
		if(fileExists( fullFilePath )){
			fileDelete(fullFilePath);
		}
	}
	function removeFormObject( objectname,siteid ) {

		if(getServiceFactory().containsBean(objectname)){
			try {
			getBean('dbUtility').dropTable(table=getBean(objectname).getTable());
			}
			catch(any e) {
				writeLog("Error dropping table on formBuilderManager removeFormObject: #arguments.objectname#");
			}
			getServiceFactory().removeBean(objectname);
		}

		var fullFilePath="#expandPath("/muraWRM/" & siteid)#/includes/model/beans/#lcase(objectname)#.cfc";

		if(fileExists( fullFilePath )){
			fileDelete(fullFilePath);
		}

		fullFilePath="#expandPath("/muraWRM/" & siteid)#/includes/model/core/formbuilder/#lcase(objectname)#Entity.cfc";

		if(fileExists( fullFilePath )){
			fileDelete(fullFilePath);
		}

	}

	function getDataType( $,fieldData,datasets,objectname ) {
		var str = "";
		var fieldtype = fieldData.fieldtype.fieldtype;
		var dataset = {sourcetype='manual'};
		var cfcBridgeName = "";

		if(StructKeyExists( arguments.datasets,arguments.fieldData.datasetid )) {
			dataset = arguments.datasets[arguments.fieldData.datasetid];
			cfcBridgeName = lcase("#arguments.objectname##dataset.source#");
		}
		if(StructKeyExists(arguments.fieldData,"columnsid") && StructKeyExists( arguments.datasets,arguments.fieldData.columnsid )) {
			columns = arguments.datasets[arguments.fieldData.columnsid];
		}

		switch(fieldtype) {
			case "nested":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(fieldData.name)#id"';
					createFieldOptionCFC($,fieldData,objectname,cfcBridgeName,dataset,false,false);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "dropdown":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(fieldData.name)#id"';
					createFieldOptionCFC($,fieldData,objectname,cfcBridgeName,dataset,false,true);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "radio":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-one" cfc="#dataset.source#" rendertype="#fieldtype#" fkcolumn="#lcase(fieldData.name)#id"';
					createFieldOptionCFC($,fieldData,objectname,cfcBridgeName,dataset,false,true);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "checkbox":
				if( dataset.sourcetype == 'muraorm' ) {
					str = ' fieldtype="one-to-many" cfc="#cfcBridgeName#" rendertype="#fieldtype#" source="#lcase(dataset.source)#" loadkey="#lcase(objectname)#id"';
					createFieldOptionCFC($,fieldData,objectname,cfcBridgeName,dataset,true,true);
				}
				else {
					str = ' datatype="varchar" length="250" rendertype="#fieldtype#"';
				}
			break;
			case "multiselect":
				str = ' fieldtype="one-to-many" cfc="#cfcBridgeName#" rendertype="dropdown" source="#lcase(dataset.source)#" loadkey="#lcase(objectname)#id"';
				createFieldOptionCFC($,fieldData,objectname,cfcBridgeName,dataset,true,true);
			break;
			case "textfield":
				str = ' datatype="varchar" rendertype="#fieldtype#" list=true';
			break;
			case "hidden":
				str = ' datatype="varchar" rendertype="#fieldtype#"';
			break;
			case "file":
				str = ' datatype="varchar" length="35" fieldtype="index" rendertype="#fieldtype#"';
			break;
			case "textarea":
				str = ' datatype="text" rendertype="#fieldtype#"';
			break;
		}

		return str;
	}

	function createMatrixParams( $,fieldData,datasets,objectname,fieldcount ) {

		var matrix = {};
		matrix.fieldcount = arguments.fieldcount;
		matrix.params = "";

		var questions = datasets[fieldData.datasetid];
		var param = "";
		var record = "";

		for(var i = 1;i <= ArrayLen(questions.datarecordorder);i++) {
			record = questions.datarecords[ questions.datarecordorder[i] ];

			matrix.fieldcount++;

			if(!structKeyExists(record,"name")) {
				record.name = rereplace( lcase(record.label),'[^a-z0-9]', '', 'all');
			}

			param = '	property name="#fieldData.name#_#record.name#"';
			param = param & ' displayname="#record.label#"';
			param = param & ' orderno="#matrix.fieldcount#"';
			param = param & ' datatype="varchar" length="35" rendertype="matrix" matrix="#fieldData.name#";#chr(13)#';

			matrix.params = matrix.params & param;
		}

		return matrix;
	}


	function createFieldOptionCFC( $,fieldData,parentObject,cfcBridgeName,dataset,createJoinentity=false,createDataentity=false ) {
		var objectname = fieldData.name;
		var exists = fileExists( "#expandPath("/muraWRM/" & $.event('siteid'))#/includes/model/beans/#lcase(arguments.cfcBridgeName)#.cfc" );
		var param = "";

		objectname = rereplacenocase( objectname,"[^[:alnum:]]","","all" );

		if( !exists && arguments.createJoinEntity ) {
			// start relationship CFC
			var con = 'component extends="mura.bean.beanORM" table="fb_#lcase(arguments.cfcBridgeName)#" entityName="#lcase(arguments.cfcBridgeName)#" displayName="#arguments.cfcBridgeName#" type="join" {#chr(13)##chr(13)#';

			var con = con & '	property name="#lcase(arguments.cfcBridgeName)#id" fieldtype="id";#chr(13)##chr(13)#';

			var con = con & '	property name="#lcase(arguments.parentobject)#" fieldtype="many-to-one" cfc="#arguments.parentobject#" fkcolumn="#lcase(arguments.parentobject)#id";#chr(13)#';
			var con = con & '	property name="#lcase(dataset.source)#" fieldtype="one-to-one" cfc="#dataset.source#" fkcolumn="#lcase(dataset.source)#id";#chr(13)#';

			con = con & "#chr(13)##chr(13)#";

			// close relationship CFC
			con = con & "#chr(13)#}";

			fileWrite( "#expandPath("/muraWRM/" & $.event('siteid'))#/includes/model/beans/#lcase(cfcBridgeName)#.cfc",con );

			if( structKeyExists(application.objectMappings,dataset.source))
			try {
				StructDelete(application.objectMappings,dataset.source);
			}
			catch(any e) {
			}
		}

		if(arguments.createDataentity == false) {
			$.globalConfig().registerBean( "#$.event('siteid')#.includes.model.beans.#lcase(cfcBridgeName)#",$.event('siteid') );
			$.getBean(cfcBridgeName).checkSchema();
			return;
		}

		exists = fileExists( expandPath("/muraWRM/" & $.event('siteid')) & "/includes/model/beans/#lcase(dataset.source)#.cfc" );

		// data beans are never recreated
		if(exists) {
			$.globalConfig().registerBean( "#$.event('siteid')#.includes.model.beans.#lcase(dataset.source)#",$.event('siteid') );
			$.getBean(dataset.source).checkSchema();
			return;
		}
		else if(arguments.dataset.sourcetype != "muraorm") {
			return;
		}

		// start data CFC
		var con = 'component extends="mura.formbuilder.fieldOptionBean" table="fb_#lcase(dataset.source)#" entityName="#lcase(dataset.source)#" displayName="#dataset.source#" {#chr(13)##chr(13)#';

		var con = con & '	property name="#lcase(dataset.source)#id" fieldtype="id";#chr(13)##chr(13)#';

		con = con & "#chr(13)##chr(13)#";

		// close data CFC
		con = con & "#chr(13)#}";

		fileWrite( "#expandPath("/muraWRM/" & $.event('siteid'))#/includes/model/beans/#lcase(dataset.source)#.cfc",con );

		if(structKeyExists(application.objectMappings,dataset.source))
		try {
			StructDelete(application.objectMappings,dataset.source);
		}
		catch(any e) {}

		if(arguments.createDataentity == false) {
			$.globalConfig().registerBean( "#$.event('siteid')#.includes.model.beans.#lcase(dataset.source)#",$.event('siteid') );
			$.getBean(dataset.source).checkSchema();
		}

		try {
		if( arguments.createJoinEntity ) {
			$.globalConfig().registerBean( "#$.event('siteid')#.includes.model.beans.#lcase(cfcBridgeName)#",$.event('siteid') );
			$.getBean(cfcBridgeName).checkSchema();

			}
		}
		catch(any e) {
			removeFormObject( cfcBridgeName,$.event('siteid') );
			rethrow(e);
		}

	}

	function createDatasetCFC( $,fieldData,dataset ) {
		var objectname = fieldData.name & "ExtendedData";
		var exists = fileExists( "#expandPath("/muraWRM/" & $.event('siteid'))#/includes/core/formbuilder/#lcase(objectname)#.cfc" );
		var param = "";
		var record = "";

		// start data CFC
		var con = 'component extends="mura.formbuilder.entityBean" table="fb_#lcase(objectname)#" entityName="#lcase(objectname)#" displayName="#objectname#" {#chr(13)##chr(13)#';
		var con = con & '	property name="#lcase(objectname)#id" fieldtype="id";#chr(13)##chr(13)#';
		var con = con & '	property name="#lcase(fieldData.name)#" fieldtype="many-to-one" cfc="#lcase(fieldData.name)#" fkcolumn="#lcase(fieldData.name)#id";#chr(13)#';

		return;

		for(var i = 1;i <= ArrayLen(arguments.dataset.datarecordcount);i++) {
			record = arguments.dataset.datarecords[ arguments.dataset.datarecordcount[i] ];
			var con = con & '	property name="#lcase(record)#" fieldtype="many-to-one" cfc="#lcase(fieldData.name)#" fkcolumn="#lcase(fieldData.name)#id";#chr(13)#';
		}


	}



	function getFormFromObject( siteid,formName,nested=false) {

		return getFormProperties( argumentCollection=arguments );
	}

	function getModuleBeans( siteid ) {
		var $=getBean('$').init(arguments.siteid);
		var dirList = directoryList( #expandPath("/muraWRM/" & siteid)# & "/includes/model/beans",false,'query' );
		var beanArray = [];

		for(var i = 1; i <= dirList.recordCount;i++) {
			var name = replaceNoCase( dirList.name[i],".cfc","");
			arrayAppend(beanArray,{name=name});

		}

		return beanArray;
	}


	function getFormProperties( siteid,formName,nested=false,debug=false ) {

		var $=getBean('$').init(arguments.siteid);
		var formObj = $.getBean( arguments.formname );
		var util = $.getBean('fb2Utility');
		var props = formObj.getProperties();
		var formProps = {};
		var formArray = [];
		var formFields = [];
		var val = 100000;
		var x = "";

		for(var i in props) {
			if( !listFindNoCase("errors,fromMuraCache,instanceID,isnew,saveErrors,site",i) ) {
				formProps[i] = getFieldProperties( props[i] );

				if( formProps[i].rendertype == "form" ) {
					formProps[i]['nested'] = getFieldProperties( arguments.siteid,formProps[i].cfc,true );
				}

				if(!structKeyExists(formProps[i],"orderno"))
					formProps[i]['orderno'] = val++;

				if(structKeyExists(formProps[i],"cfc")) {
					var dataBean = $.getBean(i);

					if(dataBean.getProperty('source') != "") {
						var dataBean = $.getBean(dataBean.getProperty('source'));
					}

					var options = dataBean
						.getFeed()
						.addParam(field='siteid',relationship='equals',criteria='#arguments.siteid#')
						.getIterator();

					formProps[i]['options'] = util.queryToArray( options.getQuery(),dataBean.getPrimaryKey() );
				}
			}
		}

		formArray = structSort(formProps,"numeric","asc","orderno" );

		for( var i = 1;i <= ArrayLen(formArray);i++ ) {
			ArrayAppend(formFields,formProps[formArray[i]]);
		}

		if(arguments.debug) {
			writeDump(formFields);
			abort;
		}


		return formFields;
	}

	function getFieldProperties( prop ) {

		var fieldProp = {};

		for(var x in arguments.prop ) {
			fieldProp["#lcase(x)#"] = arguments.prop[x];
		}

		if( !structKeyExists(fieldProp,"rendertype")) {
			fieldProp['rendertype'] = getRenderType( fieldProp );
		}

		return fieldProp;
	}


	function getRenderType( formProp ) {
		var retType = "";

		if( structKeyExists(formProp,"cfc") ) {
			retType = "dropdown";
		}

		return retType;

	}

}
