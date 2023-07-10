 <!--- License goes here --->
<cfset rsAddress=rc.userBean.getAddressById(rc.addressID)>
<cfset addressBean=rc.userBean.getAddressBeanById(rc.addressID)>
<cfset extendSets=application.classExtensionManager.getSubTypeByName("Address",rc.userBean.getsubtype(),rc.userBean.getSiteID()).getExtendSets(inherit=true,activeOnly=true) />
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000008',rc.siteid))>
<cfoutput>
<form novalidate="novalidate" action="./?muraAction=cUsers.updateAddress&amp;userid=#esapiEncode('url',rc.userid)#&amp;routeid=#rc.routeid#&amp;siteid=#esapiEncode('url',rc.siteid)#" method="post" enctype="multipart/form-data" name="form1" onsubmit="return userManager.submitForm(this);"  autocomplete="off" >

<div class="mura-header">
	<h1>#rbKey('user.memberaddressform')#</h1>
	<div class="nav-module-specific btn-group">
	<a class="btn" href="##" title="#esapiEncode('html',rbKey('sitemanager.back'))#" onclick="window.history.back(); return false;"><i class="mi-arrow-circle-left"></i> #esapiEncode('html',rbKey('sitemanager.back'))#</a>
	</div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">
				
				<h2>#esapiEncode('html',rc.userBean.getFname())# #esapiEncode('html',rc.userBean.getlname())#</h2>
					<div class="mura-control-group">
			      <label>#rbKey('user.addressname')#</label>
		      	<input id="addressName" name="addressName" type="text" value="#esapiEncode('html',rsAddress.addressName)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.address1')#</label>
		      	<input id="address1" name="address1" type="text" value="#esapiEncode('html',rsAddress.address1)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.address2')#</label>
		      	<input id="address2" name="address2" type="text" value="#esapiEncode('html',rsAddress.address2)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.city')#</label>
		      	<input id="city" name="city" type="text" value="#esapiEncode('html',rsAddress.city)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.state')#</label>
		      	<input id="state" name="state" type="text" value="#esapiEncode('html',rsAddress.state)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.zip')#</label>
		      	<input id="zip" name="zip" type="text" value="#esapiEncode('html',rsAddress.zip)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.country')#</label>
		      	<input id="country" name="country" type="text" value="#esapiEncode('html',rsAddress.country)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.phone')#</label>
		      	<input id="phone" name="phone" type="text" value="#esapiEncode('html',rsAddress.phone)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.fax')#</label>
		      	<input id="fax" name="fax" type="text" value="#esapiEncode('html',rsAddress.fax)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.website')# (#rbKey('user.includehttp')#)</label>
		      	<input id="addressURL" name="addressURL" type="text" value="#esapiEncode('html',rsAddress.addressURL)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.email')#</label>
		      	<input id="addressEmail" name="addressEmail" validate="email" message="#rbKey('user.emailvalidate')#" type="text" value="#esapiEncode('html',rsAddress.addressEmail)#">
			    </div>
					
					<div class="mura-control-group">
			      <label>#rbKey('user.hours')#</label>
		      	<textarea id="hours" rows="6" name="hours" >#esapiEncode('html',rsAddress.hours)#</textarea>
			    </div>

			<!--- extended attributes as defined in the class extension manager --->
			<cfif arrayLen(extendSets)>

			<cfloop from="1" to="#arrayLen(extendSets)#" index="s">	
			<cfset extendSetBean=extendSets[s]/>
			<cfoutput><cfset style=extendSetBean.getStyle()/><cfif not len(style)><cfset started=true/></cfif>
				<span class="extendset" extendsetid="#extendSetBean.getExtendSetID()#" categoryid="#extendSetBean.getCategoryID()#" #style#>
				<input name="extendSetID" type="hidden" value="#extendSetBean.getExtendSetID()#"/>
					<h2>#extendSetBean.getName()#</h2>
				<cfsilent>
				<cfset attributesArray=extendSetBean.getAttributes() />
				</cfsilent>
				<cfloop from="1" to="#arrayLen(attributesArray)#" index="a">	
					<cfset attributeBean=attributesArray[a]/>
					<cfset attributeValue=addressBean.getExtendedAttribute(attributeBean.getAttributeID(),true) />
					<div class="mura-control-group">
			      <label>
					<cfif len(attributeBean.getHint())>
					<span data-toggle="popover" title="" data-placement="right" data-content="#esapiEncode('html',attributeBean.gethint())#" data-original-title="#attributeBean.getLabel()# <cfif attributeBean.getType() IS "Hidden"><strong>[Hidden]</strong></cfif>">#attributeBean.getLabel()# <cfif attributeBean.getType() IS "Hidden"><strong>[Hidden]</strong></cfif> <i class="mi-question-circle"></i></span>
					<cfelse>
					#attributeBean.getLabel()# <cfif attributeBean.getType() IS "Hidden"><strong>[Hidden]</strong></cfif>
					</cfif>
					<cfif attributeBean.getType() eq "File" and len(attributeValue) and attributeValue neq 'useMuraDefault'> <a href="#application.configBean.getContext()##application.configBean.getIndexPath()#/_api/render/file/?fileID=#attributeValue#" target="_blank">[Download]</a> <input type="checkbox" value="true" name="extDelete#attributeBean.getAttributeID()#"/> Delete</cfif>
					</label>
					<!--- if it's an hidden type attribute then flip it to be a textbox so it can be editable through the admin --->
					<cfif attributeBean.getType() IS "Hidden">
						<cfset attributeBean.setType( "TextBox" ) />
					</cfif>	
						#attributeBean.renderAttribute(attributeValue)#
					</div>
				</cfloop>
			</cfoutput>
			</cfloop>

			<cfhtmlhead text='<link rel="stylesheet" href="css/tab-view.css" type="text/css" media="screen">'>
			<cfhtmlhead text='<script type="text/javascript" src="assets/js/tab-view.js"></script>'>
			<script type="text/javascript">
			initTabs(Array("#jsStringFormat(rbKey('user.basic'))#","#jsStringFormat(rbKey('user.extendedattributes'))#"),0,0,0);
			</script>	
			</cfif>
			<cfif isEditor>
				<div class="mura-actions">
					<div class="form-actions">
						<cfif rc.addressid eq ''>
							<button class="btn mura-primary" onclick="userManager.submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#rbKey('user.add')#</button>
				        <cfelse>
				            <button class="btn mura-primary" onclick="userManager.submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#rbKey('user.update')#</button>
							<button class="btn" onclick="submitForm(document.forms.form1,'delete','#jsStringFormat(rbKey('user.deleteaddressconfirm'))#');"><i class="mi-trash"></i>#rbKey('user.delete')#</button>
				           </cfif>
			    	</div>
		    	</div>

				<input type="hidden" name="action" value="">
				<input type="hidden" name="addressID" value="#esapiEncode('html_attr',rc.addressID)#">
				<input type="hidden" name="isPublic" value="#rc.userBean.getIsPublic()#">
				<cfif not rc.userBean.getAddresses().recordcount><input type="hidden" name="isPrimary" value="1"></cfif>
			</cfif>	
			</cfoutput>


			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->
</form>
