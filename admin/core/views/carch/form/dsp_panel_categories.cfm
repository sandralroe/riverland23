<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabCategorization")>
<cfoutput>
<div class="mura-panel" id="tabCategorization">
	<div class="mura-panel-heading" role="tab" id="heading-categories">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-categories" aria-expanded="false" aria-controls="panel-categories">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.categorization")#</a>
		</h4>
	</div>
		<div id="panel-categories" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-categories" aria-expanded="false" style="height: 0px;">
			<div class="mura-panel-body">

				<span id="extendset-container-tabcategorizationtop" class="extendset-container"></span>

				<div class="mura-control-group">
					<div id="categories__selected"></div>

					<!--- 'big ui' flyout panel --->
					<div class="bigui" id="bigui__categories" data-label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.managecategories'))#">
						<div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.availablecategories'))#</div>
						<div class="bigui__controls">

								<div class="mura-control-group">
									<div class="mura-grid stripe" id="mura-grid-categories">
										<dl class="mura-grid-hdr">
											<dt class="categorytitle">
													#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.availablecategories')#
											</dt>
											<dd class="categoryassignmentwrapper">
												<!--- <a title="#application.rbFactory.getKeyValue(session.rb,'tooltip.categoryfeatureassignment')#" rel="tooltip" href="##"> --->
															#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.feature')#<!---  <i class="mi-question-circle"></i>
												</a> --->
											</dd>
										</dl><!--- /.mura-grid-hdr --->
											
											<cfset rc.rsCategoryAssign=application.contentManager.getCategoriesByHistID(rc.contentBean.getContentHistID()) />
											<cf_dsp_categories_nest
												siteID="#rc.siteID#"
												parentID=""
												nestLevel="0"
												contentBean="#rc.contentBean#"
												rsCategoryAssign="#rc.rsCategoryAssign#"
											>

									</div><!--- /.mura-grid --->
								</div>

						</div>
					</div> <!--- /.bigui --->
				</div> <!--- /.mura-control-group --->	

				<span id="extendset-container-categorization" class="extendset-container"></span>
				<span id="extendset-container-tabcategorizationbottom" class="extendset-container"></span>

		</div>
	</div>
</div> 

</cfoutput>
<script>
	siteManager.initCategoryAssignments();

	var stripeCategories=function() {
			var counter=0;
			//alert($('#bigui__categories dl').length)
			$('#bigui__categories dl').each(
				function(index) {
					//alert(index)
					if(index && !$(this).parents('ul.categorylist:hidden').length)
					{
						//alert($(this).parents('ul.categorylist').length);
						counter++;
						//alert(counter)
						if(counter % 2) {
							$(this).addClass('alt');
						} else {
							$(this).removeClass('alt');
						}
					}
			});
			//alert(counter)
		}

	$(document).ready(function(){

		var catsInited=false;

		$('.hasChildren').click(function(){
			if(catsInited){
				$(this).closest('li').find('ul.categorylist:first').toggle();
				$(this).toggleClass('open');
				$(this).toggleClass('closed');
				stripeCategories();
			} else {
				$(this).closest('li').find('ul.categorylist:first').show();
				if(!$(this).hasClass('open')){
					$(this).toggleClass('open').toggleClass('closed');
				}
			}
		});

		<cfparam name="request.opencategorylist" default="">
		
		<cfset cats=$.getBean('categoryFeed')
			.addParam(
				column="categoryid",
				list=true,
				condition="in",
				criteria=request.opencategorylist)
			.getIterator()>

		<cfset itemList="">
		<cfloop condition="cats.hasNext()">
			<cfset cat=cats.next()>
			<cfif listLen(cat.getPath()) gt 1>
				<cfset to=listLen(cat.getPath())-1>
				<cfloop from="1" to="#to#" index="i">
					<cfset item=replace(listGetAt(cat.getPath(),i),"'","","all")>
					<cfif not listFind(itemlist,item)>
						<cfoutput>$('##bigui__categories li[data-categoryid="#item#"]').find('span.hasChildren:first').trigger('click');</cfoutput>
					<cfset itemlist=listAppend(itemList,item)>
					</cfif>

				</cfloop>
			</cfif>
		</cfloop>

		catsInited=true;

		stripe('stripe');

		// display selected categories in text format
		var showSelectedCats = function(){	
			var catList = '';
			var delim = '&nbsp;&raquo;&nbsp;';
			// create list of selected categories
			$('#mura-grid-categories #mura-nodes li .categorytitle label').each(function(){
				if($(this).find('input[type=checkbox]').prop('checked')){
					var appendStr = '';
					$(this).parentsUntil($('#mura-nodes'), 'li').each(function(){
						var labelText = $(this).find('> dl > dt > label').text();
						if(labelText.trim().length > 0){
							var curStr = appendStr;
							appendStr = labelText.trim();
							if (curStr.trim().length > 0){
							 appendStr = appendStr + delim + curStr;
							}
						}
					});
					catList = catList + '<li>' + appendStr + '</li>';
				}
			})
			if (catList.trim().length > 0){
				$('#categories__selected').html('<label>Selected</label><div class="bigui__preview"><ul>' + catList + '</ul></div>');
			} else {
				$('#categories__selected').html('<label>Selected</label><div class="bigui__preview"><div><cfoutput>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.nocategories'))#</cfoutput></div></div>');
			}

		}
		// run on page load
		showSelectedCats();
		// run on change of selection
		$('#mura-grid-categories #mura-nodes li .categorytitle input[type=checkbox]').on('click',function(){
			showSelectedCats();
		})

	});
</script>
