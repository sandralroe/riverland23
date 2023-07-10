<!--- license goes here --->
<cfsilent>
	<cfset request.layout=false>
	<cfparam name="rc.keywords" default="">
	<cfparam name="rc.isNew" default="1">
	<cfparam name="rc.categoryid" default="">
	<cfset rc.rsList=application.contentManager.getPrivateSearch(siteid=rc.siteid,keywords=rc.keywords,searchtype=rc.type,categoryid=rc.categoryid)>

	<cfset rc.rsLooseImages = []>
	<cfset rc.rsLooseFiles = []>

	<cfif rc.type eq 'file'>
		<cfif not len(rc.categoryid)>
			<cfset rc.rsLoose=$.getBean('filebrowser').browse(siteid=rc.siteid,directory='',filterResults=rc.keywords,filterDepth=1,resourcepath='User_Assets',completepath=true,itemsperpage=50)>
			<cfloop from="1" to="#arrayLen(rc.rsLoose.items)#" index="l">
				<cfif rc.rsLoose.items[l].isImage>
					<cfset ArrayAppend(rc.rsLooseImages,rc.rsLoose.items[l]) />
				<cfelse>
					<cfset ArrayAppend(rc.rsLooseFiles,rc.rsLoose.items[l]) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset rc.rsLooseImages = []>
			<cfset rc.rsLooseFiles = []>
		</cfif>
		
		<cfquery name="rsImages" dbtype="query">
			select * from rc.rslist
			where lower(fileExt) in ('png','jpg','jpeg','gif','webp','svg')
		</cfquery>
		<cfquery name="rsFiles" dbtype="query">
			select * from rc.rslist
			where lower(fileExt) not in ('png','jpg','jpeg','gif','webp','svg')
		</cfquery>
	<cfelse>
		<cfif not len(rc.categoryid)>
			<cfset rc.rsLoose=$.getBean('filebrowser').browse(siteid=rc.siteid,directory='',filterResults=rc.keywords,filterDepth=1,resourcepath='User_Assets',completepath=true,itemsperpage=50,imagesonly=1)>
			<cfset rc.rsLooseImages = rc.rsLoose.items>
		<cfelse>
			<cfset rc.rsLooseImages=[]>
		</cfif>
		<cfset rsImages=rc.rsList>
		<cfset rsFiles=queryNew('')>
	</cfif>
	<cfset filtered=structNew()>
</cfsilent>

<cfsavecontent variable="imagelist">
<ul class="mura-assoc-structured-images">
<cfset imagecounter=0>
 <cfoutput query="rsimages">
<cfif not structKeyExists(filtered,'#rsimages.fileid#')>
	<cfsilent>
		<cfset crumbdata=application.contentManager.getCrumbList(rsimages.contentid, rsimages.siteid)>
     	<cfset verdict=application.permUtility.getnodePerm(crumbdata)>
     	<cfset hasImage=listFindNoCase("png,gif,jpg,webp,jpeg,svg",rsimages.fileExt)>
	</cfsilent>
	<cfif verdict neq 'none'>
		<cfset filtered['#rsimages.fileid#']=true>
		<cfset imagecounter=imagecounter+1>
        <li<cfif hasImage> class="hasImage"</cfif>>
        <input type="radio" name="#esapiEncode('html_attr',rc.property)#" value="#rsimages.fileid#">
        <cfif hasImage>
      	  <img title="#esapiEncode('html_attr',rsimages.assocfilename)#" src="#$.getURLForImage(fileid=rsimages.fileid,size='small',siteid=rsimages.siteid,fileext=rsimages.fileExt,useProtocol=false)#?v=#createUUID()#"><br>
        <cfelse>
        	<i class="mi-file-text-o"></i><br>#rsimages.assocfilename#<br>
        </cfif>
      </li>
 	</cfif>
	</cfif>
</cfoutput>
<cfif arrayLen(rc.rsLooseImages)>
<cfset imagecounter = imagecounter +  arrayLen(rc.rsLooseImages) />
<cfoutput>
</ul>
<div class="assets-divider">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.unassociated'))# #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.images')#</div>
<ul class="mura-assoc-loose-images">
<cfloop from="1" to="#arrayLen(rc.rsLooseImages)#" index="loose">
<cfset looseimage=rc.rsLooseImages[loose]>
	<li class="hasImage">
	<img title="#esapiEncode('html_attr',looseimage.fullname)#" src="#looseimage.url#"><br>
	</li>
</cfloop>
</cfoutput>
</cfif>
</ul>
</cfsavecontent>

<!---

<cfsavecontent variable="looseimagelist">
<cfoutput>
<ul>
</ul>
</cfoutput>
</cfsavecontent>

