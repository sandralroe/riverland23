component extends="mura.bean.beanORM" table='tfiles' public=true entityName="file" hint="This provides file data access and persistence" {

	property name="fileid" fieldtype="id";
	property name="content" fieldtype="one-to-one" fkcolumn="contentid" cfc="content" required=false nullable=true;
	property name="site" fieldtype="many-to-one" fkcolumn="siteid" cfc="site";
	property name="filename" datatype="varchar" length=200;
	property name="contentType" datatype="varchar" length=100;
	property name="contentSubType" datatype="varchar" length=200;
	property name="fileSize" datatype="int" default=0;
	property name="fileExt" datatype="varchar" length=50;
	property name="moduleid" datatype="char" default="00000000000000000000000000000000000" length=35;
	property name="created" datatype="datetime";
	property name="deleted" datatype="int" default=0;
	property name="caption" datatype="text";
	property name="credits" datatype="varchar" length=255;
	property name="alttext" datatype="varchar" length=255;
	property name="fileField" default="newfile" persistent=false;
	property name="remoteID" type="varchar" length=255 fieldtype="index";
	property name="remoteURL" type="varchar" length=255;
	property name="remotePubDate" type="datetime" ;
	property name="remoteSource" type="varchar" length=255;
	property name="remoteSourceURL" type="varchar" length=255;
	/*
	property name="gpsaltitude" type="varchar" length=50;
	property name="gpsaltituderef" type="varchar" length=50;
	property name="gpslatitude" type="varchar" length=50;
	property name="gpslatituderef" type="varchar" length=50;
	property name="gpslongitude" type="varchar" length=50;
	property name="gpslongituderef" type="varchar" length=50;
	property name="gpsimgdirection" type="varchar" length=50;
	property name="gpstimestamp" type="varchar" length=50;
	*/
	property name="exif" datatype="text";

	/*
	function setSummary(summary){
		setValue('caption',arguments.summary);
		return this;
	}
	*/

	function setFileSize(fileSize){
		variables.instance.fileSize=int(arguments.fileSize);
		return this;
	}

	function setFileField(fileField){
		variables.instance.fileField=arguments.fileField;
		if(isdefined('form') and structKeyExists(form,variables.instance.fileField)){
			setValue(variables.instance.fileField,form['#variables.instance.fileField#']);
		}
	}

	function save(processFile=true){
		if(arguments.processFile && len(getValue('fileField')) && len(getValue(getValue('fileField')))){
			setValue('fileID',createUUID());

			var fileManager=getBean('fileManager');

			if(fileManager.isPostedFile(getValue('fileField'))){
				logText('Uploading posted field: ' & getValue('fileField'));
				local.tempFile=fileManager.upload(getValue('fileField'));
			} else {

				if(!getBean('configBean').getAllowLocalFiles() && (not( find("://",getValue('newfile')) || find("data:image/",getValue('newfile'))) || find("file://",getValue('newfile')))){
					setValue('filename','Local files are not allowed');
					return this;
				}

				var site=this.getSite();
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
				local.tempFile=fileManager.emulateUpload(filePath=filePath);
			}

			//logText(serializeJSON(local.tempFile));

			if(isStruct(local.tempfile.exif)){
				if(fileManager.allowMetaData(local.tempfile.exif)){
					local.tempFile.exif=serializeJSON(local.tempFile.exif);
				} else {
					setValue('filename','File contains invalid Metadata');
					if(fileExists(local.tempFile.serverDirectory & "/" & local.tempFile.serverfilename)){
						fileDelete(local.tempFile.serverDirectory & "/" & local.tempFile.serverfilename);
					}
					return this;
				}
			}

			var allowableExtensions=getBean('configBean').getFmAllowedExtensions();
			var allowableMimeTypes=getBean('configBean').getAllowedMimeTypes();

			if((!len(allowableExtensions) || listFindNoCase(allowableExtensions, local.tempFile.serverFileExt)) && (!len(allowableMimeTypes) || listFindNoCase(allowableMimeTypes, '#local.tempFile.contentType#/#local.tempFile.contentSubType#'))){
				structAppend(variables.instance, local.tempFile);
				structAppend(variables.instance, fileManager.process(local.tempFile,getValue('siteid')));
				variables.instance.fileExt=local.tempFile.serverFileExt;
				variables.instance.filename=local.tempFile.ClientFile;

				//writeDump(var=variables.instance,abort=true);

				param name='variables.instance.content' default='';
				param name='variables.instance.exif' default={};

				fileManager.create(argumentCollection=variables.instance);

				setAllValues(getBean('file').loadBy(fileID=getValue('fileID')).getAllValues());
			}	else {

				var fileDelim='/';

				try{
					fileDelete(local.tempfile.serverDirectory & fileDelim & local.tempfile.serverFilename & '.' & local.tempfile.serverFileExt);
				} catch (Any e){}

				setValue('filename','Invalid file type .' & ucase(local.tempfile.serverFileExt));
			}
		} else {

			serializeExif();

			if(listLast(get('filename'),'.') == 'css'){
				set({
					contentType="text",
					contentSubType="css"
					});
			} else if(listLast(get('filename'),'.') == 'js'){
				set({
					contentType="application",
					contentSubType="javascript"
					});
			}	 else if(listFindNoCase('html,htm',listLast(get('filename'),'.'))){
				set({
					contentType="text",
					contentSubType="html"
					});
			}

			super.save();
		}
		return this;

	}

	function getURL(complete=false,secure=false,method="inline"){
		return this.getSite().getWebPath(argumentCollection=arguments) & "/index.cfm/render/?fileid=#get('fileid')#&siteid=#get('siteid')#&method=#arguments.method#";
	}

	function setRemotePubDate(remotePubDate){
		variables.instance.remotepubdate=parseDateArg(arguments.remotePubDate);
		return this;
	}

	function setExifPartial(exif){
		deserializeExif();

		if(isJSON(arguments.exif)){
			arguments.exif=deserializeJSON(arguments.exif);
		}

		structAppend(variables.instance.exif,arguments.exif);

		return this;
	}

	function serializeExif(){
		if(!isJSON(getValue('exif'))){
			if(isStruct(getValue('exif'))){
				setValue('exif',serializeJSON(getValue('exif')));
			} else {
				setValue('exif','{}');
			}
		}
		return getValue('exif');
	}

	function deserializeExif(){
		if(!isStruct(getValue('exif'))){
			if(len(getValue('exif'))){
				setValue('exif',deserializeJSON(getValue('exif')));
			} else {
				setValue('exif',{});
			}
		}
		return getValue('exif');
	}

	function getExifTag(tag){
		deserializeExif();
		if(structKeyExists(variables.instance.exif,arguments.tag)){
			return variables.instance.exif['#arguments.tag#'];
		} else {
			return '';
		}
	}

	function getExifAsJSON(){
		return serializeExif();
	}

	function getExifAsStruct(){
		return deserializeExif();
	}

	function setExifTag(tag,value){
		deserializeExif();
		variables.instance.exif['#arguments.tag#']=arguments.value;
		return this;
	}

	function checkFileAccess(fileid,Mura){
		if(arguments.Mura.siteConfig('extranet')){
			var rs=queryExecute("
					select tcontent.contentid,tcontent.siteid,tcontent.path from tcontent
					where 
					tcontent.siteid= :siteid
					and tcontent.active=1
					and (
						tcontent.fileid= :fileid
						or tcontent.contenthistid in (
							select baseid from tclassextenddata
							inner join tclassextendattributes on tclassextendattributes.attributeid=tclassextenddata.attributeid
							where tclassextendattributes.type='file'
							and tclassextendattributes.siteid = :siteid
							and tclassextenddata.stringvalue= :fileid
						)
					)
				",
				{
					fileid:arguments.fileid,
					siteid:arguments.Mura.event('siteid')
				}
			);

			var assigments=getBean('contentIterator')
			
			assigments.setQuery(rs);

			if(assigments.hasNext()){
				while(assigments.hasNext()){
					if(assigments.next().getPermissions().read){
						return true;
					}
				}
			}
			
			return false;
		} else {
			return true;
		}
	}

	function allowRead(Mura){
		if(getBean('permUtility').getModulePerm('00000000000000000000000000000000000',arguments.Mura.event('siteid'))){
			return true;
		} else {
			return checkFileAccess(fileid=get('fileid'), Mura=arguments.Mura);
		}
	}

	function allowAccess(Mura){
		return true;
	}

	function allowQueryParams(params,Mura){
		if(getBean('permUtility').getModulePerm('00000000000000000000000000000000000',arguments.Mura.event('siteid'))){
			return true;
		} else if(structKeyExists(arguments.params,'fileid') && isValid('uuid',arguments.params.fileid)){
			return checkFileAccess(fileid=arguments.params.fileid, Mura=arguments.Mura);
		} else if(structKeyExists(arguments.params,'id') && isValid('uuid',arguments.params.id)){
			return checkFileAccess(fileid=arguments.params.id, Mura=arguments.Mura);
		} else {
			return false;
		}
	}

}
