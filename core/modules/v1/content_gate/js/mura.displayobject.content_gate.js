Mura.preInit(function(){
  Mura.DisplayObject.Content_gate = Mura.UI.extend({});

  Mura.DisplayObject.Content_gate.reopenClass({
    createStore:function(){
      var values={}
      return {
        set:function(key,value){
          values[key]=value;
          return this;
        },
        get:function(key){
          if(typeof values[key] != 'undefined'){
            return values[key];
          } else {
            return null;
          }
        },
        getAll:function(key){
          return values;
        }
      }
    }
  });


  Mura.DisplayObject.Content_gate.reopen({
      render: function() {
        var self=this;

        this.context.scroll = parseInt(this.context.scroll) || 0;
        this.context.delay = parseInt(this.context.delay) || 0;
        this.context.displays = parseInt(this.context.displays) || 0;
        this.context.visits = parseInt(this.context.visits) || 0;
        this.context.resetinterval = this.context.resetinterval || 'session';
        this.context.resetqty = parseInt(this.context.resetqty) ||  1;
        this.context.assetlabel = this.context.assetlabel || '';
        this.context.type = this.context.type || 'modal';
        this.context.animatespeed = this.context.animatespeed ||  'fast';
        this.context.anchorx = this.context.anchorx || 'center';
        this.context.anchory = this.context.anchory || 'center';
        this.context.animate = this.context.animate || '';
        this.context.animatespeed = this.context.animatespeed ||  'fast';
        this.context.hideengaged = parseInt(this.context.hideengaged) ||  0;
        this.context.followupurl = this.context.followupurl || '';

        this.context.width = this.context.width || 'md';
        this.context.cssclass = this.context.cssclass || '';
        this.context.instanceclass = this.context.instanceclass || '';

        if (this.context.type == 'modal') {
            this.context.anchorx = 'center';
            this.context.anchory = 'center';

            if (!this.context.animate) {
                this.context.animate = 'ttb';
            }

        } else if (this.context.type == 'bar') {
            this.context.anchorx = 'center';
            this.context.anchory = 'bottom';
            this.context.animate = 'btt';

        } else if (this.context.type == 'drawer') {
            if (this.context.anchorx == 'center') {
                this.context.anchorx = 'right';
            }

            if (this.context.anchorx == 'right') {
                this.context.animate = 'rtl';
            } else {
                this.context.animate = 'ltr';
            }

        } else if (this.context.type == 'inline') {
            this.context.width = 'full';
            this.context.animate = '';
            this.context.animatespeed = '';
        }

        if (!Mura.isNumeric(this.context.scroll)) {
            this.context.scroll = 0;
        }

        if (!Mura.isNumeric(this.context.delay)) {
            this.context.delay = 0;
        }

        if (!Mura.isNumeric(this.context.displays)) {
            this.context.displays = 0;
        }

        if (!Mura.isNumeric(this.context.visits)) {
            this.context.visits = 0;
        }

        if (!Mura.isNumeric(this.context.resetqty)) {
            this.context.resetqty = 1;
        }

        var clazz=Mura.DisplayObject.Content_gate;


        if(typeof clazz.store == 'undefined'){
          clazz.store=clazz.createStore();
        }

        if(!clazz.store.get(self.context.instanceid)){
          clazz.store.set(self.context.instanceid,clazz.createStore());
        }

        var executionid=Mura.createUUID();
        var instanceStore=clazz.store.get(self.context.instanceid);

        instanceStore.set('executionid',executionid);

        Mura('body').on(
          'click',
          self.context.selector + ", .mxp-gated-link",
          function(e){

            //console.log( (executionid==instanceStore.get('executionid')) + ':'+executionid + ":" + Mura.DisplayObject.Content_gate.store.get(self.context.instanceid).get('executionid'))

            if(Mura('div[data-instanceid="' + self.context.instanceid +'"]').length && executionid==instanceStore.get('executionid')){

              var source=Mura(e.target);

              if(!source.hasAttr('href')){
                source=source.closest('a');
              }

              if((!Mura.user.known || Mura.user.known == '0') && !source.hasClass("mxp-open-gate")){
                e.preventDefault();
                e.stopPropagation();

                var checker=Mura('div[data-instanceid="' + executionid + '"]');
                var actionTaken=false;

                function gate(){
                  actionTaken=true;
                  if(checker.length){
                    Mura.processMarkup(checker,false,true);
                  } else {
                    Mura('body').appendDisplayObject({
                      object:"cta",
                      objectid:self.context.formid,
                      instanceid:executionid,
                      formid:self.context.formid,
                      render:"client",
                      type: self.context.type,
                      scroll: self.context.scroll,
                      delay: self.context.delay,
                      displays: self.context.displays,
                      visits: self.context.visits,
                      resetinterval: self.context.resetinterval,
                      resetqty: self.context.resetqty,
                      animatespeed: self.context.animatespeed,
                      anchorx: self.context.anchorx,
                      anchory: self.context.anchory,
                      animate: self.context.animate,
                      animatespeed: self.context.animatespeed,
                      width: self.context.width,
                      cssclass: self.context.cssclass,
                      instanceclass: context.context.instanceclass,
                      queue: false,
                      followupurl: source.attr('href'),
                      hideengaged: self.context.hideengaged
                    });
                  }
                }

                if(source.hasAttr('href')){
                  clazz.store.set('gated_href',source.attr('href'));
                  if(self.context.assetlabel){
                    clazz.store.set('gated_href_label',self.context.assetlabel);
                    gate();
                  } if(source.hasAttr('label')){
                    clazz.store.set('gated_href_label',source.attr('label'));
                    gate();
                  } else if(source.hasAttr('data-label')){
                    clazz.store.set('gated_href_label',source.attr('data-label'));
                    gate();
                  } else if (!actionTaken){

                    var filenameArray=source.attr('href').split("?");
                        filenameArray=filenameArray[0].split("/");
                        filenameArray.reverse();

                    var urltitle='';

                    for(var i in filenameArray){
                      if(filenameArray[i]){
                        urltitle=filenameArray[i];
                        break;
                      }
                    }

                    if(urltitle){
                      Mura.getEntity('content')
                        .loadBy('urltitle',urltitle)
                        .then(function(content){
                          if(content.exists()){
                            clazz.store.set('gated_href_label',content.get('menutitle'));
                          } else {
                            clazz.store.set('gated_href_label',source.html());
                          }
                          gate();
                        }).catch(function(){
                          clazz.store.set('gated_href_label',source.html());
                          gate();
                        });
                    } else {
                      clazz.store.set('gated_href_label',source.html());
                      gate();
                    }
                  }
                }
              }
            }
          }
        );

        Mura.loader().load(Mura.corepath + '/modules/v1/cta/css/mura-cta-config.css');

        var region = Mura(this.context.targetEl).closest('.mura-region-local');

        if (region.length && region.data('perm')) {
            Mura(this.context.targetEl).html('<div class="mura-cta-empty" data-mura-cta-type-label="gate"></div>');
        }

        var obj = Mura(self.context.targetEl).closest('.mura-object');

        obj.hide();

        setTimeout(function() {
                obj.show();
            },
            20
        );


      }
  });

  Mura.DisplayObject.Form.reopen({
    onAfterResponseRender: function() {
      this.parseGateTokens();
    },
    onAfterRender: function() {
        this.parseGateTokens();
    },
    parseGateTokens:function(){
      //this.context.targetEl is a pointer to the dom element that contains the rendered Mura form.
      var container = Mura(this.context.targetEl);
      var gate=Mura.DisplayObject.Content_gate;

      if(gate.store){
        container.find('div.mura-form-text, div.mura-response-success').each(function(){
          var item=Mura(this);
          var html=item.html();

          if(gate.store.get('gated_href')){
            html=html.replace("${gated_href}",gate.store.get('gated_href'));
          } else if (gated_href){
            html=html.replace("${gated_href}",gated_href);
          }

          if(gate.store.get('gated_href_label')){
            html=html.replace("${gated_href_label}",gate.store.get('gated_href_label'));
          } else if (gated_href_label){
            html=html.replace("${gated_href_label}",gated_href_label);
          }

          item.html(html);

          Mura('.mura-response-success a[href="'+ gate.store.get('gated_href') + '"]').addClass("mxp-open-gate");

        });
      } else {
        container.find('div.mura-form-text, div.mura-response-success').each(function(){
          var item=Mura(this);
          var html=item.html();

          if (typeof gated_href != 'undefined' && gated_href){
            html=html.replace("${gated_href}",gated_href);
          }

          if (typeof gated_href_label != 'undefined' && gated_href_label){
            html=html.replace("${gated_href_label}",gated_href_label);
          }

          item.html(html);

          if(typeof gated_href != 'undefined' && gated_href){
            Mura('.mura-response-success  a[href="'+ gated_href + '"]').addClass("mxp-open-gate");
          }
        });
      }
    }

  });
})
