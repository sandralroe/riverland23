<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabRelatedcontent")>
<cfset subtype = application.classExtensionManager.getSubTypeByName(rc.contentBean.getType(), rc.contentBean.getSubType(), rc.contentBean.getSiteID())>
<cfset relatedContentSets = subtype.getRelatedContentSets()>

<cfoutput>
	<div class="mura-panel" id="tabRelatedcontent">
		<div class="mura-panel-heading" role="tab" id="heading-relatedcontent">
			<h4 class="mura-panel-title">
				<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-relatedcontent" aria-expanded="false" aria-controls="panel-relatedcontent">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.relatedcontent")#</a>
			</h4>
		</div>
		<div id="panel-relatedcontent" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-relatedcontent" aria-expanded="false" style="height: 0px;">
			<div class="mura-panel-body">

				<span id="extendset-container-tabrelatedcontenttop" class="extendset-container"></span>

				<div class="mura-control-group">
					<div id="relcontent__selected"></div>
					<!--- 'big ui' flyout panel --->
					<div class="bigui" id="bigui__related" data-label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.managerelatedcontent"))#">
						<div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.relatedcontent"))#</div>
						<div class="bigui__controls">
							<div id="selectRelatedContent"><!--- target for ajax ---></div>
							<div id="selectedRelatedContent" class="mura-control-group"></div>
						</div>
					</div> <!--- /.bigui --->
				</div>
				<input id="relatedContentSetData" type="hidden" name="relatedContentSetData" value="" />	

		   <span id="extendset-container-relatedcontent" class="extendset-container"></span>
		   <span id="extendset-container-tabrelatedcontentbottom" class="extendset-container"></span>

			</div>
		</div>
	</div> 
</cfoutput>

<script type="text/javascript">
	$(document).ready(function(){

		// display selected related content in text format
		var showSelectedRC = function(){	
			var rcList = '';
					// create list of selected content
					$('#selectedRelatedContent .list-table').each(function(){
						rcText = $(this).find('.list-table-content-set').text();
						rcLen = $(this).find('.list-table-items li.item').not('.empty').not('.noShow').not('.ui-sortable-placeholder').length;
						if (rcLen > 0){
							rcList = rcList + '<li>' + rcText + ': ' + rcLen + '</li>';
						}
					})

					if (rcList.trim().length > 0){
						$('#relcontent__selected').html('<label><cfoutput>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selected'))#</cfoutput></label><div class="bigui__preview"><ul>' + rcList + '</ul></div>');
					} else {
						$('#relcontent__selected').html('<label><cfoutput>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selected'))#</cfoutput></label><div class="bigui__preview"><div><cfoutput>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.relatedcontent")#</cfoutput></div></div>');
					}
				}

		// run on page load
		showSelectedRC();
		// run on click of heading
		$('#heading-relatedcontent').on('click',function(){
			showSelectedRC();
		})
		// run when bigui is opened, until closed
		$('a.bigui__launch').on('click',function(){
	    rcTimer = setInterval(function(){
		    showSelectedRC();
			}, 1000);
		});
		$('#bigui__related a.bigui__close').on('click',function(){
	    clearInterval(rcTimer);
		});

	});
</script>

