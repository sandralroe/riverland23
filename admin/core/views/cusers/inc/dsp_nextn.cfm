<!--- License goes here --->
<cfoutput>

	<cfif IsDefined('rc.nextn')>


		<script>
		jQuery(document).ready(function($){

			$('a.nextN').click(function(e){
				e.preventDefault();
				actionModal();
				$('form##frmNextN input[name="recordsperpage"]').val($(this).attr('data-nextn'));
				$('form##frmNextN input[name="pageno"]').val(1);
				$('form##frmNextN').submit();
			});

			$('a.pageNo').click(function(e){
				e.preventDefault();
				actionModal();
				$('form##frmNextN input[name="startrow"]').val($(this).attr('data-pageno'));
				$('form##frmNextN').submit();
			});

		});
		</script>

		<form id="frmNextN" action="" method="post">
			<input type="hidden" name="muraAction" value="#esapiEncode('html_attr',rc.muraAction)#">
			<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
			<input type="hidden" name="ispublic" value="#esapiEncode('html_attr',rc.ispublic)#">
			<input type="hidden" name="unassigned" value="#esapiEncode('html_attr',rc.unassigned)#">
			<input type="hidden" name="recordsperpage" value="#rc.nextn.recordsperpage#">
			<input type="hidden" name="startrow" value="#rc.nextn.startrow#">
		</form>

		<div class="container">
			<div class="mura-layout-row">

				<!--- Records Per Page --->
					<div class="btn-group">
						<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
							#rbKey('user.recordsperpage')#
							<span class="caret"></span>
						</a>
						<cfset local.arrPages = [5,10,25,50,100,250,500,1000] />
						<ul class="dropdown-menu next-n pull-right">
							<cfloop array="#local.arrPages#" index="local.pagecount">
								<li <cfif rc.recordsperpage eq local.pagecount> class="active"</cfif>><a href="##" class="nextN" data-nextn="#local.pagecount#">#local.pagecount#</a></li>
							</cfloop>
							<li <cfif rc.recordsperpage eq 100000> class="active"</cfif>><a href="##" class="nextN" data-nextn="100000">#rbKey('user.all')#</a></li>
						</ul>
					</div>

				<cfif rc.nextn.numberofpages gt 1>
				<!--- Pagination --->
					<ul class="pagination pull-right">

						<!--- Previous Link --->
							<cfscript>
								if ( rc.it.getPageIndex() == 1 ) {
									local.prevClass = 'hidden';
									local.prevNo = '';
								} else {
									local.prevClass = 'pageNo';
									local.prevNo = rc.it.getPageIndex() - 1;
								}
							</cfscript>
							<li class="#local.prevClass#">
								<a href="##" data-pageno="#local.prevNo#" class="#local.prevClass#"><i class="mi-angle-left"></i></a>
							</li>

						<!--- Page Number Links --->
							<cfloop from="#rc.nextn.firstpage#" to="#rc.nextn.lastpage#" index="local.pagenumber">
								<li<cfif val(rc.it.getPageIndex()) eq local.pagenumber> class="active"</cfif>>
									<cfset lClass = "pageNo">
									<a href="##" data-pageno="#local.pagenumber#" class="#lClass#">
										#local.pagenumber#
									</a>
								</li>
							</cfloop>

						<!--- Next Link --->
							<cfscript>
								if ( rc.it.getPageIndex() == rc.nextn.numberofpages ) {
									rc.nextClass = 'hidden';
									rc.prevNo = '';
								} else {
									rc.nextClass = 'pageNo';
									rc.prevNo = rc.it.getPageIndex() + 1;
								}
							</cfscript>
							<li class="#rc.nextClass#">
								<a href="##" data-pageno="#rc.prevNo#" class="#rc.nextClass#"><i class="mi-angle-right"></i></a>
							</li>

					</ul>
				</cfif>
			</div>
		</div>
	</cfif>
</cfoutput>
