<!--- License goes here --->
<!--- At this point this is experimental --->
<cfsilent>
<cfparam name="rc.fileid" default="">
<cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
 <!--- removing siteid from below cfquery 3/27/17 --->
<cfquery name="rsImages">
 select tfiles.fileid, tcontent.title, tcontent.contentid
	 from tfiles
 left join tcontent on (tfiles.fileid=tcontent.fileid)
 where tfiles.fileext in ('png','jpg','jpeg','svg','webp')
 and tfiles.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#$.siteConfig().getFilePoolID()#">
 and tcontent.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#$.siteConfig().getSiteID()#">
 and tcontent.active=1

 and (
	 tcontent.contentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.contentid#">

	 or tcontent.parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.contentid#">

	 or tcontent.parentid in (select tcontent.contentid from tcontent
							 where tcontent.parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.contentid#">
							 and tcontent.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#$.siteConfig().getSiteID()#">
							 and tcontent.active=1
							 )
	 )
 group by tfiles.fileid, tcontent.title, tcontent.contentid
 <!--- above added 3/28 to remove duplicate image files --->
</cfquery>
</cfsilent>
<cfinclude template="js.cfm">
<cfoutput>
<div class="mura-header">
 <h1>Select Image</h1>

 <!---
	 <div class="nav-module-specific btn-toolbar">
		 <div class="btn-group">
			 <a class="btn" href="javascript:frontEndProxy.post({cmd:'close'});"><i class="mi-arrow-left"></i>  #application.rbFactory.getKeyValue(session.rb,'collections.back')#</a>
		 </div>
	 </div><!-- /.nav-module-specific -->
 --->
</div> <!-- /.mura-header -->

<div class="block block-constrain">
 <div class="block block-bordered">
		 <div class="block-content">
		 <div class="mura-control-group">
			 <div class="mura-control">
				 <cfif rsImages.recordcount>
					 <cfloop query="rsImages">
						 <div class="image-option" style="float: left; margin: 0 10px; text-align: center" data-fileid="#rsImages.fileid#">
							 <img src="#$.getURLForImage(fileid=rsImages.fileid,size='small')#"/>
							 <figcaption>
								 <cfif rc.contentid == contentid>Current<cfelse>#title#</cfif>
							 </figcaption>
						 </div>
					 </cfloop>
				 <cfelse>
					 <div class="help-block-empty">There are currently no related images available.</div>
				 </cfif>
			 </div>
		 </div>
	 </div>
 </div>
</div>

<script>
$(function(){
 $('.image-option').click(function(){
	siteManager.updateDisplayObjectParams(
		{
			fileid:$(this).data('fileid')
		},
		false
	);
 });

 if($("##ProxyIFrame").length){
	 $("##ProxyIFrame").load(
		 function(){
			 frontEndProxy.post({cmd:'setWidth',width:600});
		 }
	 );
 } else {
	 frontEndProxy.post({cmd:'setWidth',width:600});
 }


});
</script>
</cfoutput>
