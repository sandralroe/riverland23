 <!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.src" default="">
	<cfparam name="objectParams.alt" default="">
	<cfparam name="objectParams.caption" default="">
	<cfparam name="objectParams.imagelink" default="">
	<cfparam name="objectParams.imagelinktarget" default="">
	<cfparam name="objectParams.fit" default="">
	<cfif $.globalConfig('htmlEditorType') eq 'markdown'>
		<cfset editorclass="mura-markdown">
	<cfelse>
		<cfset editorclass="mura-html">
	</cfif>
</cfsilent>
<cf_objectconfigurator params="#objectParams#">
<cfoutput>
	<div>
		<div class="mura-layout-row">
			<div class="mura-control-group">
				<label class="mura-control-label">Image Src</label>
				<input type="text" placeholder="Image URL" id="src" name="src" class="objectParam" value="#esapiEncode('html_attr',objectparams.src)#"/>
				<cfif len(request.associatedImageURL)>
					<div class="btn-group btn-group-sm" role="group" aria-label="Select Image">		
						<button type="button" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
							<i class="mi-image"></i> Select Image <span class="caret"></span>
						</button>
						<ul class="dropdown-menu">
							<li><a class="mura-finder" data-target="src" data-completepath=<cfif request.$.content('type') eq 'Variation'>"true"<cfelse>"false"</cfif> href="javascript:void(0);"><i class="mi-globe"></i> File Manager</a></li>
							<li><a id="srcassocurl" href="#request.associatedImageURL#"> <i class="mi-th"></i> Associated Image</a></li>
						</ul>
						<script>
							$(function(){
								$('##srcassocurl').click(function(){
									$('##src').val($(this).attr('href')).trigger('change');
									return false;
								})
							})
						</script>
					</div>
				<cfelse>
					<button type="button" class="btn mura-finder" data-target="src" data-completepath="false"><i class="mi-image"></i> Select Image</button>
				</cfif>
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label">Image Fit</label>
				<select class="objectParam" name="fit" data-param="fit">
					<option value="">-</option>
					<option <cfif objectParams.fit eq 'contain'>selected </cfif>value="contain">Contain</option>
					<option <cfif objectParams.fit eq 'cover'>selected </cfif>value="cover">Cover</option>
					<option <cfif objectParams.fit eq 'fill'>selected </cfif>value="fill">Fill</option>
					<option <cfif objectParams.fit eq 'scale-down'>selected </cfif>value="scale-down">Scale-Down</option>
				</select>
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label">Image Alt Text</label>
				<input type="text" name="alt" class="objectParam" value="#esapiEncode('html_attr',objectparams.alt)#"/>
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label">Image Link URL</label>
				<input type="text" placeholder="Image Link" id="imagelink" name="imagelink" class="objectParam" value="#esapiEncode('html_attr',objectparams.imagelink)#"/>
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label">Open Link in New Tab</label>
				<select  name="imagelinktarget" class="objectParam">
					<option value="_self">No</option>
					<option value="_blank"<cfif objectparams.imagelinktarget eq "_blank"> selected</cfif>>Yes</option>
				</select>
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label">Caption Text</label>
				<!---<div class="alert" id="captiondemo"><cfif objectparams.caption eq '' or objectparams.caption eq '<p></p>'>N/A<cfelse>#objectparams.caption#</cfif></div>--->
				<button type="button" class="btn #editorclass#" data-target="caption" data-label="Edit Caption"><i class="mi-pencil"></i> Edit Caption</button>
 				<input type="hidden" class="objectParam" name="caption" value="#esapiEncode('html_attr',objectparams.caption)#">
				<!---<script>
				$('input[name="caption"]').on('change',
					function(){
						if(!this.value || this.value=='<p></p>'){
							getElementById('captiondemo').innerHTML='N/A'
						} else {
							getElementById('captiondemo').innerHTML=this.value
						}
					}
				)
				</script>--->
			</div>
		</div>
		<input type="hidden" class="objectParam" name="async" value="false">
		<!--- If SSR then use default module which happens to be client side rendered --->
		<cfif $.getContentRenderer().SSR>
			<input type="hidden" class="objectParam" name="render" value="client">
		</cfif>
	</div>
	<!--- Include global config object options --->
	<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">

</cfoutput>
</cf_objectconfigurator>

