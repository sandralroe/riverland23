/* license goes here */
component extends="mura.bean.bean" entityname="dataCollection" hint="This provides data collection functionality"{

	property name='formID' required=true dataType='string';
	property name='siteID' required=true dataType='string';

	variables.formpropertylist='';
	variables.formproperties={};

	function set(property,propertyValue){

		if(!isDefined('arguments.data')){
	    	if(isSimpleValue(arguments.property)){
	    		return setValue(argumentCollection=arguments);
	    	}

	    	arguments.data=arguments.property;
    	}

		if(isQuery(arguments.data)){
			arguments.data=getBean('utility').queryRowToStruct(arguments.data);
		}

		if(structKeyExists(arguments.data,'data') && isWDDX(arguments.data.data)){
			var formdata=variables.dataCollectionManager._deserializeWDDX(arguments.data.data);
			structDelete(arguments.data, data);
			structAppend(arguments.data,formdata,true);
		}

		if(structKeyExists(arguments.data,"fieldnameOrder")){
			arguments.data.fieldnames='';

			for(local.i in listToArray(arguments.data.fieldnameOrder)){
				if(structKeyExists(form, local.i)){
					arguments.data.fieldnames = listAppend(arguments.data.fieldnames, local.i);
				}
			}

			structDelete(form, "fieldnameOrder");
			structDelete(aguments.data, "fieldnameOrder");

		} else if (application.configBean.getCompiler() neq "Adobe"){
			arguments.data.fieldnames='';
			local.aRawForm = form.getRaw();

    		for(local.i in local.aRawForm){
    			arguments.data.fieldnames=listAppend(arguments.data.fieldnames, local.i.getName());
    		}

		} else if(!structKeyExists(arguments.data,'fieldnames')) {
			arguments.data.fieldnames='';
			for(local.i in arguments.data) {
				arguments.data.fieldnames=listAppend(arguments.data.fieldnames,local.i);
			}
		}

		var prop='';

		for(prop in arguments.data){
			if (IsSimpleValue(prop) && !isNull(arguments.data['#prop#']) && Len(prop) && !(prop==getPrimaryKey() && !len(arguments.data['#prop#'])) ) {
				setValue(prop,arguments.data['#prop#']);
			}
		}

		return this;
	}

	function getValidations( content = '',prefix='' ) {

		if( isSimpleValue(arguments.content) ) {
			try{
				arguments.content=getFormBean();
			} catch(Any e){
				return false;
			}
		}

		var validations={properties={}};
		var i=1;
		var prop={};
		var rules=[];
		var message='';
		var fields='';
		var nestedform = '';
		var fieldorder = ArrayNew(1);
		var propname='';

		if(isJSON(arguments.content.getBody())){
			var formDef=deserializeJSON(content.getBody());

			if(structKeyExists(formDef.form,'pages') && isArray( formDef.form.pages )) {
				for(var i = 1; i <= ArrayLen(formDef.form.pages);i++) {
					fieldorder.addAll( formDef.form.pages[i] );
				}
			}
			else if(structKeyExists(formDef.form,'fieldOrder') && isArray(formDef.form.fieldOrder)) {
				fieldorder = formDef.form.fieldOrder;
			}

			for(i=1;i lte arrayLen(fieldorder);i=i+1){
				if(isSimpleValue(fieldorder[i])){
					prop=formDef.form.fields[fieldorder[i]];
					rules=[];

					if( prop.fieldtype.fieldtype eq 'nested' ) {
						nestedform = getBean('content').loadBy( contentID=prop.formid,siteid=getValue('siteID') );
						structAppend(validations.properties, getValidations( nestedform,prop.name & "_" ).properties );
					} else {
						if(structkeyExists(prop,'validateMessage') && len(prop.validateMessage)){
							message=prop.validateMessage;
						} else {
							message='';
						}

						if(structkeyExists(prop,'validateRegex') && len(prop.validateRegex)){
							arrayAppend(rules,{'regex'=prop.validateRegex,message=message});
						}

						if(structkeyExists(prop,'isrequired') &&  prop.isrequired){
							arrayAppend(rules,{required=true,message=message});
						}

						if(structkeyExists(prop,'validateType') && len(prop.validateType)){
							arrayAppend(rules,{dataType=prop.validateType,message=message});
						}

						if(prop.fieldtype.fieldtype == 'file'){
							propname=arguments.prefix & prop.name & "_attachment";
						} else {
							propname=arguments.prefix & prop.name;
						}

						if(arrayLen(rules)){
							validations.properties[propname]=rules;
						}

						variables.formproperties[propname]=prop;
						variables.formpropertylist=listAppend(variables.formpropertylist,propname);
					}
				}
			}
		}

		return validations;
	}

	function getFormProperties() {
		if(!isJSON(getFormBean().getBody())){
			return {};
		} else if (!isdefined('variables.formproperties')){
			validate();
		}

		return variables.formproperties;
	}

	function getFormBean(){
		param name='variables.instance.formBean' default='#getBean('content').loadBy(contentID=getValue('formID'),siteID=getValue('siteID'))#';
		return variables.instance.formBean;
	}

	function setContentID(contentID){
		variables.instance.formid=arguments.contentID;
	}

	function setObjectID(objectID){
		variables.instance.formid=arguments.objectID;
	}

	function setDataCollectionManager(dataCollectionManager){
		variables.dataCollectionManager=arguments.dataCollectionManager;
	}

	function loadBy(responseID,formID,siteID){
		set(variables.dataCollectionManager.read(responseID));
		return this;
	}

	function delete(){
		variables.dataCollectionManager.delete(getValue('responseID'));
		return this;
	}

	function save(){
		//need to make sure responseID,siteid and formID are in data
		super.validate();

		if(structIsEmpty(getErrors())){
			setValue('formResult',variables.dataCollectionManager.update(structCopy(getAllValues())));
		}

		return this;
	}

	function validate($,fields=''){

		if(!isDefined('arguments.$')){
			arguments.$=getValue('MuraScope');
			if(!isObject(arguments.$)){
				arguments.$=getBean('$').init(getValue('siteid'));
			}
		}

		super.validate(fields=arguments.fields);

		setValue('acceptData','1');

		var hasRestrictedFiles = getBean('fileManager').requestHasRestrictedFiles(scope=getAllValues(),allowedExtensions=getBean('configBean').getFMPublicAllowedExtensions());
		if (len(hasRestrictedFiles) gt 1 and findNoCase('|',hasRestrictedFiles)){
			var restrictedFilesArray=listToArray(hasRestrictedFiles, '|');
			hasRestrictedFiles=restrictedFilesArray[1];
			var fileSize=restrictedFilesArray[2];
		}
		if( hasRestrictedFiles eq '1' ){
			getErrors().requestHasRestrictedFiles=$.siteConfig().getRBFactory().getKey('sitemanager.requestHasRestrictedFiles');
		} else if (hasRestrictedFiles eq '2'){
			getErrors().requestHasRestrictedFiles=$.getBean('resourceBundle').messageFormat($.siteConfig().getRBFactory().getKey('sitemanager.requesthasinvalidsize'),fileSize);
		}

		if(!len(arguments.fields)){

			setValue('acceptData',structIsEmpty(getErrors()));

			var requestMin=getBean('configBean').getValue(property='validSessionRequestCount',defaultValue=2);

			if( requestMin
			 	&& isDefined('variables.sessionData.mura.requestcount')
				&& !(variables.sessionData.mura.requestcount >= requestMin) ){
				setValue('acceptError','Spam');
				setValue('acceptData','0');
				variables.instance.errors.Spam=getBean('settingsManager').getSite(getValue('siteid')).getRBFactory().getKey("captcha.spam");
			}


			if(getFormBean().getResponseChart()){

				 if(not isdefined('cookie.poll')){
					cookie.poll=getValue('formID');
				} else if( isdefined('cookie.poll') and listfind(cookie.poll,getValue('formID')) ){
					setValue('acceptError','Duplicate');
					variables.instance.errors.duplicate=getBean('settingsManager').getSite(getValue('siteid')).getRBFactory().getKey("poll.onlyonevote");
					setValue('acceptData','0');
				} else if( isdefined('cookie.poll') and not listfind(cookie.poll,getValue('formID')) ){
					var templist=cookie.poll;
					if( listlen(templist) eq 6){
						templist=listdeleteat(templist,1);
					}
					templist=listappend(templist,getValue('formID'));
					cookie.poll="#templist#";
				}
			}

			if(!(!len(getValue('hKey')) or getValue('hKey') eq hash(getValue('uKey'))) ){
				setValue('acceptError','Captcha');
				setValue('acceptData','0');
				variables.instance.errors.SecurityCode=getBean('settingsManager').getSite(getValue('siteid')).getRBFactory().getKey("captcha.error");
			}

			var useReCAPTCHA = Len($.siteConfig('reCAPTCHASiteKey')) && Len($.siteConfig('reCAPTCHASecret'));

			if ( useReCAPTCHA && !getBean('utility').reCAPTCHA(arguments.$.event()) ) {
				setValue('acceptError', 'reCAPTCHA');
				setValue('acceptData', '0');
				variables.instance.errors.reCAPTCHA = arguments.$.rbKey('recaptcha.error');
			} else if ( !useReCAPTCHA && !getBean('utility').cfformprotect(arguments.$.event()) ){
				setValue('acceptError', 'Spam');
				setValue('acceptData', '0');
				variables.instance.errors.Spam = arguments.$.rbKey('captcha.spam');
			}
		}

		if(len(variables.formpropertylist)){
			var fieldnames='';
			var dynamicFormFieldRegex=getBean('configBean').getValue("dynamicFormFieldRegex");

			for(var f in listToArray(getValue('fieldnames'))){
				if(listFindNoCase(variables.formpropertylist,f) || listFindNoCase('siteid,formid',f) ){
					fieldnames=listAppend(fieldnames,f);
				} else if (len(dynamicFormFieldRegex) && reFindNoCase(dynamicFormFieldRegex,f) ) {
					fieldnames=listAppend(fieldnames,f);
				} else if (right(f,10) == 'attachment'){
					local.prop=left(f,len(f)-11);

					if(listFindNoCase(variables.formpropertylist,local.prop)
						&& isDefined('variables.formproperties.#local.prop#.fieldtype.fieldtype')
						&& variables.formproperties['#local.prop#'].fieldtype.fieldtype == 'file'
					){
						fieldnames=listAppend(fieldnames,f);
					}
				}
			}

			setValue('fieldnames',fieldnames);
		}

		if(arguments.$.getContentRenderer().validateCSRFTokens && !arguments.$.validateCSRFTokens(context=getValue('formID'))){
			variables.instance.errors.csrf='Your request contained invalid tokens';
		}
	/*
	writeDUmp($.event('csrf_token'));
	writeDUmp($.event('csrf_token_expires'));
	writeDump(getValue('formID'));
	abort;
	*/
		if(hasErrors()){
			setValue('acceptData','0');
		} else {
			setValue('acceptData','1');
		}

		return this;
	}

	function submit($){

		if(!isDefined('arguments.$')){
			arguments.$=getValue('MuraScope');
			if(!isObject(arguments.$)){
				arguments.$=getBean('$').init(getValue('siteid'));
			}
		}
		
		validate(arguments.$);
		arguments.$.event('formDataBean',this);
		arguments.$.event('formBean',getFormBean());
		arguments.$.event('bean',getFormBean());
		arguments.$.event('acceptData',getValue('acceptData'));
		arguments.$.event('sendto','');
		arguments.$.announceEvent(eventName='onBeforeSubmitSave',objectid=getFormBean().getContentID());
		arguments.$.announceEvent(eventName='onBeforeFormSubmitSave',objectid=getFormBean().getContentID());
		arguments.$.announceEvent(eventName='onBeforeForm#getFormBean().getSubType()#SubmitSave',objectid=getFormBean().getContentID());

		if(structIsEmpty(getErrors())){
			var data=structCopy(getAllValues());
			var currentUser=getCurrentUser();
			if(currentUser.isLoggedIn()){
				var recordSender=getFormBean().getRecordSender();
				if(isBoolean(recordSender) && recordSender){
					data.sender_email=currentUser.get('email');
					data.sender_username=currentUser.get('username');
					data.sender_firstname=currentUser.get('fname');
					data.sender_lastname=currentUser.get('lname');
					data.sender_remoteid=currentUser.get('remoteid');
					data.fieldnames=data.fieldnames & ",sender_email,sender_username,sender_firstname,sender_lastname,sender_remoteid";
				}
			}
			setValue('formResult',variables.dataCollectionManager.update(data));
			//structAppend(variables.instance,getValue('formResult'));
			arguments.$.event('sendto','');
			arguments.$.announceEvent(eventName='onSubmitSave',objectid=getFormBean().getContentID());
			arguments.$.announceEvent(eventName='onAfterSubmitSave',objectid=getFormBean().getContentID());
			arguments.$.announceEvent(eventName='onAfterFormSubmitSave',objectid=getFormBean().getContentID());
			arguments.$.announceEvent(eventName='onAfterForm#getFormBean().getSubType()#SubmitSave',objectid=getFormBean().getContentID());

			sendNotification(arguments.$);
			sendReceipt(arguments.$);

		}

		request.cacheItem=false;

		return this;

	}

	function sendReceipt($){
		if(!isDefined('arguments.$')){
			arguments.$=getValue('MuraScope');
			if(!isObject(arguments.$)){
				arguments.$=getBean('$').init(getValue('siteid'));
			}
		}

		var subject=trim(getFormBean().getReceiptSubject());
		var text=trim(getFormBean().getReceiptText());
		var html=trim(getFormBean().getReceiptHTML());

		if(html=='<p></p>'){
			html='';
		}

		if( !$.currentUser().isLoggedIn() || !(len(subject) && (len(text) || len(html)))){
			return this;
		}
		
		var mailer=getBean('mailer');

		if(len(html)){
			mailer.sendHTML(
				 sendto = $.currentUser('email')
				, from = getValue('email')
				, subject = subject
				, siteid = getValue('siteid')
				, replyto = getValue('email')
				, bcc = ''
				, html = html
			);
		} else {
			mailer.sendText(
				 sendto = $.currentUser('email')
				, from = getValue('email')
				, subject = subject
				, siteid = getValue('siteid')
				, replyto = getValue('email')
				, bcc = ''
				, text = text
			);
		}
		
		return this;
	}

	function sendNotification($){

		if(!isDefined('arguments.$')){
			arguments.$=getValue('MuraScope');
			if(!isObject(arguments.$)){
				arguments.$=getBean('$').init(getValue('siteid'));
			}
		}

		var subject=trim(arguments.$.event('subject'));

		if(!len(subject)){
			subject=getFormBean().getTitle();
		}

		if(len(getFormBean().getNotificationSubject())){
			subject=getFormBean().getNotificationSubject();
		}

		var sendto=trim(arguments.$.event('sendto'));

		if(len(getFormBean().getResponseSendTo())){
			sendto=listAppend(sendto,getFormBean().getResponseSendTo());
		}

		if(!len(sendto)){
			return this;
		}
		
		var notificationHTML=getFormBean().getNotificationHTML();

		if(notificationHTML=='<p></p>'){
			notificationHTML='';
		}

		var bodyStruct = '';
		var mailer=getBean('mailer');

		if (isJSON(getFormBean().getBody())) {
			bodyStruct = deserializeJSON(getFormBean().getBody());
		}

		// If body is JSON, break response into an HTML table and send HTML email
		if (IsStruct(bodyStruct) && isDefined('bodyStruct.form.pages')) {
			var pagesArray = bodyStruct.form.pages;

			// I'm using an array here to keep the same order as the pagesArray,
			// as this matches the order of fields as they appear on the form.
			var parsedFormArray = [];

			for (var i = 1; i <= ArrayLen(pagesArray); i++) {
				var fieldsArray = pagesArray[i];
				for (var j = 1; j <= ArrayLen(fieldsArray); j++) {
					var fieldId = fieldsArray[j];
					var fieldObj = bodyStruct.form.fields[fieldId];
					ArrayAppend(parsedFormArray, fieldObj);
				}
			}

			// Update field values with those submitted in the form
			// Then build the HTML string with the key/value pairs.
			var formResult = getValue('formResult');
			var htmlString = '<h1 style="font-family: Helvetica; font-size: 18px">A response was submitted for the form "' & subject & '"</h1>';
			if(len(notificationHTML)){
				htmlString &= notificationHTML;
			}
			htmlString &= '<table style="font-family: Helvetica" width="500" cellspacing="10" >';
			for (var k = 1; k <= ArrayLen(parsedFormArray); k++) {
				var field = parsedFormArray[k];
				if (field.fieldtype.fieldtype != 'textblock') {
					if (field.fieldtype.fieldtype == 'section' ) {
						htmlString &= '<tr><td colspan="2" style="font-weight: bold">' & field.label & '</td></tr>';
					} else {
						if (StructKeyExists(formResult, field.name)) {
							field.value = esapiEncode('html', formResult[field.name]);
						} else if (StructKeyExists(formResult, field.name & '_attachment') && isValid('uuid',formResult['#field.name#_attachment'])) {
							var redirectid=createUUID();
							var userRedirect=getBean('userRedirect').set(
							{
								redirectid=redirectid,
								url="#arguments.$.siteConfig().getResourcePath(complete=1)##application.configBean.getIndexPath()#/_api/render/file/?fileID=#formResult['#field.name#_attachment']#&method=attachment",
								siteid=arguments.$.siteConfig('siteid'),
								created=now()
							}).save();

							if(arguments.$.siteConfig('isremote')){
								field.value &= '<a href="#arguments.$.siteConfig().getResourcePath(complete=1)##arguments.$.siteConfig().getContentRenderer().getURLStem(siteid=arguments.$.siteConfig('siteid'),filename=redirectid,hashURLS=false)#" target="_blank">Download</a>';
							} else {
								field.value &= '<a href="#arguments.$.siteConfig().getWebPath(complete=1)##arguments.$.siteConfig().getContentRenderer().getURLStem(arguments.$.siteConfig('siteid'),redirectid)#" target="_blank">Download</a>';			
							}	
						}

						htmlString &= '<tr><td style="vertical-align: top; min-width: 100px">' & field.label & '</td><td>' & field.value & '</td></tr>';
					}
				}
			}


			htmlString &= '</table>';

			mailer.sendHTML(
				args = getValue('formResult')
				, sendto = sendto
				, from = getValue('email')
				, subject = subject
				, siteid = getValue('siteid')
				, replyto = getValue('email')
				, bcc = ''
				, html = htmlString
			);

		} else if(mailer.isValidEmailFormat(getValue('email'))){
			mailer.send(
				args = getValue('formResult')
				, sendto = sendto
				, from = getValue('email')
				, subject = subject
				, siteid = getValue('siteid')
				, replyto = getValue('email')
				, bcc = ''
			);

		} else {
			mailer.send(
				args = getValue('formResult')
				, sendto = sendto
				, from = mailer.getFromEmail(getValue('siteid'))
				, subject = subject
				, siteid = getValue('siteid')
				, replyto = ''
				, bcc = ''
			);
		}

		return this;
	}

	function dspResponse($){
		return '';
	}

	function render($){
		var bean=getFormBean();
		var returnStr='';

		if(!isDefined('arguments.$')){
			arguments.$=getValue('MuraScope');
			if(!isObject(arguments.$)){
				arguments.$=getBean('$').init(getValue('siteid'));
			}
		}

		if(!$.getContentRenderer().useLayoutManager() && bean.getDisplayTitle() > 0){
			returnStr='<#arguments.$.getHeaderTag('subHead1')#>#HTMLEditFormat(bean.getTitle())#</#arguments.$.getHeaderTag('subHead1')#>';
		}

		param name="form.formid" default="";

		if(getHTTPRequestData().method == 'POST' && len(getValue('formid')) && getValue('formid') == bean.getContentID()){
			submit(arguments.$);

			var response=dspResponse();

			if(!len(response)){
				response=arguments.$.dspObject_Include(
							thefile='datacollection/dsp_response.cfm'
						);
			}

			returnStr=returnStr & response;
		} else {
			var renderedForm=arguments.$.renderEvent('onForm#bean.getSubType()#BodyRender');

			/*
			if(!len(renderedForm)){
				renderedForm=arguments.$.dspObject_include(theFile='extensions/dsp_Form_' & REReplace(bean.getSubType(), "[^a-zA-Z0-9_]", "", "ALL") & ".cfm",throwError=false);
			}
			*/
			if(len(renderedForm)){
				return renderedForm;
			}

			if(isJSON(bean.getBody())) {
				renderedForm=arguments.$.setDynamicContent(
					arguments.$.dspObject_Include(
						thefile='formbuilder/dsp_form.cfm',
						formid=bean.getContentID(),
						siteid=bean.getSiteID(),
						formJSON=bean.getBody()
					)
				);

			} else {
				renderedForm=bean.getBody();
				if(!find("dsp_form_protect.cfm",renderedForm) ){
					renderedForm=replaceNoCase(renderedForm,"</form>","[mura]$.dspObject_Include(thefile='form/dsp_form_protect.cfm')[/mura]</form>");
				}
				renderedForm=arguments.$.setDynamicContent(renderedForm);
			}

			renderedForm=variables.dataCollectionManager.renderForm(
				bean.getContentID(),
				bean.getSiteID(),
				renderedForm,
				bean.getResponseChart(),
				arguments.$.content('contentID'),
				arguments.$
			);

			returnStr=returnStr & renderedForm;

			if(find("htmlEditor",renderedForm)){
				arguments.$.addToHTMLHeadQueue("htmlEditor.cfm");
				returnStr=returnStr & '<script type="text/javascript">setHTMLEditors(200,500);</script>';
			}
		}

		if(bean.getIsOnDisplay() && bean.getForceSSL()){
			request.forceSSL = 1;
			request.cacheItem=false;
		} else if (!bean.getDoCache()) {
			request.cacheItem=bean.getDoCache();
		}
		return returnStr;
	}

}
