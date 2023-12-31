 <!--- license goes here --->
<cfsavecontent variable="rc.ajax">
<cfoutput>
<script src="dist/bundle.js?coreversion=#application.coreversion#" type="text/javascript" ></script>
</cfoutput>
</cfsavecontent>
<cfoutput>
<div class="mura-header">
	<h1>Trash Detail</h1>
	<div class="nav-module-specific btn-group">
	<a class="btn" href="./?muraAction=cTrash.list&siteID=#esapiEncode('url',rc.trashItem.getSiteID())#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#esapiEncode('url',rc.pageNum)#&sinceDate=#esapiEncode('url',$.event('sinceDate'))#&beforeDate=#esapiEncode('url',$.event('beforeDate'))#"><i class="mi-arrow-circle-left"></i>  Back to Trash Bin</a>
	</div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
			<ul class="metadata">
			<li><strong>Label:</strong> #esapiEncode('html',rc.trashItem.getObjectLabel())#</li>
			<li><strong>Type:</strong> #esapiEncode('html',rc.trashItem.getObjectType())#</li>
			<li><strong>SubType:</strong> #esapiEncode('html',rc.trashItem.getObjectSubType())#</li>
			<li><strong>ObjectID:</strong> #esapiEncode('html',rc.trashItem.getObjectID())#</li>
			<li><strong>SiteID:</strong> #esapiEncode('html',rc.trashItem.getSiteID())#</li>
			<li><strong>ParentID:</strong> #esapiEncode('html',rc.trashItem.getParentID())#</li>
			<li><strong>Object Class:</strong> #esapiEncode('html',rc.trashItem.getObjectClass())#</li>
			<li><strong>DeleteID:</strong> #esapiEncode('html',rc.trashItem.getDeleteID())#</li>
			<li><strong>Deleted Date:</strong> #LSDateFormat(rc.trashItem.getDeletedDate(),session.dateKeyFormat)# #LSTimeFormat(rc.trashItem.getDeletedDate(),"short")#</li>
			<li><strong>Deleted By:</strong> #esapiEncode('html',rc.trashItem.getDeletedBy())#</li>
			</ul>

			<cfif not listFindNoCase("Page,Folder,File,Link,Gallery,Calender,Form,Component,Variation",rc.trashItem.getObjectType())>
				</div> <!-- /.block-content -->
				<div class="mura-actions">
				<div class="clearfix form-actions">
					<button class="btn mura-primary" onclick="return confirmDialog('Restore Item From Trash?','?muraAction=cTrash.restore&objectID=#rc.trashItem.getObjectID()#&siteid=#rc.trashItem.getSiteID()#');"><i class="mi-cogs"></i>Restore Item</button>
					<cfif len(rc.trashItem.getDeleteID())>
					<button class="btn" onclick="return confirmDialog('Restore All Items in Delete Transaction from Trash?','?muraAction=cTrash.restore&objectID=#rc.trashItem.getObjectID()#&deleteID=#rc.trashItem.getDeleteID()#&siteid=#rc.trashItem.getSiteID()#');"><i class="mi-cogs"></i>Restore All Items in Delete Transaction</button>
					</cfif>
				</div>
			</div>
		<cfelse>
		<cfset parentBean=application.serviceFactory.getBean("content").loadBy(contentID=rc.trashItem.getParentID(),siteID=rc.trashItem.getSiteID())>

		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentparent')#:
				<span id="mover1" class="text">
					<cfif parentBean.getIsNew()>NA<cfelse>#esapiEncode('html',parentBean.getMenuTitle())#</cfif>
					<button id="selectParent" name="selectParent" class="btn">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectnewparent')#
					</button>
				</span>
			<span id="mover2" style="display:none">
				<input type="hidden" id="parentid" name="parentid" value="#esapiEncode('html_attr',rc.trashItem.getParentID())#">
			</span>
			</label>
		</div>
		</div> <!-- /.block-content -->
		<div class="mura-actions">
			<div class="clearfix form-actions">
			<cfif len(rc.trashItem.getDeleteID())>
			<button class="btn" onclick="restoreAll();"><i class="mi-cogs"></i>Restore All Items in Delete Transaction</button>
			</cfif>
			<button class="btn mura-primary" onclick="restoreItem();"><i class="mi-cogs"></i>Restore Item</button>
			</div>
		</div>

		<script>
		function restoreItem(){
			var parentid="";

			if(typeof(jQuery('##parentid').val()) != 'undefined' ){
				parentid=jQuery('##parentid').val();
			}else{
				parentid=jQuery('input:radio[name=parentid]:checked').val();
			}

			if(parentid.length==35){
				confirmDialog('Restore Item From Trash?',"?muraAction=cTrash.restore&siteID=#rc.trashItem.getSiteID()#&objectID=#rc.trashItem.getObjectID()#&parentid=" + parentid);
			}else{
				alertDialog('Please select a valid content parent.');
			}
		}

		function restoreAll(){
			var parentid="";

			if(typeof(jQuery('##parentid').val()) != 'undefined' ){
				parentid=jQuery('##parentid').val();
			}else{
				parentid=jQuery('input:radio[name=parentid]:checked').val();
			}

			if(parentid.length==35){
				confirmDialog('Restore Item From Trash?',"?muraAction=cTrash.restore&siteID=#rc.trashItem.getSiteID()#&objectID=#rc.trashItem.getObjectID()#&deleteID=#rc.trashItem.getDeleteID()#&parentid=" + parentid);
			}else{
				alertDialog('Please select a valid content parent.');
			}
		}

		jQuery(document).ready(function(){
			$('##selectParent').click(function(e){
				e.preventDefault();
				siteManager.loadSiteParents(
					'#esapiEncode('javascript',rc.trashItem.getSiteID())#'
					,'#esapiEncode('javascript',rc.trashItem.getParentID())#'
					,'#esapiEncode('javascript',rc.trashItem.getParentID())#'
					,''
					,1
				);
				return false;
			});
		});

		</script>
			</cfif>

	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
