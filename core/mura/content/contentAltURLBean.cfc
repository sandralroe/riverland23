component extends="mura.bean.beanORMVersioned" table="tcontentalturl" entityname="alturl" versioned="true" bundleable="true" displayname="alturl" {

	// primary key
		property name="alturlid" fieldtype="id";
		property name="ismuracontent" datatype="tinyint" default="0";
		property name="statuscode" datatype="string" deafult="302";
		property name="alturl" fieldtype="index" datatype="varchar" length="255";
		property name="datecreated" datatype="datetime";
		property name="lastmodifiedby" fieldtype="many-to-one" relatesto="user" fkcolumn="lastUpdateById" ;


		function validate(){

			super.validate();

			if(!get('ismuracontent')){
				var redirectCheck = getBean('alturl').loadBy(alturl=get('alturl'),siteid=get('siteid'));
				var contentCheck = getBean('content').loadBy(filename=get('alturl'),siteid=get('siteid'));
			}
			

			// if it doesnt exist or it's a redirect from a mura node to a mura node add it
			if(!get('ismuracontent')
				&& (
					(
						redirectCheck.exists() 
						&& redirectCheck.get('contentid') != get('contentid')
						&& redirectCheck.getContent().getActive()
					)	
					|| contentCheck.exists()
				)
			) {

				// else set the custom error to display
				var errors=getErrors();
				
				if(redirectCheck.exists() && redirectCheck.get('contentid') != get('contentid')){
					var redirectContentCheck=redirectCheck.getContent();
					if(!redirectContentCheck.exists()){
						redirectCheck.delete();
					} else {
						contentCheck=redirectContentCheck;
					}
				}

				if(contentCheck.exists()){
					errors["alturl_#get('alturlid')#"]='#esapiEncode("html",getBean('settingsManager').getSite(variables.instance.siteID).getRBFactory().getKey("sitemanager.alturlinuseon"))#
 &quot;#get("alturl")#&quot; #esapiEncode("html",getBean('settingsManager').getSite(variables.instance.siteID).getRBFactory().getKey("sitemanager.alturlinuseoncontd"))# <strong><!---<a href="#contentCheck.getEditURL()#">--->#esapiEncode("html",contentCheck.getMenutitle())#<!---</a>---></strong>.<br>#esapiEncode("html",getBean('settingsManager').getSite(variables.instance.siteID).getRBFactory().getKey("sitemanager.alturlremovedup"))#';
				}
			}

			return this;

		}

		remote function validateAltUrl(siteid) {

			var Mura=getBean('Mura').init(arguments.siteid);

			var content=Mura.getBean('content').loadBy(contentid=Mura.event('contentid'));

			var URLValuesJSON = deserializeJSON ( Mura.event( 'inputValues' ) );
			var contentId = Mura.event( 'contentId' );
			var isMuraContent = Mura.event('isMuraContent');

			var theAltURL = Mura.getBean('alturl');

			for( object in URLValuesJSON  ) {

				var altURLId    = listLast(#object.name#,'_');
				var altURLValue = object.value;

				theAltURL.set({
					alturlid=altURLId,
					alturl=altURLValue,
					ismuracontent=isMuraContent,
					contentid=contentId,
					statuscode=object.statusCode,
					datecreated=createODBCDateTime(now()),
					lastUpdateById=Mura.currentUser('userid')
				});

				content.addObject(theAltURL);

				theAltURL.validate();

				//return { result: theAltUrl.hasErrors() };

				if(theAltURL.hasErrors()) {
					return { result: { errors: theAltURL.getErrors(), hasErrors: theAltURL.hasErrors()  } };
					//return {result: theAltUrl.hasErrors() };
				}
			}
			return { result: { errors: theAltURL.getErrors(), hasErrors: false  } };
		}

		function persistToVersion(previousBean,newBean,$){
			if(
				arguments.newBean.getContentID() != arguments.$.event('alturluiid')
				&& arguments.previousBean.getContentID() == arguments.newBean.getContentID()
			){
				return true;
			} else {
				return false;
			}
		}

}
