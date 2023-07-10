 <!--- license goes here --->
<cfparam name="objectParams.modalimages" default="false">
<cfoutput>
<div class="mura-control-group">
  	<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagesize')#</label>
	<select name="imageSize" data-displayobjectparam="imageSize" class="objectParam">
		<cfloop list="Small,Medium,Large" index="i">
			<option value="#lcase(i)#"<cfif i eq feed.getImageSize()> selected</cfif>>#I#</option>
		</cfloop>
		<cfset imageSizes=application.settingsManager.getSite(rc.siteid).getCustomImageSizeIterator()>
		<cfloop condition="imageSizes.hasNext()">
			<cfset image=imageSizes.next()>
			<option value="#lcase(image.getName())#"<cfif image.getName() eq feed.getImageSize()> selected</cfif>>#esapiEncode('html',image.getName())#</option>
		</cfloop>
		<option value="custom"<cfif "custom" eq feed.getImageSize()> selected</cfif>>Custom</option>
	</select>
</div>

<div id="imageoptionscontainer" style="display:none">
    <div class="mura-control-group" >
    	<label>#application.rbFactory.getKeyValue(session.rb,'collections.imageheight')#</label>
      	<input class="objectParam" name="imageHeight" data-displayobjectparam="imageHeight" type="text" value="#feed.getImageHeight()#" />
    </div>
    <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'collections.imagewidth')#</label>
    	<input class="objectParam" name="imageWidth" data-displayobjectparam="imageWidth" type="text" value="#feed.getImageWidth()#" />
    </div>
</div>

<div class="mura-control-group" id="availableFields">
	<label>
		<div>#application.rbFactory.getKeyValue(session.rb,'collections.selectedfields')#</div>
		<button id="editFields" class="btn"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'collections.edit')#</button>
	</label>
	<div id="sortableFields" class="sortable-sidebar">
		<cfset displaylist=feed.getdisplaylist()>
		<cfset displayLabels=feed.getDisplayLabels(displayList)>
		<ul id="displayListSort" class="displayListSortOptions">
			<cfloop list="#displayList#" index="i">
				<cftry>
					<cfset attrLabel = listGetAt(displayLabels,listFind(displayList,i))>
					<cfcatch>
						<cfset attrLabel = i>
					</cfcatch>
				</cftry>
				<li class="ui-state-highlight" data-attributecol="#trim(i)#">#attrLabel#</li>
			</cfloop>
		</ul>
		<input type="hidden" id="displaylist" class="objectParam" value="#esapiEncode('html_attr',feed.getdisplaylist())#" name="displaylist"  data-displayobjectparam="displaylist"/>
	</div>
</div>
<div class="mura-control-group">
  	<label>#application.rbFactory.getKeyValue(session.rb,'collections.viewimagesasgallery')#</label>
	<select name="modalimages" data-displayobjectparam="modalimages" class="objectParam">
		<cfloop list="True,False" index="i">
			<option value="#lcase(i)#"<cfif objectparams.modalimages eq i> selected</cfif>>#i#</option>
		</cfloop>
	</select>
</div>
<script>
	$(function(){
		$('##editFields').click(function(){
			frontEndProxy.post({
				cmd:'openModal',
				src:'?muraAction=cArch.selectfields&siteid=#esapiEncode("url",rc.siteid)#&contenthistid=#esapiEncode("url",rc.contenthistid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true&displaylist=' + $("##displaylist").val()
				}
			);
		});

		$("##displayListSort").sortable({
			update: function(event) {
				event.stopPropagation();
				$("##displaylist").val("");
				$("##displayListSort > li").each(function() {
					var current = $("##displaylist").val();

					if(current != '') {
						$("##displaylist").val(current + "," + $(this).html());
					} else {
						$("##displaylist").val($(this).html());
					}
				});

				updateDraft();
				//siteManager.updateObjectPreview();

			}
		}).disableSelection();

		$('##layoutoptionscontainer').show();

		$('select[name="layout"]').off('change').on('change',setLayoutOptions);

		function handleImageSizeChange(){
			if($('select[name="imageSize"]').val()=='custom'){
				$('##imageoptionscontainer').show()
			}else{
				$('##imageoptionscontainer').hide();
				$('##imageoptionscontainer').find(':input').val('AUTO');
			}
		}

		$('select[name="imageSize"]').change(handleImageSizeChange);

		handleImageSizeChange();
	});

</script>
</cfoutput>
