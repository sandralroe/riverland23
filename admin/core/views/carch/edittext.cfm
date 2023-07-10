<cfsilent>
<cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
<cfif $.globalConfig("htmlEditorType") eq "markdown">
	<cfset editorclass="mura-markdown">
<cfelse>
	<cfset editorclass="mura-html">
</cfif>
</cfsilent>
<cfinclude template="js.cfm">
<cfoutput>
<div class="mura-header">
	<h1>Edit Text</h1>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  	<div class="block-content">
		  	<div class="mura-control-group">
				<textarea style="display:none;" name="source" id="source" class="#editorclass#" data-height="400" data-width="100%"></textarea>
			</div>
			<div class="mura-actions">
				<div class="form-actions">
					<button class="btn mura-primary" id="updateBtn"><i class="mi-check-circle"></i>Update</button>
				</div>
			</div>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
<script>
	$(function($){
		var target='source';
		var input=Mura('##source');
        siteManager.setDisplayObjectModalWidth(950);
		
		<cfif $.globalConfig("htmlEditorType") eq "markdown">
			siteManager.requestDisplayObjectParams(function(params){
				markdownInstances[input.attr('name')].setMarkdown(params.source)
			});

			Mura("##updateBtn").click(function(){
				
                var params={};
                if(markdownInstances && typeof markdownInstances.source){
                    input.val(markdownInstances[input.attr('name')].getMarkdown())
                    params.source=input.val();
                }
                
                siteManager.updateDisplayObjectParams(params,false);
            });
		<cfelse>
			siteManager.requestDisplayObjectParams(function(params){
				CKEDITOR.instances[target].setData(params[target])
			});

			Mura("##updateBtn").click(function(){
				var params={};
				params[target]=CKEDITOR.instances[target].getData();
				siteManager.updateDisplayObjectParams(params,false);
			});
		</cfif>
    });
</script>
</cfoutput>
