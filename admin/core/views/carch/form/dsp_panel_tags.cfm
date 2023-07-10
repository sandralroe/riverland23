<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabTags")>
<cfoutput>
<div class="mura-panel" id="tabTags">
	<div class="mura-panel-heading" role="tab" id="heading-tags">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-tags" aria-expanded="false" aria-controls="panel-tags">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.tags")#</a>
		</h4>
	</div>
	<div id="panel-tags" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-tags" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">

				<span id="extendset-container-tabtagstop" class="extendset-container"></span>
		   		<div id="tags" class="mura-control justify tagSelector">
					<div class="mura-control-group">
					   	<label>
					   		#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.defaulttags')#
					   	</label>
		  				<input type="text" name="tags">
		  				<cfif len(rc.contentBean.getTags())>
		  					<cfloop list="#rc.contentBean.getTags()#" index="i">
		  						<span class="tag">
		  							#esapiEncode('html',i)# <a><i class="mi-times-circle"></i></a>
		  						  <input name="tags" type="hidden" value="#esapiEncode('html_attr',i)#">
		  						</span>
		  					</cfloop>
		  				</cfif>
					</div> <!--- /.mura-control-group --->
				</div> <!--- /.mura-control .tagSelector --->

				<script>
					$(document).ready(function(){
						$.ajax({
							url: '?muraAction=carch.loadtagarray&siteid=' + siteid,
							dataType: 'text',
							success:function(data){
		                        var tagArray=[];
		                        if(data){
							       tagArray=eval('(' + data + ')');
		                        }
								$('##tags').tagSelector(tagArray, 'tags');
							}
						});
					});
				</script>


				<cfset tagGroupList=$.siteConfig('customTagGroups')>

				<cfif len(tagGroupList)>
				<cfloop list="#tagGroupList#" index="g" delimiters="^,">
				<cfset g=trim(g)>
				<div id="#g#tags" class="mura-control justify tagSelector">
					<div class="mura-control-group">
					   	<label>
					   		#g# #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.tags')#
					   	</label>
						<input type="text" name="#g#tags">
						<cfif len(rc.contentBean.getValue('#g#tags'))>
							<cfloop list="#rc.contentBean.getValue('#g#tags')#" index="i">
								<span class="tag">
									#esapiEncode('html',i)# <a><i class="mi-times-circle"></i></a>
								    <input name="#g#tags" type="hidden" value="#esapiEncode('html_attr',i)#">
								</span>
							</cfloop>
						</cfif>
					</div> <!--- /.mura-control-group --->
				</div> <!--- /.mura-control .tagSelector --->
				<script>
					$(document).ready(function(){
						$.ajax({
							url:'?muraAction=carch.loadtagarray&siteid=' + siteid + '&taggroup=#g#',
							dataType: 'text',
							success: function(data){
								var tagArray=eval('(' + data + ')');
								$('###g#tags').tagSelector(tagArray, '#g#tags');
							}
						});
					});
				</script>
			</cfloop>
				</cfif>

				<span id="extendset-container-tags" class="extendset-container"></span>
				<span id="extendset-container-tabtagsbottom" class="extendset-container"></span>
		</div>
	</div>
</div> 
</cfoutput>