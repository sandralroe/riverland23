const jQuery=require('jquery');
const cache = {};

jQuery.event.special.touchstart = 
{
  setup( _, ns, handle )
  {
    if ( ns.includes("noPreventDefault") ) 
    {
      this.addEventListener("touchstart", handle, { passive: false });
    } 
    else 
    {
      this.addEventListener("touchstart", handle, { passive: true });
    }
  }
};

function importAll (r) {
  r.keys().forEach(key => cache[key] = r(key));
}

importAll(require.context('./_jquery', true, /\.js$/));


jQuery.widget("ui.dialog", jQuery.ui.dialog,
{
    open: function ()
    {
        var $dialog = jQuery(this.element[0]);

        var maxZ = 0;
        jQuery('*').each(function ()
        {
            var thisZ = jQuery(this).css('zIndex');
            thisZ = (thisZ === 'auto' ? (Number(maxZ) + 1) : thisZ);
            if (thisZ<200000 && thisZ > maxZ) maxZ = thisZ;
        });

        jQuery(".ui-widget-overlay").css("zIndex", (maxZ + 1));

        $dialog.parent().css("zIndex", (maxZ + 2));

        return this._super();
    }
});
