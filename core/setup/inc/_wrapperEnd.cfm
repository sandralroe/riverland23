<cfoutput>
							</div><!-- /block-content -->
						</div><!-- /.mura-focus-block -->
					</div> <!-- /.mura-setup -->
				</div> <!-- /.content -->
			</main>

			<div id="alertDialog" title="Alert" class="alert alert-notice hide">
				<span id="alertDialogMessage"></span>
			</div>
		</div><!-- /.page-container -->
	<cfif cgi.http_user_agent contains 'msie'>
	<!--[if IE 6]>
	<script type="text/javascript" src="#context#/admin/assets/js/ie6notice.js"></script>
	<![endif]-->
	</cfif>
	</body>
</html>
</cfoutput>