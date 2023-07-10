 <!--- license goes here --->
<cfsilent>
<cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
<cfset feed=$.getBean("feed")>
<cfset feed.set(url)>

<cfset displayList=feed.getDisplayList()>
<cfset displayLabels=feed.getDisplayLabels(displayList)>
<cfif isdefined('url.fieldoptions') and len(url.fieldoptions)>
	<cfset availableList=url.fieldoptions>
	<cfif isdefined('url.fieldoptionlabels') and len(url.fieldoptionlabels)>
		<cfset availableLabels=url.fieldoptionlabels>
	<cfelse>
		<cfset availableLabels=url.fieldoptions>
	</cfif>
<cfelse>
	<cfset availableList=feed.getAvailableDisplayList()>
	<cfset availableLabels=feed.getAvailableDisplayList(listCol="label")>
</cfif>

<cfset availListArr = listToArray(availableList)>
<cfset availLabelArr = listToArray(availableLabels)>
<cfparam name="rc.paramname" default="displaylist">
</cfsilent>
<cfinclude template="js.cfm">
<cfoutput>

<div class="mura-header">
	<h1>Select Fields</h1>
</div> <!-- /.mura-header -->
<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">
			<div class="mura-control-group" id="availableFields">
				<div id="sortableFields" class="mura-control justify">
					<p class="dragMsg">
						<span class="dragFrom half">#application.rbFactory.getKeyValue(session.rb,'sitemanager.selectfields.dragfieldsfromhere')#&hellip;</span><span class="half">&hellip;#application.rbFactory.getKeyValue(session.rb,'sitemanager.selectfields.dropthem')#.</span>
					</p>

					<ul id="availableListSort" class="displayListSortOptions">
						<cfif arrayLen(availListArr)>
							<cfloop from="1" to="#arrayLen(availListArr)#" index="i">
								<cfif not listFind(displayList,availListArr[i])>
									<cftry>
										<cfset availAttrLabel = availLabelArr[i]>
										<cfcatch>
											<cfset availAttrLabel = availListArr[i]>
										</cfcatch>
									</cftry>
									<li class="ui-state-default" data-attributecol="#esapiEncode('html_attr',availListArr[i])#">#esapiEncode('html',availAttrLabel)#</li>
								</cfif>
							</cfloop>
						</cfif>
					</ul>

					<ul id="displayListSort" class="displayListSortOptions">
						<cfloop list="#displayList#" index="i">
								<cftry>
								<cfset attrLabel = listGetAt(displayLabels,listFind(displayList,i))>
									<cfcatch>
										<cfset attrLabel = i>
									</cfcatch>
								</cftry>
							<li class="ui-state-highlight" data-attributecol="#esapiEncode('html_attr',trim(i))#">#esapiEncode('html',attrLabel)#</li>
						</cfloop>
					</ul>
					<input type="hidden" id="displayList" class="objectParam" value="#esapiEncode('html_attr',displayList)#" name="displayList"  data-displayobjectparam="displayList"/>
				</div>
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

$(function(){
	if($("##ProxyIFrame").length){
		$("##ProxyIFrame").load(
			function(){
				frontEndProxy.post({cmd:'setWidth',width:600});
			}
		);
	} else {
		frontEndProxy.post({cmd:'setWidth',width:600});
	}

	$('##updateBtn').click(function(){
		frontEndProxy.post({
			cmd:'setObjectParams',
			reinit:true,
			instanceid:'#esapiEncode("javascript",rc.instanceid)#',
			params:{
				'#esapiEncode('javascript',rc.paramname)#':$('##displayList').val()
				}
			});
	});

	$("##availableListSort, ##displayListSort").sortable({
		connectWith: ".displayListSortOptions",
		update: function(event) {
			event.stopPropagation();
			$("##displayList").val("");
			$("##displayListSort > li").each(function() {
				var current = $("##displayList").val();

				if(current != '') {
					$("##displayList").val(current + "," + $(this).attr('data-attributecol'));
				} else {
					$("##displayList").val($(this).attr('data-attributecol'));
				}

			});

		}
	}).disableSelection();

});
</script>
</cfoutput>