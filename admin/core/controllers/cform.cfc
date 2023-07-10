/* license goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		if ( !(variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000004',arguments.rc.siteid) ) ) {
			secure(arguments.rc);
		}
	}

	public function setFormBuilderManager(formBuilderManager) output=false {
		variables.formBuilderManager=arguments.formBuilderManager;
	}

	public string function export(struct rc="#StructNew()#") output=false {
		var zipTool	= createObject("component","mura.Zip");
		var tempDir=getTempDirectory();

		var formStruct = getBean('content').loadBy(contentID=arguments.rc.contentid,siteid=rc.siteid ).getAllValues();
		var formJSON = {};

		formJSON.body = formStruct.body;
		formJSON.responseMessage = formStruct.responseMessage;
		formJSON.responseSendTo = formStruct.responseSendTo;

		formJSON = serializeJSON(formJSON);

		var zipTitle = rereplaceNoCase(lcase(formStruct.title),"[^a-zA-Z0-9]{1,}","_","all") & "_" & dateFormat(now(),"yyyy_dd_mm") & "_" & rc.siteid;

		rc.zipFileLocation = "#tempDir#/form-#zipTitle#.zip";
		rc.zipTitle = zipTitle;

		fileWrite(tempDir & "/form.json",formJSON);
		zipTool.AddFiles(zipFilePath=rc.zipFileLocation,directory=tempDir,recurse="false",filter="*.json");
	}

	public string function importform(struct rc="#StructNew()#") output=false {
		var zipTool	= createObject("component","mura.Zip");
		var tempDir=getTempDirectory();
		var tempFolder = createUUID();

		if(structCount(form) && form.formzip != '') {

			if(form.title == "") {
				rc.errormessage="Title is required";
				return;
			}

			directoryCreate("#tempDir#/#tempFolder#");
			var uploadedFile = fileUpload("#tempDir#/#tempFolder#","form.formzip","application/zip","overwrite");

			zipTool.Extract(zipFilePath="#tempDir#/#tempFolder#/#uploadedfile.serverfile#",extractPath="#tempDir#/#tempFolder#",overwriteFiles=true);

			var formJSON = fileRead("#tempDir#/#tempFolder#/form.json");

			if(!isJSON(formJSON)) {
				rc.errormessage="Upload did not contain an exported Mura Form";
				return;
			}

			var formStruct = deserializeJSON(formJSON);

			var newFormBean = getBean('content');

			newFormBean.set('type','Form');
			newFormBean.set('siteid',rc.siteid);
			newFormBean.set('moduleid','00000000000000000000000000000000004');
			newFormBean.set('body',formStruct.body);
			newFormBean.set('responseMessage',formStruct.responseMessage);
			newFormBean.set('responseSendTo',formStruct.responseSendTo);
			newFormBean.set('title',form.title);

			newFormBean.save();
			location("?muraAction=cArch.list&siteid=#rc.siteid#&topid=00000000000000000000000000000000004&moduleid=00000000000000000000000000000000004&activeTab=0",false);
		}



	}

	public string function getDialog(struct rc="#StructNew()#") output=false {
		arguments.rc.return	= variables.formBuilderManager.getDialog( dialog=arguments.rc.dialog );
	}

	public string function getForm(struct rc="#StructNew()#") output=false {
		var formBean	= "";
		if ( !StructKeyExists( arguments.rc,"formID" ) ) {
			arguments.rc.formID = createUUID();
		}
		formBean	= variables.formBuilderManager.getFormBean( formID=arguments.rc.formID );
		arguments.rc.return = formBean.getAsJSON();
	}

	public string function getField(struct rc="#StructNew()#") output=false {
		var fieldBean	= "";
		if ( !StructKeyExists( arguments.rc,"fieldID" ) ) {
			arguments.rc.fieldID = createUUID();
		}
		if ( !StructKeyExists( arguments.rc,"fieldType" ) ) {
			arguments.rc.fieldType = "field-textfield";
		}
		fieldBean	= variables.FormBuilderManager.getfieldBean( fieldID=arguments.rc.fieldID,formID=arguments.rc.formID,fieldtype=arguments.rc.fieldType );
		arguments.rc.return = fieldBean.getAsJSON();
	}

	public string function getFieldType(struct rc="#StructNew()#") output=false {
		var fieldTypeBean	= "";
		if ( !StructKeyExists( rc,"fieldTypeID" ) ) {
			arguments.rc.fieldTypeID = createUUID();
		}
		if ( !StructKeyExists( rc,"fieldType" ) ) {
			arguments.rc.fieldType = "field-textfield";
		}
		fieldTypeBean	= variables.FormBuilderManager.getfieldTypeBean( fieldTypeID=arguments.rc.fieldTypeID,fieldType=arguments.rc.fieldType );
		arguments.rc.return = fieldTypeBean.getAsJSON();
	}

	public string function getFieldTemplate(struct rc="#StructNew()#") output=false {
		var fieldTemplate	= variables.FormBuilderManager.getFieldTemplate( arguments.rc.fieldtype );
		arguments.rc.return = fieldTemplate;
	}

	public string function getDataset(struct rc="#StructNew()#") output=false {
		var datasetBean	= "";
		if ( !StructKeyExists( arguments.rc,"datasetID" ) || !len(arguments.rc.datasetID) ) {
			arguments.rc.datasetID = createUUID();
		}
		datasetBean	= variables.FormBuilderManager.getdatasetBean( datasetID=arguments.rc.datasetID,fieldID=arguments.rc.fieldID );
		arguments.rc.return = datasetBean.getAsJSON();
	}

}
