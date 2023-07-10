/* License goes here */
dashboardManager = {
	loadUserActivity(siteID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cDashboard.loadUserActivity&siteID=' + siteID + '&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#userActivityData');
		d.html('<div class="load-inline"></div>');
		$('#userActivityData .load-inline').spin(spinnerArgs2);

		$.get(url + "?" + pars, function(data) {
			$('#userActivityData .load-inline').spin(false);
			document.getElementById('userActivityData').innerHTML=data;
			d.animate({
				'opacity': 'hide'
			}, 1000, null, function() {
				d.animate({
					'opacity': 'show'
				}, 1000);
			});
		});
		return false;
	},

	loadPopularContent(siteID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cDashboard.loadPopularContent&siteID=' + siteID + '&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#popularContentData');
		d.html('<div class="load-inline"></div>');
		$('#popularContentData .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$('#popularContentData .load-inline').spin(false);
			document.getElementById('popularContentData').innerHTML=data;
			//d.html(data);
			d.animate({
				'opacity': 'hide'
			}, 1000, null, function() {
				d.animate({
					'opacity': 'show'
				}, 1000);
			});
		});
		return false;
	},

	loadRecentComments(siteID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cDashboard.loadRecentComments&siteID=' + siteID + '&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#recentCommentsData');
		d.html('<div class="load-inline"></div>');
		$('#recentCommentsData .load-inline').spin(spinnerArgs2);
		$.get(url + "?" + pars, function(data) {
			$('#recentCommentsData .load-inline').spin(false);
			document.getElementById('recentCommentsData').innerHTML=data;
			d.animate({
				'opacity': 'hide'
			}, 1000, null, function() {
				d.animate({
					'opacity': 'show'
				}, 1000);
			});
		});
		return false;
	},


	loadFormActivity(siteID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cDashboard.loadFormActivity&siteID=' + siteID + '&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#recentFormActivityData');
		d.html('<div class="load-inline"></div>');
		$('#recentFormActivityData .load-inline').spin(spinnerArgs2);

		$.get(url + "?" + pars, function(data) {
			$('#recentFormActivityData .load-inline').spin(false);
			document.getElementById('recentFormActivityData').innerHTML=data;
			d.animate({
				'opacity': 'hide'
			}, 1000, null, function() {
				d.animate({
					'opacity': 'show'
				}, 1000);
			});
		});
		return false;
	},

	loadEmailActivity(siteID) {
		var url = 'index.cfm';
		var pars = 'muraAction=cDashboard.loadEmailActivity&siteID=' + siteID + '&cacheid=' + Math.random();

		//location.href=url + "?" + pars;
		var d = $('#emailBroadcastsData');
		d.html('<div class="load-inline"></div>');
		$('#emailBroadcastsData .load-inline').spin(spinnerArgs2);

		$.get(url + "?" + pars, function(data) {
			$('#emailBroadcastsData .load-inline').spin(false);
			document.getElementById('emailBroadcastsData').innerHTML=data;
			d.animate({
				'opacity': 'hide'
			}, 1000, null, function() {
				d.animate({
					'opacity': 'show'
				}, 1000);
			});
		});
		return false;
	}
}