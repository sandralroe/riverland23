/* License goes here */

/*function addSearchOption(containerid){

	var num =$(containerid).getElementsByTagName('LI').length + 1
	var str= '<p id="newFileP' + num + '"><input type="file" id="fileId' + num + '"  name="newFile' + num +'" ><input type="button" value="cancel" onclick="$(\'newFileP' + num + '\').innerHTML=\'\';"</p>';
	new Insertion.Bottom(containerid, str);

}*/


$searchParams={
	addSearchParam(){

		var num =$('#searchParams > .mura-control').length;
		var str= '<div class="mura-control justify">' + $('#searchParams > .mura-control').html() + '</div>';
		$('#searchParams').append(str);
		var newParam = $('#searchParams > .mura-control:last');
		var newParamSelects = $('#searchParams > .mura-control:last > select');
		var newParamInputs = $('#searchParams > .mura-control:last > input');

		newParamSelects[0].selectedIndex=0;
		newParamSelects[1].selectedIndex=0;
		newParamSelects[2].selectedIndex=0;
		newParamInputs[1].setAttribute('value','');

		this.setSearchParamNames(newParam,num + 1);
	},

	setSearchParamNames(param,num){

		var newParamSelects =$(param).find("select");
		var newParamInputs = $(param).find("input");

		newParamSelects[0].setAttribute('name','paramRelationship' + num);
		newParamSelects[1].setAttribute('name','paramField'  + num);
		newParamSelects[2].setAttribute('name','paramCondition'  + num);
		newParamInputs[0].setAttribute('value',num);
		newParamInputs[1].setAttribute('name','paramCriteria' + num);

	},

	setSearchButtons(){
		var params=$('#searchParams > .mura-control');
		var num =params.length;

		if(num == 1){
			var buttons = params.find("a");
				$(buttons[0]).hide();
				$(buttons[1]).show();
				params.find("select:first").hide();
		} else {

			self=this;

			params.each(function(index){
					if(index==0){
						var buttons =$(params[index]).find("a");
						$(params[index]).find('select:first').hide();
						$(buttons[0]).hide();
						$(buttons[1]).hide();
					} else {
						var buttons =$(params[index]).find("a");
						$(params[index]).find('select:first').show();

						if(index!= num-1){
							$(buttons[0]).show();
							$(buttons[1]).hide();

						}else{
							$(buttons[0]).show();
							$(buttons[1]).show();
						}

						 self.setSearchParamNames(params[index],index + 1);
					}
				}
			);

		}

		return false;
	},

	removeSeachParam(option){

		new $(option).remove();

		return false;
	}
}