<cfsavecontent variable="loosefilelist">
<cfoutput>
<ul>
</ul>
</cfoutput>
</cfsavecontent>
--->

<cfsavecontent variable="filelist">
<ul class="mura-assoc-structured-files">
<cfset filecounter=0>
   <cfoutput query="rsfiles">
	<cfif not structKeyExists(filtered,'#rsfiles.fileid#')>
		<cfsilent>
			<cfset crumbdata=application.contentManager.getCrumbList(rsfiles.contentid, rc.siteid)>
       		<cfset verdict=application.permUtility.getnodePerm(crumbdata)>
       		<cfset hasImage=listFindNoCase("png,gif,jpg,jpeg,webp,svg",rsfiles.fileExt)>
		</cfsilent>
		<cfif verdict neq 'none'>
			<cfset filtered['#rsfiles.fileid#']=true>
			<cfset filecounter=filecounter+1>
	        <li><input type="radio" name="#esapiEncode('html_attr',rc.property)#-sel" value="#rsfiles.fileid#">&nbsp;<span class="mura-assoc-file-option"><i class="mi-file-text-o"></i>&nbsp;#esapiEncode('html',rsfiles.assocfilename)#</span></li>
	 	</cfif>
 	</cfif>
 </cfoutput>
 <cfif arrayLen(rc.rsLooseFiles)>
 <cfset filecounter = filecounter + arrayLen(rc.rsLooseFiles) />
<cfoutput>
</ul>
<span>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.unassociated'))# #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.files')#</span>
<hr noshade>
<ul class="mura-assoc-loose-files">
<cfloop from="1" to="#arrayLen(rc.rsLooseFiles)#" index="loose">
<cfset loosefile=rc.rsLooseFiles[loose]>
    <li><input type="radio" name="#esapiEncode('html_attr',rc.property)#-sel" value="#loosefile.url#">&nbsp;<span class="mura-assoc-file-option"><i class="mi-file-text-o"></i>&nbsp;#esapiEncode('html',loosefile.fullname)#</span></li>
</cfloop>
</cfoutput>
</cfif>
</ul>
</cfsavecontent>

<cfset totalcounter = filecounter + imagecounter>
<cfoutput>
<div class="mura-control-group">
	<div class="mura-input-set assocFilterControls">
		<input class="filesearch" value="#esapiEncode('html_attr',rc.keywords)#" type="text" maxlength="50" placeholder="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.searchforexistingfiles'))#">
			<!--- categories --->
			<cf_dsp_categories_filter>
			<!--- /categories --->
		<button type="button" class="btn assocFilterSubmit"><i class="mi-search"></i></button>
	</div>
