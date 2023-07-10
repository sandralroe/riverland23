/* License goes here */


//  DHTML Menu for Site Summary
categoryManager = {
	DHTML: (document.getElementById || document.all || document.layers),
	lastid: "",

	getObj(name) {
		if(document.getElementById) {
			this.obj = document.getElementById(name);
			this.style = document.getElementById(name).style;
		} else if(document.all) {
			this.obj = document.all[name];
			this.style = document.all[name].style;
		} else if(document.layers) {
			this.obj = document.layers[name];
			this.style = document.layers[name];
		}
	},

	showMenu(id, obj, parentid, siteid) {

		if(window.innerHeight) {
			var posTop = window.pageYOffset
		} else if(document.documentElement && document.documentElement.scrollTop) {
			var posTop = document.documentElement.scrollTop
		} else if(document.body) {
			var posTop = document.body.scrollTop
		}

		if(window.innerWidth) {
			var posLeft = window.pageXOffset
		} else if(document.documentElement && document.documentElement.scrollLeft) {
			var posLeft = document.documentElement.scrollLeft
		} else if(document.body) {
			var posLeft = document.body.scrollLeft
		}

		var xPos = this.findPosX(obj);
		var yPos = this.findPosY(obj);

		xPos = xPos - 10;

		document.getElementById(id).style.top = yPos + "px";
		document.getElementById(id).style.left = xPos + "px";
		$('#' + id).removeClass('hide');

		document.getElementById('newCategoryLink').href = './?muraAction=cCategory.edit&parentid=' + parentid + '&siteid=' + siteid;

	// append action links
		var actionLinks = obj.parentNode.parentNode.getElementsByClassName("actions")[0].getElementsByTagName("ul")[0].getElementsByTagName("li");
		var optionList = document.getElementById('newCategoryOptions');
		// remove old links
		var oldLinks = optionList.getElementsByClassName("li-action");
		var l;
		while ((l = oldLinks[0])) {
			l.parentNode.removeChild(l);
		}
		// create new links
		var newPage = document.getElementById('newPage');
	  for (var i = 0; i < actionLinks.length; i++ ) {
        if(actionLinks[i].className.indexOf('disabled') < 0){
	        var item = document.createElement("li");
	        item.innerHTML = actionLinks[i].innerHTML;
	        var link = item.getElementsByTagName("a")[0];
	        var titleStr = link.getAttribute("title");
	        item.className = 'li-action ' + titleStr.toLowerCase();
	        link.removeAttribute("title");
	        link.innerHTML = link.innerHTML + titleStr;
	        if(titleStr.toLowerCase() == 'edit'){
	        	optionList.insertBefore(item, newPage.nextSibling);
	        } else {
        		optionList.appendChild(item);
	        }
        }
    }


		if(this.lastid != "" && this.lastid != id) {
			this.hideMenu(this.lastid);
		}

//		this.navTimer = setTimeout('categoryManager.hideMenu(categoryManager.lastid);', 6000);
		this.lastid = id;
	},

	findPosX(obj) {
		var curleft = 0;
		if(obj.offsetParent) {
			while(obj.offsetParent) {
				curleft += obj.offsetLeft
				obj = obj.offsetParent;
			}
		} else if(obj.x) curleft += obj.x;
		return curleft;
	},

	findPosY(obj) {
		var curtop = 0;
		if(obj.offsetParent) {
			while(obj.offsetParent) {
				curtop += obj.offsetTop
				obj = obj.offsetParent;
			}
		} else if(obj.y) curtop += obj.y;
		return curtop;
	},


	keepMenu(id) {
//		this.navTimer = setTimeout('categoryManager.hideMenu(categoryManager.lastid);', 6000);
		$('#' + id).removeClass('hide');
	},

	hideMenu(id) {
//		if(this.navTimer != null) clearTimeout(this.navTimer);
		$('#' + id).addClass('hide');
	}
}