</div>
<!--- if search is submitted --->
<cfif len(rc.keywords) or len(rc.categoryid)>

	<div class="selectAssocImageResults block" id="selectAssocImageResults-#esapiEncode('html',rc.property)#">
	<!--- if no results --->
	<cfif totalcounter eq 0>
		<div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'sitemanager.noresults')#</div>
	<!--- if results are found --->
	<cfelse>
		<p><strong>#totalcounter# #application.rbFactory.getKeyValue(session.rb,'sitemanager.result')#<cfif totalcounter gt 1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.result.s')#</cfif></strong></p>
		<!--- file search results --->
			<div class="mura-panel-group assocfile-panels" role="tablist" aria-multiselectable="true">
				<cfif imagecounter gt 0>
					<div  class="mura-panel mura-assoc-images">			
						<div class="mura-panel-heading" role="tab" id="heading-images-#esapiEncode('html',rc.property)#">
							<h4 class="mura-panel-title">
								<a onclick="toggleAssocPanel(this);" href="##mura-assoc-images-#esapiEncode('html',rc.property)#" class="collapse<cfif filecounter gt 0> collapsed</cfif>"><i class="mi-picture-o"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.images')# (#imagecounter#)</a>						
							</h4>
						</div>
					<div id="mura-assoc-images-#esapiEncode('html',rc.property)#" class="panel-collapse<cfif filecounter gt 0> collapse</cfif>">	
						<div class="mura-panel-body">
						#imagelist#
					</div> <!---/.mura-panel-body --->
				</div> <!--- /.panel-collapse --->
			</div> <!--- /.mura-panel --->
		</cfif>
		<cfif rc.type eq 'file' and filecounter gt 0>
			<div class="mura-panel mura-assoc-files">
				<div class="mura-panel-heading" role="tab" id="heading-#esapiEncode('html',rc.property)#">
					<h4 class="mura-panel-title">
						<a onclick="toggleAssocPanel(this);" href="##mura-assoc-files-#esapiEncode('html',rc.property)#" class="collapse<cfif imagecounter gt 0> collapsed</cfif>"><i class="mi-file-text-o"></i> <cfif imagecounter gt 0>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.otherfiles')#<cfelse>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.files')#</cfif> (#filecounter#)</a>						
					</h4>
				</div>
				<div id="mura-assoc-files-#esapiEncode('html',rc.property)#" class="panel-collapse<cfif imagecounter gt 0> collapse</cfif>">
					<div class="mura-panel-body">
						#filelist#
					</div> <!---/.mura-panel-body --->
				</div> <!--- /.panel-collapse --->
			</div> <!--- /.mura-panel --->
		</cfif>

	</div> <!--- /.panel-group --->
	<input type="hidden" <cfif rc.property eq 'fileid'>name="newfile"<cfelse>name="#esapiEncode('html_attr',rc.property)#"</cfif> id="selected-newfile" class="mura-file-selector-newfile">

	<!--- js for search results --->
	<script type="text/javascript">
		var toggleAssocPanel = function(el){
			var tab = $(el);
			var panel = tab.parents('.mura-panel').find('div.panel-collapse');
			if (tab.hasClass('collapsed')){
				tab.removeClass('collapsed');
				panel.removeClass('collapse');
			} else {
				tab.addClass('collapsed');
				panel.addClass('collapse');
			}
		}

		Mura(document).on('click','ul.mura-assoc-loose-images li img', function(){
			assocParent = $(this).parents('.mura-file-selector');
			assocSrc = $(this).attr('src');
			assocTitle = $(this).attr('title');
			assocPreview = $(this).parents('.mura-associmg-ph > img');
			assocSidebarPreview = $('img##assocImagePreview');
			$('##mura-assoc-images-fileid ul li.active').removeClass('active');
			$(this).parents('.mura-assoc-marker-icon').show();
			$(assocPreview).show().attr('src',assocSrc);
			$(assocSidebarPreview).show().attr('src',assocSrc);
			$(this).find('.mura-assoc-marker-label').text(assocTitle);
			$(assocParent).find('.assocFileTools').hide();
			$("##selected-newfile").val(assocSrc);
		})
		$(document).on('click','ul.mura-assoc-structured-images li img', function(){
			assocParent = $(this).parents('.mura-file-selector');
			assocSrc = $(this).attr('src');
			assocTitle = $(this).attr('title');
			assocPreview = $(this).parents('.mura-associmg-ph > img');
			assocSidebarPreview = $('img##assocImagePreview');
			$('##mura-assoc-images-fileid ul li.active').removeClass('active');
			$(this).find('.mura-assoc-marker-icon').show();
			$(assocPreview).show().attr('src',assocSrc);
			$(assocSidebarPreview).show().attr('src',assocSrc);
			$(this).find('.mura-assoc-marker-label').text(assocTitle);
			$(assocParent).find('.assocFileTools').hide();
			$("##selected-newfile").val(assocSrc);
		})
		$(document).on('click','ul.mura-assoc-structured-files li', function(){
			assocChoice = $('input[name="#esapiEncode('html_attr',rc.property)#-sel"]:checked').val();
			assocParent = $(this).parents('.mura-file-selector');
			assocPreview = $(this).find('.mura-associmg-ph > img');
			assocHtml = $(this).find('.mura-assoc-file-option').html();
			$('##mura-assoc-images-fileid ul li.active').removeClass('active');
			$(this).find('.mura-assoc-marker-icon').hide();
			$('##assocImagePreview').hide().attr('src','');
			$(this).find('.mura-assoc-marker-label').html(assocHtml);
			$(assocPreview).hide().attr('src','');
			$(assocParent).find('.assocFileTools').hide();
			$("##selected-newfile").val(assocChoice);
		})		
		$(document).on('click','ul.mura-assoc-loose-files li', function(){
			assocChoice = $('input[name="#esapiEncode('html_attr',rc.property)#-sel"]:checked').val();
			assocParent = $(this).parents('.mura-file-selector');
			assocPreview = $(this).find('.mura-associmg-ph > img');
			assocHtml = $(this).find('.mura-assoc-file-option').html();
			$('##mura-assoc-images-fileid ul li.active').removeClass('active');
			$(this).find('.mura-assoc-marker-icon').hide();
			$('##assocImagePreview').hide().attr('src','');
			$(this).find('.mura-assoc-marker-label').html(assocHtml);
			$(assocPreview).hide().attr('src','');
			$(assocParent).find('.assocFileTools').hide();
			$("##selected-newfile").val(assocChoice);
		})		
	</script>

	</cfif>
	<!--- /if results --->

	</div> <!--- /.selectAssocImageResults.block --->
</cfif>
<!--- /if search submitted --->

</cfoutput>