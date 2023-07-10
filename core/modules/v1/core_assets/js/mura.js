(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define("Mura", [], factory);
	else if(typeof exports === 'object')
		exports["Mura"] = factory();
	else
		root["Mura"] = factory();
})(self, function() {
return /******/ (function() { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ 147:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.Cache
   * @name Mura.Cache
   * @class
   * @extends Mura.Core
   * @memberof	Mura
   * @return {Mura.Cache}
   */

  Mura.Cache = Mura.Core.extend( /** @lends Mura.Cache.prototype */
  {
    init: function init() {
      this.cache = {};
      return this;
    },
    /**
     * getKey - Returns Key value associated with key Name
     *
     * @param	{string} keyName Key Name
     * @return {*}				 Key Value
     */
    getKey: function getKey(keyName) {
      return Mura.hashCode(keyName);
    },
    /**
     * get - Returns the value associated with key name
     *
     * @param	{string} keyName	description
     * @param	{*} keyValue Default Value
     * @return {*}
     */
    get: function get(keyName, keyValue) {
      var key = this.getKey(keyName);
      if (typeof this.cache[key] != 'undefined') {
        return this.cache[key].keyValue;
      } else if (typeof keyValue != 'undefined') {
        this.set(keyName, keyValue, key);
        return this.cache[key].keyValue;
      } else {
        return;
      }
    },
    /**
     * set - Sets and returns key value
     *
     * @param	{string} keyName	Key Name
     * @param	{*} keyValue Key Value
     * @param	{string} key			Key
     * @return {*}
     */
    set: function set(keyName, keyValue, key) {
      key = key || this.getKey(keyName);
      this.cache[key] = {
        name: keyName,
        value: keyValue
      };
      return keyValue;
    },
    /**
     * has - Returns if the key name has a value in the cache
     *
     * @param	{string} keyName Key Name
     * @return {boolean}
     */
    has: function has(keyName) {
      return typeof this.cache[getKey(keyName)] != 'undefined';
    },
    /**
     * getAll - Returns object containing all key and key values
     *
     * @return {object}
     */
    getAll: function getAll() {
      return this.cache;
    },
    /**
     * purgeAll - Purges all key/value pairs from cache
     *
     * @return {object}	Self
     */
    purgeAll: function purgeAll() {
      this.cache = {};
      return this;
    },
    /**
     * purge - Purges specific key name from cache
     *
     * @param	{string} keyName Key Name
     * @return {object}				 Self
     */
    purge: function purge(keyName) {
      var key = this.getKey(keyName);
      if (typeof this.cache[key] != 'undefined') delete this.cache[key];
      return this;
    }
  });
  Mura.datacache = new Mura.Cache();
}
module.exports = attach;

/***/ }),

/***/ 506:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  /**
  * Creates a new Mura.entities.Content
  * @name Mura.entities.Content
  * @class
  * @extends Mura.Entity
  * @memberof Mura
  * @param	{object} properties Object containing values to set into object
  * @return {Mura.entities.Content}
  */

  Mura.entities.Content = Mura.Entity.extend( /** @lends Mura.entities.Content.prototype */
  {
    /**
     * hasParent - Returns true if content has a parent.
     *
     * @return {boolean}
     */
    hasParent: function hasParent() {
      var parentid = this.get('parentid');
      return !(!parentid || ['00000000000000000000000000000000END', '00000000000000000000000000000000003', '00000000000000000000000000000000004', '00000000000000000000000000000000099'].find(function (value) {
        return value === parentid;
      }));
    },
    /**
     * updateFromDom - Updates editable data from what's in the DOM.
     *
     * @return {string}
     */
    updateFromDom: function updateFromDom() {
      var regions = this.get('displayregions');
      if (regions && _typeof(regions) === 'object') {
        Object.keys(regions).forEach(function (key) {
          var region = regions[key];
          if (region) {
            var items = [];
            Mura('.mura-region-local[data-regionid="' + region.regionid + '"]').forEach(function () {
              Mura(this).children('.mura-object[data-object]').forEach(function () {
                var obj = Mura(this);
                if (typeof Mura.displayObjectInstances[obj.data('instanceid')] != 'undefined') {
                  Mura.displayObjectInstances[obj.data('instanceid')].reset(obj, false);
                }
                items.push(Mura.cleanModuleProps(obj.data()));
              });
            });
            region.local.items = items;
          }
        });
      }
      var self = this;
      Mura('div.mura-object[data-targetattr]').each(function () {
        var obj = Mura(this);
        if (typeof Mura.displayObjectInstances[obj.data('instanceid')] != 'undefined') {
          Mura.displayObjectInstances[obj.data('instanceid')].reset(obj, false);
        }
        self.set(obj.data('targetattr'), Mura.cleanModuleProps(Mura(this).data()));
      });
      Mura('.mura-editable-attribute.inline').forEach(function () {
        var editable = Mura(this);
        var attributeName = editable.data('attribute');
        self.set(attributeName, editable.html());
      });
      return this;
    },
    /**
     * renderDisplayRegion - Returns a string with display region markup.
     *
     * @return {string}
     */
    renderDisplayRegion: function renderDisplayRegion(region) {
      return Mura.buildDisplayRegion(this.get('displayregions')[region]);
    },
    /**
     * dspRegion - Appends a display region to a element.
     *
     * @return {self}
     */
    dspRegion: function dspRegion(selector, region, label) {
      if (Mura.isNumeric(region) && region <= this.get('displayregionnames').length) {
        region = this.get('displayregionnames')[region - 1];
      }
      Mura(selector).processDisplayRegion(this.get('displayregions')[region], label);
      return this;
    },
    /**
     * getRelatedContent - Gets related content sets by name
     *
     * @param	{string} relatedContentSetName
     * @param	{object} params
     * @return {Mura.EntityCollection}
     */
    getRelatedContent: function getRelatedContent(relatedContentSetName, params) {
      var self = this;
      relatedContentSetName = relatedContentSetName || '';
      return new Promise(function (resolve, reject) {
        var query = [];
        params = params || {};
        params.siteid = self.get('siteid') || Mura.siteid;
        if (self.has('contenthistid') && self.get('contenthistid')) {
          params.contenthistid = self.get('contenthistid');
        }
        for (var key in params) {
          if (key != 'entityname' && key != 'filename' && key != 'siteid' && key != 'method') {
            query.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key]));
          }
        }
        self._requestcontext.request({
          type: 'get',
          url: self._requestcontext.getAPIEndpoint() + '/content/' + self.get('contentid') + '/relatedcontent/' + relatedContentSetName + '?' + query.join('&'),
          params: params,
          success: function success(resp) {
            if (typeof resp.data.items != 'undefined') {
              var returnObj = new Mura.EntityCollection(resp.data, self._requestcontext);
            } else {
              var returnObj = new Mura.Entity({
                siteid: Mura.siteid
              }, self._requestcontext);
              for (var p in resp.data) {
                if (resp.data.hasOwnProperty(p)) {
                  returnObj.set(p, new Mura.EntityCollection(resp.data[p], self._requestcontext));
                }
              }
            }
            if (typeof resolve == 'function') {
              resolve(returnObj);
            }
          },
          error: reject
        });
      });
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 791:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function _slicedToArray(arr, i) { return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _unsupportedIterableToArray(arr, i) || _nonIterableRest(); }
function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }
function _iterableToArrayLimit(arr, i) { var _i = arr == null ? null : typeof Symbol !== "undefined" && arr[Symbol.iterator] || arr["@@iterator"]; if (_i == null) return; var _arr = []; var _n = true; var _d = false; var _s, _e; try { for (_i = _i.call(arr); !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"] != null) _i["return"](); } finally { if (_d) throw _e; } } return _arr; }
function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }
function attach(Mura) {
  'use strict';

  /**
   * login - Logs user into Mura
   *
   * @param	{string} username Username
   * @param	{string} password Password
   * @param	{string} siteid	 Siteid
   * @return {Promise}
   * @memberof {class} Mura
   */
  function login(username, password, siteid) {
    return Mura.getRequestContext().login(username, password, siteid);
  }

  /**
   * logout - Logs user out
   *
   * @param	{type} siteid Siteid
   * @return {Promise}
   * @memberof {class} Mura
   */
  function logout(siteid) {
    return Mura.getRequestContext().logout(siteid);
  }

  /**
   * trackEvent - This is for Mura Experience Platform. It has no use with Mura standard
   *
   * @param	{object} data event data
   * @return {Promise}
   * @memberof {class} Mura
   */
  function trackEvent(data) {
    //This all needs to be cleaned up

    //Turn off metric when editing content, perhaps should be removed
    if (typeof Mura.editing != 'undefined' && Mura.editing) {
      return new Promise(function (resolve, reject) {
        resolve = resolve || function () {};
        resolve();
      });
    }
    var isMXP = typeof Mura.trackingVars != 'undefined';
    var instanceVars = {
      ga: {
        trackingvars: {}
      }
    };
    var gaFound = false;
    var trackingComplete = false;
    var attempt = 0;
    var eventData = {};
    eventData.category = data.event_category || data.eventCategory || data.category || '';
    eventData.name = data.event_action || data.eventAction || data.action || data.eventName || data.name || '';
    eventData.label = data.event_label || data.eventLabel || data.label || '';
    eventData.type = data.hit_type || data.hitType || data.type || 'event';
    eventData.value = data.event_value || data.eventValue || data.value || undefined;
    if (typeof data.nonInteraction == 'undefined') {
      eventData.nonInteraction = false;
    } else {
      eventData.nonInteraction = data.nonInteraction;
    }
    eventData.contentid = data.contentid || Mura.contentid;
    eventData.objectid = data.objectid || '';
    function track() {
      //Only happen the first time to coral data announce tracking event
      //Subsequent calls are ignored, as the tracking is already complete
      if (!attempt) {
        instanceVars.ga.trackingvars.eventCategory = eventData.category;
        instanceVars.ga.trackingvars.eventAction = eventData.name;
        instanceVars.ga.trackingvars.nonInteraction = eventData.nonInteraction;
        instanceVars.ga.trackingvars.hitType = eventData.type;
        if (typeof eventData.value != 'undefined' && Mura.isNumeric(eventData.value)) {
          instanceVars.ga.trackingvars.eventValue = eventData.value;
        }
        if (eventData.label) {
          instanceVars.ga.trackingvars.eventLabel = eventData.label;
        } else if (isMXP) {
          if (typeof instanceVars.object != 'undefined') {
            instanceVars.ga.trackingvars.eventLabel = instanceVars.object.title;
          } else {
            instanceVars.ga.trackingvars.eventLabel = instanceVars.content.title;
          }
          eventData.label = instanceVars.ga.trackingvars.eventLabel;
        }
        Mura(document).trigger('muraTrackEvent', instanceVars);
        Mura(document).trigger('muraRecordEvent', instanceVars);
      }

      //The method will keep trying to track until ga, gtag are found
      if (typeof gtag != 'undefined') {
        //swap out ga for gtag variables
        instanceVars.ga.trackingvars.event_category = instanceVars.ga.trackingvars.eventCategory;
        instanceVars.ga.trackingvars.event_action = instanceVars.ga.trackingvars.eventAction;
        instanceVars.ga.trackingvars.non_interaction = instanceVars.ga.trackingvars.nonInteraction;
        instanceVars.ga.trackingvars.hit_type = instanceVars.ga.trackingvars.hitType;
        instanceVars.ga.trackingvars.event_value = instanceVars.ga.trackingvars.eventValue;
        instanceVars.ga.trackingvars.event_label = instanceVars.ga.trackingvars.eventLabel;
        delete instanceVars.ga.trackingvars.eventCategory;
        delete instanceVars.ga.trackingvars.eventAction;
        delete instanceVars.ga.trackingvars.eventName;
        delete instanceVars.ga.trackingvars.nonInteraction;
        delete instanceVars.ga.trackingvars.hitType;
        delete instanceVars.ga.trackingvars.eventValue;
        delete instanceVars.ga.trackingvars.eventLabel;
        if (typeof Mura.trackingVars != 'undefined') {
          if (Mura.trackingVars.ga.trackingid) {
            instanceVars.ga.trackingvars.send_to = Mura.trackingVars.ga.trackingid;
            gtag('event', instanceVars.ga.trackingvars.event_action, instanceVars.ga.trackingvars);
          } else if (Mura.trackingVars.ga.measurementid) {
            instanceVars.ga.trackingvars.send_to = Mura.trackingVars.ga.measurementid;
            instanceVars.ga.trackingvars.event_name = instanceVars.ga.trackingvars.event_action;
            delete instanceVars.ga.trackingvars.event_action;
            gtag('event', instanceVars.ga.trackingvars.event_name, instanceVars.ga.trackingvars);
          }
        } else {
          instanceVars.ga.trackingvars.event_name = instanceVars.ga.trackingvars.event_action;
          gtag('event', instanceVars.ga.trackingvars.event_name, instanceVars.ga.trackingvars);
        }
        gaFound = true;
        trackingComplete = true;
      } else if (typeof ga != 'undefined') {
        if (isMXP) {
          ga('mxpGATracker.send', eventData.type, instanceVars.ga.trackingvars);
        } else {
          ga('send', eventData.type, instanceVars.ga.trackingvars);
        }
        gaFound = true;
        trackingComplete = true;
      }
      attempt++;
      if (!gaFound && attempt < 250) {
        setTimeout(track, 1);
      } else {
        trackingComplete = true;
      }
    }
    if (isMXP) {
      var trackingID = data.contentid + data.objectid;
      if (typeof Mura.trackingMetadata[trackingID] != 'undefined') {
        Mura.deepExtend(instanceVars, Mura.trackingMetadata[trackingID]);
        instanceVars.eventData = eventData;
        track();
      } else {
        Mura.get(Mura.getAPIEndpoint(), {
          method: 'findTrackingProps',
          siteid: Mura.siteid,
          contentid: eventData.contentid,
          objectid: eventData.objectid
        }).then(function (response) {
          Mura.deepExtend(instanceVars, response.data);
          instanceVars.eventData = data;
          for (var p in instanceVars.ga.trackingvars) {
            if (instanceVars.ga.trackingvars.hasOwnProperty(p) && p.substring(0, 1) == 'd' && typeof instanceVars.ga.trackingvars[p] != 'string') {
              instanceVars.ga.trackingvars[p] = new String(instanceVars.ga.trackingvars[p]);
            }
          }
          Mura.trackingMetadata[trackingID] = {};
          Mura.deepExtend(Mura.trackingMetadata[trackingID], response.data);
          track();
        });
      }
    } else {
      track();
    }
    return new Promise(function (resolve, reject) {
      resolve = resolve || function () {};
      function checkComplete() {
        if (trackingComplete) {
          resolve();
        } else {
          setTimeout(checkComplete, 1);
        }
      }
      checkComplete();
    });
  }

  /**
  * renderFilename - Returns "Rendered" JSON object of content
  *
  * @param	{type} filename Mura content filename
  * @param	{type} params Object
  * @return {Promise}
  * @memberof {class} Mura
  */
  function renderFilename(filename, params) {
    return Mura.getRequestContext().renderFilename(filename, params);
  }

  /**
   * declareEntity - Declare Entity with in service factory
   *
   * @param	{object} entityConfig Entity config object
   * @return {Promise}
   * @memberof {class} Mura
   */
  function declareEntity(entityConfig) {
    return Mura.getRequestContext().declareEntity(entityConfig);
  }

  /**
   * undeclareEntity - Deletes entity class from Mura
   *
   * @param	{object} entityName
   * @return {Promise}
   * @memberof {class} Mura
   */
  function undeclareEntity(entityName, deleteSchema) {
    deleteSchema = deleteSchema || false;
    return Mura.getRequestContext().undeclareEntity(entityName, deleteSchema);
  }

  /**
   * openGate - Open's content gate when using MXP
   *
   * @param	{string} contentid Optional: default's to Mura.contentid
   * @return {Promise}
   * @memberof {class} Mura
   */
  function openGate(contentid) {
    return Mura.getRequestContext().openGate(contentid);
  }

  /**
   * getEntity - Returns Mura.Entity instance
   *
   * @param	{string} entityname Entity Name
   * @param	{string} siteid		 Siteid
   * @return {Mura.Entity}
   * @memberof {class} Mura
   */
  function getEntity(entityname, siteid) {
    siteid = siteid || Mura.siteid;
    return Mura.getRequestContext().getEntity(entityname, siteid);
  }

  /**
   * getFeed - Return new instance of Mura.Feed
   *
   * @param	{type} entityname Entity name
   * @return {Mura.Feed}
   * @memberof {class} Mura
   */
  function getFeed(entityname, siteid) {
    siteid = siteid || Mura.siteid;
    return Mura.getRequestContext().getFeed(entityname, siteid);
  }

  /**
   * getCurrentUser - Return Mura.Entity for current user
   *
   * @param	{object} params Load parameters, fields:list of fields
   * @return {Promise}
   * @memberof {class} Mura
   */
  function getCurrentUser(params) {
    return new Promise(function (resolve, reject) {
      if (Mura.currentUser) {
        return resolve(Mura.currentUser);
      } else {
        Mura.getRequestContext().getCurrentUser(params).then(function (currentUser) {
          Mura.currentUser = currentUser;
          resolve(Mura.currentUser);
        }, function (currentUser) {
          Mura.currentUser = currentUser;
          resolve(Mura.currentUser);
        });
      }
    });
  }

  /**
   * findText - Return Mura.Collection for content with text
   *
   * @param	{object} params Load parameters
   * @return {Promise}
   * @memberof {class} Mura
   */
  function findText(text, params) {
    return Mura.getRequestContext().findText(text, params);
  }

  /**
   * findQuery - Returns Mura.EntityCollection with properties that match params
   *
   * @param	{object} params Object of matching params
   * @return {Promise}
   * @memberof {class} Mura
   */
  function findQuery(params) {
    return Mura.getRequestContext().findQuery(params);
  }
  function evalScripts(el) {
    if (typeof el == 'string') {
      el = parseHTML(el);
    }
    var scripts = [];
    var ret = el.childNodes;
    for (var i = 0; ret[i]; i++) {
      if (scripts && nodeName(ret[i], "script") && (!ret[i].type || ret[i].type.toLowerCase() === "text/javascript")) {
        if (ret[i].src) {
          scripts.push(ret[i]);
        } else {
          scripts.push(ret[i].parentNode ? ret[i].parentNode.removeChild(ret[i]) : ret[i]);
        }
      } else if (ret[i].nodeType == 1 || ret[i].nodeType == 9 || ret[i].nodeType == 11) {
        evalScripts(ret[i]);
      }
    }
    for (var $script in scripts) {
      evalScript(scripts[$script]);
    }
  }
  function evalScript(el) {
    if (el.src) {
      Mura.loader().load(el.src);
      Mura(el).remove();
    } else {
      var data = el.text || el.textContent || el.innerHTML || "";
      var head = document.getElementsByTagName("head")[0] || document.documentElement,
        script = document.createElement("script");
      script.type = "text/javascript";
      //script.appendChild( document.createTextNode( data ) );
      script.text = data;
      head.insertBefore(script, head.firstChild);
      head.removeChild(script);
      if (el.parentNode) {
        el.parentNode.removeChild(el);
      }
    }
  }
  function nodeName(el, name) {
    return el.nodeName && el.nodeName.toUpperCase() === name.toUpperCase();
  }
  function changeElementType(el, to) {
    var newEl = document.createElement(to);

    // Try to copy attributes across
    for (var i = 0, a = el.attributes, n = a.length; i < n; ++i) {
      el.setAttribute(a[i].name, a[i].value);
    }

    // Try to move children across
    while (el.hasChildNodes()) {
      newEl.appendChild(el.firstChild);
    }

    // Replace the old element with the new one
    el.parentNode.replaceChild(newEl, el);

    // Return the new element, for good measure.
    return newEl;
  }

  /*
  Defaults to holdReady is true so that everything
  is queued up until the DOMContentLoaded is fired
  */
  var holdingReady = true;
  var holdingReadyAltered = false;
  var holdingQueueReleased = false;
  var holdingQueue = [];
  var holdingPreInitQueue = [];

  /*
  if(typeof jQuery != 'undefined' && typeof jQuery.holdReady != 'undefined'){
  		jQuery.holdReady(true);
  }
  */

  /*
  When DOMContentLoaded is fired check to see it the
  holdingReady has been altered by custom code.
  If it hasn't then fire holding functions.
  */
  function initReadyQueue() {
    if (!holdingReadyAltered) {
      /*
      if(typeof jQuery != 'undefined' && typeof jQuery.holdReady != 'undefined'){
      		jQuery.holdReady(false);
      }
      */
      releaseReadyQueue();
    }
  }
  ;
  function releaseReadyQueue() {
    holdingQueueReleased = true;
    holdingReady = false;
    holdingQueue.forEach(function (fn) {
      readyInternal(fn);
    });
    holdingQueue = [];
  }
  function holdReady(hold) {
    if (!holdingQueueReleased) {
      holdingReady = hold;
      holdingReadyAltered = true;

      /*
      if(typeof jQuery != 'undefined' && typeof jQuery.holdReady != 'undefined'){
      		jQuery.holdReady(hold);
      }
      */

      if (!holdingReady) {
        releaseReadyQueue();
      }
    }
  }
  function ready(fn) {
    if (!holdingQueueReleased) {
      holdingQueue.push(fn);
    } else {
      readyInternal(fn);
    }
  }
  function readyInternal(fn) {
    if (typeof document != 'undefined') {
      if (document.readyState != 'loading') {
        //IE set the readyState to interative too early
        setTimeout(function () {
          fn(Mura);
        }, 1);
      } else {
        document.addEventListener('DOMContentLoaded', function () {
          fn(Mura);
        });
      }
    } else {
      fn(Mura);
    }
  }

  /**
   * get - Make GET request
   *
   * @param	{url} url	URL
   * @param	{object} data Data to send to url
   * @return {Promise}
   * @memberof {class} Mura
   */
  function get(url, data, config) {
    return Mura.getRequestContext().get(url, data, config);
  }

  /**
   * post - Make POST request
   *
   * @param	{url} url	URL
   * @param	{object} data Data to send to url
   * @return {Promise}
   * @memberof {class} Mura
   */
  function post(url, data, config) {
    return Mura.getRequestContext().post(url, data, config);
  }

  /**
   * put - Make PUT request
   *
   * @param	{url} url	URL
   * @param	{object} data Data to send to url
   * @return {Promise}
   * @memberof {class} Mura
   */
  function put(url, data, config) {
    return Mura.getRequestContext().put(url, data, config);
  }

  /**
   * update - Make UPDATE request
   *
   * @param	{url} url	URL
   * @param	{object} data Data to send to url
   * @return {Promise}
   * @memberof {class} Mura
   */
  function patch(url, data, config) {
    return Mura.getRequestContext().patch(url, data, config);
  }

  /**
   * delete - Make Delete request
   *
   * @param	{url} url	URL
   * @param	{object} data Data to send to url
   * @return {Promise}
   * @memberof {class} Mura
   */
  function deleteReq(url, data, config) {
    return Mura.getRequestContext().delete(url, data, config);
  }

  /**
   * ajax - Make ajax request
   *
   * @param	{object} params
   * @return {Promise}
   * @memberof {class} Mura
   */
  function ajax(config) {
    return Mura.getRequestContext().request(config);
  }

  /**
   * normalizeRequesConfig - Standardizes request handler objects
   *
   * @param	{object} config
   * @memberof {object} config
   */
  function normalizeRequestConfig(config) {
    /* 
    	Moving to native fetch whenever possible for beter next support
    	At this point we still use axios for file uploads
    */
    config.progress = config.progress || config.onProgress || config.onUploadProgress || false;
    config.download = config.download || config.onDownload || config.onDownloadProgress || false;
    config.abort = config.abort || config.onAbort || function () {};
    config.success = config.success || config.onSuccess || function () {};
    config.error = config.error || config.onError || function () {};
    config.headers = config.headers || {};
    config.type = config.type || 'get';
    config.next = config.next || {};
    config.cache = config.cache || 'default';
    var transformedHeaders = {};
    Object.entries(config.headers).forEach(function (_ref) {
      var _ref2 = _slicedToArray(_ref, 2),
        key = _ref2[0],
        value = _ref2[1];
      transformedHeaders[key.toLowerCase()] = value;
    });
    config.headers = transformedHeaders;
    if (typeof Mura.maxQueryStringLength != 'undefined') {
      config.maxQueryStringLength = config.maxQueryStringLength || Mura.maxQueryStringLength;
    }
    return config;
  }

  /**
   * getRequestContext - Returns a new Mura.RequestContext;
   *
   * @name getRequestContext
   * @param	{object} request		 Siteid
   * @param	{object} response Entity name
   * @return {Mura.RequestContext}	 Mura.RequestContext
   * @memberof {class} Mura
   */
  function getRequestContext(request, response, headers, siteid, endpoint, mode, renderMode) {
    //Logic aded to support single config object arg
    if (_typeof(request) === 'object' && typeof response === 'undefined') {
      var config = request;
      request = config.req;
      response = config.res;
      headers = config.headers;
      siteid = config.siteid;
      endpoint = config.endpoint;
      mode = config.mode;
      renderMode = config.renderMode;
    } else {
      if (typeof headers == 'string') {
        var originalSiteid = siteid;
        siteid = headers;
        if (_typeof(originalSiteid) === 'object') {
          headers = originalSiteid;
        } else {
          headers = {};
        }
      }
    }
    if (_typeof(headers) === 'object') {
      for (var h in headers) {
        if (headers.hasOwnProperty(h)) {
          headers[h.toLowerCase()] = headers[h];
        }
      }
    }
    request = request || Mura.request;
    response = response || Mura.response;
    endpoint = endpoint || Mura.getAPIEndpoint();
    mode = mode || Mura.getMode();
    renderMode = typeof renderMode != 'undefined' ? renderMode : Mura.getRenderMode();
    return new Mura.RequestContext(request, response, headers, siteid, endpoint, mode, renderMode);
  }

  /**
   * getDefaultRequestContext - Returns the default Mura.RequestContext;
   *
   * @name getDefaultRequestContext
   * @return {Mura.RequestContext}	 Mura.RequestContext
   * @memberof {class} Mura
   */
  function getDefaultRequestContext() {
    return Mura.getRequestContext();
  }

  /**
   * generateOAuthToken - Generate Outh toke for REST API
   *
   * @param	{string} grant_type	Grant type (Use client_credentials)
   * @param	{type} client_id		 Client ID
   * @param	{type} client_secret Secret Key
   * @return {Promise}
   * @memberof {class} Mura
   */
  function generateOAuthToken(grant_type, client_id, client_secret) {
    return new Promise(function (resolve, reject) {
      get(Mura.getAPIEndpoint().replace('/json/', '/rest/') + 'oauth?grant_type=' + encodeURIComponent(grant_type) + '&client_id=' + encodeURIComponent(client_id) + '&client_secret=' + encodeURIComponent(client_secret), {
        cache: 'no-cache'
      }).then(function (resp) {
        if (resp.data != 'undefined') {
          resolve(resp.data);
        } else {
          if (typeof resp.error != 'undefined' && typeof reject == 'function') {
            reject(resp);
          } else {
            resolve(resp);
          }
        }
      });
    });
  }
  function each(selector, fn) {
    select(selector).each(fn);
  }
  function on(el, eventName, fn) {
    if (eventName == 'ready') {
      Mura.ready(fn);
    } else {
      if (typeof el.addEventListener == 'function') {
        el.addEventListener(eventName, function (event) {
          if (typeof fn.call == 'undefined') {
            fn(event);
          } else {
            fn.call(el, event);
          }
        }, true);
      }
    }
  }
  function trigger(el, eventName, eventDetail) {
    if (typeof document != 'undefined') {
      var bubbles = eventName == "change" ? false : true;
      if (document.createEvent) {
        if (eventDetail && !isEmptyObject(eventDetail)) {
          var event = document.createEvent('CustomEvent');
          event.initCustomEvent(eventName, bubbles, true, eventDetail);
        } else {
          var eventClass = "";
          switch (eventName) {
            case "click":
            case "mousedown":
            case "mouseup":
              eventClass = "MouseEvents";
              break;
            case "focus":
            case "change":
            case "blur":
            case "select":
              eventClass = "HTMLEvents";
              break;
            default:
              eventClass = "Event";
              break;
          }
          var event = document.createEvent(eventClass);
          event.initEvent(eventName, bubbles, true);
        }
        event.synthetic = true;
        el.dispatchEvent(event);
      } else {
        try {
          document.fireEvent("on" + eventName);
        } catch (e) {
          console.warn("Event failed to fire due to legacy browser: on" + eventName);
        }
      }
    }
  }
  ;
  function off(el, eventName, fn) {
    el.removeEventListener(eventName, fn);
  }
  function parseSelection(selector) {
    if (_typeof(selector) == 'object' && Array.isArray(selector)) {
      var selection = selector;
    } else if (typeof selector == 'string') {
      var selection = nodeListToArray(document.querySelectorAll(selector));
    } else {
      if (typeof StaticNodeList != 'undefined' && selector instanceof StaticNodeList || typeof NodeList != 'undefined' && selector instanceof NodeList || typeof HTMLCollection != 'undefined' && selector instanceof HTMLCollection) {
        var selection = nodeListToArray(selector);
      } else {
        var selection = [selector];
      }
    }
    if (typeof selection.length == 'undefined') {
      selection = [];
    }
    return selection;
  }
  function isEmptyObject(obj) {
    return _typeof(obj) != 'object' || Object.keys(obj).length == 0;
  }
  function filter(selector, fn) {
    return select(parseSelection(selector)).filter(fn);
  }
  function nodeListToArray(nodeList) {
    var arr = [];
    for (var i = nodeList.length; i--; arr.unshift(nodeList[i])) {
      ;
    }
    return arr;
  }
  function select(selector) {
    return new Mura.DOMSelection(parseSelection(selector), selector);
  }
  function escapeHTML(str) {
    if (typeof document != 'undefined') {
      var div = document.createElement('div');
      div.appendChild(document.createTextNode(str));
      return div.innerHTML;
    } else {
      return Mura._escapeHTML(str);
    }
  }
  ;

  // UNSAFE with unsafe strings; only use on previously-escaped ones!
  function unescapeHTML(escapedStr) {
    var div = document.createElement('div');
    div.innerHTML = escapedStr;
    var child = div.childNodes[0];
    return child ? child.nodeValue : '';
  }
  ;
  function parseHTML(str) {
    var tmp = document.implementation.createHTMLDocument();
    tmp.body.innerHTML = str;
    return tmp.body.children;
  }
  ;
  function parseStringAsTemplate(stringValue) {
    var errors = {};
    var parsedString = stringValue;
    var doLoop = true;
    do {
      var finder = /(\${)(.+?)(})/.exec(parsedString);
      if (finder) {
        var template = void 0;
        try {
          template = eval('`${' + finder[2] + '}`');
        } catch (e) {
          console.log('error parsing string template: ' + '${' + finder[2] + '}', e);
          template = '[error]' + finder[2] + '[/error]';
        }
        parsedString = parsedString.replace(finder[0], template);
      } else {
        doLoop = false;
      }
    } while (doLoop);
    parsedString = parsedString.replace('[error]', '${');
    parsedString = parsedString.replace('[/error]', '}');
    return parsedString;
  }
  function getData(el) {
    var data = {};
    Array.prototype.forEach.call(el.attributes, function (attr) {
      if (/^data-/.test(attr.name)) {
        data[attr.name.substr(5)] = parseString(attr.value);
      }
    });
    return data;
  }
  function getProps(el) {
    return getData(el);
  }

  /**
   * isNumeric - Returns if the value is numeric
   *
   * @name isNumeric
   * @param	{*} val description
   * @return {boolean}
   * @memberof {class} Mura
   */
  function isNumeric(val) {
    return Number(parseFloat(val)) == val;
  }

  /**
  * buildDisplayRegion - Renders display region data returned from Mura.renderFilename()
  *
  * @param	{any} data Region data to build string from
  * @return {string}
  */
  function buildDisplayRegion(data) {
    if (typeof data == 'undefined') {
      return '';
    }
    var str = "<div class=\"mura-region\" data-regionid=\"" + escapeHTML(data.regionid) + "\">";
    function buildItemHeader(data) {
      var classes = data.class || '';
      var header = "<div class=\"mura-object " + escapeHTML(classes) + "\"";
      for (var p in data) {
        if (data.hasOwnProperty(p)) {
          if (_typeof(data[p]) == 'object') {
            header += " data-" + p + "=\'" + escapeHTML(JSON.stringify(data[p]).replace(/'/g, "&#39;")) + "\'";
          } else {
            header += " data-" + p + "=\"" + escapeHTML(data[p]).replace(/"/g, "&quot;") + "\"";
          }
        }
      }
      header += ">";
      return header;
    }
    function buildRegionSectionHeader(section, name, perm, regionid) {
      if (name) {
        if (section == 'inherited') {
          return "<div class=\"mura-region-inherited\"><div class=\"frontEndToolsModal mura\"><span class=\"mura-edit-label mi-lock\">" + escapeHTML(name.toUpperCase()) + ": Inherited</span></div>";
        } else {
          return "<div class=\"mura-editable mura-inactive\"><div class=\"mura-region-local mura-inactive mura-editable-attribute\" data-loose=\"false\" data-regionid=\"" + escapeHTML(regionid) + "\" data-inited=\"false\" data-perm=\"" + escapeHTML(perm) + "\"><label class=\"mura-editable-label\" style=\"display:none\">" + escapeHTML(name.toUpperCase()) + "</label>";
        }
      } else {
        return "<div class=\"mura-region-" + escapeHTML(section) + "\">";
      }
    }
    if (data.inherited.items.length) {
      if (data.inherited.header) {
        str += data.inherited.header;
      } else {
        str += buildRegionSectionHeader('inherited', data.name, data.inherited.perm, data.regionid);
      }
      for (var i in data.inherited.items) {
        if (data.inherited.items[i].header) {
          str += data.inherited.items[i].header;
        } else {
          str += buildItemHeader(data.inherited.items[i]);
        }
        if (typeof data.inherited.items[i].html != 'undefined' && data.inherited.items[i].html) {
          str += data.inherited.items[i].html;
        }
        if (data.inherited.items[i].footer) {
          str += data.inherited.items[i].footer;
        } else {
          str += "</div>";
        }
      }
      str += "</div>";
    }
    if (data.local.header) {
      str += data.local.header;
    } else {
      str += buildRegionSectionHeader('local', data.name, data.local.perm, data.regionid);
    }
    if (data.local.items.length) {
      for (var i in data.local.items) {
        if (data.local.items[i].header) {
          str += data.local.items[i].header;
        } else {
          str += buildItemHeader(data.local.items[i]);
        }
        if (typeof data.local.items[i].html != 'undefined' && data.local.items[i].html) {
          str += data.local.items[i].html;
        }
        if (data.local.items[i].footer) {
          str += data.local.items[i].footer;
        } else {
          str += '</div>';
        }
      }
    }
    //when editing the region header contains two divs
    if (data.name) {
      str += "</div></div>";
    } else {
      str += "</div>";
    }
    str += "</div>";
    return str;
  }
  function parseString(val) {
    if (typeof val == 'string') {
      var lcaseVal = val.toLowerCase();
      if (lcaseVal == 'false') {
        return false;
      } else if (lcaseVal == 'true') {
        return true;
      } else {
        if (!(typeof val == 'string' && val.length == 35) && isNumeric(val)) {
          var numVal = parseFloat(val);
          if (numVal == 0 || !isNaN(1 / numVal)) {
            return numVal;
          }
        }
        try {
          var testVal = JSON.parse.call(null, val);
          if (typeof testVal != 'string') {
            return testVal;
          } else {
            return val;
          }
        } catch (e) {
          return val;
        }
      }
    } else {
      return val;
    }
  }
  function getAttributes(el) {
    var data = {};
    Array.prototype.forEach.call(el.attributes, function (attr) {
      data[attr.name] = attr.value;
    });
    return data;
  }

  /**
   * formToObject - Returns if the value is numeric
   *
   * @name formToObject
   * @param	{form} form Form to serialize
   * @return {object}
   * @memberof {class} Mura
   */
  function formToObject(form) {
    var field,
      s = {};
    if (_typeof(form) == 'object' && form.nodeName == "FORM") {
      var len = form.elements.length;
      for (var i = 0; i < len; i++) {
        field = form.elements[i];
        if (field.name && !field.disabled && field.type != 'file' && field.type != 'reset' && field.type != 'submit' && field.type != 'button') {
          if (field.type == 'select-multiple') {
            var val = [];
            for (var j = form.elements[i].options.length - 1; j >= 0; j--) {
              if (field.options[j].selected) {
                val.push(field.options[j].value);
              }
            }
            s[field.name] = val.join(",");
          } else if (field.type != 'checkbox' && field.type != 'radio' || field.checked) {
            if (typeof s[field.name] == 'undefined') {
              s[field.name] = field.value;
            } else {
              s[field.name] = s[field.name] + ',' + field.value;
            }
          }
        }
      }
    }
    return s;
  }

  //http://youmightnotneedjquery.com/
  /**
   * extend - Extends object one level
   *
   * @name extend
   * @return {object}
   * @memberof {class} Mura
   */
  function extend(out) {
    out = out || {};
    for (var i = 1; i < arguments.length; i++) {
      if (!arguments[i]) continue;
      for (var key in arguments[i]) {
        if (key != '__proto__' && typeof arguments[i].hasOwnProperty != 'undefined' && arguments[i].hasOwnProperty(key)) out[key] = arguments[i][key];
      }
    }
    return out;
  }
  ;

  /**
   * deepExtend - Extends object to full depth
   *
   * @name deepExtend
   * @return {object}
   * @memberof {class} Mura
   */
  function deepExtend(out) {
    out = out || {};
    for (var i = 1; i < arguments.length; i++) {
      var obj = arguments[i];
      if (!obj) continue;
      for (var key in obj) {
        if (key != '__proto__' && typeof arguments[i].hasOwnProperty != 'undefined' && arguments[i].hasOwnProperty(key)) {
          if (Array.isArray(obj[key])) {
            out[key] = obj[key].slice(0);
          } else if (_typeof(obj[key]) === 'object') {
            out[key] = deepExtend({}, obj[key]);
          } else {
            out[key] = obj[key];
          }
        }
      }
    }
    return out;
  }

  /**
   * createCookie - Creates cookie
   *
   * @name createCookie
   * @param	{string} name	Name
   * @param	{*} value Value
   * @param	{number} days	Days
   * @return {void}
   * @memberof {class} Mura
   */
  function createCookie(name, value, days, domain) {
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
      var expires = "; expires=" + date.toGMTString();
    } else {
      var expires = "";
    }
    if (typeof location != 'undefined' && location.protocol == 'https:') {
      var secure = '; secure; samesite=None;';
    } else {
      var secure = '';
    }
    if (typeof domain != 'undefined') {
      domain = '; domain=' + domain;
    } else {
      domain = '';
    }
    document.cookie = name + "=" + value + expires + "; path=/" + secure + domain;
  }

  /**
   * readCookie - Reads cookie value
   *
   * @name readCookie
   * @param	{string} name Name
   * @return {*}
   * @memberof {class} Mura
   */
  function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1, c.length);
      }
      if (c.indexOf(nameEQ) == 0) return unescape(c.substring(nameEQ.length, c.length));
    }
    return "";
  }

  /**
   * eraseCookie - Removes cookie value
   *
   * @name eraseCookie
   * @param	{type} name description
   * @return {type}			description
   * @memberof {class} Mura
   */
  function eraseCookie(name) {
    createCookie(name, "", -1);
  }
  function $escape(value) {
    if (typeof encodeURIComponent != 'undefined') {
      return encodeURIComponent(value);
    } else {
      return escape(value).replace(new RegExp("\\+", "g"), "%2B").replace(/[\x00-\x1F\x7F-\x9F]/g, "");
    }
  }
  function $unescape(value) {
    return unescape(value);
  }

  //deprecated
  function addLoadEvent(func) {
    var oldonload = onload;
    if (typeof onload != 'function') {
      onload = func;
    } else {
      onload = function onload() {
        oldonload();
        func();
      };
    }
  }
  function noSpam(user, domain) {
    locationstring = "mailto:" + user + "@" + domain;
    location = locationstring;
  }

  /**
   * isUUID - description
   *
   * @name isUUID
   * @param	{*} value Value
   * @return {boolean}
   * @memberof {class} Mura
   */
  function isUUID(value) {
    if (typeof value == 'string' && (value.length == 35 && value[8] == '-' && value[13] == '-' && value[18] == '-' || value == '00000000000000000000000000000000001' || value == '00000000000000000000000000000000000' || value == '00000000000000000000000000000000003' || value == '00000000000000000000000000000000005' || value == '00000000000000000000000000000000099')) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * createUUID - Create UUID
   *
   * @name createUUID
   * @return {string}
   * @memberof {class} Mura
   */
  function createUUID() {
    var s = [],
      itoh = '0123456789ABCDEF';

    // Make array of random hex digits. The UUID only has 32 digits in it, but we
    // allocate an extra items to make room for the '-'s we'll be inserting.
    for (var i = 0; i < 35; i++) {
      s[i] = Math.floor(Math.random() * 0x10);
    }

    // Conform to RFC-4122, section 4.4
    s[14] = 4; // Set 4 high bits of time_high field to version
    s[19] = s[19] & 0x3 | 0x8; // Specify 2 high bits of clock sequence

    // Convert to hex chars
    for (var i = 0; i < 36; i++) {
      s[i] = itoh[s[i]];
    }

    // Insert '-'s
    s[8] = s[13] = s[18] = '-';
    return s.join('');
  }

  /**
   * setHTMLEditor - Set Html Editor
   *
   * @name setHTMLEditor
   * @param	{dom.element} el Dom Element
   * @return {void}
   * @memberof {class} Mura
   */
  function setHTMLEditor(el) {
    function initEditor() {
      var instance = CKEDITOR.instances[el.getAttribute('id')];
      var conf = {
        height: 200,
        width: '70%'
      };
      extend(conf, Mura(el).data());
      if (instance) {
        instance.destroy();
        CKEDITOR.remove(instance);
      }
      CKEDITOR.replace(el.getAttribute('id'), getHTMLEditorConfig(conf), htmlEditorOnComplete);
    }
    function htmlEditorOnComplete(editorInstance) {
      editorInstance.resetDirty();
      var totalIntances = CKEDITOR.instances;
    }
    function getHTMLEditorConfig(customConfig) {
      var attrname = '';
      var htmlEditorConfig = {
        toolbar: 'htmlEditor',
        customConfig: 'config.js.cfm'
      };
      if (_typeof(customConfig) == 'object') {
        extend(htmlEditorConfig, customConfig);
      }
      return htmlEditorConfig;
    }
    loader().loadjs(Mura.corepath + '/vendor/ckeditor/ckeditor.js', function () {
      initEditor();
    });
  }
  var commandKeyActive = false;
  var keyCmdCheck = function keyCmdCheck(event) {
    switch (event.which) {
      case 17: //ctrl
      case 27: //escape
      case 91:
        //cmd
        commandKeyActive = event.which;
        break;
      case 69:
        if (commandKeyActive) {
          event.preventDefault();
          Mura.editroute = Mura.editroute || "/";
          var inEditRoute = typeof location.pathname.startsWith != 'undefined' && location.pathname.startsWith(Mura.editroute);
          if (inEditRoute && typeof MuraInlineEditor != 'undefined') {
            MuraInlineEditor.init();
          } else {
            var params = getQueryStringParams(location.search);
            if (typeof params.editlayout == 'undefined') {
              Mura.editroute = Mura.editroute || '';
              if (Mura.editroute) {
                if (inEditRoute) {
                  if (typeof params.previewid != 'undefined') {
                    location.href = Mura.editroute + location.pathname + "?previewid=" + params.previewid;
                  }
                } else {
                  if (typeof params.previewid != 'undefined') {
                    location.href = Mura.editroute + location.pathname + "?previewid=" + params.previewid;
                  } else {
                    location.href = Mura.editroute + location.pathname;
                  }
                }
              }
            }
          }
        }
        break;
      case 76:
        if (commandKeyActive) {
          event.preventDefault();
          var params = getQueryStringParams(location.search);
          if (params.display != 'login') {
            var lu = '';
            var ru = '';
            if (typeof Mura.loginURL != "undefined") {
              lu = Mura.loginURL;
            } else if (typeof Mura.loginurl != "undefined") {
              lu = Mura.loginurl;
            } else {
              lu = "?display=login";
            }
            if (typeof Mura.returnURL != "undefined") {
              ru = Mura.returnURL;
            } else if (typeof Mura.returnurl != "undefined") {
              ru = Mura.returnurl;
            } else {
              ru = location.href;
            }
            lu = new String(lu);
            if (lu.indexOf('?') != -1) {
              location.href = lu + "&returnUrl=" + encodeURIComponent(ru);
            } else {
              location.href = lu + "?returnUrl=" + encodeURIComponent(ru);
            }
          }
        }
        break;
      default:
        commandKeyActive = false;
        break;
    }
  };

  /**
   * isInteger - Returns if the value is an integer
   *
   * @name isInteger
   * @param	{*} Value to check
   * @return {boolean}
   * @memberof {class} Mura
   */
  function isInteger(s) {
    var i;
    for (i = 0; i < s.length; i++) {
      // Check that current character is number.
      var c = s.charAt(i);
      if (c < "0" || c > "9") return false;
    }
    // All characters are numbers.
    return true;
  }
  function createDate(str) {
    var valueArray = str.split("/");
    var mon = valueArray[0];
    var dt = valueArray[1];
    var yr = valueArray[2];
    var date = new Date(yr, mon - 1, dt);
    if (!isNaN(date.getMonth())) {
      return date;
    } else {
      return new Date();
    }
  }
  function dateToString(date) {
    var mon = date.getMonth() + 1;
    var dt = date.getDate();
    var yr = date.getFullYear();
    if (mon < 10) {
      mon = "0" + mon;
    }
    if (dt < 10) {
      dt = "0" + dt;
    }
    return mon + "/" + dt + "/20" + new String(yr).substring(2, 4);
  }
  function stripCharsInBag(s, bag) {
    var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++) {
      var c = s.charAt(i);
      if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
  }
  function daysInFebruary(year) {
    // February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return year % 4 == 0 && (!(year % 100 == 0) || year % 400 == 0) ? 29 : 28;
  }
  function DaysArray(n) {
    for (var i = 1; i <= n; i++) {
      this[i] = 31;
      if (i == 4 || i == 6 || i == 9 || i == 11) {
        this[i] = 30;
      }
      if (i == 2) {
        this[i] = 29;
      }
    }
    return this;
  }

  /**
   * generateDateFormat - dateformt for input type="date"
   *
   * @name generateDateFormat
   * @return {string}
   */
  function generateDateFormat(dtStr, fldName) {
    var formatArray = ['mm', 'dd', 'yyyy'];
    return [formatArray[Mura.dtformat[0]], formatArray[Mura.dtformat[1]], formatArray[Mura.dtformat[2]]].join(Mura.dtch);
  }

  /**
   * isDate - Returns if the value is a data
   *
   * @name isDate
   * @param	{*}	Value to check
   * @return {boolean}
   * @memberof {class} Mura
   */
  function isDate(dtStr, fldName) {
    var daysInMonth = DaysArray(12);
    var dtArray = dtStr.split(Mura.dtch);
    if (dtArray.length != 3) {
      //alert("The date format for the "+fldName+" field should be : short")
      return false;
    }
    var strMonth = dtArray[Mura.dtformat[0]];
    var strDay = dtArray[Mura.dtformat[1]];
    var strYear = dtArray[Mura.dtformat[2]];

    /*
    if(strYear.length == 2){
    	strYear="20" + strYear;
    }
    */
    strYr = strYear;
    if (strDay.charAt(0) == "0" && strDay.length > 1) strDay = strDay.substring(1);
    if (strMonth.charAt(0) == "0" && strMonth.length > 1) strMonth = strMonth.substring(1);
    for (var i = 1; i <= 3; i++) {
      if (strYr.charAt(0) == "0" && strYr.length > 1) strYr = strYr.substring(1);
    }
    month = parseInt(strMonth);
    day = parseInt(strDay);
    year = parseInt(strYr);
    if (month < 1 || month > 12) {
      //alert("Please enter a valid month in the "+fldName+" field")
      return false;
    }
    if (day < 1 || day > 31 || month == 2 && day > daysInFebruary(year) || day > daysInMonth[month]) {
      //alert("Please enter a valid day	in the "+fldName+" field")
      return false;
    }
    if (strYear.length != 4 || year == 0 || year < Mura.minYear || year > Mura.maxYear) {
      //alert("Please enter a valid 4 digit year between "+Mura.minYear+" and "+Mura.maxYear +" in the "+fldName+" field")
      return false;
    }
    if (isInteger(stripCharsInBag(dtStr, Mura.dtch)) == false) {
      //alert("Please enter a valid date in the "+fldName+" field")
      return false;
    }
    return true;
  }

  /**
   * isEmail - Returns if value is valid email
   *
   * @param	{string} str String to parse for email
   * @return {boolean}
   * @memberof {class} Mura
   */
  function isEmail(e) {
    return /^[a-zA-Z_0-9-'\+~]+(\.[a-zA-Z_0-9-'\+~]+)*@([a-zA-Z_0-9-]+\.)+[a-zA-Z]{2,8}$/.test(e);
  }
  function initShadowBox(el) {
    if (typeof window == 'undefined' || typeof window.document == 'undefined') {
      return;
    }
    ;
    if (Mura(el).find('[data-rel^="shadowbox"],[rel^="shadowbox"]').length) {
      loader().load([Mura.context + '/core/modules/v1/core_assets/css/shadowbox.min.css', Mura.context + '/core/modules/v1/core_assets/js/shadowbox.js'], function () {
        Mura('#shadowbox_overlay,#shadowbox_container').remove();
        window.Shadowbox.init();
      });
    }
  }

  /**
   * validateForm - Validates Mura form
   *
   * @name validateForm
   * @param	{type} frm					Form element to validate
   * @param	{function} customaction Custom action (optional)
   * @return {boolean}
   * @memberof {class} Mura
   */
  function validateForm(frm, customaction) {
    function getValidationFieldName(theField) {
      if (theField.getAttribute('data-label') != undefined) {
        return theField.getAttribute('data-label');
      } else if (theField.getAttribute('label') != undefined) {
        return theField.getAttribute('label');
      } else {
        return theField.getAttribute('name');
      }
    }
    function getValidationIsRequired(theField) {
      if (theField.getAttribute('data-required') != undefined) {
        return theField.getAttribute('data-required').toLowerCase() == 'true';
      } else if (theField.getAttribute('required') != undefined) {
        return theField.getAttribute('required').toLowerCase() == 'true';
      } else {
        return false;
      }
    }
    function getValidationMessage(theField, defaultMessage) {
      if (theField.getAttribute('data-message') != undefined) {
        return theField.getAttribute('data-message');
      } else if (theField.getAttribute('message') != undefined) {
        return theField.getAttribute('message');
      } else {
        return getValidationFieldName(theField).toUpperCase() + defaultMessage;
      }
    }
    function getValidationType(theField) {
      if (theField.getAttribute('data-validate') != undefined) {
        return theField.getAttribute('data-validate').toUpperCase();
      } else if (theField.getAttribute('validate') != undefined) {
        return theField.getAttribute('validate').toUpperCase();
      } else {
        return '';
      }
    }
    function hasValidationMatchField(theField) {
      if (theField.getAttribute('data-matchfield') != undefined && theField.getAttribute('data-matchfield') != '') {
        return true;
      } else if (theField.getAttribute('matchfield') != undefined && theField.getAttribute('matchfield') != '') {
        return true;
      } else {
        return false;
      }
    }
    function getValidationMatchField(theField) {
      if (theField.getAttribute('data-matchfield') != undefined) {
        return theField.getAttribute('data-matchfield');
      } else if (theField.getAttribute('matchfield') != undefined) {
        return theField.getAttribute('matchfield');
      } else {
        return '';
      }
    }
    function hasValidationRegex(theField) {
      if (theField.value != undefined) {
        if (theField.getAttribute('data-regex') != undefined && theField.getAttribute('data-regex') != '') {
          return true;
        } else if (theField.getAttribute('regex') != undefined && theField.getAttribute('regex') != '') {
          return true;
        }
      } else {
        return false;
      }
    }
    function getValidationRegex(theField) {
      if (theField.getAttribute('data-regex') != undefined) {
        return theField.getAttribute('data-regex');
      } else if (theField.getAttribute('regex') != undefined) {
        return theField.getAttribute('regex');
      } else {
        return '';
      }
    }
    var theForm = frm;
    var errors = "";
    var setFocus = 0;
    var started = false;
    var startAt;
    var firstErrorNode;
    var validationType = '';
    var validations = {
      properties: {}
    };
    var frmInputs = theForm.getElementsByTagName("input");
    var rules = new Array();
    var data = {};
    var $customaction = customaction;
    for (var f = 0; f < frmInputs.length; f++) {
      var theField = frmInputs[f];
      validationType = getValidationType(theField).toUpperCase();
      rules = new Array();
      if (theField.style.display == "") {
        if (getValidationIsRequired(theField)) {
          rules.push({
            required: true,
            message: getValidationMessage(theField, ' is required.')
          });
        }
        if (validationType != '') {
          if (validationType == 'EMAIL' && theField.value != '') {
            rules.push({
              dataType: 'EMAIL',
              message: getValidationMessage(theField, ' must be a valid email address.')
            });
          } else if (validationType == 'NUMERIC' && theField.value != '') {
            rules.push({
              dataType: 'NUMERIC',
              message: getValidationMessage(theField, ' must be numeric.')
            });
          } else if (validationType == 'REGEX' && theField.value != '' && hasValidationRegex(theField)) {
            rules.push({
              regex: getValidationRegex(theField),
              message: getValidationMessage(theField, ' is not valid.')
            });
          } else if (validationType == 'MATCH' && hasValidationMatchField(theField) && theField.value != theForm[getValidationMatchField(theField)].value) {
            rules.push({
              eq: theForm[getValidationMatchField(theField)].value,
              message: getValidationMessage(theField, ' must match' + getValidationMatchField(theField) + '.')
            });
          } else if (validationType == 'DATE' && theField.value != '') {
            rules.push({
              dataType: 'DATE',
              message: getValidationMessage(theField, ' must be a valid date [MM/DD/YYYY].')
            });
          }
        }
        if (rules.length) {
          validations.properties[theField.getAttribute('name')] = rules;

          //if(!Array.isArray(data[theField.getAttribute('name')])){
          data[theField.getAttribute('name')] = [];
          //}

          for (var v = 0; v < frmInputs.length; v++) {
            if (frmInputs[v].getAttribute('name') == theField.getAttribute('name')) {
              if (frmInputs[v].getAttribute('type').toLowerCase() == 'checkbox' || frmInputs[v].getAttribute('type').toLowerCase() == 'radio') {
                if (frmInputs[v].checked) {
                  data[theField.getAttribute('name')].push(frmInputs[v].value);
                }
              } else if (typeof frmInputs[v].value != 'undefined' && frmInputs[v].value != '') {
                data[theField.getAttribute('name')].push(frmInputs[v].value);
              }
            }
          }
        }
      }
    }
    for (var p in data) {
      if (data.hasOwnProperty(p)) {
        data[p] = data[p].join();
      }
    }
    var frmTextareas = theForm.getElementsByTagName("textarea");
    for (f = 0; f < frmTextareas.length; f++) {
      theField = frmTextareas[f];
      validationType = getValidationType(theField);
      rules = new Array();
      if (theField.style.display == "" && getValidationIsRequired(theField)) {
        rules.push({
          required: true,
          message: getValidationMessage(theField, ' is required.')
        });
      } else if (validationType != '') {
        if (validationType == 'REGEX' && theField.value != '' && hasValidationRegex(theField)) {
          rules.push({
            regex: getValidationRegex(theField),
            message: getValidationMessage(theField, ' is not valid.')
          });
        }
      }
      if (rules.length) {
        validations.properties[theField.getAttribute('name')] = rules;
        data[theField.getAttribute('name')] = theField.value;
      }
    }
    var frmSelects = theForm.getElementsByTagName("select");
    for (f = 0; f < frmSelects.length; f++) {
      theField = frmSelects[f];
      validationType = getValidationType(theField);
      rules = new Array();
      if (theField.style.display == "" && getValidationIsRequired(theField)) {
        rules.push({
          required: true,
          message: getValidationMessage(theField, ' is required.')
        });
      }
      if (rules.length) {
        validations.properties[theField.getAttribute('name')] = rules;
        data[theField.getAttribute('name')] = theField.value;
      }
    }
    try {
      //alert(JSON.stringify(validations));
      //console.log(data);
      //console.log(validations);
      ajax({
        type: 'post',
        url: Mura.getAPIEndpoint() + '?method=validate',
        data: {
          data: encodeURIComponent(JSON.stringify(data)),
          validations: encodeURIComponent(JSON.stringify(validations)),
          version: 4
        },
        success: function success(resp) {
          data = resp.data;
          if (Object.keys(data).length === 0) {
            if (typeof $customaction == 'function') {
              $customaction(theForm);
              return false;
            } else {
              document.createElement('form').submit.call(theForm);
            }
          } else {
            var msg = '';
            for (var e in data) {
              msg = msg + data[e] + '\n';
            }
            alert(msg);
          }
        },
        error: function error(resp) {
          alert(JSON.stringify(resp));
        }
      });
    } catch (err) {
      console.log(err);
    }
    return false;
  }
  function setLowerCaseKeys(obj) {
    for (var key in obj) {
      if (key !== key.toLowerCase()) {
        // might already be in its lower case version
        obj[key.toLowerCase()] = obj[key]; // swap the value to a new lower case key
        delete obj[key]; // delete the old key
      }

      if (_typeof(obj[key.toLowerCase()]) == 'object') {
        setLowerCaseKeys(obj[key.toLowerCase()]);
      }
    }
    return obj;
  }
  function isScrolledIntoView(el) {
    if (typeof window == 'undefined' || typeof window.document == 'undefined' || window.innerHeight) {
      true;
    }
    try {
      var elemTop = el.getBoundingClientRect().top;
      var elemBottom = el.getBoundingClientRect().bottom;
    } catch (e) {
      return true;
    }
    var isVisible = elemTop < window.innerHeight && elemBottom >= 0;
    return isVisible;
  }

  /**
   * loader - Returns Mura.Loader
   *
   * @name loader
   * @return {Mura.Loader}
   * @memberof {class} Mura
   */
  function loader() {
    return Mura.ljs;
  }
  var layoutmanagertoolbar = '<span class="mura-fetborder mura-fetborder-left"></span><span class="mura-fetborder mura-fetborder-right"></span><span class="mura-fetborder mura-fetborder-top"></span><span class="mura-fetborder mura-fetborder-bottom"></span><div class="frontEndToolsModal mura"><span class="mura-edit-icon"></span><span class="mura-edit-label"></span></div>';
  function processMarkup(scope) {
    return new Promise(function (resolve, reject) {
      if (!(scope instanceof Mura.DOMSelection)) {
        scope = select(scope);
      }
      function find(selector) {
        return scope.find(selector);
      }
      var processors = [function () {
        //if layout manager UI exists check for rendered regions and remove them from additional regions
        if (Mura('.mura__layout-manager__display-regions').length) {
          find('.mura-region').each(function (el) {
            var region = Mura(el);
            if (!region.closest('.mura__layout-manager__display-regions').length) {
              Mura('.mura-region__item[data-regionid="' + region.data('regionid') + '"]').remove();
            }
          });
          if (!Mura('.mura__layout-manager__display-regions .mura-region__item').length) {
            Mura('#mura-objects-openregions-btn, .mura__layout-manager__display-regions').remove();
          }
        }
      }, function () {
        find('.mura-object, .mura-async-object').each(function (el) {
          if (scope == document) {
            var obj = Mura(el);
            if (!obj.parent().closest('.mura-object').length) {
              processDisplayObject(this, Mura.queueobjects).then(resolve);
            }
          } else {
            processDisplayObject(el, Mura.queueobjects).then(resolve);
          }
        });
      }, function () {
        find(".htmlEditor").each(function (el) {
          setHTMLEditor(el);
        });
      }, function () {
        if (find(".cffp_applied,	.cffp_mm, .cffp_kp").length) {
          var fileref = document.createElement('script');
          fileref.setAttribute("type", "text/javascript");
          fileref.setAttribute("src", Mura.corepath + '/vendor/cfformprotect/js/cffp.js');
          document.getElementsByTagName("head")[0].appendChild(fileref);
        }
      }, function () {
        Mura.reCAPTCHALanguage = Mura.reCAPTCHALanguage || 'en';
        if (find(".g-recaptcha-container").length) {
          loader().loadjs("https://www.recaptcha.net/recaptcha/api.js?onload=MuraCheckForReCaptcha&render=explicit&hl=" + Mura.reCAPTCHALanguage, function () {
            find(".g-recaptcha-container").each(function (el) {
              var notready = 0;
              ;
              window.MuraCheckForReCaptcha = function () {
                Mura('.g-recaptcha-container').each(function () {
                  var self = this;
                  if ((typeof grecaptcha === "undefined" ? "undefined" : _typeof(grecaptcha)) == 'object' && typeof grecaptcha.render != 'undefined' && !self.innerHTML) {
                    self.setAttribute('data-widgetid', grecaptcha.render(self.getAttribute('id'), {
                      'sitekey': self.getAttribute('data-sitekey'),
                      'theme': self.getAttribute('data-theme'),
                      'type': self.getAttribute('data-type')
                    }));
                  } else {
                    notready++;
                  }
                });
                if (notready) {
                  setTimeout(function () {
                    window.MuraCheckForReCaptcha();
                  }, 10);
                }
              };
              window.MuraCheckForReCaptcha();
            });
          });
        }
      }, function () {
        if (typeof resizeEditableObject == 'function') {
          scope.closest('.editableObject').each(function (el) {
            resizeEditableObject(el);
          });
          find(".editableObject").each(function (el) {
            resizeEditableObject(el);
          });
        }
      }, function () {
        if (Mura.handleObjectClick == 'function') {
          find('.mura-object, .frontEndToolsModal').on('click', Mura.handleObjectClick);
        }
        if (typeof window != 'undefined' && typeof window.document != 'undefined' && window.MuraInlineEditor && window.MuraInlineEditor.checkforImageCroppers) {
          find("img").each(function (el) {
            window.muraInlineEditor.checkforImageCroppers(el);
          });
        }
      }, function () {
        initShadowBox(scope.node);
      }];
      for (var h = 0; h < processors.length; h++) {
        processors[h]();
      }
    });
  }
  function addEventHandler(eventName, fn) {
    if (_typeof(eventName) == 'object') {
      for (var h in eventName) {
        if (eventName.hasOwnProperty(h)) {
          on(document, h, eventName[h]);
        }
      }
    } else {
      on(document, eventName, fn);
    }
  }
  function submitForm(frm, obj) {
    frm = frm.node ? frm.node : frm;
    if (obj) {
      obj = obj.node ? obj : Mura(obj);
    } else {
      obj = Mura(frm).closest('.mura-async-object');
    }
    if (!obj.length) {
      Mura(frm).trigger('formSubmit', formToObject(frm));
      frm.submit();
    }
    if (frm.getAttribute('enctype') == 'multipart/form-data') {
      var data = new FormData(frm);
      var checkdata = setLowerCaseKeys(formToObject(frm));
      var keys = filterUnwantedParams(deepExtend(setLowerCaseKeys(obj.data()), urlparams, {
        siteid: Mura.siteid,
        contentid: Mura.contentid,
        contenthistid: Mura.contenthistid,
        nocache: 1
      }));
      if (obj.data('siteid')) {
        keys.siteid = obj.data('siteid');
      }
      for (var k in keys) {
        if (!(k in checkdata)) {
          data.append(k, keys[k]);
        }
      }
      if ('objectparams' in checkdata) {
        data.append('objectparams2', encodeURIComponent(JSON.stringify(obj.data('objectparams'))));
      }
      if ('nocache' in checkdata) {
        data.append('nocache', 1);
      }
      var postconfig = {
        url: Mura.getAPIEndpoint() + '?method=processAsyncObject',
        type: 'POST',
        data: data,
        success: function success(resp) {
          //console.log(data.object,resp)
          setTimeout(function () {
            handleResponse(obj, resp);
          }, 0);
        }
      };
    } else {
      var data = filterUnwantedParams(deepExtend(setLowerCaseKeys(obj.data()), urlparams, setLowerCaseKeys(formToObject(frm)), {
        siteid: Mura.siteid,
        contentid: Mura.contentid,
        contenthistid: Mura.contenthistid,
        nocache: 1
      }));
      if (obj.data('siteid')) {
        data.siteid = obj.data('siteid');
      }
      if (data.object == 'container' && data.content) {
        delete data.content;
      }
      if (!('g-recaptcha-response' in data)) {
        var reCaptchaCheck = Mura(frm).find("#g-recaptcha-response");
        if (reCaptchaCheck.length && typeof reCaptchaCheck.val() != 'undefined') {
          data['g-recaptcha-response'] = eCaptchaCheck.val();
        }
      }
      if ('objectparams' in data) {
        data['objectparams'] = encodeURIComponent(JSON.stringify(data['objectparams']));
      }
      var postconfig = {
        url: Mura.getAPIEndpoint() + '?method=processAsyncObject',
        type: 'POST',
        data: data,
        success: function success(resp) {
          //console.log(data.object,resp)
          setTimeout(function () {
            handleResponse(obj, resp);
          }, 0);
        }
      };
    }
    var self = obj.node;
    self.prevInnerHTML = self.innerHTML;
    self.prevData = filterUnwantedParams(obj.data());
    if (typeof self.prevData != 'undefined' && typeof self.prevData.preloadermarkup != 'undefined') {
      self.innerHTML = self.prevData.preloadermarkup;
    } else {
      self.innerHTML = Mura.preloadermarkup;
    }
    Mura(frm).trigger('formSubmit', data);
    ajax(postconfig);
  }
  function firstToUpperCase(str) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
  }
  function firstToLowerCase(str) {
    return str.substr(0, 1).toLowerCase() + str.substr(1);
  }
  function cleanModuleProps(obj) {
    if (obj) {
      var dataTargets = ['runtime', 'perm', 'startrow', 'pagenum', 'pageidx', 'nextnid', 'purgecache', 'origininstanceid'];
      if (typeof obj.removeAttr == 'function') {
        dataTargets.forEach(function (item) {
          obj.removeAttr('data-' + item);
        });
        if (obj.hasAttr('data-cachedwithin') && !obj.attr('data-cachedwithin')) {
          obj.removeAttr('data-cachedwithin');
        }
      } else {
        dataTargets.forEach(function (item) {
          if (typeof obj[item] != 'undefined') {
            delete obj[item];
          }
        });
        delete obj.inited;
      }
    }
    return obj;
  }
  function resetAsyncObject(el, empty) {
    var self = Mura(el);
    if (self.data('transient')) {
      self.remove();
    } else {
      if (typeof empty == 'undefined') {
        empty = true;
      }
      cleanModuleProps(self);
      if (empty) {
        self.removeAttr('data-inited');
      }
      var data = self.data();
      for (var p in data) {
        if (data.hasOwnProperty(p) && (typeof p == 'undefined' || data[p] === '')) {
          self.removeAttr('data-' + p);
        }
      }
      if (typeof Mura.displayObjectInstances[self.data('instanceid')] != 'undefined') {
        Mura.displayObjectInstances[self.data('instanceid')].reset(self, empty);
      }
      if (empty) {
        self.html('');
      }
    }
  }
  function processAsyncObject(el, usePreloaderMarkup) {
    var obj = Mura(el);
    if (obj.data('async') === null) {
      obj.data('async', true);
    }
    if (typeof usePreloaderMarkup == 'undefined') {
      usePreloaderMarkup = true;
    }
    return processDisplayObject(obj, false, true, false, usePreloaderMarkup);
  }
  function filterUnwantedParams(params) {
    //Strip out unwanted attributes
    var unwanted = ['iconclass', 'objectname', 'inited', 'params', 'stylesupport', 'cssstyles', 'metacssstyles', 'contentcssstyles', 'cssclass', 'cssid', 'metacssclass', 'metacssid', 'contentcssclass', 'contentcssid', 'transient', 'draggable', 'objectspacing', 'metaspacing', 'contentspacing'];
    for (var c = 0; c < unwanted.length; c++) {
      delete params[unwanted[c]];
    }
    return params;
  }
  function destroyDisplayObjects() {
    for (var property in Mura.displayObjectInstances) {
      if (Mura.displayObjectInstances.hasOwnProperty(property)) {
        var obj = Mura.displayObjectInstances[property];
        if (typeof obj.destroy == 'function') {
          obj.destroy();
        }
        delete Mura.displayObjectInstances[property];
      }
    }
  }
  function destroyModules() {
    destroyDisplayObjects();
  }
  function wireUpObject(obj, response, attempt) {
    attempt = attempt || 0;
    attempt++;
    obj = obj.node ? obj : Mura(obj);
    obj.data('inited', true);
    if (response) {
      if (typeof response == 'string') {
        obj.html(trim(response));
      } else if (typeof response.html == 'string' && response.render != 'client') {
        obj.html(trim(response.html));
        if (response.render == 'server') {
          obj.data('render', 'server');
        }
      } else {
        var context = filterUnwantedParams(deepExtend(obj.data(), response));
        var template = obj.data('clienttemplate') || obj.data('object');
        var properNameCheck = firstToUpperCase(template);
        if (typeof Mura.DisplayObject[properNameCheck] != 'undefined') {
          template = properNameCheck;
        }
        if (typeof context.async != 'undefined') {
          obj.data('async', context.async);
        }
        if (typeof context.render != 'undefined') {
          obj.data('render', context.render);
        }
        if (typeof context.rendertemplate != 'undefined') {
          obj.data('rendertemplate', context.rendertemplate);
        }
        if (typeof Mura.DisplayObject[template] != 'undefined') {
          context.html = '';
          if (typeof Mura.displayObjectInstances[obj.data('instanceid')] != 'undefined') {
            Mura.displayObjectInstances[obj.data('instanceid')].destroy();
          }
          obj.html(Mura.templates.content({
            html: ''
          }));
          obj.prepend(Mura.templates.meta(context));
          context.targetEl = obj.children('.mura-object-content').node;
          Mura.displayObjectInstances[obj.data('instanceid')] = new Mura.DisplayObject[template](context);
          Mura.displayObjectInstances[obj.data('instanceid')].trigger('beforeRender');
          Mura.displayObjectInstances[obj.data('instanceid')].renderClient();
        } else if (typeof Mura.templates[template] != 'undefined') {
          context.html = '';
          obj.html(Mura.templates.content(context));
          obj.prepend(Mura.templates.meta(context));
          context.targetEl = obj.children('.mura-object-content').node;
          Mura.templates[template](context);
        } else {
          if (attempt < 1000) {
            setTimeout(function () {
              wireUpObject(obj, response, attempt);
            }, 1);
          } else {
            console.log('Missing Client Template for:');
            console.log(obj.data());
          }
        }
      }
    } else {
      var context = filterUnwantedParams(obj.data());
      var template = obj.data('clienttemplate') || obj.data('object');
      var properNameCheck = firstToUpperCase(template);
      if (typeof Mura.DisplayObject[properNameCheck] != 'undefined') {
        template = properNameCheck;
      }
      if (typeof Mura.DisplayObject[template] == 'function') {
        context.html = '';
        if (typeof Mura.displayObjectInstances[obj.data('instanceid')] != 'undefined') {
          Mura.displayObjectInstances[obj.data('instanceid')].destroy();
        }
        obj.html(Mura.templates.content({
          html: ''
        }));
        obj.prepend(Mura.templates.meta(context));
        context.targetEl = obj.children('.mura-object-content').node;
        Mura.displayObjectInstances[obj.data('instanceid')] = new Mura.DisplayObject[template](context);
        Mura.displayObjectInstances[obj.data('instanceid')].trigger('beforeRender');
        Mura.displayObjectInstances[obj.data('instanceid')].renderClient();
      } else if (typeof Mura.templates[template] != 'undefined') {
        context.html = '';
        obj.html(Mura.templates.content(context));
        obj.prepend(Mura.templates.meta(context));
        context.targetEl = obj.children('.mura-object-content').node;
        Mura.templates[template](context);
      } else {
        if (attempt < 1000) {
          setTimeout(function () {
            wireUpObject(obj, response, attempt);
          }, 1);
        } else {
          console.log('Missing Client Template for:');
          console.log(obj.data());
        }
      }
    }
    obj.calculateDisplayObjectStyles();
    obj.hide().show();
    if (Mura.layoutmanager && Mura.editing) {
      if (obj.hasClass('mura-body-object') || obj.is('div.mura-object[data-targetattr]')) {
        obj.children('.frontEndToolsModal').remove();
        obj.prepend(Mura.layoutmanagertoolbar);
        if (obj.data('objectname')) {
          obj.children('.frontEndToolsModal').children('.mura-edit-label').html(obj.data('objectname'));
        } else {
          obj.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(obj.data('object')));
        }
        if (obj.data('objecticonclass')) {
          obj.children('.frontEndToolsModal').children('.mura-edit-label').addClass(obj.data('objecticonclass'));
        }
        MuraInlineEditor.setAnchorSaveChecks(obj.node);
        obj.addClass('mura-active').hover(Mura.initDraggableObject_hoverin, Mura.initDraggableObject_hoverout);
      } else {
        //replace this with Mura.initEditableObject.call(obj.node) in future
        var initEditableObject = function initEditableObject(item) {
          var objectParams;
          if (item.data('transient')) {
            item.remove();
          } else if (Mura.type == 'Variation' && !(item.is('[data-mxpeditable]') || item.closest('.mxp-editable').length)) {
            return;
          }
          item.addClass("mura-active");
          if (Mura.type == 'Variation') {
            objectParams = item.data();
            item.children('.frontEndToolsModal').remove();
            item.children('.mura-fetborder').remove();
            item.prepend(window.Mura.layoutmanagertoolbar);
            if (item.data('objectname')) {
              item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
            } else {
              item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
            }
            if (item.data('objecticonclass')) {
              item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
            }
            item.off("click", Mura.handleObjectClick).on("click", Mura.handleObjectClick);
            item.find("img").each(function (el) {
              MuraInlineEditor.checkforImageCroppers(el);
            });
            item.find('.mura-object').each(function (el) {
              initEditableObject(Mura(el));
            });
            Mura.initDraggableObject(item.node);
          } else {
            var lcaseObject = item.data('object');
            if (typeof lcaseObject == 'string') {
              lcaseObject = lcaseObject.toLowerCase();
            }
            var region = item.closest('.mura-region-local, div.mura-object[data-object][data-targetattr]');
            if (region.length) {
              if (region.is('.mura-region-local') && region.data('perm') || region.is('div.mura-object[data-object][data-targetattr]')) {
                objectParams = item.data();
                if (window.MuraInlineEditor.objectHasConfigurator(item) || !window.Mura.layoutmanager && window.MuraInlineEditor.objectHasEditor(objectParams)) {
                  item.children('.frontEndToolsModal').remove();
                  item.children('.mura-fetborder').remove();
                  item.prepend(window.Mura.layoutmanagertoolbar);
                  if (item.data('objectname')) {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
                  } else {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
                  }
                  if (item.data('objecticonclass')) {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
                  }
                  item.off("click", Mura.handleObjectClick).on("click", Mura.handleObjectClick);
                  item.find("img").each(function (el) {
                    MuraInlineEditor.checkforImageCroppers(el);
                  });
                  item.find('.mura-object').each(function (el) {
                    initEditableObject(Mura(el));
                  });
                  Mura.initDraggableObject(item.node);
                  if (typeof Mura.initPinnedObject == 'function') {
                    item.find('div.mura-object[data-pinned="true"]').each(function (el) {
                      Mura.initPinnedObject(el);
                    });
                  }
                }
              }
            } else if (lcaseObject == 'form' || lcaseObject == 'component') {
              var entity = Mura.getEntity('content');
              var conditionalApply = function conditionalApply() {
                objectParams = item.data();
                if (window.MuraInlineEditor.objectHasConfigurator(item) || !window.Mura.layoutmanager && window.MuraInlineEditor.objectHasEditor(objectParams)) {
                  item.addClass('mura-active');
                  item.hover(Mura.initDraggableObject_hoverin, Mura.initDraggableObject_hoverout);
                  item.data('notconfigurable', true);
                  item.children('.frontEndToolsModal').remove();
                  item.children('.mura-fetborder').remove();
                  item.prepend(window.Mura.layoutmanagertoolbar);
                  if (item.data('objectname')) {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
                  } else {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
                  }
                  if (item.data('objecticonclass')) {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
                  }
                  item.off("click", Mura.handleObjectClick).on("click", Mura.handleObjectClick);
                  item.find("img").each(function (el) {
                    MuraInlineEditor.checkforImageCroppers(el);
                  });
                  item.find('.mura-object').each(function (el) {
                    initEditableObject(Mura(el));
                  });
                }
              };
              if (item.data('perm')) {
                conditionalApply();
              } else {
                if (Mura.isUUID(item.data('objectid'))) {
                  entity.loadBy('contentid', item.data('objectid'), {
                    type: lcaseObject
                  }).then(function (bean) {
                    bean.get('permissions').then(function (permissions) {
                      if (permissions.get('save')) {
                        item.data('perm', true);
                        conditionalApply();
                      }
                    });
                  });
                } else {
                  entity.loadBy('title', item.data('objectid'), {
                    type: lcaseObject
                  }).then(function (bean) {
                    bean.get('permissions').then(function (permissions) {
                      if (permissions.get('save')) {
                        item.data('perm', true);
                        conditionalApply();
                      }
                    });
                  });
                }
              }
            }
          }
        };
        initEditableObject(obj);
      }
    }
    obj.hide().show();

    //if(obj.data('object') != 'container' || obj.data('content')){
    processMarkup(obj.node);
    //}

    if (obj.data('object') != 'container') {
      obj.find('a[href="javascript:history.back();"]').each(function (el) {
        Mura(el).off("click").on("click", function (e) {
          if (obj.node.prevInnerHTML) {
            e.preventDefault();
            wireUpObject(obj, obj.node.prevInnerHTML);
            if (obj.node.prevData) {
              for (var p in obj.node.prevData) {
                select('[name="' + p + '"]').val(obj.node.prevData[p]);
              }
            }
            obj.node.prevInnerHTML = false;
            obj.node.prevData = false;
          }
        });
      });
      if (obj.data('render') && obj.data('render').toLowerCase() == 'server') {
        obj.find('form').each(function (el) {
          var form = Mura(el);
          if (form.closest('.mura-object').data('instanceid') == obj.data('instanceid')) {
            if (form.data('async') || !(form.hasData('async') && !form.data('async')) && !(form.hasData('autowire') && !form.data('autowire')) && !form.attr('action') && !form.attr('onsubmit') && !form.attr('onSubmit')) {
              form.on('submit', function (e) {
                e.preventDefault();
                validateForm(this, function (frm) {
                  submitForm(frm, obj);
                });
                return false;
              });
            }
          }
        });
      }
    }
    obj.trigger('asyncObjectRendered');
  }
  function handleResponse(obj, resp) {
    obj = obj.node ? obj : Mura(obj);

    // handle HTML response
    resp = !resp.data ? {
      data: resp
    } : resp;
    if (typeof resp.data.redirect != 'undefined') {
      if (resp.data.redirect && resp.data.redirect != location.href) {
        location.href = resp.data.redirect;
      } else {
        location.reload(true);
      }
    } else if (resp.data.apiEndpoint) {
      ajax({
        type: "POST",
        xhrFields: {
          withCredentials: true
        },
        crossDomain: true,
        url: resp.data.apiEndpoint,
        data: resp.data,
        success: function success(data) {
          if (typeof data == 'string') {
            wireUpObject(obj, data);
          } else if (_typeof(data) == 'object' && 'html' in data) {
            wireUpObject(obj, data.html);
          } else if (_typeof(data) == 'object' && 'data' in data && 'html' in data.data) {
            wireUpObject(obj, data.data.html);
          } else {
            wireUpObject(obj, data.data);
          }
        }
      });
    } else {
      wireUpObject(obj, resp.data);
    }
  }
  function processDisplayObject(el, queue, rerender, resolveFn, usePreloaderMarkup) {
    try {
      var obj = el.node ? el : Mura(el);
      if (!obj.data('object')) {
        obj.data('inited', true);
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            resolve(obj);
          }
        });
      }
      if (obj.data('queue') != null) {
        queue = obj.data('queue');
        if (typeof queue == 'string') {
          queue = queue.toLowerCase();
          if (queue == 'no' || queue == 'false') {
            queue = false;
            obj.data('queue', false);
          } else {
            queue = true;
            obj.data('queue', true);
          }
        }
      }
      var rendered = rerender && !obj.data('async') ? false : obj.children('.mura-object-content').length;
      queue = queue == null || rendered ? false : queue;
      if (document.createEvent && queue && !isScrolledIntoView(obj.node)) {
        if (!resolveFn) {
          return new Promise(function (resolve, reject) {
            resolve = resolve || function () {};
            setTimeout(function () {
              processDisplayObject(obj.node, true, false, resolve, usePreloaderMarkup);
            }, 10);
          });
        } else {
          setTimeout(function () {
            var resp = processDisplayObject(obj.node, true, false, resolveFn, usePreloaderMarkup);
            if (_typeof(resp) == 'object' && typeof resolveFn == 'function') {
              resp.then(resolveFn);
            }
          }, 10);
          return;
        }
      }
      if (!obj.node.getAttribute('data-instanceid')) {
        obj.node.setAttribute('data-instanceid', createUUID());
      }

      //if(obj.data('async')){
      obj.addClass("mura-async-object");
      //}

      if (rendered && !obj.data('async')) {
        return new Promise(function (resolve, reject) {
          obj.calculateDisplayObjectStyles();
          var template = obj.data('clienttemplate') || obj.data('object');
          var properNameCheck = firstToUpperCase(template);
          if (typeof Mura.Module[properNameCheck] != 'undefined') {
            template = properNameCheck;
          }
          if (typeof Mura.Module[template] != 'undefined') {
            //obj.data('render','client')
          }
          if (!rerender && obj.data('render') == 'client' && obj.children('.mura-object-content').length) {
            var context = filterUnwantedParams(obj.data());
            if (typeof context.instanceid != 'undefined' && typeof Mura.hydrationData[context.instanceid] != 'undefined') {
              Mura.extend(context, Mura.hydrationData[context.instanceid]);
            }
            if (typeof Mura.DisplayObject[template] != 'undefined') {
              context.targetEl = obj.children('.mura-object-content').node;
              Mura.displayObjectInstances[obj.data('instanceid')] = new Mura.DisplayObject[template](context);
              Mura.displayObjectInstances[obj.data('instanceid')].trigger('beforeRender');
              Mura.displayObjectInstances[obj.data('instanceid')].hydrate();
            } else {
              console.log('Missing Client Template for:');
              console.log(obj.data());
            }
            obj.data('inited', true);
          }
          if (obj.data('render') && obj.data('render').toLowerCase() == 'server') {
            obj.find('form').each(function (el) {
              var form = Mura(el);
              if (form.closest('.mura-object').data('instanceid') == obj.data('instanceid')) {
                if (form.data('async') || !(form.hasData('async') && !form.data('async')) && !(form.hasData('autowire') && !form.data('autowire')) && !form.attr('action') && !form.attr('onsubmit') && !form.attr('onSubmit')) {
                  form.on('submit', function (e) {
                    e.preventDefault();
                    validateForm(this, function (frm) {
                      submitForm(frm, obj);
                    });
                    return false;
                  });
                }
              }
            });
          }
          if (typeof resolve == 'function') {
            resolve(obj);
          }
        });
      }
      return new Promise(function (resolve, reject) {
        var data = deepExtend(setLowerCaseKeys(obj.data()), urlparams, {
          siteid: Mura.siteid,
          contentid: Mura.contentid,
          contenthistid: Mura.contenthistid
        });
        if (obj.data('siteid')) {
          data.siteid = obj.node.getAttribute('data-siteid');
        }
        if (obj.data('contentid')) {
          data.contentid = obj.node.getAttribute('data-contentid');
        }
        if (obj.data('contenthistid')) {
          data.contenthistid = obj.node.getAttribute('data-contenthistid');
        }
        if ('objectparams' in data) {
          data['objectparams'] = encodeURIComponent(JSON.stringify(data['objectparams']));
        }
        if (!obj.data('async') && obj.data('render') == 'client') {
          wireUpObject(obj);
          if (typeof resolve == 'function') {
            if (typeof resolve.call == 'undefined') {
              resolve(obj);
            } else {
              resolve.call(obj.node, obj);
            }
          }
        } else {
          //console.log(data);
          if (usePreloaderMarkup) {
            if (typeof data.preloadermarkup != 'undefined') {
              obj.node.innerHTML = data.preloadermarkup;
              delete data.preloadermarkup;
            } else {
              obj.node.innerHTML = Mura.preloadermarkup;
            }
          }
          var requestType = 'get';
          var requestData = filterUnwantedParams(data);
          var postCheck = new RegExp(/<\/?[a-z][\s\S]*>/i);
          for (var p in requestData) {
            if (requestData.hasOwnProperty(p) && requestData[p] && postCheck.test(requestData[p])) {
              requestType = 'post';
              break;
            }
          }
          ajax({
            url: Mura.getAPIEndpoint() + '?method=processAsyncObject',
            type: requestType,
            data: requestData,
            maxQueryStringLength: 827,
            success: function success(resp) {
              //console.log(data.object,resp)
              setTimeout(function () {
                handleResponse(obj, resp);
                if (typeof resolve == 'function') {
                  if (typeof resolve.call == 'undefined') {
                    resolve(obj);
                  } else {
                    resolve.call(obj.node, obj);
                  }
                }
              }, 0);
            }
          });
        }
      });
    } catch (e) {
      console.error(e);
      if (typeof resolve == 'function') {
        resolve(obj);
      }
    }
  }
  function processModule(el, queue, rerender, resolveFn, usePreloaderMarkup) {
    return processDisplayObject(el, queue, rerender, resolveFn, usePreloaderMarkup);
  }
  var hashparams = {};
  var urlparams = {};
  function handleHashChange() {
    if (typeof location != 'undefined') {
      var hash = location.hash;
    } else {
      var hash = '';
    }
    if (hash) {
      hash = hash.substring(1);
    }
    if (hash) {
      hashparams = getQueryStringParams(hash);
      if (hashparams.nextnid) {
        Mura('.mura-async-object[data-nextnid="' + hashparams.nextnid + '"]').each(function (el) {
          Mura(el).data(hashparams);
          processAsyncObject(el);
        });
      } else if (hashparams.objectid) {
        Mura('.mura-async-object[data-objectid="' + hashparams.objectid + '"]').each(function (el) {
          Mura(el).data(hashparams);
          processAsyncObject(el);
        });
      }
    }
  }

  /**
   * trim - description
   *
   * @param	{string} str Trims string
   * @return {string}		 Trimmed string
   * @memberof {class} Mura
   */
  function trim(str) {
    return str.replace(/^\s+|\s+$/gm, '');
  }
  function extendClass(baseClass, subClass) {
    var muraObject = function muraObject() {
      this.init.apply(this, arguments);
    };
    muraObject.prototype = Object.create(baseClass.prototype);
    muraObject.prototype.constructor = muraObject;
    muraObject.prototype.handlers = {};
    muraObject.reopen = function (subClass) {
      Mura.extend(muraObject.prototype, subClass);
    };
    muraObject.reopenClass = function (subClass) {
      Mura.extend(muraObject, subClass);
    };
    muraObject.on = function (eventName, fn) {
      eventName = eventName.toLowerCase();
      if (typeof muraObject.prototype.handlers[eventName] == 'undefined') {
        muraObject.prototype.handlers[eventName] = [];
      }
      if (!fn) {
        return muraObject;
      }
      for (var i = 0; i < muraObject.prototype.handlers[eventName].length; i++) {
        if (muraObject.prototype.handlers[eventName][i] == handler) {
          return muraObject;
        }
      }
      muraObject.prototype.handlers[eventName].push(fn);
      return muraObject;
    };
    muraObject.off = function (eventName, fn) {
      eventName = eventName.toLowerCase();
      if (typeof muraObject.prototype.handlers[eventName] == 'undefined') {
        muraObject.prototype.handlers[eventName] = [];
      }
      if (!fn) {
        muraObject.prototype.handlers[eventName] = [];
        return muraObject;
      }
      for (var i = 0; i < muraObject.prototype.handlers[eventName].length; i++) {
        if (muraObject.prototype.handlers[eventName][i] == handler) {
          muraObject.prototype.handlers[eventName].splice(i, 1);
        }
      }
      return muraObject;
    };
    Mura.extend(muraObject.prototype, subClass);
    return muraObject;
  }

  /**
   * getQueryStringParams - Returns object of params in string
   *
   * @name getQueryStringParams
   * @param	{string} queryString Query String
   * @return {object}
   * @memberof {class} Mura
   */
  function getQueryStringParams(queryString) {
    if (typeof queryString === 'undefined') {
      if (typeof location != 'undefined') {
        queryString = location.search;
      } else {
        return {};
      }
    }
    var params = {};
    var e,
      a = /\+/g,
      // Regex for replacing addition symbol with a space
      r = /([^&;=]+)=?([^&;]*)/g,
      d = function d(s) {
        return decodeURIComponent(s.replace(a, " "));
      };
    if (queryString.substring(0, 1) == '?') {
      var q = queryString.substring(1);
    } else {
      var q = queryString;
    }
    while (e = r.exec(q)) {
      params[d(e[1]).toLowerCase()] = d(e[2]);
    }
    return params;
  }

  /**
   * getHREFParams - Returns object of params in string
   *
   * @name getHREFParams
   * @param	{string} href
   * @return {object}
   * @memberof {class} Mura
   */
  function getHREFParams(href) {
    var a = href.split('?');
    if (a.length == 2) {
      return getQueryStringParams(a[1]);
    } else {
      return {};
    }
  }
  function inArray(elem, array, i) {
    var len;
    if (array) {
      if (array.indexOf) {
        return array.indexOf.call(array, elem, i);
      }
      len = array.length;
      i = i ? i < 0 ? Math.max(0, len + i) : i : 0;
      for (; i < len; i++) {
        // Skip accessing in sparse arrays
        if (i in array && array[i] === elem) {
          return i;
        }
      }
    }
    return -1;
  }

  /**
   * getStyleSheet - Returns a stylesheet object;
   *
   * @param	{string} id Text string
   * @return {object}						Self
   */
  function getStyleSheet(id) {
    if (Mura.isInNode()) {
      return getStyleSheetPlaceHolder(id);
    } else {
      var sheet = Mura('#' + id);
      if (sheet.length) {
        return sheet.get(0).sheet;
      } else {
        Mura('HEAD').append('<style id="' + id + '" type="text/css"></style>');
        return Mura('#' + id).get(0).sheet;
      }
    }
  }

  /**
   * applyModuleCustomCSS - Returns a stylesheet object;
   *
   * @param	{object} stylesupport Object Containing Module Style configuration
   * @param	{object} sheet Object StyleSheet object
   * @param	{string} id Text string
   * @return {void}	void
   */
  function applyModuleCustomCSS(stylesupport, sheet, id) {
    stylesupport = stylesupport || {};
    if (typeof stylesupport.css != 'undefined' && stylesupport.css) {
      var styles = stylesupport.css.split('}');
      if (Array.isArray(styles) && styles.length) {
        styles.forEach(function (style) {
          var styleParts = style.split("{");
          if (styleParts.length > 1) {
            var selectors = styleParts[0].split(',');
            selectors.forEach(function (subSelector) {
              try {
                var subStyle = 'div.mura-object[data-instanceid="' + id + '"] ' + subSelector.replace(/\$self/g, '') + '{' + styleParts[1] + '}';
                sheet.insertRule(subStyle, sheet.cssRules.length);
                if (Mura.editing) {
                  console.log('Applying dynamic styles:' + subStyle);
                }
              } catch (e) {
                if (Mura.editing) {
                  console.log('Error applying dynamic styles:' + subStyle);
                  console.log(e);
                }
              }
            });
          }
        });
      }
    }
  }

  /**
   * getStyleSheetPlaceHolder - ;
   *
   * @return {object}	 object
   */
  function getStyleSheetPlaceHolder(id) {
    return {
      deleteRule: function deleteRule(idx) {
        this.cssRules.splice(idx, 1);
      },
      insertRule: function insertRule(rule) {
        this.cssRules.push(rule);
      },
      cssRules: [],
      id: id,
      targets: {
        object: {
          class: "mura-object"
        },
        meta: {
          class: "mura-object-meta"
        },
        metawrapper: {
          class: "mura-object-meta-wrapper"
        },
        content: {
          class: "mura-object-content"
        }
      }
    };
  }

  /**
   * normalizeModuleClassesAndIds - ;
   *
   * @param	{object} params Object Containing Module Style configuration
   * @return {object}	style object
   */
  function normalizeModuleClassesAndIds(params, sheet) {
    if (typeof sheet == 'undefined') {
      sheet = getStyleSheetPlaceHolder('mura-styles-' + params.instanceid);
    }
    if (typeof params.class != 'undefined' && params.class != '') {
      sheet.targets.object.class += ' ' + params.class;
    }
    if (typeof params.cssclass != 'undefined' && params.cssclass != '') {
      sheet.targets.object.class += ' ' + params.cssclass;
    }
    if (typeof params.cssid != 'undefined' && params.cssid != '') {
      sheet.targets.object.id = params.cssid;
    }
    if (typeof params.metacssclass != 'undefined' && params.metacssclass != '') {
      sheet.targets.meta.class += ' ' + params.metacssclass;
    }
    if (typeof params.metacssid != 'undefined' && params.metacssid != '') {
      sheet.targets.meta.id = params.metacssid;
    }
    if (typeof params.contentcssclass != 'undefined' && params.contentcssclass != '') {
      sheet.targets.content.class += ' ' + params.contentcssclass;
    }
    if (typeof params.contentcssid != 'undefined' && params.contentcssid != '') {
      sheet.targets.content.id = params.contentcssid;
    }
    if (typeof params.objectspacing != 'undefined' && params.objectspacing != '' && params.objectspacing != 'custom') {
      sheet.targets.object.class += ' ' + params.objectspacing;
    }
    if (typeof params.metaspacing != 'undefined' && params.metaspacing != '' && params.metaspacing != 'custom') {
      sheet.targets.meta.class += ' ' + params.metaspacing;
    }
    if (typeof params.contentspacing != 'undefined' && params.contentspacing != '' && params.contentspacing != 'custom') {
      sheet.targets.content.class += ' ' + params.contentspacing;
    }
    if (sheet.targets.content.class.split(' ').find(function ($class) {
      return $class === 'container';
    })) {
      sheet.targets.metawrapper.class += ' container';
    }
    return sheet;
  }

  /**
   * recordModuleClassesAndIds - ;
   *
   * @param	{object} params Object Containing Module Style configuration
   * @return {object}	style object
   */
  function recordModuleClassesAndIds(params) {
    params.instanceid = params.instanceid || createUUID();
    params.stylesupport = params.stylesupport || {};
    var sheet = getStyleSheet('mura-styles-' + params.instanceid);
    if (sheet.recorded) {
      return sheet;
    }
    normalizeModuleClassesAndIds(params, sheet);
    return sheet;
  }

  /**
   * recordModuleStyles - ;
   *
   * @param	{object} params Object Containing Module Style configuration
   * @return {object}	style object
   */
  function recordModuleStyles(params) {
    params.instanceid = params.instanceid || createUUID();
    params.stylesupport = params.stylesupport || {};
    var sheet = getStyleSheet('mura-styles-' + params.instanceid);
    if (sheet.recorded) {
      return sheet;
    }
    var styleTargets = getModuleStyleTargets(params.instanceid, false);
    applyModuleStyles(params.stylesupport, styleTargets.object, sheet);
    applyModuleCustomCSS(params.stylesupport, sheet, params.instanceid);
    applyModuleStyles(params.stylesupport, styleTargets.meta, sheet);
    applyModuleStyles(params.stylesupport, styleTargets.content, sheet);
    normalizeModuleClassesAndIds(params, sheet);
    return sheet;
  }

  /**
   * applyModuleStyles - Returns a stylesheet object;
   *
   * @param	{object} stylesupport Object Containing Module Style configuration
   * @param	{object} group Object Containing a group of selectors
   * @param	{object} sheet StyleSheet object
   * @param	{object} obj Mura.DomSelection
   * @return {void}	void
   */
  function applyModuleStyles(stylesupport, group, sheet, obj) {
    var acummulator = {};
    //group is for object, content, meta
    group.targets.forEach(function (target) {
      var styles = {};
      var dyncss = '';
      if (stylesupport && stylesupport[target.name]) {
        styles = stylesupport[target.name];
      }
      //console.log(target.name)
      //console.log(styles)
      acummulator = Mura.extend(acummulator, styles);
      handleBackround(acummulator);
      for (var s in acummulator) {
        if (acummulator.hasOwnProperty(s)) {
          var p = s.toLowerCase();
          if (Mura.styleMap && typeof Mura.styleMap.tojs[p] != 'undefined' && Mura.styleMap.tocss[Mura.styleMap.tojs[p]] != 'undefined') {
            dyncss += Mura.styleMap.tocss[Mura.styleMap.tojs[p]] + ': ' + acummulator[s] + ' !important;';
          } else if (typeof obj != 'undefined') {
            obj.css(s, acummulator[s]);
          }
        }
      }
      //console.log(target.name,acummulator,dyncss)
      if (dyncss) {
        try {
          //selector is for edit mode or standard
          target.selectors.forEach(function (selector) {
            //console.log(selector)
            sheet.insertRule(selector + ' {' + dyncss + '}}', sheet.cssRules.length);
            //console.log(selector + ' {' + dyncss+ '}}')
            handleTextColor(sheet, selector, acummulator);
          });
        } catch (e) {
          console.log(selector + ' {' + dyncss + '}}');
          console.log(e);
        }
      }
    });
    function handleBackround(styles) {
      if (typeof styles.backgroundImage != 'undefined' && styles.backgroundImage) {
        var bgArray = styles.backgroundImage.split(',');
        if (bgArray.length) {
          styles.backgroundImage = Mura.trim(bgArray[bgArray.length - 1]);
        }
      }
      var hasLayeredBg = styles && typeof styles.backgroundColor != 'undefined' && styles.backgroundColor && typeof styles.backgroundImage != 'undefined' && styles.backgroundImage;
      if (hasLayeredBg) {
        styles.backgroundImage = 'linear-gradient(' + styles.backgroundColor + ', ' + styles.backgroundColor + ' ), ' + styles.backgroundImage;
      } else {
        if (typeof styles.backgroundimage != 'undefined' && styles.backgroundimage) {
          var bgArray = styles.backgroundimage.split(',');
          if (bgArray.length) {
            styles.backgroundimage = Mura.trim(bgArray[bgArray.length - 1]);
          }
        }
        hasLayeredBg = styles && typeof styles.backgroundcolor != 'undefined' && styles.backgroundcolor && typeof styles.backgroundimage != 'undefined' && styles.backgroundimage;
        if (hasLayeredBg) {
          styles.backgroundImage = 'linear-gradient(' + styles.backgroundcolor + ', ' + styles.backgroundcolor + ' ), ' + styles.backgroundimage;
        }
      }
    }
    function handleTextColor(sheet, selector, styles) {
      try {
        if (styles.color) {
          var selectorArray = selector.split('{');
          var style = selectorArray[0] + '{' + selectorArray[1] + ', ' + selectorArray[1] + ' label, ' + selectorArray[1] + ' p, ' + selectorArray[1] + ' h1, ' + selectorArray[1] + ' h2, ' + selectorArray[1] + ' h3, ' + selectorArray[1] + ' h4, ' + selectorArray[1] + ' h5, ' + selectorArray[1] + ' h6, ' + selectorArray[1] + ' a, ' + selectorArray[1] + ' a:link, ' + selectorArray[1] + ' a:visited, ' + selectorArray[1] + ' a:hover, ' + selectorArray[1] + ' .breadcrumb-item + .breadcrumb-item::before, ' + selectorArray[1] + ' a:active { color:' + styles.color + ' !important;}} ';
          sheet.insertRule(style, sheet.cssRules.length);
          //console.log(style)
          sheet.insertRule(selector + ' * {color:inherit !important}}', sheet.cssRules.length);
          //console.log(selector + ' * {color:inherit}')
          sheet.insertRule(selector + ' hr { border-color:' + styles.color + ' !important;}}', sheet.cssRules.length);
        }
      } catch (e) {
        console.log("error adding color: " + styles.color);
        console.log(e);
      }
    }
  }
  function getBreakpoint() {
    if (typeof document != 'undefined') {
      var breakpoints = getBreakpoints();
      var width = document.documentElement.clientWidth;
      if (Mura.editing) {
        width = width - 300;
      }
      if (width >= breakpoints.xl) {
        return 'xl';
      } else if (width >= breakpoints.lg) {
        return 'lg';
      } else if (width >= breakpoints.md) {
        return 'md';
      } else if (width >= breakpoints.sm) {
        return 'sm';
      } else {
        return 'xs';
      }
    } else {
      return '';
    }
  }
  function getBreakpoints() {
    if (typeof Mura.breakpoints != 'undefined') {
      return Mura.breakpoints;
    } else {
      return {
        xl: 1200,
        lg: 992,
        md: 768,
        sm: 576
      };
    }
  }
  function getModuleStyleTargets(id, dynamic) {
    var breakpoints = getBreakpoints();
    var sidebar = 300;
    var objTargets = {
      object: {
        targets: [{
          name: 'objectstyles',
          selectors: ['@media (min-width: ' + breakpoints.xl + 'px) { div[data-instanceid="' + id + '"]', '@media (min-width: ' + (breakpoints.xl + sidebar) + 'px) { .mura-editing div[data-instanceid="' + id + '"]']
        }, {
          name: 'object_lg_styles',
          selectors: ['@media (min-width: ' + breakpoints.lg + 'px) and (max-width: ' + (breakpoints.xl - 1) + 'px) { div[data-instanceid="' + id + '"]', '@media (min-width: ' + (breakpoints.lg + sidebar) + 'px) and (max-width: ' + (breakpoints.xl + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"]']
        }, {
          name: 'object_md_styles',
          selectors: ['@media (min-width: ' + breakpoints.md + 'px) and (max-width:' + (breakpoints.lg - 1) + 'px) { div[data-instanceid="' + id + '"]', '@media (min-width: ' + (breakpoints.md + sidebar) + 'px) and (max-width: ' + (breakpoints.lg + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"]']
        }, {
          name: 'object_sm_styles',
          selectors: ['@media (min-width: ' + breakpoints.sm + 'px) and (max-width: ' + (breakpoints.md - 1) + 'px) { div[data-instanceid="' + id + '"]', '@media (min-width: ' + (breakpoints.sm + sidebar) + 'px) and (max-width: ' + (breakpoints.md + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"]']
        }, {
          name: 'object_xs_styles',
          selectors: ['@media (max-width: ' + (breakpoints.sm - 1) + 'px) { div[data-instanceid="' + id + '"]', '@media (max-width: ' + (breakpoints.sm + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"]']
        }]
      },
      meta: {
        targets: [{
          name: 'metastyles',
          selectors: ['@media (min-width: ' + breakpoints.xl + 'px) { div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta', '@media (min-width: ' + (breakpoints.xl + sidebar) + 'px) { .mura-editing div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta']
        }, {
          name: 'meta_lg_styles',
          selectors: ['@media (min-width: ' + breakpoints.lg + 'px) and (max-width: ' + (breakpoints.xl - 1) + 'px) { div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta', '@media (min-width: ' + (breakpoints.lg + sidebar) + 'px) and (max-width: ' + (breakpoints.xl + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta']
        }, {
          name: 'meta_md_styles',
          selectors: ['@media (min-width: ' + breakpoints.md + 'px) and (max-width: ' + (breakpoints.lg - 1) + 'px) { div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta', '@media (min-width: ' + (breakpoints.md + sidebar) + 'px) and (max-width: ' + (breakpoints.lg + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta']
        }, {
          name: 'meta_sm_styles',
          selectors: ['@media (min-width: ' + breakpoints.sm + 'px) and (max-width: ' + (breakpoints.md - 1) + 'px) { div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta', '@media (min-width: ' + (breakpoints.sm + sidebar) + 'px) and (max-width: ' + (breakpoints.md + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta']
        }, {
          name: 'meta_xs_styles',
          selectors: ['@media (max-width: ' + (breakpoints.sm - 1) + 'px) { div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta', '@media (max-width: ' + (breakpoints.sm + sidebar - 1) + 'px) { .mura-editing div[data-instanceid="' + id + '"] > div.mura-object-meta-wrapper > div.mura-object-meta']
        }]
      },
      content: {
        targets: [{
          name: 'contentstyles',
          selectors: ['@media (min-width: ' + breakpoints.xl + 'px) { div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content', '@media (min-width: ' + (breakpoints.xl + sidebar) + 'px) { .mura-editing div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content']
        }, {
          name: 'content_lg_styles',
          selectors: ['@media (min-width: ' + breakpoints.lg + 'px) and (max-width: ' + (breakpoints.xl - 1) + 'px) { div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content', '@media (min-width: ' + (breakpoints.lg + sidebar) + 'px) and (max-width: ' + (breakpoints.xl + sidebar - 1) + 'px) { .mura-editing div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content']
        }, {
          name: 'content_md_styles',
          selectors: ['@media (min-width: ' + breakpoints.md + 'px) and (max-width: ' + (breakpoints.lg - 1) + 'px) { div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content', '@media (min-width: ' + (breakpoints.md + sidebar) + 'px) and (max-width: ' + (breakpoints.lg + sidebar - 1) + 'px) { .mura-editing div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content']
        }, {
          name: 'content_sm_styles',
          selectors: ['@media (min-width: ' + breakpoints.sm + 'px) and (max-width: ' + (breakpoints.md - 1) + 'px) { div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content', '@media (min-width: ' + (breakpoints.sm + sidebar) + 'px) and (max-width: ' + (breakpoints.md + sidebar - 1) + 'px) { .mura-editing div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content']
        }, {
          name: 'content_xs_styles',
          selectors: ['@media (max-width: ' + (breakpoints.sm - 1) + 'px) { div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content', '@media (max-width: ' + (breakpoints.sm + sidebar - 1) + 'px) { .mura-editing div.mura-object[data-instanceid="' + id + '"] > div.mura-object-content']
        }]
      }
    };
    if (!dynamic) {
      for (var elTarget in objTargets) {
        if (objTargets.hasOwnProperty(elTarget)) {
          objTargets[elTarget].targets.forEach(function (target) {
            target.selectors.pop();
          });
        }
      }
    }
    return objTargets;
  }

  /**
   * setRequestHeader - Initialiazes feed
   *
   * @name setRequestHeader
   * @param	{string} headerName	Name of header
   * @param	{string} value Header value
   * @return {Mura.RequestContext} Self
   * @memberof {class} Mura
   */
  function setRequestHeader(headerName, value) {
    Mura.requestHeaders[headerName] = value;
    return this;
  }

  /**
   * getRequestHeader - Returns a request header value
   *
   * @name getRequestHeader
   * @param	{string} headerName	Name of header
   * @return {string} header Value
   * @memberof {class} Mura
   */
  function getRequestHeader(headerName) {
    if (typeof Mura.requestHeaders[headerName] != 'undefined') {
      return Mura.requestHeaders[headerName];
    } else {
      return null;
    }
  }

  /**
   * getRequestHeaders - Returns a request header value
   *
   * @name getRequestHeaders
   * @return {object} All Headers
   * @memberof {class} Mura
   */
  function getRequestHeaders() {
    return Mura.requestHeaders;
  }

  //http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/

  /**
   * hashCode - description
   *
   * @name hashCode
   * @param	{string} s String to hash
   * @return {string}
   * @memberof {class} Mura
   */
  function hashCode(s) {
    var hash = 0,
      strlen = s.length,
      i,
      c;
    if (strlen === 0) {
      return hash;
    }
    for (i = 0; i < strlen; i++) {
      c = s.charCodeAt(i);
      hash = (hash << 5) - hash + c;
      hash = hash & hash; // Convert to 32bit integer
    }

    return hash >>> 0;
  }

  /**
   * Returns if the current request s running in Node.js
  **/
  function isInNode() {
    return typeof process !== 'undefined' && {}.toString.call(process) === '[object process]' || typeof document == 'undefined';
  }

  /**
   * Global Request Headers
  **/
  var requestHeaders = {};
  function throttle(func, interval) {
    var timeout;
    return function () {
      var context = this,
        args = arguments;
      var later = function later() {
        timeout = false;
      };
      if (!timeout) {
        func.apply(context, args);
        timeout = true;
        setTimeout(later, interval);
      }
    };
  }
  function debounce(func, interval) {
    var timeout;
    return function () {
      var context = this,
        args = arguments;
      var later = function later() {
        timeout = null;
        func.apply(context, args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, interval || 200);
    };
  }
  function getAPIEndpoint() {
    if (Mura.apiendpoint) {
      Mura.apiEndpoint = Mura.apiendpoint;
      delete Mura.apiendpoint;
      if (Mura.mode.toLowerCase() == 'rest') {
        Mura.apiEndpoint = Mura.apiEndpoint.replace('/json/', '/rest/');
      }
    }
    return Mura.apiEndpoint;
  }
  function setAPIEndpoint(apiEndpoint) {
    Mura.apiEndpoint = apiEndpoint;
  }
  function setMode(mode) {
    Mura.mode = mode;
  }
  function getMode() {
    return Mura.mode;
  }
  function getRenderMode() {
    return Mura.renderMode;
  }
  function setRenderMode(renderMode) {
    Mura.renderMode = renderMode;
  }
  function startUserStateListener(interval) {
    Mura.userStateListenerInterval = interval;
  }
  function stopUserStateListener() {
    Mura.userStateListenerInterval = false;
  }
  function pollUserState() {
    if (typeof window != 'undefined' && typeof document != 'undefined' && (Mura.userStateListenerInterval || Mura.editing)) {
      Mura.getEntity('user').invoke('pollState').then(function (state) {
        var data = state;
        if (typeof state == 'string') {
          try {
            data = JSON.parse(state);
          } catch (e) {
            data = state;
          }
        }
        Mura(document).trigger('muraUserStateMessage', data);
      });
    }
    var interval = typeof Mura.userStateListenerInterval === 'number' && Mura.userStateListenerInterval ? Mura.userStateListenerInterval : 60000;
    setTimeout(pollUserState, interval);
  }
  function deInit() {
    //This all needs to be moved to a state object
    delete Mura._requestcontext;
    delete Mura.response;
    delete Mura.request;
    Mura.requestHeaders = {};
    Mura.displayObjectInstances = {};
    delete Mura.renderMode;
    delete Mura.userStateListenerInterval;
    delete Mura.currentUser;
    Mura.mode = "json";
    setAPIEndpoint(getAPIEndpoint().replace('/rest/', '/json/'));
    Mura.trackingMetadata = {};
    delete Mura.trackingVars;
    //delete Mura.apiEndpoint;
    //delete Mura.apiendpoint;
    delete Mura.perm;
    delete Mura.formdata;
    delete Mura.windowResponsiveModules;
    delete Mura.windowResizeID;
    delete Mura.Content;
    delete Mura.content;
    return Mura;
  }

  //Mura.init()
  function init(config) {
    var existingEndpoint = '';
    if (Mura.siteid && config.siteid && Mura.siteid != config.siteid) {
      delete Mura.apiEndpoint;
      delete Mura.apiendpoint;
    }
    if (typeof Mura.apiEndpoint != 'undefined' && Mura.apiEndpoint) {
      existingEndpoint = Mura.apiEndpoint;
    }
    if (typeof config.content != 'undefined') {
      if (typeof config.content.get == 'undefined') {
        config.content = getEntity('content').set(config.content);
      }
      Mura.extend(config, config.content.get('config'));
    }
    if (existingEndpoint) {
      config.apiEndpoint = existingEndpoint;
      delete config.apiendpoint;
    }
    if (config.rootpath) {
      config.context = config.rootpath;
    }
    if (config.endpoint) {
      config.context = config.endpoint;
    }
    if (!config.context) {
      config.context = '';
    }
    if (!config.rootpath) {
      config.rootpath = config.context;
    }
    if (!config.assetpath) {
      config.assetpath = config.context + "/sites/" + config.siteid;
    }
    if (!config.siteassetpath) {
      config.siteassetpath = config.assetpath;
    }
    if (!config.fileassetpath) {
      config.fileassetpath = config.assetpath;
    }
    if (config.apiendpoint) {
      config.apiEndpoint = config.apiendpoint;
      delete config.apiendpoint;
    }
    if (typeof config.indexfileinapi == 'undefined') {
      if (typeof Mura.indexfileinapi != 'undefined') {
        config.indexfileinapi = Mura.indexfileinapi;
      } else {
        config.indexfileinapi = true;
      }
    }
    if (!config.apiEndpoint) {
      if (config.indexfileinapi) {
        config.apiEndpoint = config.context + '/index.cfm/_api/json/v1/' + config.siteid + '/';
      } else {
        config.apiEndpoint = config.context + '/_api/json/v1/' + config.siteid + '/';
      }
    }
    if (config.apiEndpoint.indexOf('/_api/') == -1) {
      if (config.indexfileinapi) {
        config.apiEndpoint = config.apiEndpoint + '/index.cfm/_api/json/v1/' + config.siteid + '/';
      } else {
        config.apiEndpoint = config.apiEndpoint + '/_api/json/v1/' + config.siteid + '/';
      }
    }
    if (!config.pluginspath) {
      config.pluginspath = config.context + '/plugins';
    }
    if (!config.corepath) {
      config.corepath = config.context + '/core';
    }
    if (!config.jslib) {
      config.jslib = 'jquery';
    }
    if (!config.perm) {
      config.perm = 'none';
    }
    if (typeof config.layoutmanager == 'undefined') {
      config.layoutmanager = false;
    }
    if (typeof config.mobileformat == 'undefined') {
      config.mobileformat = false;
    }
    if (typeof config.queueObjects != 'undefined') {
      config.queueobjects = config.queueObjects;
      delete config.queueobjects;
    }
    if (typeof config.queueobjects == 'undefined') {
      config.queueobjects = true;
    }
    if (typeof config.rootdocumentdomain != 'undefined' && config.rootdocumentdomain != '') {
      document.domain = config.rootdocumentdomain;
    }
    if (typeof config.preloaderMarkup != 'undefined') {
      config.preloadermarkup = config.preloaderMarkup;
      delete config.preloaderMarkup;
    }
    if (typeof config.preloadermarkup == 'undefined') {
      config.preloadermarkup = '';
    }
    if (typeof config.rb == 'undefined') {
      config.rb = {};
    }
    if (typeof config.dtExample != 'undefined') {
      config.dtexample = config.dtExample;
      delete config.dtExample;
    }
    if (typeof config.dtexample == 'undefined') {
      config.dtexample = "11/10/2024";
    }
    if (typeof config.dtCh != 'undefined') {
      config.dtch = config.dtCh;
      delete config.dtCh;
    }
    if (typeof config.dtch == 'undefined') {
      config.dtch = "/";
    }
    if (typeof config.dtFormat != 'undefined') {
      config.dtformat = config.dtFormat;
      delete config.dtFormat;
    }
    if (typeof config.dtformat == 'undefined') {
      config.dtformat = [0, 1, 2];
    }
    if (typeof config.dtLocale != 'undefined') {
      config.dtlocale = config.dtLocale;
      delete config.dtLocale;
    }
    if (typeof config.dtlocale == 'undefined') {
      config.dtlocale = "en-US";
    }
    if (typeof config.useHTML5DateInput != 'undefined') {
      config.usehtml5dateinput = config.useHTML5DateInput;
      delete config.usehtml5dateinput;
    }
    if (typeof config.usehtml5dateinput == 'undefined') {
      config.usehtml5dateinput = false;
    }
    if (typeof config.cookieConsentEnabled != 'undefined') {
      config.cookieconsentenabled = config.cookieConsentEnabled;
      delete config.cookieConsentEnabled;
    }
    if (typeof config.cookieconsentenabled == 'undefined') {
      config.cookieconsentenabled = false;
    }
    if (typeof config.initialProcessMarkupSelector == 'undefined') {
      if (typeof window != 'undefined' && typeof document != 'undefined') {
        var initialProcessMarkupSelector = 'document';
      } else {
        var initialProcessMarkupSelector = '';
      }
    } else {
      var initialProcessMarkupSelector = config.initialProcessMarkupSelector;
    }
    config.formdata = typeof FormData != 'undefined' ? true : false;
    var initForDataOnly = false;
    if (typeof config.processMarkup != 'undefined') {
      initForDataOnly = typeof config.processMarkup != 'function' && !config.processMarkup;
      delete config.processMarkup;
    } else if (typeof config.processmarkup != 'undefined') {
      initForDataOnly = typeof config.processmarkup != 'function' && !config.processmarkup;
      delete config.processmarkup;
    }
    extend(Mura, config);
    Mura.trackingMetadata = {};
    Mura.hydrationData = {};
    if (typeof config.content != 'undefined' && typeof config.content.get != 'undefined' && config.content.get('displayregions')) {
      for (var r in config.content.properties.displayregions) {
        if (config.content.properties.displayregions.hasOwnProperty(r)) {
          var data = config.content.properties.displayregions[r];
          if (typeof data.inherited != 'undefined' && typeof data.inherited.items != 'undefined') {
            for (var d in data.inherited.items) {
              Mura.hydrationData[data.inherited.items[d].instanceid] = data.inherited.items[d];
            }
          }
          if (typeof data.local != 'undefined' && typeof data.local.items != 'undefined') {
            for (var d in data.local.items) {
              Mura.hydrationData[data.local.items[d].instanceid] = data.local.items[d];
            }
          }
        }
      }
    }
    Mura.dateformat = generateDateFormat();
    if (Mura.mode.toLowerCase() == 'rest') {
      Mura.apiEndpoint = Mura.apiEndpoint.replace('/json/', '/rest/');
    }
    if (typeof window != 'undefined' && typeof window.document != 'undefined') {
      if (Array.isArray(window.queuedMuraCmds) && window.queuedMuraCmds.length) {
        holdingQueue = window.queuedMuraCmds.concat(holdingQueue);
        window.queuedMuraCmds = [];
      }
      if (Array.isArray(window.queuedMuraPreInitCmds) && window.queuedMuraPreInitCmds.length) {
        holdingPreInitQueue = window.queuedMuraPreInitCmds.concat(holdingPreInitQueue);
        window.queuedMuraPreInitCmds = [];
      }
    }
    if (!initForDataOnly) {
      destroyDisplayObjects();
      stopUserStateListener();
      Mura(function () {
        for (var cmd in holdingPreInitQueue) {
          if (typeof holdingPreInitQueue[cmd] == 'function') {
            holdingPreInitQueue[cmd](Mura);
          }
        }
        if (typeof window != 'undefined' && typeof window.document != 'undefined') {
          var hash = location.hash;
          if (hash) {
            hash = hash.substring(1);
          }
          urlparams = setLowerCaseKeys(getQueryStringParams(location.search));
          if (hashparams.nextnid) {
            Mura('.mura-async-object[data-nextnid="' + hashparams.nextnid + '"]').each(function (el) {
              Mura(el).data(hashparams);
            });
          } else if (hashparams.objectid) {
            Mura('.mura-async-object[data-nextnid="' + hashparams.objectid + '"]').each(function (el) {
              Mura(el).data(hashparams);
            });
          }
          Mura(window).on('hashchange', handleHashChange);
          Mura(document).on('click', 'div.mura-object .mura-next-n a,div.mura-object .mura-search-results div.moreResults a,div.mura-object div.mura-pagination a', function (e) {
            e.preventDefault();
            var href = Mura(e.target).attr('href');
            if (href != '#') {
              var hArray = href.split('?');
              var source = Mura(e.target);
              var data = setLowerCaseKeys(getQueryStringParams(hArray[hArray.length - 1]));
              var obj = source.closest('div.mura-object');
              obj.data(data);
              processAsyncObject(obj.node).then(function () {
                try {
                  if (typeof window != 'undefined' && typeof document != 'undefined') {
                    var rect = obj.node.getBoundingClientRect();
                    var elemTop = rect.top;
                    if (elemTop < 0) {
                      window.scrollTo(0, Mura(document).scrollTop() + elemTop);
                    }
                  }
                } catch (e) {
                  console.log(e);
                }
              });
            }
          });
          if (!Mura.inAdmin && initialProcessMarkupSelector) {
            if (initialProcessMarkupSelector == 'document') {
              processMarkup(document);
            } else {
              processMarkup(initialProcessMarkupSelector);
            }
          }
          Mura.markupInitted = true;
          if (Mura.cookieconsentenabled) {
            Mura(function () {
              Mura('body').appendDisplayObject({
                object: 'cookie_consent',
                queue: false,
                statsid: 'cookie_consent'
              });
            });
          }
          Mura(document).on("keydown", function (event) {
            keyCmdCheck(event);
          });
          Mura.breakpoint = getBreakpoint();
          Mura.windowResponsiveModules = {};
          window.addEventListener("resize", function () {
            clearTimeout(Mura.windowResizeID);
            Mura.windowResizeID = setTimeout(doneResizing, 250);
            function doneResizing() {
              var breakpoint = getBreakpoint();
              if (breakpoint != Mura.breakpoint) {
                Mura.breakpoint = breakpoint;
                Mura('.mura-object').each(function (el) {
                  var obj = Mura(el);
                  var instanceid = obj.data('instanceid');
                  if (typeof Mura.windowResponsiveModules[instanceid] == 'undefined' || Mura.windowResponsiveModules[instanceid]) {
                    obj.calculateDisplayObjectStyles(true);
                  }
                });
              }
              delete Mura.windowResizeID;
            }
          });
          Mura(document).trigger('muraReady');
          pollUserState();
        }
      });
      readyInternal(initReadyQueue);
    }
    return Mura;
  }
  Mura = extend(function (selector, context) {
    if (typeof selector == 'function') {
      Mura.ready(selector);
      return this;
    } else {
      if (typeof context == 'undefined') {
        return select(selector);
      } else {
        return select(context).find(selector);
      }
    }
  }, {
    preInit: function preInit(fn) {
      if (holdingReady) {
        holdingPreInitQueue.push(fn);
      } else {
        Mura(fn);
      }
    },
    generateOAuthToken: generateOAuthToken,
    entities: {},
    feeds: {},
    submitForm: submitForm,
    escapeHTML: escapeHTML,
    unescapeHTML: unescapeHTML,
    processDisplayObject: processDisplayObject,
    processModule: processModule,
    processAsyncObject: processAsyncObject,
    resetAsyncObject: resetAsyncObject,
    setLowerCaseKeys: setLowerCaseKeys,
    throttle: throttle,
    debounce: debounce,
    noSpam: noSpam,
    addLoadEvent: addLoadEvent,
    loader: loader,
    addEventHandler: addEventHandler,
    trigger: trigger,
    ready: ready,
    on: on,
    off: off,
    extend: extend,
    inArray: inArray,
    isNumeric: isNumeric,
    post: post,
    get: get,
    delete: deleteReq,
    put: put,
    patch: patch,
    deepExtend: deepExtend,
    ajax: ajax,
    request: ajax,
    changeElementType: changeElementType,
    setHTMLEditor: setHTMLEditor,
    each: each,
    parseHTML: parseHTML,
    getData: getData,
    cleanModuleProps: cleanModuleProps,
    getProps: getProps,
    isEmptyObject: isEmptyObject,
    isScrolledIntoView: isScrolledIntoView,
    evalScripts: evalScripts,
    validateForm: validateForm,
    escape: $escape,
    unescape: $unescape,
    getBean: getEntity,
    getEntity: getEntity,
    getCurrentUser: getCurrentUser,
    renderFilename: renderFilename,
    startUserStateListener: startUserStateListener,
    stopUserStateListener: stopUserStateListener,
    findQuery: findQuery,
    getFeed: getFeed,
    login: login,
    logout: logout,
    extendClass: extendClass,
    init: init,
    formToObject: formToObject,
    createUUID: createUUID,
    isUUID: isUUID,
    processMarkup: processMarkup,
    getQueryStringParams: getQueryStringParams,
    layoutmanagertoolbar: layoutmanagertoolbar,
    parseString: parseString,
    createCookie: createCookie,
    readCookie: readCookie,
    eraseCookie: eraseCookie,
    trim: trim,
    hashCode: hashCode,
    DisplayObject: {},
    displayObjectInstances: {},
    destroyDisplayObjects: destroyDisplayObjects,
    destroyModules: destroyModules,
    holdReady: holdReady,
    trackEvent: trackEvent,
    recordEvent: trackEvent,
    isInNode: isInNode,
    getRequestContext: getRequestContext,
    getDefaultRequestContext: getDefaultRequestContext,
    requestHeaders: requestHeaders,
    setRequestHeader: setRequestHeader,
    getRequestHeader: getRequestHeaders,
    getRequestHeaders: getRequestHeaders,
    mode: 'json',
    declareEntity: declareEntity,
    undeclareEntity: undeclareEntity,
    buildDisplayRegion: buildDisplayRegion,
    openGate: openGate,
    firstToUpperCase: firstToUpperCase,
    firstToLowerCase: firstToLowerCase,
    normalizeRequestConfig: normalizeRequestConfig,
    getStyleSheet: getStyleSheet,
    getStyleSheetPlaceHolder: getStyleSheetPlaceHolder,
    applyModuleStyles: applyModuleStyles,
    applyModuleCustomCSS: applyModuleCustomCSS,
    recordModuleStyles: recordModuleStyles,
    recordModuleClassesAndIds: recordModuleClassesAndIds,
    getModuleStyleTargets: getModuleStyleTargets,
    getBreakpoint: getBreakpoint,
    getAPIEndpoint: getAPIEndpoint,
    setAPIEndpoint: setAPIEndpoint,
    getMode: getMode,
    setMode: setMode,
    getRenderMode: getRenderMode,
    setRenderMode: setRenderMode,
    parseStringAsTemplate: parseStringAsTemplate,
    findText: findText,
    deInit: deInit,
    inAdmin: false,
    lmv: 2,
    homeid: '00000000000000000000000000000000001',
    cloning: false
  });
  Mura.Module = Mura.DisplayObject;
  return Mura;
}
module.exports = attach;

/***/ }),

/***/ 839:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  'use strict';

  /**
   * Creates a new Mura.DOMSelection
   * @name	Mura.DOMSelection
   * @class
   * @param	{object} properties Object containing values to set into object
   * @return {Mura.DOMSelection}
   * @extends Mura.Core
   * @memberof Mura
   */

  /**
  	* @ignore
  	*/
  Mura.DOMSelection = Mura.Core.extend( /** @lends Mura.DOMSelection.prototype */
  {
    init: function init(selection, origSelector) {
      this.selection = selection;
      this.origSelector = origSelector;
      if (this.selection.length && this.selection[0]) {
        this.parentNode = this.selection[0].parentNode;
        this.childNodes = this.selection[0].childNodes;
        this.node = selection[0];
        this.length = this.selection.length;
      } else {
        this.parentNode = null;
        this.childNodes = null;
        this.node = null;
        this.length = 0;
      }
      if (typeof Mura.supportPassive == 'undefined') {
        Mura.supportsPassive = false;
        try {
          var opts = Object.defineProperty({}, 'passive', {
            get: function get() {
              Mura.supportsPassive = true;
            }
          });
          window.addEventListener("testPassive", null, opts);
          window.removeEventListener("testPassive", null, opts);
        } catch (e) {}
      }
    },
    /**
     * get - Deprecated: Returns element at index of selection, use item()
     *
     * @param	{number} index Index of selection
     * @return {*}
     */
    get: function get(index) {
      if (typeof index != 'undefined') {
        return this.selection[index];
      } else {
        return this.selection;
      }
    },
    /**
     * select - Returns new Mura.DomSelection
     *
     * @param	{string} selector Selector
     * @return {object}
     */
    select: function select(selector) {
      return Mura(selector);
    },
    /**
     * each - Runs function against each item in selection
     *
     * @param	{function} fn Method
     * @return {Mura.DOMSelection} Self
     */
    each: function each(fn) {
      this.selection.forEach(function (el, idx, array) {
        if (typeof fn.call == 'undefined') {
          fn(el, idx, array);
        } else {
          fn.call(el, el, idx, array);
        }
      });
      return this;
    },
    /**
     * each - Runs function against each item in selection
     *
     * @param	{function} fn Method
     * @return {Mura.DOMSelection} Self
     */
    forEach: function forEach(fn) {
      this.selection.forEach(function (el, idx, array) {
        if (typeof fn.call == 'undefined') {
          fn(el, idx, array);
        } else {
          fn.call(el, el, idx, array);
        }
      });
      return this;
    },
    /**
     * filter - Creates a new Mura.DomSelection instance contains selection values that pass filter function by returning true
     *
     * @param	{function} fn Filter function
     * @return {object}		New Mura.DOMSelection
     */
    filter: function filter(fn) {
      return Mura(this.selection.filter(function (el, idx, array) {
        if (typeof fn.call == 'undefined') {
          return fn(el, idx, array);
        } else {
          return fn.call(el, el, idx, array);
        }
      }));
    },
    /**
     * map - Creates a new Mura.DomSelection instance contains selection values that are returned by Map function
     *
     * @param	{function} fn Map function
     * @return {object}		New Mura.DOMSelection
     */
    map: function map(fn) {
      return Mura(this.selection.map(function (el, idx, array) {
        if (typeof fn.call == 'undefined') {
          return fn(el, idx, array);
        } else {
          return fn.call(el, el, idx, array);
        }
      }));
    },
    /**
     * reduce - Returns value from	reduce function
     *
     * @param	{function} fn Reduce function
     * @param	{any} initialValue Starting accumulator value
     * @return {accumulator}
     */
    reduce: function reduce(fn, initialValue) {
      initialValue = initialValue || 0;
      return this.selection.reduce(function (accumulator, item, idx, array) {
        if (typeof fn.call == 'undefined') {
          return fn(accumulator, item, idx, array);
        } else {
          return fn.call(item, accumulator, item, idx, array);
        }
      }, initialValue);
    },
    /**
     * isNumeric - Returns if value is numeric
     *
     * @param	{*} val Value
     * @return {type}		 description
     */
    isNumeric: function (_isNumeric) {
      function isNumeric(_x) {
        return _isNumeric.apply(this, arguments);
      }
      isNumeric.toString = function () {
        return _isNumeric.toString();
      };
      return isNumeric;
    }(function (val) {
      if (typeof val != 'undefined') {
        return isNumeric(val);
      }
      return isNumeric(this.selection[0]);
    }),
    /**
     * processMarkup - Process Markup of selected dom elements
     *
     * @return {Promise}
     */
    processMarkup: function processMarkup() {
      var self = this;
      return new Promise(function (resolve, reject) {
        self.each(function (el) {
          Mura.processMarkup(el);
        });
      });
    },
    /**
     * addEventHandler - Add event event handling object
     *
     * @param	{string} selector	Selector (optional: for use with delegated events)
     * @param	{object} handler				description
     * @return {Mura.DOMSelection} Self
     */
    addEventHandler: function addEventHandler(selector, handler) {
      if (typeof handler == 'undefined') {
        handler = selector;
        selector = '';
      }
      for (var h in handler) {
        if (eventName.hasOwnProperty(h)) {
          if (typeof selector == 'string' && selector) {
            on(h, selector, handler[h]);
          } else {
            on(h, handler[h]);
          }
        }
      }
      return this;
    },
    /**
     * on - Add event handling method
     *
     * @param	{string} eventName Event name
     * @param	{string} selector	Selector (optional: for use with delegated events)
     * @param	{function} fn				description
     * @return {Mura.DOMSelection} Self
     */
    on: function on(eventName, selector, fn, EventListenerOptions) {
      if (typeof EventListenerOptions == 'undefined') {
        if (typeof fn != 'undefined' && typeof fn != 'function') {
          EventListenerOptions = fn;
        } else {
          EventListenerOptions = true;
        }
      }
      if (eventName == 'touchstart' || eventName == 'end') {
        EventListenerOptions = Mura.supportsPassive ? {
          passive: true
        } : false;
      }
      if (typeof selector == 'function') {
        fn = selector;
        selector = '';
      }
      if (eventName == 'ready') {
        if (document.readyState != 'loading') {
          var self = this;
          setTimeout(function () {
            self.each(function (target) {
              if (selector) {
                Mura(target).find(selector).each(function (target) {
                  if (typeof fn.call == 'undefined') {
                    fn(target);
                  } else {
                    fn.call(target, target);
                  }
                });
              } else {
                if (typeof fn.call == 'undefined') {
                  fn(target);
                } else {
                  fn.call(target, target);
                }
              }
            });
          }, 1);
          return this;
        } else {
          eventName = 'DOMContentLoaded';
        }
      }
      this.each(function (el) {
        if (typeof this.addEventListener == 'function') {
          var self = el;
          this.addEventListener(eventName, function (event) {
            if (selector) {
              if (Mura(event.target).is(selector)) {
                if (typeof fn.call == 'undefined') {
                  return fn(event);
                } else {
                  return fn.call(event.target, event);
                }
              }
            } else {
              if (typeof fn.call == 'undefined') {
                return fn(event);
              } else {
                return fn.call(self, event);
              }
            }
          }, EventListenerOptions);
        }
      });
      return this;
    },
    /**
     * hover - Adds hovering events to selected dom elements
     *
     * @param	{function} handlerIn	In method
     * @param	{function} handlerOut Out method
     * @return {object}						Self
     */
    hover: function hover(handlerIn, handlerOut, EventListenerOptions) {
      if (typeof EventListenerOptions == 'undefined' || EventListenerOptions == null) {
        EventListenerOptions = Mura.supportsPassive ? {
          passive: true
        } : false;
      }
      this.on('mouseover', handlerIn, EventListenerOptions);
      this.on('mouseout', handlerOut, EventListenerOptions);
      this.on('touchstart', handlerIn, EventListenerOptions);
      this.on('touchend', handlerOut, EventListenerOptions);
      return this;
    },
    /**
     * click - Adds onClick event handler to selection
     *
     * @param	{function} fn Handler function
     * @return {Mura.DOMSelection} Self
     */
    click: function click(fn) {
      this.on('click', fn);
      return this;
    },
    /**
     * change - Adds onChange event handler to selection
     *
     * @param	{function} fn Handler function
     * @return {Mura.DOMSelection} Self
     */
    change: function change(fn) {
      this.on('change', fn);
      return this;
    },
    /**
     * submit - Adds onSubmit event handler to selection
     *
     * @param	{function} fn Handler function
     * @return {Mura.DOMSelection} Self
     */
    submit: function submit(fn) {
      if (fn) {
        this.on('submit', fn);
      } else {
        this.each(function (el) {
          if (typeof el.submit == 'function') {
            Mura.submitForm(el);
          }
        });
      }
      return this;
    },
    /**
     * ready - Adds onReady event handler to selection
     *
     * @param	{function} fn Handler function
     * @return {Mura.DOMSelection} Self
     */
    ready: function ready(fn) {
      this.on('ready', fn);
      return this;
    },
    /**
     * off - Removes event handler from selection
     *
     * @param	{string} eventName Event name
     * @param	{function} fn			Function to remove	(optional)
     * @return {Mura.DOMSelection} Self
     */
    off: function off(eventName, fn) {
      this.each(function (el, idx, array) {
        if (typeof eventName != 'undefined') {
          if (typeof fn != 'undefined') {
            el.removeEventListener(eventName, fn);
          } else {
            el[eventName] = null;
          }
        } else {
          if (typeof el.parentElement != 'undefined' && el.parentElement && typeof el.parentElement.replaceChild != 'undefined') {
            var elClone = el.cloneNode(true);
            el.parentElement.replaceChild(elClone, el);
            array[idx] = elClone;
          } else {
            console.log("Mura: Can not remove all handlers from element without a parent node");
          }
        }
      });
      return this;
    },
    /**
     * unbind - Removes event handler from selection
     *
     * @param	{string} eventName Event name
     * @param	{function} fn			Function to remove	(optional)
     * @return {Mura.DOMSelection} Self
     */
    unbind: function unbind(eventName, fn) {
      this.off(eventName, fn);
      return this;
    },
    /**
     * bind - Add event handling method
     *
     * @param	{string} eventName Event name
     * @param	{string} selector	Selector (optional: for use with delegated events)
     * @param	{function} fn				description
     * @return {Mura.DOMSelection}					 Self
     */
    bind: function bind(eventName, fn) {
      this.on(eventName, fn);
      return this;
    },
    /**
     * trigger - Triggers event on selection
     *
     * @param	{string} eventName	 Event name
     * @param	{object} eventDetail Event properties
     * @return {Mura.DOMSelection}						 Self
     */
    trigger: function trigger(eventName, eventDetail) {
      eventDetail = eventDetail || {};
      this.each(function (el) {
        Mura.trigger(el, eventName, eventDetail);
      });
      return this;
    },
    /**
     * parent - Return new Mura.DOMSelection of the first elements parent
     *
     * @return {Mura.DOMSelection}
     */
    parent: function parent() {
      if (!this.selection.length) {
        return this;
      }
      return Mura(this.selection[0].parentNode);
    },
    /**
     * children - Returns new Mura.DOMSelection or the first elements children
     *
     * @param	{string} selector Filter (optional)
     * @return {Mura.DOMSelection}
     */
    children: function children(selector) {
      if (!this.selection.length) {
        return this;
      }
      if (this.selection[0].hasChildNodes()) {
        var children = Mura(this.selection[0].childNodes);
        if (typeof selector == 'string') {
          var filterFn = function filterFn(el) {
            return (el.nodeType === 1 || el.nodeType === 11 || el.nodeType === 9) && el.matchesSelector(selector);
          };
        } else {
          var filterFn = function filterFn(el) {
            return el.nodeType === 1 || el.nodeType === 11 || el.nodeType === 9;
          };
        }
        return children.filter(filterFn);
      } else {
        return Mura([]);
      }
    },
    /**
     * find - Returns new Mura.DOMSelection matching items under the first selection
     *
     * @param	{string} selector Selector
     * @return {Mura.DOMSelection}
     */
    find: function find(selector) {
      if (this.selection.length && this.selection[0]) {
        var removeId = false;
        if (this.selection[0].nodeType == '1' || this.selection[0].nodeType == '11') {
          var result = this.selection[0].querySelectorAll(selector);
        } else if (this.selection[0].nodeType == '9') {
          var result = document.querySelectorAll(selector);
        } else {
          var result = [];
        }
        return Mura(result);
      } else {
        return Mura([]);
      }
    },
    /**
     * first - Returns first item in selection
     *
     * @return {*}
     */
    first: function first() {
      if (this.selection.length) {
        return Mura(this.selection[0]);
      } else {
        return Mura([]);
      }
    },
    /**
     * last - Returns last item in selection
     *
     * @return {*}
     */
    last: function last() {
      if (this.selection.length) {
        return Mura(this.selection[this.selection.length - 1]);
      } else {
        return Mura([]);
      }
    },
    /**
     * selector - Returns css selector for first item in selection
     *
     * @return {string}
     */
    selector: function selector() {
      var pathes = [];
      var path,
        node = Mura(this.selection[0]);
      while (node.length) {
        var realNode = node.get(0),
          name = realNode.localName;
        if (!name) {
          break;
        }
        if (!node.data('hastempid') && node.attr('id') && node.attr('id') != 'mura-variation-el') {
          name = '#' + node.attr('id');
          path = name + (path ? ' > ' + path : '');
          break;
        } else if (node.data('instanceid')) {
          name = '[data-instanceid="' + node.data('instanceid') + '"]';
          path = name + (path ? ' > ' + path : '');
          break;
        } else {
          name = name.toLowerCase();
          var parent = node.parent();
          var sameTagSiblings = parent.children(name);
          if (sameTagSiblings.length > 1) {
            var allSiblings = parent.children();
            var index = allSiblings.index(realNode) + 1;
            if (index > 0) {
              name += ':nth-child(' + index + ')';
            }
          }
          path = name + (path ? ' > ' + path : '');
          node = parent;
        }
      }
      pathes.push(path);
      return pathes.join(',');
    },
    /**
     * siblings - Returns new Mura.DOMSelection of first item's siblings
     *
     * @param	{string} selector Selector to filter siblings (optional)
     * @return {Mura.DOMSelection}
     */
    siblings: function siblings(selector) {
      if (!this.selection.length) {
        return this;
      }
      var el = this.selection[0];
      if (el.hasChildNodes()) {
        var silbings = Mura(this.selection[0].childNodes);
        if (typeof selector == 'string') {
          var filterFn = function filterFn(el) {
            return (el.nodeType === 1 || el.nodeType === 11 || el.nodeType === 9) && el.matchesSelector(selector);
          };
        } else {
          var filterFn = function filterFn(el) {
            return el.nodeType === 1 || el.nodeType === 11 || el.nodeType === 9;
          };
        }
        return silbings.filter(filterFn);
      } else {
        return Mura([]);
      }
    },
    /**
     * item - Returns item at selected index
     *
     * @param	{number} idx Index to return
     * @return {*}
     */
    item: function item(idx) {
      return this.selection[idx];
    },
    /**
     * index - Returns the index of element
     *
     * @param	{*} el Element to return index of
     * @return {*}
     */
    index: function index(el) {
      return this.selection.indexOf(el);
    },
    /**
     * indexOf - Returns the index of element
     *
     * @param	{*} el Element to return index of
     * @return {*}
     */
    indexOf: function indexOf(el) {
      return this.selection.indexOf(el);
    },
    /**
     * closest - Returns new Mura.DOMSelection of closest parent matching selector
     *
     * @param	{string} selector Selector
     * @return {Mura.DOMSelection}
     */
    closest: function closest(selector) {
      if (!this.selection.length) {
        return null;
      }
      var el = this.selection[0];
      for (var parent = el; parent !== null && parent.matchesSelector && !parent.matchesSelector(selector); parent = el.parentElement) {
        el = parent;
      }
      ;
      if (parent) {
        return Mura(parent);
      } else {
        return Mura([]);
      }
    },
    /**
     * append - Appends element to items in selection
     *
     * @param	{*} el Element to append
     * @return {Mura.DOMSelection} Self
     */
    append: function append(el) {
      this.each(function (target) {
        try {
          if (typeof el == 'string') {
            target.insertAdjacentHTML('beforeend', el);
          } else {
            target.appendChild(el);
          }
        } catch (e) {
          console.log(e);
        }
      });
      return this;
    },
    /**
     * appendDisplayObject - Appends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    appendDisplayObject: function appendDisplayObject(data) {
      var self = this;
      delete data.method;
      if (typeof data.transient == 'undefined') {
        data.transient = true;
      }
      return new Promise(function (resolve, reject) {
        self.each(function (target) {
          var el = document.createElement('div');
          el.setAttribute('class', 'mura-object');
          var preserveid = false;
          for (var a in data) {
            if (_typeof(data[a]) == 'object') {
              el.setAttribute('data-' + a, JSON.stringify(data[a]));
            } else if (a != 'preserveid') {
              el.setAttribute('data-' + a, data[a]);
            } else {
              preserveid = data[a];
            }
          }
          if (typeof data.async == 'undefined') {
            el.setAttribute('data-async', true);
          }
          if (typeof data.render == 'undefined') {
            el.setAttribute('data-render', 'server');
          }
          if (preserveid && Mura.isUUID(data.instanceid)) {
            el.setAttribute('data-instanceid', data.instanceid);
          } else {
            el.setAttribute('data-instanceid', Mura.createUUID());
          }
          var self = target;
          function watcher() {
            if (Mura.markupInitted) {
              Mura(self).append(el);
              Mura.processDisplayObject(el, true, true).then(resolve, reject);
            } else {
              setTimeout(watcher);
            }
          }
          watcher();
        });
      });
    },
    /**
     * appendModule - Appends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    appendModule: function appendModule(data) {
      return this.appendDisplayObject(data);
    },
    /**
     * insertDisplayObjectAfter - Inserts display object after selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    insertDisplayObjectAfter: function insertDisplayObjectAfter(data) {
      var self = this;
      delete data.method;
      if (typeof data.transient == 'undefined') {
        data.transient = true;
      }
      return new Promise(function (resolve, reject) {
        self.each(function (target) {
          var el = document.createElement('div');
          el.setAttribute('class', 'mura-object');
          var preserveid = false;
          for (var a in data) {
            if (_typeof(data[a]) == 'object') {
              el.setAttribute('data-' + a, JSON.stringify(data[a]));
            } else if (a != 'preserveid') {
              el.setAttribute('data-' + a, data[a]);
            } else {
              preserveid = data[a];
            }
          }
          if (typeof data.async == 'undefined') {
            el.setAttribute('data-async', true);
          }
          if (typeof data.render == 'undefined') {
            el.setAttribute('data-render', 'server');
          }
          if (preserveid && Mura.isUUID(data.instanceid)) {
            el.setAttribute('data-instanceid', data.instanceid);
          } else {
            el.setAttribute('data-instanceid', Mura.createUUID());
          }
          var self = target;
          function watcher() {
            if (Mura.markupInitted) {
              Mura(self).after(el);
              Mura.processDisplayObject(el, true, true).then(resolve, reject);
            } else {
              setTimeout(watcher);
            }
          }
          watcher();
        });
      });
    },
    /**
     * insertModuleAfter - Appends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    insertModuleAfter: function insertModuleAfter(data) {
      return this.insertDisplayObjectAfter(data);
    },
    /**
     * insertDisplayObjectBefore - Inserts display object after selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    insertDisplayObjectBefore: function insertDisplayObjectBefore(data) {
      var self = this;
      delete data.method;
      if (typeof data.transient == 'undefined') {
        data.transient = true;
      }
      return new Promise(function (resolve, reject) {
        self.each(function (target) {
          var el = document.createElement('div');
          el.setAttribute('class', 'mura-object');
          var preserveid = false;
          for (var a in data) {
            if (_typeof(data[a]) == 'object') {
              el.setAttribute('data-' + a, JSON.stringify(data[a]));
            } else if (a != 'preserveid') {
              el.setAttribute('data-' + a, data[a]);
            } else {
              preserveid = data[a];
            }
          }
          if (typeof data.async == 'undefined') {
            el.setAttribute('data-async', true);
          }
          if (typeof data.render == 'undefined') {
            el.setAttribute('data-render', 'server');
          }
          if (preserveid && Mura.isUUID(data.instanceid)) {
            el.setAttribute('data-instanceid', data.instanceid);
          } else {
            el.setAttribute('data-instanceid', Mura.createUUID());
          }
          var self = target;
          function watcher() {
            if (Mura.markupInitted) {
              Mura(self).before(el);
              Mura.processDisplayObject(el, true, true).then(resolve, reject);
            } else {
              setTimeout(watcher);
            }
          }
          watcher();
        });
      });
    },
    /**
     * insertModuleBefore - Appends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    insertModuleBefore: function insertModuleBefore(data) {
      return this.insertDisplayObjectBefore(data);
    },
    /**
     * prependDisplayObject - Prepends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    prependDisplayObject: function prependDisplayObject(data) {
      var self = this;
      delete data.method;
      if (typeof data.transient == 'undefined') {
        data.transient = true;
      }
      return new Promise(function (resolve, reject) {
        self.each(function (target) {
          var el = document.createElement('div');
          el.setAttribute('class', 'mura-object');
          var preserveid = false;
          for (var a in data) {
            if (_typeof(data[a]) == 'object') {
              el.setAttribute('data-' + a, JSON.stringify(data[a]));
            } else if (a != 'preserveid') {
              el.setAttribute('data-' + a, data[a]);
            } else {
              preserveid = data[a];
            }
          }
          if (typeof data.async == 'undefined') {
            el.setAttribute('data-async', true);
          }
          if (typeof data.render == 'undefined') {
            el.setAttribute('data-render', 'server');
          }
          if (preserveid && Mura.isUUID(data.instanceid)) {
            el.setAttribute('data-instanceid', data.instanceid);
          } else {
            el.setAttribute('data-instanceid', Mura.createUUID());
          }
          var self = target;
          function watcher() {
            if (Mura.markupInitted) {
              Mura(self).prepend(el);
              Mura.processDisplayObject(el, true, true).then(resolve, reject);
            } else {
              setTimeout(watcher);
            }
          }
          watcher();
        });
      });
    },
    /**
     * prependModule - Prepends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    prependModule: function prependModule(data) {
      return this.prependDisplayObject(data);
    },
    /**
     * processDisplayObject - Handles processing of display object params to selection
     *
     * @return {Promise}
     */
    processDisplayObject: function processDisplayObject() {
      var self = this;
      return new Promise(function (resolve, reject) {
        self.each(function (target) {
          Mura.processDisplayObject(target, true, true).then(resolve, reject);
        });
      });
    },
    /**
     * processModule - Prepends display object to selected items
     *
     * @return {Promise}
     */
    processModule: function processModule() {
      return this.processDisplayObject();
    },
    /**
     * prepend - Prepends element to items in selection
     *
     * @param	{*} el Element to append
     * @return {Mura.DOMSelection} Self
     */
    prepend: function prepend(el) {
      this.each(function (target) {
        try {
          if (typeof el == 'string') {
            target.insertAdjacentHTML('afterbegin', el);
          } else {
            target.insertBefore(el, target.firstChild);
          }
        } catch (e) {
          console.log(e);
        }
      });
      return this;
    },
    /**
     * before - Inserts element before items in selection
     *
     * @param	{*} el Element to append
     * @return {Mura.DOMSelection} Self
     */
    before: function before(el) {
      this.each(function (target) {
        try {
          if (typeof el == 'string') {
            target.insertAdjacentHTML('beforebegin', el);
          } else {
            target.parentNode.insertBefore(el, target);
          }
        } catch (e) {
          console.log(e);
        }
      });
      return this;
    },
    /**
     * after - Inserts element after items in selection
     *
     * @param	{*} el Element to append
     * @return {Mura.DOMSelection} Self
     */
    after: function after(el) {
      this.each(function (target) {
        try {
          if (typeof el == 'string') {
            target.insertAdjacentHTML('afterend', el);
          } else {
            if (target.nextSibling) {
              target.parentNode.insertBefore(el, target.nextSibling);
            } else {
              target.parentNode.appendChild(el);
            }
          }
        } catch (e) {
          console.log(e);
        }
      });
      return this;
    },
    /**
     * hide - Hides elements in selection
     *
     * @return {object}	Self
     */
    hide: function hide() {
      this.each(function (el) {
        el.style.display = 'none';
      });
      return this;
    },
    /**
     * show - Shows elements in selection
     *
     * @return {object}	Self
     */
    show: function show() {
      this.each(function (el) {
        el.style.display = '';
      });
      return this;
    },
    /**
     * repaint - repaints elements in selection
     *
     * @return {object}	Self
     */
    redraw: function redraw() {
      this.each(function (el) {
        var elm = Mura(el);
        setTimeout(function () {
          elm.show();
        }, 1);
      });
      return this;
    },
    /**
     * remove - Removes elements in selection
     *
     * @return {object}	Self
     */
    remove: function remove() {
      this.each(function (el) {
        el.parentNode && el.parentNode.removeChild(el);
      });
      return this;
    },
    /**
     * detach - Detaches elements in selection
     *
     * @return {object}	Self
     */
    detach: function detach() {
      var detached = [];
      this.each(function (el) {
        el.parentNode && detached.push(el.parentNode.removeChild(el));
      });
      return Mura(detached);
    },
    /**
     * addClass - Adds class to elements in selection
     *
     * @param	{string} className Name of class
     * @return {Mura.DOMSelection} Self
     */
    addClass: function addClass(className) {
      if (className.length) {
        this.each(function (el) {
          if (el.classList) {
            el.classList.add(className);
          } else {
            el.className += ' ' + className;
          }
        });
      }
      return this;
    },
    /**
     * hasClass - Returns if the first element in selection has class
     *
     * @param	{string} className Class name
     * @return {Mura.DOMSelection} Self
     */
    hasClass: function hasClass(className) {
      return this.is("." + className);
    },
    /**
     * removeClass - Removes class from elements in selection
     *
     * @param	{string} className Class name
     * @return {Mura.DOMSelection} Self
     */
    removeClass: function removeClass(className) {
      this.each(function (el) {
        if (el.classList) {
          el.classList.remove(className);
        } else if (el.className) {
          el.className = el.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ');
        }
      });
      return this;
    },
    /**
     * toggleClass - Toggles class on elements in selection
     *
     * @param	{string} className Class name
     * @return {Mura.DOMSelection} Self
     */
    toggleClass: function toggleClass(className) {
      this.each(function (el) {
        if (el.classList) {
          el.classList.toggle(className);
        } else {
          var classes = el.className.split(' ');
          var existingIndex = classes.indexOf(className);
          if (existingIndex >= 0) classes.splice(existingIndex, 1);else classes.push(className);
          el.className = classes.join(' ');
        }
      });
      return this;
    },
    /**
     * empty - Removes content from elements in selection
     *
     * @return {object}	Self
     */
    empty: function empty() {
      this.each(function (el) {
        el.innerHTML = '';
      });
      return this;
    },
    /**
     * evalScripts - Evaluates script tags in selection elements
     *
     * @return {object}	Self
     */
    evalScripts: function evalScripts() {
      if (!this.selection.length) {
        return this;
      }
      this.each(function (el) {
        Mura.evalScripts(el);
      });
      return this;
    },
    /**
     * html - Returns or sets HTML of elements in selection
     *
     * @param	{string} htmlString description
     * @return {object}						Self
     */
    html: function html(htmlString) {
      if (typeof htmlString != 'undefined') {
        this.each(function (el) {
          el.innerHTML = htmlString;
          Mura.evalScripts(el);
        });
        return this;
      } else {
        if (!this.selection.length) {
          return '';
        }
        return this.selection[0].innerHTML;
      }
    },
    /**
     * css - Sets css value for elements in selection
     *
     * @param	{string} ruleName Css rule name
     * @param	{string} value		Rule value
     * @return {object}					Self
     */
    css: function css(ruleName, value) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof ruleName == 'undefined' && typeof value == 'undefined') {
        try {
          return getComputedStyle(this.selection[0]);
        } catch (e) {
          //console.log(e)
          return {};
        }
      } else if (_typeof(ruleName) == 'object') {
        this.each(function (el) {
          try {
            for (var p in ruleName) {
              el.style[Mura.styleMap.tojs[p.toLowerCase()]] = ruleName[p];
            }
          } catch (e) {
            //console.log(e)
          }
        });
      } else if (typeof value != 'undefined') {
        this.each(function (el) {
          try {
            el.style[Mura.styleMap.tojs[ruleName.toLowerCase()]] = value;
          } catch (e) {
            //console.log(e)
          }
        });
        return this;
      } else {
        try {
          return getComputedStyle(this.selection[0])[Mura.styleMap.tojs[ruleName.toLowerCase()]];
        } catch (e) {
          //console.log(e)
        }
      }
      return this;
    },
    /**
     * calculateDisplayObjectStyles - Looks at data attrs and sets appropriate styles
     *
     * @return {object}	Self
     */
    calculateDisplayObjectStyles: function calculateDisplayObjectStyles(windowResponse) {
      this.each(function (el) {
        var breakpoints = ['mura-xs', 'mura-sm', 'mura-md', 'mura-lg', 'mura-xl'];
        var objBreakpoint = 'mura-sm';
        var obj = Mura(el);
        for (var b = 0; b < breakpoints.length; b++) {
          if (obj.is('.' + breakpoints[b])) {
            objBreakpoint = breakpoints[b];
            break;
          }
        }
        var styleTargets = Mura.getModuleStyleTargets(obj.data('instanceid'), true);
        var fullsize = breakpoints.indexOf('mura-' + Mura.getBreakpoint()) >= breakpoints.indexOf(objBreakpoint);
        Mura.windowResponsiveModules = Mura.windowResponsiveModules || {};
        Mura.windowResponsiveModules[obj.data('instanceid')] = false;
        obj = obj.node ? obj : Mura(obj);
        if (!windowResponse) {
          applyObjectClassesAndId(obj);
        }
        var styleSupport = obj.data('stylesupport') || {};
        if (typeof styleSupport == 'string') {
          try {
            styleSupport = JSON.parse.call(null, styleSupport);
          } catch (e) {
            styleSupport = {};
          }
          if (typeof styleSupport == 'string') {
            styleSupport = {};
          }
        }
        obj.removeAttr('style');
        if (!fullsize) {
          if (styleSupport && _typeof(styleSupport.objectstyles) == 'object') {
            var objectstyles = styleSupport.objectstyles;
            delete objectstyles.margin;
            delete objectstyles.marginLeft;
            delete objectstyles.marginRight;
            delete objectstyles.marginTop;
            delete objectstyles.marginBottom;
          }
        }
        if (!fullsize || fullsize && !(obj.css('marginTop') == '0px' && obj.css('marginBottom') == '0px' && obj.css('marginLeft') == '0px' && obj.css('marginRight') == '0px')) {
          Mura.windowResponsiveModules[obj.data('instanceid')] = true;
        }
        if (!windowResponse) {
          var sheet = Mura.getStyleSheet('mura-styles-' + obj.data('instanceid'));
          while (sheet.cssRules.length) {
            sheet.deleteRule(0);
          }
          Mura.applyModuleStyles(styleSupport, styleTargets.object, sheet, obj);
          Mura.applyModuleCustomCSS(styleSupport, sheet, obj.data('instanceid'));
        }
        var metaWrapper = obj.children('.mura-object-meta-wrapper');
        if (metaWrapper.length) {
          styleSupport.metastyles = styleSupport.metastyles || {};
          var meta = metaWrapper.children('.mura-object-meta');
          if (meta.length) {
            meta.removeAttr('style');
            if (!windowResponse) {
              applyMetaClassesAndId(obj, meta, metaWrapper);
              Mura.applyModuleStyles(styleSupport, styleTargets.meta, sheet, obj);
            }
          }
        }
        var content = obj.children('.mura-object-content').first();
        content.removeAttr('style');
        if (!windowResponse) {
          applyContentClassesAndId(obj, content, metaWrapper);
          Mura.applyModuleStyles(styleSupport, styleTargets.content, sheet, obj);
        }
        applyMarginWidthOffset(obj);
        pinUIToolsToTopLeft(obj);
        function applyObjectClassesAndId(obj) {
          if (obj.data('class')) {
            var classes = obj.data('class');
            if (typeof classes != 'Array') {
              var classes = classes.split(' ');
            }
            for (var c = 0; c < classes.length; c++) {
              if (!obj.hasClass(classes[c])) {
                obj.addClass(classes[c]);
              }
            }
          }
          if (obj.data('cssclass')) {
            var classes = obj.data('cssclass');
            if (typeof classes != 'array') {
              var classes = classes.split(' ');
            }
            for (var c = 0; c < classes.length; c++) {
              if (!obj.hasClass(classes[c])) {
                obj.addClass(classes[c]);
              }
            }
          }
          if (obj.data('objectspacing')) {
            var classes = obj.data('objectspacing');
            if (typeof classes != 'array') {
              var classes = classes.split(' ');
            }
            for (var c = 0; c < classes.length; c++) {
              if (c != 'custom' && !obj.hasClass(classes[c])) {
                obj.addClass(classes[c]);
              }
            }
          }
          if (obj.data('cssid')) {
            obj.attr('id', obj.data('cssid'));
          } else {
            obj.removeAttr('id');
          }
        }
        function applyMetaClassesAndId(obj, meta, metawrapper) {
          if (obj.data('metacssid')) {
            meta.attr('id', obj.data('metacssid'));
          } else {
            meta.removeAttr('id');
          }
          if (obj.data('metacssclass')) {
            obj.data('metacssclass').split(' ').forEach(function (c) {
              if (!meta.hasClass(c)) {
                meta.addClass(c);
              }
            });
          }
          if (obj.data('metaspacing')) {
            var classes = obj.data('metaspacing');
            if (typeof classes != 'array') {
              var classes = classes.split(' ');
            }
            for (var c = 0; c < classes.length; c++) {
              if (c != 'custom' && !meta.hasClass(classes[c])) {
                meta.addClass(classes[c]);
              }
            }
          }
          if (obj.is('.mura-object-label-left, .mura-object-label-right')) {
            var left = meta.css('marginLeft');
            var right = meta.css('marginRight');
            if (!(left == '0px' && right == '0px') && left.charAt(0) != "-" && right.charAt(0) != "-") {
              meta.css('width', 'calc(50% - (' + left + ' + ' + right + '))');
            }
          }
        }
        function applyContentClassesAndId(obj, content, metaWrapper) {
          if (obj.data('contentcssid')) {
            content.attr('id', obj.data('contentcssid'));
          } else {
            content.removeAttr('id');
          }
          if (obj.data('contentcssclass')) {
            obj.data('contentcssclass').split(' ').forEach(function (c) {
              if (!content.hasClass(c)) {
                content.addClass(c);
              }
            });
          }
          if (obj.data('contentspacing')) {
            var classes = obj.data('contentspacing');
            if (typeof classes != 'array') {
              var classes = classes.split(' ');
            }
            for (var c = 0; c < classes.length; c++) {
              if (c != 'custom' && !content.hasClass(classes[c])) {
                content.addClass(classes[c]);
              }
            }
          }
          if (content.hasClass('container')) {
            metaWrapper.addClass('container');
          } else {
            metaWrapper.removeClass('container');
          }
          if (obj.is('.mura-object-label-left, .mura-object-label-right')) {
            var left = content.css('marginLeft');
            var right = content.css('marginRight');
            if (!(left == '0px' && right == '0px') && left.charAt(0) != "-" && right.charAt(0) != "-") {
              if (fullsize) {
                content.css('width', 'calc(50% - (' + left + ' + ' + right + '))');
              }
              Mura.windowResponsiveModules[obj.data('instanceid')] = true;
            }
          }
        }
        function applyMarginWidthOffset(obj) {
          var left = obj.css('marginLeft');
          var right = obj.css('marginRight');
          if (!obj.is('.mura-center') && !(left == '0px' && right == '0px') && !(left == 'auto' || right == 'auto') && left.charAt && left.charAt(0) != "-" && right.charAt && right.charAt(0) != "-") {
            if (fullsize) {
              var width = '100%';
              if (obj.is('.mura-one')) {
                width = '8.33%';
              } else if (obj.is('.mura-two')) {
                width = '16.66%';
              } else if (obj.is('.mura-three')) {
                width = '25%';
              } else if (obj.is('.mura-four')) {
                width = '33.33%';
              } else if (obj.is('.mura-five')) {
                width = '41.66%';
              } else if (obj.is('.mura-six')) {
                width = '50%';
              } else if (obj.is('.mura-seven')) {
                width = '58.33';
              } else if (obj.is('.mura-eight')) {
                width = '66.66%';
              } else if (obj.is('.mura-nine')) {
                width = '75%';
              } else if (obj.is('.mura-ten')) {
                width = '83.33%';
              } else if (obj.is('.mura-eleven')) {
                width = '91.66%';
              } else if (obj.is('.mura-twelve')) {
                width = '100%';
              } else if (obj.is('.mura-one-third')) {
                width = '33.33%';
              } else if (obj.is('.mura-two-thirds')) {
                width = '66.66%';
              } else if (obj.is('.mura-one-half')) {
                width = '50%';
              } else {
                width = '100%';
              }
              obj.css('width', 'calc(' + width + ' - (' + left + ' + ' + right + '))');
            }
            Mura.windowResponsiveModules[obj.data('instanceid')] = true;
          }
        }
        function pinUIToolsToTopLeft(obj) {
          var top = obj.css('paddingTop');
          var left = obj.css('paddingTop');
          if (top.replace && (top.replace(/[^0-9]/g, '') != '0' || left.replace && left.replace(/[^0-9]/g, '') != '0')) {
            obj.addClass('mura-object-pin-tools');
          } else {
            obj.removeClass('mura-object-pin-tools');
          }
        }
      });
      return this;
    },
    /**
     * text - Gets or sets the text content of each element in the selection
     *
     * @param	{string} textString Text string
     * @return {object}						Self
     */
    text: function text(textString) {
      if (typeof textString != 'undefined') {
        this.each(function (el) {
          el.textContent = textString;
        });
        return this;
      } else {
        return this.selection[0].textContent;
      }
    },
    /**
     * is - Returns if the first element in the select matches the selector
     *
     * @param	{string} selector description
     * @return {boolean}
     */
    is: function is(selector) {
      if (!this.selection.length) {
        return false;
      }
      try {
        if (typeof this.selection[0] !== "undefined") {
          return this.selection[0].matchesSelector && this.selection[0].matchesSelector(selector);
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    },
    /**
     * hasAttr - Returns is the first element in the selection has an attribute
     *
     * @param	{string} attributeName description
     * @return {boolean}
     */
    hasAttr: function hasAttr(attributeName) {
      if (!this.selection.length) {
        return false;
      }
      return typeof this.selection[0].hasAttribute == 'function' && this.selection[0].hasAttribute(attributeName);
    },
    /**
     * hasData - Returns if the first element in the selection has data attribute
     *
     * @param	{sting} attributeName Data atttribute name
     * @return {boolean}
     */
    hasData: function hasData(attributeName) {
      if (!this.selection.length) {
        return false;
      }
      return this.hasAttr('data-' + attributeName);
    },
    /**
     * offsetParent - Returns first element in selection's offsetParent
     *
     * @return {object}	offsetParent
     */
    offsetParent: function offsetParent() {
      if (!this.selection.length) {
        return this;
      }
      var el = this.selection[0];
      return el.offsetParent || el;
    },
    /**
     * outerHeight - Returns first element in selection's outerHeight
     *
     * @param	{boolean} withMargin Whether to include margin
     * @return {number}
     */
    outerHeight: function outerHeight(withMargin) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof withMargin == 'undefined') {
        var outerHeight = function outerHeight(el) {
          var height = el.offsetHeight;
          var style = getComputedStyle(el);
          height += parseInt(style.marginTop) + parseInt(style.marginBottom);
          return height;
        };
        return outerHeight(this.selection[0]);
      } else {
        return this.selection[0].offsetHeight;
      }
    },
    /**
     * height - Returns height of first element in selection or set height for elements in selection
     *
     * @param	{number} height	Height (option)
     * @return {object}				Self
     */
    height: function height(_height) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof width != 'undefined') {
        if (!isNaN(_height)) {
          _height += 'px';
        }
        this.css('height', _height);
        return this;
      }
      var el = this.selection[0];
      //var type=el.constructor.name.toLowerCase();
      if (typeof window != 'undefined' && typeof window.document != 'undefined' && el === window) {
        return innerHeight;
      } else if (el === document) {
        var body = document.body;
        var html = document.documentElement;
        return Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
      }
      var styles = getComputedStyle(el);
      var margin = parseFloat(styles['marginTop']) + parseFloat(styles['marginBottom']);
      return Math.ceil(el.offsetHeight + margin);
    },
    /**
     * width - Returns width of first element in selection or set width for elements in selection
     *
     * @param	{number} width Width (optional)
     * @return {object}			 Self
     */
    width: function (_width) {
      function width(_x2) {
        return _width.apply(this, arguments);
      }
      width.toString = function () {
        return _width.toString();
      };
      return width;
    }(function (width) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof width != 'undefined') {
        if (!isNaN(width)) {
          width += 'px';
        }
        this.css('width', width);
        return this;
      }
      var el = this.selection[0];
      //var type=el.constructor.name.toLowerCase();
      if (typeof window != 'undefined' && typeof window.document != 'undefined' && el === window) {
        return innerWidth;
      } else if (el === document) {
        var body = document.body;
        var html = document.documentElement;
        return Math.max(body.scrollWidth, body.offsetWidth, html.clientWidth, html.scrolWidth, html.offsetWidth);
      }
      return getComputedStyle(el).width;
    }),
    /**
     * width - Returns outerWidth of first element in selection
     *
     * @return {number}
     */
    outerWidth: function outerWidth() {
      if (!this.selection.length) {
        return 0;
      }
      var el = this.selection[0];
      var width = el.offsetWidth;
      var style = getComputedStyle(el);
      width += parseInt(style.marginLeft) + parseInt(style.marginRight);
      return width;
    },
    /**
     * scrollTop - Returns the scrollTop of the current document
     *
     * @return {object}
     */
    scrollTop: function scrollTop() {
      if (!this.selection.length) {
        return 0;
      }
      var el = this.selection[0];
      if (typeof el.scrollTop != 'undefined') {
        return el.scrollTop;
      } else {
        return window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;
      }
    },
    /**
     * offset - Returns offset of first element in selection
     *
     * @return {object}
     */
    offset: function offset() {
      if (!this.selection.length) {
        return this;
      }
      var box = this.selection[0].getBoundingClientRect();
      return {
        top: box.top + (pageYOffset || document.scrollTop) - (document.clientTop || 0),
        left: box.left + (pageXOffset || document.scrollLeft) - (document.clientLeft || 0)
      };
    },
    /**
     * removeAttr - Removes attribute from elements in selection
     *
     * @param	{string} attributeName Attribute name
     * @return {object}							 Self
     */
    removeAttr: function removeAttr(attributeName) {
      if (!this.selection.length) {
        return this;
      }
      this.each(function (el) {
        if (el && typeof el.removeAttribute == 'function') {
          el.removeAttribute(attributeName);
        }
      });
      return this;
    },
    /**
     * changeElementType - Changes element type of elements in selection
     *
     * @param	{string} type Element type to change to
     * @return {Mura.DOMSelection} Self
     */
    changeElementType: function changeElementType(type) {
      if (!this.selection.length) {
        return this;
      }
      this.each(function (el) {
        Mura.changeElementType(el, type);
      });
      return this;
    },
    /**
     * val - Set the value of elements in selection
     *
     * @param	{*} value Value
     * @return {Mura.DOMSelection} Self
     */
    val: function val(value) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof value != 'undefined') {
        this.each(function (el) {
          if (el.tagName == 'radio') {
            if (el.value == value) {
              el.checked = true;
            } else {
              el.checked = false;
            }
          } else {
            el.value = value;
          }
        });
        return this;
      } else if (this.selection[0].tagName == 'SELECT') {
        var val = [];
        for (var j = this.selection[0].options.length - 1; j >= 0; j--) {
          if (this.selection[0].options[j].selected) {
            val.push(this.selection[0].options[j].value);
          }
        }
        return val.join(",");
      } else {
        if (Object.prototype.hasOwnProperty.call(this.selection[0], 'value') || typeof this.selection[0].value != 'undefined') {
          return this.selection[0].value;
        } else {
          return '';
        }
      }
    },
    /**
     * attr - Returns attribute value of first element in selection or set attribute value for elements in selection
     *
     * @param	{string} attributeName Attribute name
     * @param	{*} value				 Value (optional)
     * @return {Mura.DOMSelection} Self
     */
    attr: function attr(attributeName, value) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof value == 'undefined' && typeof attributeName == 'undefined') {
        return Mura.getAttributes(this.selection[0]);
      } else if (_typeof(attributeName) == 'object') {
        this.each(function (el) {
          if (el.setAttribute) {
            for (var p in attributeName) {
              el.setAttribute(p, attributeName[p]);
            }
          }
        });
        return this;
      } else if (typeof value != 'undefined') {
        this.each(function (el) {
          if (el.setAttribute) {
            el.setAttribute(attributeName, value);
          }
        });
        return this;
      } else {
        if (this.selection[0] && this.selection[0].getAttribute) {
          return this.selection[0].getAttribute(attributeName);
        } else {
          return undefined;
        }
      }
    },
    /**
     * data - Returns data attribute value of first element in selection or set data attribute value for elements in selection
     *
     * @param	{string} attributeName Attribute name
     * @param	{*} value				 Value (optional)
     * @return {Mura.DOMSelection} Self
     */
    data: function data(attributeName, value) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof value == 'undefined' && typeof attributeName == 'undefined') {
        return Mura.getData(this.selection[0]);
      } else if (_typeof(attributeName) == 'object') {
        this.each(function (el) {
          for (var p in attributeName) {
            el.setAttribute("data-" + p, attributeName[p]);
          }
        });
        return this;
      } else if (typeof value != 'undefined') {
        this.each(function (el) {
          el.setAttribute("data-" + attributeName, value);
        });
        return this;
      } else if (this.selection[0] && this.selection[0].getAttribute) {
        return Mura.parseString(this.selection[0].getAttribute("data-" + attributeName));
      } else {
        return undefined;
      }
    },
    /**
     * prop - Returns attribute value of first element in selection or set attribute value for elements in selection
     *
     * @param	{string} attributeName Attribute name
     * @param	{*} value				 Value (optional)
     * @return {Mura.DOMSelection} Self
     */
    prop: function prop(attributeName, value) {
      if (!this.selection.length) {
        return this;
      }
      if (typeof value == 'undefined' && typeof attributeName == 'undefined') {
        return Mura.getProps(this.selection[0]);
      } else if (_typeof(attributeName) == 'object') {
        this.each(function (el) {
          for (var p in attributeName) {
            el.setAttribute(p, attributeName[p]);
          }
        });
        return this;
      } else if (typeof value != 'undefined') {
        this.each(function (el) {
          el.setAttribute(attributeName, value);
        });
        return this;
      } else {
        return Mura.parseString(this.selection[0].getAttribute(attributeName));
      }
    },
    /**
     * fadeOut - Fades out elements in selection
     *
     * @return {Mura.DOMSelection} Self
     */
    fadeOut: function fadeOut() {
      this.each(function (el) {
        el.style.opacity = 1;
        (function fade() {
          if ((el.style.opacity -= .1) < 0) {
            el.style.opacity = 0;
            el.style.display = "none";
          } else {
            requestAnimationFrame(fade);
          }
        })();
      });
      return this;
    },
    /**
     * fadeIn - Fade in elements in selection
     *
     * @param	{string} display Display value
     * @return {Mura.DOMSelection} Self
     */
    fadeIn: function fadeIn(display) {
      this.each(function (el) {
        el.style.opacity = 0;
        el.style.display = display || "block";
        (function fade() {
          var val = parseFloat(el.style.opacity);
          if (!((val += .1) > 1)) {
            el.style.opacity = val;
            requestAnimationFrame(fade);
          }
        })();
      });
      return this;
    },
    /**
     * toggle - Toggles display object elements in selection
     *
     * @return {Mura.DOMSelection} Self
     */
    toggle: function toggle() {
      this.each(function (el) {
        if (typeof el.style.display == 'undefined' || el.style.display == '') {
          el.style.display = 'none';
        } else {
          el.style.display = '';
        }
      });
      return this;
    },
    /**
     * slideToggle - Place holder
     *
     * @return {Mura.DOMSelection} Self
     */
    slideToggle: function slideToggle() {
      this.each(function (el) {
        if (typeof el.style.display == 'undefined' || el.style.display == '') {
          el.style.display = 'none';
        } else {
          el.style.display = '';
        }
      });
      return this;
    },
    /**
     * focus - sets focus of the first select element
     *
     * @return {self}
     */
    focus: function focus() {
      if (!this.selection.length) {
        return this;
      }
      this.selection[0].focus();
      return this;
    },
    /**
     * renderEditableAttr- Returns a string with editable attriute markup markup.
     *
     * @param	{object} params Keys: name, type, required, validation, message, label
     * @return {self}
     */
    makeEditableAttr: function makeEditableAttr(params) {
      if (!this.selection.length) {
        return this;
      }
      var value = this.selection[0].innerHTML;
      params = params || {};
      if (!params.name) {
        return this;
      }
      params.type = params.type || "text";
      if (typeof params.required == 'undefined') {
        params.required = false;
      }
      if (typeof params.validation == 'undefined') {
        params.validation = '';
      }
      if (typeof params.message == 'undefined') {
        params.message = '';
      }
      if (typeof params.label == 'undefined') {
        params.label = params.name;
      }
      var outerClass = "mura-editable mura-inactive";
      var innerClass = "mura-inactive mura-editable-attribute";
      if (params.type == "htmlEditor") {
        outerClass += " mura-region mura-region-loose";
        innerClass += " mura-region-local";
      } else {
        outerClass += " inline";
        innerClass += " inline";
      }
      var innerClass = "mura-inactive mura-editable-attribute";
      /*
      <div class="mura-editable mura-inactive inline">
      <label class="mura-editable-label" style="">TITLE</label>
      <div contenteditable="false" id="mura-editable-attribute-title" class="mura-inactive mura-editable-attribute inline" data-attribute="title" data-type="text" data-required="false" data-message="" data-label="title">About</div>
      </div>
      	<div class="mura-region mura-region-loose mura-editable mura-inactive">
      <label class="mura-editable-label" style="">BODY</label>
      <div contenteditable="false" id="mura-editable-attribute-body" class="mura-region-local mura-inactive mura-editable-attribute" data-attribute="body" data-type="htmlEditor" data-required="false" data-message="" data-label="body" data-loose="true" data-perm="true" data-inited="false"></div>
      </div>
      */
      var markup = '<div class="' + outerClass + '">';
      markup += '<div contenteditable="false" id="mura-editable-attribute-' + params.name + ' class="' + innerClass + '" ';
      markup += ' data-attribute="' + params.name + '" ';
      markup += ' data-type="' + params.type + '" ';
      markup += ' data-required="' + params.required + '" ';
      markup += ' data-message="' + params.message + '" ';
      markup += ' data-label="' + params.label + '"';
      if (params.type == 'htmlEditor') {
        markup += ' data-loose="true" data-perm="true" data-inited="false"';
      }
      markup += '>' + value + '</div>';
      markup += '<label class="mura-editable-label" style="display:none">' + params.label.toUpperCase() + '</label>';
      markup += '</div>';
      this.selection[0].innerHTML = markup;
      Mura.evalScripts(this.selection[0]);
      return this;
    },
    /**
    * processDisplayRegion - Renders and processes the display region data returned from Mura.renderFilename()
    *
    * @param	{any} data Region data to render
    * @return {Promise}
    */
    processDisplayRegion: function processDisplayRegion(data, label) {
      if (typeof data == 'undefined' || !this.selection.length) {
        return this.processMarkup();
      }
      this.html(Mura.buildDisplayRegion(data));
      if (label != 'undefined') {
        this.find('label.mura-editable-label').html('DISPLAY REGION : ' + data.label);
      }
      return this.processMarkup();
    },
    /**
     * appendDisplayObject - Appends display object to selected items
     *
     * @param	{object} data Display objectparams (including object='objectkey')
     * @return {Promise}
     */
    dspObject: function dspObject(data) {
      return this.appendDisplayObject(data);
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 501:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  /**
  * Creates a new Mura.Entity
  * @name	Mura.Entity
  * @class
  * @extends Mura.Core
  * @memberof Mura
  * @param	{object} properties Object containing values to set into object
  * @return {Mura.Entity}
  */

  Mura.Entity = Mura.Core.extend( /** @lends Mura.Entity.prototype */
  {
    init: function init(properties, requestcontext) {
      properties = properties || {};
      properties.entityname = properties.entityname || 'content';
      properties.siteid = properties.siteid || Mura.siteid;
      this.set(properties);
      if (typeof this.properties.isnew == 'undefined') {
        this.properties.isnew = 1;
      }
      if (this.properties.isnew) {
        this.set('isdirty', true);
      } else {
        this.set('isdirty', false);
      }
      if (typeof this.properties.isdeleted == 'undefined') {
        this.properties.isdeleted = false;
      }
      this._requestcontext = requestcontext || Mura.getRequestContext();
      this.cachePut();
      return this;
    },
    /**
     * updateFromDom - Updates editable data from what's in the DOM.
     *
     * @return {string}
     */
    updateFromDom: function updateFromDom() {
      return this;
    },
    /**
     * setRequestContext - Sets the RequestContext
     *
     * @RequestContext	{Mura.RequestContext} Mura.RequestContext List of fields
     * @return {Mura.Feed}				Self
     */
    setRequestContext: function setRequestContext(requestcontext) {
      this._requestcontext = requestcontext;
      return this;
    },
    /**
     * getEnpoint - Returns API endpoint for entity type
     *
     * @return {string} All Headers
     */
    getAPIEndpoint: function getAPIEndpoint() {
      return this._requestcontext.getAPIEndpoint() + this.get('entityname') + '/';
    },
    /**
     * invoke - Invokes a method
     *
     * @param	{string} name Method to call
     * @param	{object} params Arguments to submit to method
     * @param	{string} method GET or POST
     * @return {any}
     */
    invoke: function invoke(name, params, method, config) {
      if (_typeof(name) == 'object') {
        params = name.params || name.data || {};
        method = name.method || name.type || 'get';
        config = name;
        name = name.name;
      } else {
        config = config || {};
      }
      Mura.normalizeRequestConfig(config);
      var self = this;
      if (typeof method == 'undefined' && typeof params == 'string') {
        method = params;
        params = {};
      }
      params = params || {};
      method = method || "post";
      if (this[name] == 'function') {
        return this[name].apply(this, params);
      }
      return new Promise(function (resolve, reject) {
        if (typeof resolve == 'function') {
          config.success = resolve;
        }
        if (typeof reject == 'function') {
          config.error = reject;
        }
        method = method.toLowerCase();
        self._requestcontext.request({
          type: method,
          url: self.getAPIEndpoint() + name,
          cache: method == 'get' ? config.cache : 'default',
          next: config.next,
          data: params,
          success: function success(resp) {
            if (typeof resp.error == 'undefined') {
              if (typeof config.success == 'function') {
                if (typeof resp.data != 'undefined') {
                  config.success(resp.data);
                } else {
                  config.success(resp);
                }
              }
            } else {
              if (typeof config.error == 'function') {
                config.error(resp);
              }
            }
          },
          error: function error(resp) {
            if (typeof config.error == 'function') {
              config.error(resp);
            }
          },
          progress: config.progress,
          abort: config.abort
        });
      });
    },
    /**
     * invokeWithCSRF - Proxies method call to remote api, but first generates CSRF tokens based on name
     *
     * @param	{string} name Method to call
     * @param	{object} params Arguments to submit to method
     * @param	{string} method GET or POST
     * @return {Promise} All Headers
     */
    invokeWithCSRF: function invokeWithCSRF(name, params, method, config) {
      if (_typeof(name) == 'object') {
        params = name.params || {};
        method = name.method || 'get';
        config = name;
        name = name.name;
      } else {
        config = config || {};
      }
      var self = this;
      Mura.normalizeRequestConfig(config);
      if (self._requestcontext.getMode().toLowerCase() == 'rest') {
        return new Promise(function (resolve, reject) {
          return self.invoke(name, params, method, config).then(resolve, reject);
        });
      } else {
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            config.success = resolve;
          }
          if (typeof reject == 'function') {
            config.error = reject;
          }
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint() + '?method=generateCSRFTokens',
            data: {
              siteid: self.get('siteid'),
              context: name
            },
            success: function success(resp) {
              if (params instanceof FormData) {
                params.append('csrf_token', resp.data.csrf_token);
                params.append('csrf_token_expires', resp.data.csrf_token_expires);
              } else {
                params = Mura.extend(params, resp.data);
              }
              if (resp.data != 'undefined') {
                self.invoke(name, params, method, config).then(resolve, reject);
              } else {
                if (typeof config.error == 'function') {
                  config.error(resp);
                }
              }
            },
            error: function error(resp) {
              if (typeof config.error == 'function') {
                config.error(resp);
              }
            }
          });
        });
      }
    },
    /**
     * exists - Returns if the entity was previously saved
     *
     * @return {boolean}
     */
    exists: function exists() {
      return this.has('isnew') && !this.get('isnew');
    },
    /**
     * get - Retrieves property value from entity
     *
     * @param	{string} propertyName Property Name
     * @param	{*} defaultValue Default Value
     * @return {*}							Property Value
     */
    get: function get(propertyName, defaultValue) {
      if (typeof propertyName == 'undefined') {
        return this.getAll();
      }
      if (typeof this.properties.links != 'undefined' && typeof this.properties.links[propertyName] != 'undefined') {
        var self = this;
        if (_typeof(this.properties[propertyName]) == 'object') {
          return new Promise(function (resolve, reject) {
            if ('items' in self.properties[propertyName]) {
              var returnObj = new Mura.EntityCollection(self.properties[propertyName], self._requestcontext);
            } else {
              if (Mura.entities[self.properties[propertyName].entityname]) {
                var returnObj = new Mura.entities[self.properties[propertyName].entityname](self.properties[propertyName], self._requestcontext);
              } else {
                var returnObj = new Mura.Entity(self.properties[propertyName], self._requestcontext);
              }
            }
            if (typeof resolve == 'function') {
              resolve(returnObj);
            }
          });
        } else {
          if (_typeof(defaultValue) == 'object') {
            var params = defaultValue;
          } else {
            var params = {};
          }
          return new Promise(function (resolve, reject) {
            self._requestcontext.request({
              type: 'get',
              url: self.properties.links[propertyName],
              params: params,
              success: function success(resp) {
                if ('items' in resp.data) {
                  var returnObj = new Mura.EntityCollection(resp.data, self._requestcontext);
                } else {
                  if (Mura.entities[self.entityname]) {
                    var returnObj = new Mura.entities[self.entityname](resp.data, self._requestcontext);
                  } else {
                    var returnObj = new Mura.Entity(resp.data, self._requestcontext);
                  }
                }
                //Dont cache if there are custom params
                if (Mura.isEmptyObject(params)) {
                  self.set(propertyName, resp.data);
                }
                if (typeof resolve == 'function') {
                  resolve(returnObj);
                }
              },
              error: function error(resp) {
                if (typeof reject == 'function') {
                  reject(resp);
                }
              }
            });
          });
        }
      } else if (typeof this.properties[propertyName] != 'undefined') {
        return this.properties[propertyName];
      } else if (typeof defaultValue != 'undefined') {
        this.properties[propertyName] = defaultValue;
        return this.properties[propertyName];
      } else {
        return '';
      }
    },
    /**
     * set - Sets property value
     *
     * @param	{string} propertyName	Property Name
     * @param	{*} propertyValue Property Value
     * @return {Mura.Entity} Self
     */
    set: function set(propertyName, propertyValue) {
      if (_typeof(propertyName) == 'object') {
        this.properties = Mura.deepExtend(this.properties, propertyName);
        this.set('isdirty', true);
      } else if (typeof this.properties[propertyName] == 'undefined' || this.properties[propertyName] != propertyValue) {
        this.properties[propertyName] = propertyValue;
        this.set('isdirty', true);
      }
      return this;
    },
    /**
     * has - Returns is the entity has a certain property within it
     *
     * @param	{string} propertyName Property Name
     * @return {type}
     */
    has: function has(propertyName) {
      return typeof this.properties[propertyName] != 'undefined' || typeof this.properties.links != 'undefined' && typeof this.properties.links[propertyName] != 'undefined';
    },
    /**
     * getAll - Returns all of the entities properties
     *
     * @return {object}
     */
    getAll: function getAll() {
      return this.properties;
    },
    /**
     * load - Loads entity from JSON API
     *
     * @return {Promise}
     */
    load: function load() {
      return this.loadBy('id', this.get('id'));
    },
    /**
     * new - Loads properties of a new instance from JSON API
     *
     * @param	{type} params Property values that you would like your new entity to have
     * @return {Promise}
     */
    'new': function _new(params) {
      var self = this;
      return new Promise(function (resolve, reject) {
        params = Mura.extend({
          entityname: self.get('entityname'),
          method: 'findNew',
          siteid: self.get('siteid')
        }, params);
        self._requestcontext.get(self._requestcontext.getAPIEndpoint(), params, {
          cache: 'no-cache'
        }).then(function (resp) {
          self.set(resp.data);
          if (typeof resolve == 'function') {
            resolve(self);
          }
        });
      });
    },
    /**
     * checkSchema - Checks the schema for Mura ORM entities
     *
     * @return {Promise}
     */
    'checkSchema': function checkSchema() {
      var self = this;
      return new Promise(function (resolve, reject) {
        if (self._requestcontext.getMode().toLowerCase() == 'rest') {
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint(),
            data: {
              entityname: self.get('entityname'),
              method: 'checkSchema',
              siteid: self.get('siteid')
            },
            success: function success(resp) {
              if (resp.data != 'undefined') {
                if (typeof resolve == 'function') {
                  resolve(self);
                }
              } else {
                console.log(resp);
                if (typeof reject == 'function') {
                  reject(self);
                }
              }
            },
            error: function error(resp) {
              self.set('errors', resp.error);
              if (typeof reject == 'function') {
                reject(self);
              }
            }
          });
        } else {
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint() + '?method=generateCSRFTokens',
            data: {
              siteid: self.get('siteid'),
              context: ''
            },
            success: function success(resp) {
              self._requestcontext.request({
                type: 'post',
                url: self._requestcontext.getAPIEndpoint(),
                data: Mura.extend({
                  entityname: self.get('entityname'),
                  method: 'checkSchema',
                  siteid: self.get('siteid')
                }, {
                  'csrf_token': resp.data.csrf_token,
                  'csrf_token_expires': resp.data.csrf_token_expires
                }),
                success: function success(resp) {
                  if (resp.data != 'undefined') {
                    if (typeof resolve == 'function') {
                      resolve(self);
                    }
                  } else {
                    console.log(resp);
                    self.set('errors', resp.error);
                    if (typeof reject == 'function') {
                      reject(self);
                    }
                  }
                },
                error: function error(resp) {
                  this.success(resp);
                }
              });
            },
            error: function error(resp) {
              this.success(resp);
            }
          });
        }
      });
    },
    /**
     * undeclareEntity - Undeclares an Mura ORM entity with service factory
     *
     * @return {Promise}
     */
    'undeclareEntity': function undeclareEntity(deleteSchema) {
      deleteSchema = deleteSchema || false;
      var self = this;
      return new Promise(function (resolve, reject) {
        if (self._requestcontext.getMode().toLowerCase() == 'rest') {
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint(),
            data: {
              entityname: self.get('entityname'),
              deleteSchema: deleteSchema,
              method: 'undeclareEntity',
              siteid: self.get('siteid')
            },
            success: function success(resp) {
              if (resp.data != 'undefined') {
                if (typeof resolve == 'function') {
                  resolve(self);
                }
              } else {
                console.log(resp);
                self.set('errors', resp.error);
                if (typeof reject == 'function') {
                  reject(self);
                }
              }
            },
            error: function error(resp) {
              this.success(resp);
            }
          });
        } else {
          return self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint() + '?method=generateCSRFTokens',
            data: {
              siteid: self.get('siteid'),
              context: ''
            },
            success: function success(resp) {
              self._requestcontext.request({
                type: 'post',
                url: self._requestcontext.getAPIEndpoint(),
                data: Mura.extend({
                  entityname: self.get('entityname'),
                  method: 'undeclareEntity',
                  siteid: self.get('siteid')
                }, {
                  'csrf_token': resp.data.csrf_token,
                  'csrf_token_expires': resp.data.csrf_token_expires
                }),
                success: function success(resp) {
                  if (resp.data != 'undefined') {
                    if (typeof resolve == 'function') {
                      resolve(self);
                    }
                  } else {
                    self.set('errors', resp.error);
                    if (typeof reject == 'function') {
                      reject(self);
                    }
                  }
                }
              });
            },
            error: function error(resp) {
              this.success(resp);
            }
          });
        }
      });
    },
    /**
     * loadBy - Loads entity by property and value
     *
     * @param	{string} propertyName	The primary load property to filter against
     * @param	{string|number} propertyValue The value to match the propert against
     * @param	{object} params				Addition parameters
     * @return {Promise}
     */
    loadBy: function loadBy(propertyName, propertyValue, params) {
      propertyName = propertyName || 'id';
      propertyValue = propertyValue || this.get(propertyName) || 'null';
      var self = this;
      if (propertyName == 'id') {
        var cachedValue = Mura.datacache.get(propertyValue);
        if (typeof cachedValue != 'undefined') {
          this.set(cachedValue);
          return new Promise(function (resolve, reject) {
            resolve(self);
          });
        }
      }
      return new Promise(function (resolve, reject) {
        params = Mura.extend({
          entityname: self.get('entityname').toLowerCase(),
          method: 'findQuery',
          siteid: self.get('siteid')
        }, params);
        if (params.entityname == 'content' || params.entityname == 'contentnav') {
          params.includeHomePage = 1;
          params.showNavOnly = 0;
          params.showExcludeSearch = 1;
        }
        var cache = params.cache || 'default';
        delete params.cache;
        var next = params.next || {};
        delete params.next;
        params[propertyName] = propertyValue;
        self._requestcontext.findQuery(params, {
          cache: cache,
          next: next
        }).then(function (collection) {
          if (collection.get('items').length) {
            self.set(collection.get('items')[0].getAll());
          }
          if (typeof resolve == 'function') {
            resolve(self);
          }
        }, function (resp) {
          if (typeof reject == 'function') {
            reject(resp);
          }
        });
      });
    },
    /**
     * validate - Validates instance
     *
     * @param	{string} fields List of properties to validate, defaults to all
     * @return {Promise}
     */
    validate: function validate(fields) {
      fields = fields || '';
      var self = this;
      var data = Mura.deepExtend({}, self.getAll());
      data.fields = fields;
      return new Promise(function (resolve, reject) {
        self._requestcontext.request({
          type: 'post',
          url: self._requestcontext.getAPIEndpoint() + '?method=validate',
          data: {
            data: JSON.stringify(data),
            validations: '{}',
            version: 4
          },
          success: function success(resp) {
            if (resp.data != 'undefined') {
              self.set('errors', resp.data);
            } else {
              self.set('errors', resp.error);
            }
            if (typeof resolve == 'function') {
              resolve(self);
            }
          },
          error: function error(resp) {
            self.set('errors', resp.error);
            resolve(self);
          }
        });
      });
    },
    /**
     * hasErrors - Returns if the entity has any errors
     *
     * @return {boolean}
     */
    hasErrors: function hasErrors() {
      var errors = this.get('errors', {});
      return typeof errors == 'string' && errors != '' || _typeof(errors) == 'object' && !Mura.isEmptyObject(errors);
    },
    /**
     * getErrors - Returns entites errors property
     *
     * @return {object}
     */
    getErrors: function getErrors() {
      return this.get('errors', {});
    },
    /**
     * save - Saves entity to JSON API
     *
     * @return {Promise}
     */
    save: function save(config) {
      config = config || {};
      Mura.normalizeRequestConfig(config);
      var self = this;
      if (!this.get('isdirty')) {
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            config.success = resolve;
          }
          if (typeof config.success == 'function') {
            config.success(self);
          }
        });
      }
      if (!this.get('id')) {
        return new Promise(function (resolve, reject) {
          var temp = Mura.deepExtend({}, self.getAll());
          self._requestcontext.request({
            type: 'get',
            url: self._requestcontext.getAPIEndpoint() + self.get('entityname') + '/new',
            success: function success(resp) {
              self.set(resp.data);
              self.set(temp);
              self.set('id', resp.data.id);
              self.set('isdirty', true);
              self.cachePut();
              self.save(config).then(resolve, reject);
            },
            error: config.error,
            abort: config.abort
          });
        });
      } else {
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            config.success = resolve;
          }
          if (typeof reject == 'function') {
            config.error = reject;
          }
          var context = self.get('id');
          if (self._requestcontext.getMode().toLowerCase() == 'rest') {
            self._requestcontext.request({
              type: 'post',
              url: self._requestcontext.getAPIEndpoint() + '?method=save',
              data: self.getAll(),
              success: function success(resp) {
                if (resp.data != 'undefined') {
                  self.set(resp.data);
                  self.set('isdirty', false);
                  if (self.get('saveerrors') || Mura.isEmptyObject(self.getErrors())) {
                    if (typeof config.success == 'function') {
                      config.success(self);
                    }
                  } else {
                    if (typeof config.error == 'function') {
                      config.error(self);
                    }
                  }
                } else {
                  self.set('errors', resp.error);
                  if (typeof config.error == 'function') {
                    config.error(self);
                  }
                }
              },
              error: function error(resp) {
                self.set('errors', resp.error);
                if (typeof config.error == 'function') {
                  config.error(self);
                }
              },
              progress: config.progress,
              abort: config.abort
            });
          } else {
            self._requestcontext.request({
              type: 'post',
              url: self._requestcontext.getAPIEndpoint() + '?method=generateCSRFTokens',
              data: {
                siteid: self.get('siteid'),
                context: context
              },
              success: function success(resp) {
                self._requestcontext.request({
                  type: 'post',
                  url: self._requestcontext.getAPIEndpoint() + '?method=save',
                  data: Mura.extend(self.getAll(), {
                    'csrf_token': resp.data.csrf_token,
                    'csrf_token_expires': resp.data.csrf_token_expires
                  }),
                  success: function success(resp) {
                    if (resp.data != 'undefined') {
                      self.set(resp.data);
                      self.set('isdirty', false);
                      if (self.get('saveerrors') || Mura.isEmptyObject(self.getErrors())) {
                        if (typeof config.success == 'function') {
                          config.success(self);
                        }
                      } else {
                        if (typeof config.error == 'function') {
                          config.error(self);
                        }
                      }
                    } else {
                      self.set('errors', resp.error);
                      if (typeof config.error == 'function') {
                        config.error(self);
                      }
                    }
                  },
                  error: function error(resp) {
                    self.set('errors', resp.error);
                    if (typeof config.error == 'function') {
                      config.error(self);
                    }
                  },
                  progress: config.progress,
                  abort: config.abort
                });
              },
              error: function error(resp) {
                this.error(resp);
              },
              abort: config.abort
            });
          }
        });
      }
    },
    /**
     * delete - Deletes entity
     *
     * @return {Promise}
     */
    'delete': function _delete(config) {
      config = config || {};
      Mura.normalizeRequestConfig(config);
      var self = this;
      if (self._requestcontext.getMode().toLowerCase() == 'rest') {
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            config.success = resolve;
          }
          if (typeof reject == 'function') {
            config.error = reject;
          }
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint() + '?method=delete',
            data: {
              siteid: self.get('siteid'),
              id: self.get('id'),
              entityname: self.get('entityname')
            },
            success: function success() {
              self.set('isdeleted', true);
              self.cachePurge();
              if (typeof config.success == 'function') {
                config.success(self);
              }
            },
            error: config.error,
            progress: config.progress,
            abort: config.abort
          });
        });
      } else {
        return new Promise(function (resolve, reject) {
          if (typeof resolve == 'function') {
            config.success = resolve;
          }
          if (typeof reject == 'function') {
            config.error = reject;
          }
          self._requestcontext.request({
            type: 'post',
            url: self._requestcontext.getAPIEndpoint() + '?method=generateCSRFTokens',
            data: {
              siteid: self.get('siteid'),
              context: self.get('id')
            },
            success: function success(resp) {
              self._requestcontext.request({
                type: 'post',
                url: self._requestcontext.getAPIEndpoint() + '?method=delete',
                data: {
                  siteid: self.get('siteid'),
                  id: self.get('id'),
                  entityname: self.get('entityname'),
                  'csrf_token': resp.data.csrf_token,
                  'csrf_token_expires': resp.data.csrf_token_expires
                },
                success: function success() {
                  self.set('isdeleted', true);
                  self.cachePurge();
                  if (typeof config.success == 'function') {
                    config.success(self);
                  }
                },
                error: config.error,
                progress: config.progress,
                abort: config.abort
              });
            },
            error: config.error,
            abort: config.abort
          });
        });
      }
    },
    /**
     * getFeed - Returns a Mura.Feed instance of this current entitie's type and siteid
     *
     * @return {object}
     */
    getFeed: function getFeed() {
      return this._requestcontext.getFeed(this.get('entityName'));
    },
    /**
     * cachePurge - Purges this entity from client cache
     *
     * @return {object}	Self
     */
    cachePurge: function cachePurge() {
      Mura.datacache.purge(this.get('id'));
      return this;
    },
    /**
     * cachePut - Places this entity into client cache
     *
     * @return {object}	Self
     */
    cachePut: function cachePut() {
      if (!this.get('isnew')) {
        Mura.datacache.set(this.get('id'), this);
      }
      return this;
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 826:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.EntityCollection
   * @name	Mura.EntityCollection
   * @class
   * @extends Mura.Entity
   * @memberof	Mura
   * @param	{object} properties Object containing values to set into object
   * @return {Mura.EntityCollection} Self
   */

  Mura.EntityCollection = Mura.Entity.extend( /** @lends Mura.EntityCollection.prototype */
  {
    init: function init(properties, requestcontext) {
      properties = properties || {};
      this.set(properties);
      this._requestcontext = requestcontext || Mura._requestcontext;
      var self = this;
      if (Array.isArray(self.get('items'))) {
        self.set('items', self.get('items').map(function (obj) {
          var entityname = obj.entityname.substr(0, 1).toUpperCase() + obj.entityname.substr(1);
          if (Mura.entities[entityname]) {
            return new Mura.entities[entityname](obj, self._requestcontext);
          } else {
            return new Mura.Entity(obj, self._requestcontext);
          }
        }));
      }
      return this;
    },
    /**
     * length - Returns length entity collection
     *
     * @return {number}		 integer
     */
    length: function length() {
      return this.properties.items.length;
    },
    /**
     * item - Return entity in collection at index
     *
     * @param	{nuymber} idx Index
     * @return {object}		 Mura.Entity
     */
    item: function item(idx) {
      return this.properties.items[idx];
    },
    /**
     * index - Returns index of item in collection
     *
     * @param	{object} item Entity instance
     * @return {number}			Index of entity
     */
    index: function index(item) {
      return this.properties.items.indexOf(item);
    },
    /**
     * indexOf - Returns index of item in collection
     *
     * @param	{object} item Entity instance
     * @return {number}			Index of entity
     */
    indexOf: function indexOf(item) {
      return this.properties.items.indexOf(item);
    },
    /**
     * getAll - Returns object with of all entities and properties
     *
     * @return {object}
     */
    getAll: function getAll() {
      var self = this;
      if (typeof self.properties.items != 'undefined') {
        return Mura.extend({}, self.properties, {
          items: self.properties.items.map(function (obj) {
            return obj.getAll();
          })
        });
      } else if (typeof self.properties.properties != 'undefined') {
        return Mura.extend({}, self.properties, {
          properties: self.properties.properties.map(function (obj) {
            return obj.getAll();
          })
        });
      }
    },
    /**
     * each - Passes each entity in collection through function
     *
     * @param	{function} fn Function
     * @return {object}	Self
     */
    each: function each(fn) {
      this.properties.items.forEach(function (item, idx) {
        if (typeof fn.call == 'undefined') {
          fn(item, idx);
        } else {
          fn.call(item, item, idx);
        }
      });
      return this;
    },
    /**
    * each - Passes each entity in collection through function
    *
    * @param	{function} fn Function
    * @return {object}	Self
    */
    forEach: function forEach(fn) {
      return this.each(fn);
    },
    /**
     * sort - Sorts collection
     *
     * @param	{function} fn Sorting function
     * @return {object}	 Self
     */
    sort: function sort(fn) {
      this.properties.items.sort(fn);
      return this;
    },
    /**
     * filter - Returns new Mura.EntityCollection of entities in collection that pass filter
     *
     * @param	{function} fn Filter function
     * @return {Mura.EntityCollection}
     */
    filter: function filter(fn) {
      var newProps = {};
      for (var p in this.properties) {
        if (this.properties.hasOwnProperty(p) && p != 'items' && p != 'links') {
          newProps[p] = this.properties[p];
        }
      }
      var collection = new Mura.EntityCollection(newProps, this._requestcontext);
      return collection.set('items', this.properties.items.filter(function (item, idx) {
        if (typeof fn.call == 'undefined') {
          return fn(item, idx);
        } else {
          return fn.call(item, item, idx);
        }
      }));
    },
    /**
     * map - Returns new Array returned from map function
     *
     * @param	{function} fn Filter function
     * @return {Array}
     */
    map: function map(fn) {
      return this.properties.items.map(function (item, idx) {
        if (typeof fn.call == 'undefined') {
          return fn(item, idx);
        } else {
          return fn.call(item, item, idx);
        }
      });
    },
    /**
     * reverse - Returns new Array returned from map function
     *
     * @param	{function} fn Sorting function
     * @return {object}	 collection
     */
    reverse: function reverse(fn) {
      var newProps = {};
      for (var p in this.properties) {
        if (this.properties.hasOwnProperty(p) && p != 'items' && p != 'links') {
          newProps[p] = this.properties[p];
        }
      }
      var collection = new Mura.EntityCollection(newProps, this._requestcontext);
      collection.set('items', this.properties.items.reverse());
      return collection;
    },
    /**
     * reduce - Returns value from	reduce function
     *
     * @param	{function} fn Reduce function
     * @param	{any} initialValue Starting accumulator value
     * @return {accumulator}
     */
    reduce: function reduce(fn, initialValue) {
      initialValue = initialValue || 0;
      return this.properties.items.reduce(function (accumulator, item, idx, array) {
        if (typeof fn.call == 'undefined') {
          return fn(accumulator, item, idx, array);
        } else {
          return fn.call(item, accumulator, item, idx, array);
        }
      }, initialValue);
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 248:
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

function factory() {
  var Mura = __webpack_require__(791)({});
  __webpack_require__(285)(Mura);
  __webpack_require__(58)(Mura);
  __webpack_require__(980)(Mura);
  __webpack_require__(147)(Mura);
  __webpack_require__(501)(Mura);
  __webpack_require__(506)(Mura);
  __webpack_require__(808)(Mura);
  __webpack_require__(826)(Mura);
  __webpack_require__(847)(Mura);
  __webpack_require__(23)(Mura);
  __webpack_require__(839)(Mura);
  __webpack_require__(789)(Mura);
  __webpack_require__(86)(Mura);
  __webpack_require__(943)(Mura);
  __webpack_require__(180)(Mura);
  __webpack_require__(397)(Mura);
  __webpack_require__(876)(Mura);
  __webpack_require__(324)(Mura);
  __webpack_require__(711)(Mura);
  __webpack_require__(654)(Mura);
  __webpack_require__(526)(Mura);
  if (Mura.isInNode()) {
    Mura._escapeHTML = __webpack_require__(Object(function webpackMissingModule() { var e = new Error("Cannot find module 'escape-html'"); e.code = 'MODULE_NOT_FOUND'; throw e; }()));
  } else if (typeof window != 'undefined') {
    window.m = Mura;
    window.mura = Mura;
    window.Mura = Mura;
    window.validateForm = Mura.validateForm;
    window.setHTMLEditor = Mura.setHTMLEditor;
    window.createCookie = Mura.createCookie;
    window.readCookie = Mura.readCookie;
    window.addLoadEvent = Mura.addLoadEvent;
    window.noSpam = Mura.noSpam;
    window.initMura = Mura.init;
  }
  return Mura;
}
module.exports = factory;

/***/ }),

/***/ 847:
/***/ (function(module) {

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }
function attach(Mura) {
  var _Mura$Core$extend;
  /**
   * Creates a new Mura.Feed
   * @name  Mura.Feed
   * @class
   * @extends Mura.Core
   * @memberof Mura
   * @param  {string} siteid     Siteid
   * @param  {string} entityname Entity name
   * @return {Mura.Feed}            Self
   */

  /**
   * @ignore
   */

  Mura.Feed = Mura.Core.extend((_Mura$Core$extend = {
    init: function init(siteid, entityname, requestcontext) {
      this.queryString = entityname + '/?';
      this.propIndex = 0;
      this.cache = 'default';
      this.next = {};
      this._requestcontext = requestcontext || Mura.getRequestContext();
      return this;
    },
    /**
     * cache - Sets the cache policy for the  feed to use
     *
     * @param  {string} name Name of feed as defined in admin
     * @return {Mura.Feed}              Self
     */
    cache: function cache(_cache) {
      this.cache = _cache;
      return this;
    },
    /**
     * next - Sets the next config for the  feed to use
     *
     * @param  {object} next next config for the  feed to use
     * @return {Mura.Feed}              Self
     */
    next: function next(_next) {
      this.next = _next;
      return _next;
    },
    /**
     * fields - List fields to retrieve from API
     *
     * @param  {string} fields List of fields
     * @return {Mura.Feed}        Self
     */
    fields: function fields(_fields) {
      if (typeof _fields != 'undefined' && _fields) {
        this.queryString += '&fields=' + encodeURIComponent(_fields);
      }
      return this;
    },
    /**
     * setRequestContext - Sets the RequestContext
     *
     * @RequestContext  {Mura.RequestContext} Mura.RequestContext List of fields
     * @return {Mura.Feed}        Self
     */
    setRequestContext: function setRequestContext(RequestContext) {
      this._requestcontext = RequestContext;
      return this;
    },
    /**
     * contentPoolID - Sets items per page
     *
     * @param  {string} contentPoolID Items per page
     * @return {Mura.Feed}              Self
     */
    contentPoolID: function contentPoolID(_contentPoolID) {
      this.queryString += '&contentpoolid=' + encodeURIComponent(_contentPoolID);
      return this;
    },
    /**
     * name - Sets the name of the content feed to use
     *
     * @param  {string} name Name of feed as defined in admin
     * @return {Mura.Feed}              Self
     */
    name: function name(_name) {
      this.queryString += '&feedname=' + encodeURIComponent(_name);
      return this;
    },
    /**
     * cacheKey - Set unique key in cache
     *
     * @param  {string} cacheKey Unique key in cache
     * @return {Mura.Feed}              Self
     */
    cacheKey: function cacheKey(_cacheKey) {
      this.queryString += '&cacheKey=' + encodeURIComponent(_cacheKey);
      return this;
    },
    /**
     * cachedWithin - Sets maximum number of seconds to remain in cache
     *
     * @param  {number} cachedWithin Maximum number of seconds to remain in cache
     * @return {Mura.Feed}              Self
     */
    cachedWithin: function cachedWithin(_cachedWithin) {
      this.queryString += '&cachedWithin=' + encodeURIComponent(_cachedWithin);
      return this;
    },
    /**
     * purgeCache - Sets whether to purge any existing cached values
     *
     * @param  {boolean} purgeCache Whether to purge any existing cached values
     * @return {Mura.Feed}              Self
     */
    purgeCache: function purgeCache(_purgeCache) {
      this.queryString += '&purgeCache=' + encodeURIComponent(_purgeCache);
      return this;
    },
    /**
     * contentPoolID - Sets items per page
     *
     * @param  {string} feedID Items per page
     * @return {Mura.Feed}              Self
     */
    feedID: function feedID(_feedID) {
      this.queryString += '&feedid=' + encodeURIComponent(_feedID);
      return this;
    },
    /**
     * where - Optional method for starting query chain
     *
     * @param  {string} property Property name
     * @return {Mura.Feed}          Self
     */
    where: function where(property) {
      if (property) {
        return this.andProp(property);
      }
      return this;
    },
    /**
     * prop - Add new property value
     *
     * @param  {string} property Property name
     * @return {Mura.Feed}          Self
     */
    prop: function prop(property) {
      return this.andProp(property);
    },
    /**
     * andProp - Add new AND property value
     *
     * @param  {string} property Property name
     * @return {Mura.Feed}          Self
     */
    andProp: function andProp(property) {
      this.queryString += '&' + encodeURIComponent(property + '[' + this.propIndex + ']') + '=';
      this.propIndex++;
      return this;
    },
    /**
     * orProp - Add new OR property value
     *
     * @param  {string} property Property name
     * @return {Mura.Feed}          Self
     */
    orProp: function orProp(property) {
      this.queryString += '&or' + encodeURIComponent('[' + this.propIndex + ']') + '&';
      this.propIndex++;
      this.queryString += encodeURIComponent(property + '[' + this.propIndex + ']') + '=';
      this.propIndex++;
      return this;
    },
    /**
     * isEQ - Checks if preceding property value is EQ to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isEQ: function isEQ(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent(criteria);
      return this;
    },
    /**
     * isNEQ - Checks if preceding property value is NEQ to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isNEQ: function isNEQ(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent('neq^' + criteria);
      return this;
    },
    /**
     * isLT - Checks if preceding property value is LT to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isLT: function isLT(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent('lt^' + criteria);
      return this;
    },
    /**
     * isLTE - Checks if preceding property value is LTE to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isLTE: function isLTE(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent('lte^' + criteria);
      return this;
    },
    /**
     * isGT - Checks if preceding property value is GT to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isGT: function isGT(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent('gt^' + criteria);
      return this;
    },
    /**
     * isGTE - Checks if preceding property value is GTE to criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    isGTE: function isGTE(criteria) {
      if (typeof criteria == 'undefined' || criteria === '' || criteria == null) {
        criteria = 'null';
      }
      this.queryString += encodeURIComponent('gte^' + criteria);
      return this;
    },
    /**
     * isIn - Checks if preceding property value is IN to list of criterias
     *
     * @param  {*} criteria Criteria List
     * @return {Mura.Feed}          Self
     */
    isIn: function isIn(criteria) {
      if (Array.isArray(criteria)) {
        criteria = criteria.join();
      }
      this.queryString += encodeURIComponent('in^' + criteria);
      return this;
    },
    /**
     * isNotIn - Checks if preceding property value is NOT IN to list of criterias
     *
     * @param  {*} criteria Criteria List
     * @return {Mura.Feed}          Self
     */
    isNotIn: function isNotIn(criteria) {
      if (Array.isArray(criteria)) {
        criteria = criteria.join();
      }
      this.queryString += encodeURIComponent('notin^' + criteria);
      return this;
    },
    /**
     * containsValue - Checks if preceding property value is CONTAINS the value of criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    containsValue: function containsValue(criteria) {
      this.queryString += encodeURIComponent('containsValue^' + criteria);
      return this;
    },
    contains: function contains(criteria) {
      this.queryString += encodeURIComponent('containsValue^' + criteria);
      return this;
    },
    /**
     * beginsWith - Checks if preceding property value BEGINS WITH criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    beginsWith: function beginsWith(criteria) {
      this.queryString += encodeURIComponent('begins^' + criteria);
      return this;
    },
    /**
     * endsWith - Checks if preceding property value ENDS WITH criteria
     *
     * @param  {*} criteria Criteria
     * @return {Mura.Feed}          Self
     */
    endsWith: function endsWith(criteria) {
      this.queryString += encodeURIComponent('ends^' + criteria);
      return this;
    },
    /**
     * openGrouping - Start new logical condition grouping
     *
     * @return {Mura.Feed}          Self
     */
    openGrouping: function openGrouping() {
      this.queryString += '&openGrouping' + encodeURIComponent('[' + this.propIndex + ']');
      this.propIndex++;
      return this;
    },
    /**
     * openGrouping - Starts new logical condition grouping
     *
     * @return {Mura.Feed}          Self
     */
    andOpenGrouping: function andOpenGrouping() {
      this.queryString += '&andOpenGrouping' + encodeURIComponent('[' + this.propIndex + ']');
      this.propIndex++;
      return this;
    },
    /**
     * orOpenGrouping - Starts new logical condition grouping
     *
     * @return {Mura.Feed}          Self
     */
    orOpenGrouping: function orOpenGrouping() {
      this.queryString += '&orOpenGrouping' + encodeURIComponent('[' + this.propIndex + ']');
      this.propIndex++;
      return this;
    },
    /**
     * openGrouping - Closes logical condition grouping
     *
     * @return {Mura.Feed}          Self
     */
    closeGrouping: function closeGrouping() {
      this.queryString += '&closeGrouping' + encodeURIComponent('[' + this.propIndex + ']');
      this.propIndex++;
      return this;
    },
    /**
     * sort - Set desired sort or return collection
     *
     * @param  {string} property  Property
     * @param  {string} direction Sort direction
     * @return {Mura.Feed}           Self
     */
    sort: function sort(property, direction) {
      direction = direction || 'asc';
      if (direction == 'desc') {
        this.queryString += '&sort' + encodeURIComponent('[' + this.propIndex + ']') + '=' + encodeURIComponent('-' + property);
      } else {
        this.queryString += '&sort' + encodeURIComponent('[' + this.propIndex + ']') + '=' + encodeURIComponent(property);
      }
      this.propIndex++;
      return this;
    },
    /**
     * itemsPerPage - Sets items per page
     *
     * @param  {number} itemsPerPage Items per page
     * @return {Mura.Feed}              Self
     */
    itemsPerPage: function itemsPerPage(_itemsPerPage) {
      this.queryString += '&itemsPerPage=' + encodeURIComponent(_itemsPerPage);
      return this;
    },
    /**
     * pageIndex - Sets items per page
     *
     * @param  {number} pageIndex page to start at
     */
    pageIndex: function pageIndex(_pageIndex) {
      this.queryString += '&pageIndex=' + encodeURIComponent(_pageIndex);
      return this;
    },
    /**
     * maxItems - Sets max items to return
     *
     * @param  {number} maxItems Items to return
     * @return {Mura.Feed}              Self
     */
    maxItems: function maxItems(_maxItems) {
      this.queryString += '&maxItems=' + encodeURIComponent(_maxItems);
      return this;
    },
    /**
     * distinct - Sets to select distinct values of select fields
     *
     * @param  {boolean} distinct Whether to to select distinct values
     * @return {Mura.Feed}              Self
     */
    distinct: function distinct(_distinct) {
      if (typeof _distinct == 'undefined') {
        _distinct = true;
      }
      this.queryString += '&distinct=' + encodeURIComponent(_distinct);
      return this;
    },
    /**
     * aggregate - Define aggregate values that you would like (sum,max,min,cout,avg,groupby)
     *
     * @param  {string} type Type of aggregation (sum,max,min,cout,avg,groupby)
     * @param  {string} property property
     * @return {Mura.Feed}	Self
     */
    aggregate: function aggregate(type, property) {
      if (type == 'count' && typeof property == 'undefined') {
        property = '*';
      }
      if (typeof type != 'undefined' && typeof property != 'undefined') {
        this.queryString += '&' + encodeURIComponent(type + '[' + this.propIndex + ']') + '=' + property;
        this.propIndex++;
      }
      return this;
    },
    /**
     * liveOnly - Set whether to return all content or only content that is currently live.
     * This only works if the user has module level access to the current site's content
     *
     * @param  {number} liveOnly 0 or 1
     * @return {Mura.Feed}              Self
     */
    liveOnly: function liveOnly(_liveOnly) {
      this.queryString += '&liveOnly=' + encodeURIComponent(_liveOnly);
      return this;
    },
    /**
     * groupBy - Sets property or properties to group by
     *
     * @param  {string} groupBy
     * @return {Mura.Feed}              Self
     */
    groupBy: function groupBy(property) {
      if (typeof property != 'undefined') {
        this.queryString += '&' + encodeURIComponent('groupBy[' + this.propIndex + ']') + '=' + property;
        this.propIndex++;
      }
      return this;
    }
  }, _defineProperty(_Mura$Core$extend, "maxItems", function maxItems(_maxItems2) {
    this.queryString += '&maxItems=' + encodeURIComponent(_maxItems2);
    return this;
  }), _defineProperty(_Mura$Core$extend, "showNavOnly", function showNavOnly(_showNavOnly) {
    this.queryString += '&showNavOnly=' + encodeURIComponent(_showNavOnly);
    return this;
  }), _defineProperty(_Mura$Core$extend, "expand", function expand(_expand) {
    if (typeof _expand == 'undefined') {
      _expand = 'all';
    }
    if (_expand) {
      this.queryString += '&expand=' + encodeURIComponent(_expand);
    }
    return this;
  }), _defineProperty(_Mura$Core$extend, "expandDepth", function expandDepth(_expandDepth) {
    _expandDepth = _expandDepth || 1;
    if (Mura.isNumeric(_expandDepth) && Number(parseFloat(_expandDepth)) > 1) {
      this.queryString += '&expandDepth=' + encodeURIComponent(_expandDepth);
    }
    return this;
  }), _defineProperty(_Mura$Core$extend, "findMany", function findMany(ids) {
    if (!Array.isArray(ids)) {
      ids = ids.split(",");
    }
    if (!ids.length) {
      ids = [Mura.createUUID()];
    }
    if (ids.length === 1) {
      this.andProp('id').isEQ(ids[0]);
    } else {
      this.queryString += '&id=' + encodeURIComponent(ids.join(","));
    }
    return this;
  }), _defineProperty(_Mura$Core$extend, "pointInTime", function pointInTime(_pointInTime) {
    this.queryString += '&pointInTime=' + encodeURIComponent(_pointInTime);
    return this;
  }), _defineProperty(_Mura$Core$extend, "showExcludeSearch", function showExcludeSearch(_showExcludeSearch) {
    this.queryString += '&showExcludeSearch=' + encodeURIComponent(_showExcludeSearch);
    return this;
  }), _defineProperty(_Mura$Core$extend, "applyPermFilter", function applyPermFilter(_applyPermFilter) {
    this.queryString += '&applyPermFilter=' + encodeURIComponent(_applyPermFilter);
    return this;
  }), _defineProperty(_Mura$Core$extend, "imageSizes", function imageSizes(_imageSizes) {
    this.queryString += '&imageSizes=' + encodeURIComponent(_imageSizes);
    return this;
  }), _defineProperty(_Mura$Core$extend, "useCategoryIntersect", function useCategoryIntersect(_useCategoryIntersect) {
    this.queryString += '&useCategoryIntersect=' + encodeURIComponent(_useCategoryIntersect);
    return this;
  }), _defineProperty(_Mura$Core$extend, "includeHomepage", function includeHomepage(_includeHomepage) {
    this.queryString += '&includehomepage=' + encodeURIComponent(_includeHomepage);
    return this;
  }), _defineProperty(_Mura$Core$extend, "innerJoin", function innerJoin(relatedEntity) {
    this.queryString += '&innerJoin' + encodeURIComponent('[' + this.propIndex + ']') + '=' + encodeURIComponent(relatedEntity);
    this.propIndex++;
    return this;
  }), _defineProperty(_Mura$Core$extend, "leftJoin", function leftJoin(relatedEntity) {
    this.queryString += '&leftJoin' + encodeURIComponent('[' + this.propIndex + ']') + '=' + encodeURIComponent(relatedEntity);
    this.propIndex++;
    return this;
  }), _defineProperty(_Mura$Core$extend, "getIterator", function getIterator(params) {
    return this.getQuery(params);
  }), _defineProperty(_Mura$Core$extend, "getQuery", function getQuery(params) {
    var self = this;
    if (typeof params != 'undefined') {
      for (var p in params) {
        if (params.hasOwnProperty(p)) {
          if (typeof self[p] == 'function') {
            self[p](params[p]);
          } else {
            self.andProp(p).isEQ(params[p]);
          }
        }
      }
    }
    return new Promise(function (resolve, reject) {
      var rcEndpoint = self._requestcontext.getAPIEndpoint();
      if (rcEndpoint.charAt(rcEndpoint.length - 1) == "/") {
        var apiEndpoint = rcEndpoint;
      } else {
        var apiEndpoint = rcEndpoint + '/';
      }
      self._requestcontext.request({
        type: 'get',
        cache: self.cache,
        next: self.next,
        url: apiEndpoint + self.queryString,
        success: function success(resp) {
          if (resp.data != 'undefined') {
            var returnObj = new Mura.EntityCollection(resp.data, self._requestcontext);
            if (typeof resolve == 'function') {
              resolve(returnObj);
            }
          } else if (typeof reject == 'function') {
            reject(resp);
          }
        },
        error: function error(resp) {
          if (typeof reject == 'function') {
            reject(resp);
          }
        }
      });
    });
  }), _Mura$Core$extend));
}
module.exports = attach;

/***/ }),

/***/ 23:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  //https://github.com/malko/l.js
  /*
  * script for js/css parallel loading with dependancies management
  * @author Jonathan Gotti < jgotti at jgotti dot net >
  * @licence dual licence mit / gpl
  * @since 2012-04-12
  * @todo add prefetching using text/cache for js files
  * @changelog
  *            - 2014-06-26 - bugfix in css loaded check when hashbang is used
  *            - 2014-05-25 - fallback support rewrite + null id bug correction + minification work
  *            - 2014-05-21 - add cdn fallback support with hashbang url
  *            - 2014-05-22 - add support for relative paths for stylesheets in checkLoaded
  *            - 2014-05-21 - add support for relative paths for scripts in checkLoaded
  *            - 2013-01-25 - add parrallel loading inside single load call
  *            - 2012-06-29 - some minifier optimisations
  *            - 2012-04-20 - now sharp part of url will be used as tag id
  *                         - add options for checking already loaded scripts at load time
  *            - 2012-04-19 - add addAliases method
  * @note coding style is implied by the target usage of this script not my habbits
  */

  if (typeof window != 'undefined' && typeof window.document != 'undefined') {
    var isA = function isA(a, b) {
        return a instanceof (b || Array);
      }
      //-- some minifier optimisation
      ,
      D = document,
      getElementsByTagName = 'getElementsByTagName',
      length = 'length',
      readyState = 'readyState',
      onreadystatechange = 'onreadystatechange'
      //-- get the current script tag for further evaluation of it's eventual content
      ,
      scripts = D[getElementsByTagName]("script"),
      scriptTag = scripts[scripts[length] - 1],
      script = scriptTag.innerHTML.replace(/^\s+|\s+$/g, '');
    try {
      var preloadsupport = w.document.createElement("link").relList.supports("preload");
    } catch (e) {
      var preloadsupport = false;
    }

    //avoid multiple inclusion to override current loader but allow tag content evaluation
    if (!Mura.ljs) {
      var checkLoaded = scriptTag.src.match(/checkLoaded/) ? 1 : 0
        //-- keep trace of header as we will make multiple access to it
        ,
        header = D[getElementsByTagName]("head")[0] || D.documentElement,
        urlParse = function urlParse(url) {
          var parts = {}; // u => url, i => id, f = fallback
          parts.u = url.replace(/#(=)?([^#]*)?/g, function (m, a, b) {
            parts[a ? 'f' : 'i'] = b;
            return '';
          });
          return parts;
        },
        appendElmt = function appendElmt(type, attrs, cb) {
          var el = D.createElement(type),
            i;
          if (type == 'script' && cb) {
            //-- this is not intended to be used for link
            if (el[readyState]) {
              el[onreadystatechange] = function () {
                if (el[readyState] === "loaded" || el[readyState] === "complete") {
                  el[onreadystatechange] = null;
                  cb();
                }
              };
            } else {
              el.onload = cb;
            }
          } else if (type == 'link' && _typeof(attrs) == 'object' && typeof attrs.rel != 'undefined' && attrs.rel == 'preload') {
            var loadCB = function loadCB() {
              if (el.addEventListener) {
                el.removeEventListener("load", loadCB);
              }
              el.media = media || "all";
              el.rel = "stylesheet";
            };
            var onloadcssdefined = function onloadcssdefined(cb) {
              var sheets = document.styleSheets;
              var resolvedHref = attrs.href;
              var i = sheets.length;
              while (i--) {
                if (sheets[i].href === resolvedHref) {
                  return cb();
                }
              }
              setTimeout(function () {
                onloadcssdefined(cb);
              });
            };
            /*
            Inspired by
            https://github.com/filamentgroup/loadCSS/blob/master/src/loadCSS.js
            */

            var media = attrs.media || 'all';
            attrs.as = attrs.as || 'style';
            if (!preloadsupport) {
              attrs.media = 'x only';
              attrs.rel = "stylesheet";
            }
            ;
            if (el.addEventListener) {
              el.addEventListener("load", loadCB);
            }
            el.onloadcssdefined = onloadcssdefined;
            onloadcssdefined(loadCB);
          }
          for (i in attrs) {
            attrs[i] && (el[i] = attrs[i]);
          }
          header.appendChild(el);
          // return e; // unused at this time so drop it
        },
        _load = function load(url, cb) {
          if (this.aliases && this.aliases[url]) {
            var args = this.aliases[url].slice(0);
            isA(args) || (args = [args]);
            cb && args.push(cb);
            return this.load.apply(this, args);
          }
          if (isA(url)) {
            // parallelized request
            for (var l = url[length]; l--;) {
              this.load(url[l]);
            }
            cb && url.push(cb); // relaunch the dependancie queue
            return this.load.apply(this, url);
          }
          if (url.match(/\.css\b/)) {
            return this.loadcss(url, cb);
          } else if (url.match(/\.html\b/)) {
            return this.loadimport(url, cb);
          } else {
            return this.loadjs(url, cb);
          }
        },
        loaded = {} // will handle already loaded urls
        ,
        loader = {
          aliases: {},
          loadjs: function loadjs(url, attrs, cb) {
            if (_typeof(url) == 'object') {
              if (Array.isArray(url)) {
                return loader.load.apply(this, arguments);
              } else if (typeof attrs === 'function') {
                cb = attrs;
                attrs = {};
                url = attrs.href;
              } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
                return loader.load.apply(this, arguments);
              } else {
                attrs = url;
                url = attrs.href;
                cb = undefined;
              }
            } else if (typeof attrs == 'function') {
              cb = attrs;
              attrs = {};
            } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
              return loader.load.apply(this, arguments);
            }
            if (typeof attrs === 'undefined') {
              attrs = {};
            }
            var parts = urlParse(url);
            var partToAttrs = [['i', 'id'], ['f', 'fallback'], ['u', 'src']];
            for (var i = 0; i < partToAttrs.length; i++) {
              var part = partToAttrs[i];
              if (!(part[1] in attrs) && part[0] in parts) {
                attrs[part[1]] = parts[part[0]];
              }
            }
            if (typeof attrs.type === 'undefined') {
              attrs.type = 'text/javascript';
            }
            var finalAttrs = {};
            for (var a in attrs) {
              if (a != 'fallback') {
                finalAttrs[a] = attrs[a];
              }
            }
            finalAttrs.onerror = function (error) {
              if (attrs.fallback) {
                var c = error.currentTarget;
                c.parentNode.removeChild(c);
                finalAttrs.src = attrs.fallback;
                appendElmt('script', attrs, cb);
              }
            };
            if (loaded[finalAttrs.src] === true) {
              // already loaded exec cb if any
              cb && cb();
              return this;
            } else if (loaded[finalAttrs.src] !== undefined) {
              // already asked for loading we append callback if any else return
              if (cb) {
                loaded[finalAttrs.src] = function (ocb, cb) {
                  return function () {
                    ocb && ocb();
                    cb && cb();
                  };
                }(loaded[finalAttrs.src], cb);
              }
              return this;
            }
            // first time we ask this script
            loaded[finalAttrs.src] = function (cb) {
              return function () {
                loaded[finalAttrs.src] = true;
                cb && cb();
              };
            }(cb);
            cb = function cb() {
              loaded[url]();
            };
            appendElmt('script', finalAttrs, cb);
            return this;
          },
          loadcss: function loadcss(url, attrs, cb) {
            if (_typeof(url) == 'object') {
              if (Array.isArray(url)) {
                return loader.load.apply(this, arguments);
              } else if (typeof attrs === 'function') {
                cb = attrs;
                attrs = url;
                url = attrs.href;
              } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
                return loader.load.apply(this, arguments);
              } else {
                attrs = url;
                url = attrs.href;
                cb = undefined;
              }
            } else if (typeof attrs == 'function') {
              cb = attrs;
              attrs = {};
            } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
              return loader.load.apply(this, arguments);
            }
            var parts = urlParse(url);
            parts = {
              type: 'text/css',
              rel: 'stylesheet',
              href: url,
              id: parts.i
            };
            if (typeof attrs !== 'undefined') {
              for (var a in attrs) {
                parts[a] = attrs[a];
              }
            }
            loaded[parts.href] || appendElmt('link', parts);
            loaded[parts.href] = true;
            cb && cb();
            return this;
          },
          loadimport: function loadimport(url, attrs, cb) {
            if (_typeof(url) == 'object') {
              if (Array.isArray(url)) {
                return loader.load.apply(this, arguments);
              } else if (typeof attrs === 'function') {
                cb = attrs;
                attrs = url;
                url = attrs.href;
              } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
                return loader.load.apply(this, arguments);
              } else {
                attrs = url;
                url = attrs.href;
                cb = undefined;
              }
            } else if (typeof attrs == 'function') {
              cb = attrs;
              attrs = {};
            } else if (typeof attrs == 'string' || _typeof(attrs) == 'object' && Array.isArray(attrs)) {
              return loader.load.apply(this, arguments);
            }
            var parts = urlParse(url);
            parts = {
              rel: 'import',
              href: url,
              id: parts.i
            };
            if (typeof attrs !== 'undefined') {
              for (var a in attrs) {
                parts[a] = attrs[a];
              }
            }
            loaded[parts.href] || appendElmt('link', parts);
            loaded[parts.href] = true;
            cb && cb();
            return this;
          },
          load: function load() {
            var argv = arguments,
              argc = argv[length];
            if (argc === 1 && isA(argv[0], Function)) {
              argv[0]();
              return this;
            }
            _load.call(this, argv[0], argc <= 1 ? undefined : function () {
              loader.load.apply(loader, [].slice.call(argv, 1));
            });
            return this;
          },
          addAliases: function addAliases(aliases) {
            for (var i in aliases) {
              this.aliases[i] = isA(aliases[i]) ? aliases[i].slice(0) : aliases[i];
            }
            return this;
          }
        };
      if (checkLoaded) {
        var i, l, links, url;
        for (i = 0, l = scripts[length]; i < l; i++) {
          (url = scripts[i].getAttribute('src')) && (loaded[url.replace(/#.*$/, '')] = true);
        }
        links = D[getElementsByTagName]('link');
        for (i = 0, l = links[length]; i < l; i++) {
          (links[i].rel === 'import' || links[i].rel === 'stylesheet' || links[i].type === 'text/css') && (loaded[links[i].getAttribute('href').replace(/#.*$/, '')] = true);
        }
      }
      //export ljs
      Mura.ljs = loader;
      // eval inside tag code if any
    }

    scriptTag.src && script && appendElmt('script', {
      innerHTML: script
    });
  }
}
module.exports = attach;

/***/ }),

/***/ 285:
/***/ (function(module) {

function attach(Mura) {
  /**
  * Creates a new Mura.Core
  * @name Mura.Core
  * @class
  * @memberof Mura
  * @param  {object} properties Object containing values to set into object
  * @return {Mura.Core}
  */

  function Core() {
    this.init.apply(this, arguments);
    return this;
  }

  /** @lends Mura.Core.prototype */
  Core.prototype = {
    init: function init() {},
    /**
     * invoke - Invokes a method
     *
     * @param  {string} funcName Method to call
     * @param  {object} params Arguments to submit to method
     * @return {any}
     */
    invoke: function invoke(funcName, params) {
      params = params || {};
      if (this[funcName] == 'function') {
        return this[funcName].apply(this, params);
      }
    },
    /**
     * trigger - Triggers custom event on Mura objects
     *
     * @name Mura.Core.trigger
     * @function
     * @param  {string} eventName  Name of header
     * @return {object}  Self
     */
    trigger: function trigger(eventName) {
      eventName = eventName.toLowerCase();
      if (typeof this.prototype.handlers[eventName] != 'undefined') {
        var handlers = this.prototype.handlers[eventName];
        for (var handler in handlers) {
          if (typeof handler.call == 'undefined') {
            handler(this);
          } else {
            handler.call(this, this);
          }
        }
      }
      return this;
    }
  };

  /** @lends Mura.Core.prototype */

  /**
   * Extend - Allow the creation of new Mura core classes
   *
   * @name Mura.Core.extend
   * @function
   * @param  {object} properties  Properties to add to new class prototype
   * @return {class}  Self
   */
  Core.extend = function (properties) {
    var self = this;
    return Mura.extend(Mura.extendClass(self, properties), {
      extend: self.extend,
      handlers: []
    });
  };
  Mura.Core = Core;
}
module.exports = attach;

/***/ }),

/***/ 56:
/***/ (function(__unused_webpack_module, exports) {

if (typeof window != 'undefined' && typeof window.document != 'undefined') {
  window.Element && function (ElementPrototype) {
    ElementPrototype.matchesSelector = ElementPrototype.matchesSelector || ElementPrototype.mozMatchesSelector || ElementPrototype.msMatchesSelector || ElementPrototype.oMatchesSelector || ElementPrototype.webkitMatchesSelector || function (selector) {
      var node = this,
        nodes = (node.parentNode || node.document).querySelectorAll(selector),
        i = -1;
      while (nodes[++i] && nodes[i] != node) {
        ;
      }
      return !!nodes[i];
    };
  }(Element.prototype);

  //https://github.com/filamentgroup/loadCSS/blob/master/src/cssrelpreload.js
  /*! loadCSS. [c]2017 Filament Group, Inc. MIT License */
  /* This file is meant as a standalone workflow for
  - testing support for link[rel=preload]
  - enabling async CSS loading in browsers that do not support rel=preload
  - applying rel preload css once loaded, whether supported or not.
  */
  (function (w) {
    "use strict";

    // rel=preload support test
    if (!w.loadCSS) {
      w.loadCSS = function () {};
    }
    // define on the loadCSS obj
    var rp = loadCSS.relpreload = {};
    // rel=preload feature support test
    // runs once and returns a function for compat purposes
    rp.support = function () {
      var ret;
      try {
        ret = w.document.createElement("link").relList.supports("preload");
      } catch (e) {
        ret = false;
      }
      return function () {
        return ret;
      };
    }();
    // if preload isn't supported, get an asynchronous load by using a non-matching media attribute
    // then change that media back to its intended value on load
    rp.bindMediaToggle = function (link) {
      // remember existing media attr for ultimate state, or default to 'all'
      var finalMedia = link.media || "all";
      function enableStylesheet() {
        link.media = finalMedia;
      }
      // bind load handlers to enable media
      if (link.addEventListener) {
        link.addEventListener("load", enableStylesheet);
      } else if (link.attachEvent) {
        link.attachEvent("onload", enableStylesheet);
      }
      // Set rel and non-applicable media type to start an async request
      // note: timeout allows this to happen async to let rendering continue in IE
      setTimeout(function () {
        link.rel = "stylesheet";
        link.media = "only x";
      });
      // also enable media after 3 seconds,
      // which will catch very old browsers (android 2.x, old firefox) that don't support onload on link
      setTimeout(enableStylesheet, 3000);
    };
    // loop through link elements in DOM
    rp.poly = function () {
      // double check this to prevent external calls from running
      if (rp.support()) {
        return;
      }
      var links = w.document.getElementsByTagName("link");
      for (var i = 0; i < links.length; i++) {
        var link = links[i];
        // qualify links to those with rel=preload and as=style attrs
        if (link.rel === "preload" && link.getAttribute("as") === "style" && !link.getAttribute("data-loadcss")) {
          // prevent rerunning on link
          link.setAttribute("data-loadcss", true);
          // bind listeners to toggle media back
          rp.bindMediaToggle(link);
        }
      }
    };
    // if unsupported, run the polyfill
    if (!rp.support()) {
      // run once at least
      rp.poly();
      // rerun poly on an interval until onload
      var run = w.setInterval(rp.poly, 500);
      if (w.addEventListener) {
        w.addEventListener("load", function () {
          rp.poly();
          w.clearInterval(run);
        });
      } else if (w.attachEvent) {
        w.attachEvent("onload", function () {
          rp.poly();
          w.clearInterval(run);
        });
      }
    }
    // commonjs
    if (true) {
      exports.loadCSS = loadCSS;
    } else {}
  })(window);

  //https://stackoverflow.com/questions/44091567/how-to-cover-a-div-with-an-img-tag-like-background-image-does
  if ('objectFit' in document.documentElement.style === false) {
    document.addEventListener('DOMContentLoaded', function () {
      Array.prototype.forEach.call(document.querySelectorAll('img[data-object-fit]'), function (image) {
        (image.runtimeStyle || image.style).background = 'url("' + image.src + '") no-repeat 50%/' + (image.currentStyle ? image.currentStyle['object-fit'] : image.getAttribute('data-object-fit'));
        image.src = 'data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'' + image.width + '\' height=\'' + image.height + '\'%3E%3C/svg%3E';
      });
    });
  }
}

/***/ }),

/***/ 980:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  /**
  * Creates a new Mura.RequestContext
  * @name	Mura.RequestContext
  * @class
  * @extends Mura.Core
  * @memberof Mura
  * @param	{object} request		 Siteid
  * @param	{object} response Entity name
  * @param	{object} requestHeaders Optional
  * @return {Mura.RequestContext} Self
  */

  Mura.RequestContext = Mura.Core.extend( /** @lends Mura.RequestContext.prototype */
  {
    init: function init(request, response, headers, siteid, endpoint, mode) {
      //Logic aded to support single config object arg
      if (_typeof(request) === 'object' && typeof response === 'undefined') {
        var config = request;
        request = config.req || config.request;
        response = config.res || config.response;
        headers = config.headers;
        siteid = config.siteid;
        endpoint = config.endpoint;
        mode = config.mode;
        renderMode = config.renderMode;
      } else {
        if (typeof headers == 'string') {
          var originalSiteid = siteid;
          siteid = headers;
          if (_typeof(originalSiteid) === 'object') {
            headers = originalSiteid;
          } else {
            headers = {};
          }
        }
      }
      this.siteid = siteid || Mura.siteid;
      this.apiEndpoint = endpoint || Mura.getAPIEndpoint();
      this.mode = mode || Mura.getMode();
      this.renderMode = typeof renderMode != 'undefined' ? renderMode : Mura.getRenderMode();
      this.requestObject = request;
      this.responseObject = response;
      this._request = new Mura.Request(request, response, headers, this.renderMode);
      if (this.mode == 'rest') {
        this.apiEndpoint = this.apiEndpoint.replace('/json/', '/rest/');
      }
      return this;
    },
    /**
     * setRequestHeader - Initialiazes feed
     *
     * @param	{string} headerName	Name of header
     * @param	{string} value Header value
     * @return {Mura.RequestContext}	Self
     */
    setRequestHeader: function setRequestHeader(headerName, value) {
      this._request.setRequestHeader(headerName, value);
      return this;
    },
    /**
     * getRequestHeader - Returns a request header value
     *
     * @param	{string} headerName	Name of header
     * @return {string} header Value
     */
    getRequestHeader: function getRequestHeader(headerName) {
      return this._request.getRequestHeader(headerName);
    },
    /**
     * getAPIEndpoint() - Returns api endpoint
     *
     * @return {string} api endpoint
     */
    getAPIEndpoint: function getAPIEndpoint() {
      return this.apiEndpoint;
    },
    /**
     * setAPIEndpoint() - sets api endpoint
     * 
     * @param	{string} apiEndpoin apiEndpoint
     * @return {object} self
     */
    setAPIEndpoint: function setAPIEndpoint(apiEndpoint) {
      this.apiEndpoint = apiEndpoint;
      return this;
    },
    /**
     * getMode() - Returns context's mode either rest or json
     *
     * @return {string} mode
     */
    getMode: function getMode() {
      return this.mode;
    },
    /**
     * setAPIEndpoint() - sets context's mode either rest or json
     * 
     * @param	{string} mode mode
     * @return {object} self
     */
    setMode: function setMode(mode) {
      this.mode = mode;
      if (this.mode == 'rest') {
        this.apiEndpoint = this.apiEndpoint.replace('/json/', '/rest/');
      } else {
        this.apiEndpoint = this.apiEndpoint.replace('/rest/', '/json/');
      }
      return this;
    },
    /**
     * getRequestHeaders - Returns a request header value
     *
     * @return {object} All Headers
     */
    getRequestHeaders: function getRequestHeaders() {
      return this._request.getRequestHeaders();
    },
    /**
     * request - Executes a request
     *
     * @param	{object} params		 Object
     * @return {Promise}						Self
     */
    request: function request(config) {
      return this._request.execute(config);
    },
    /**
     * renderFilename - Returns "Rendered" JSON object of content
     *
     * @param	{type} filename Mura content filename
     * @param	{type} params Object
     * @return {Promise}
     */
    renderFilename: function renderFilename(filename, params) {
      var query = [];
      var self = this;
      params = params || {};
      params.filename = params.filename || '';
      params.siteid = params.siteid || this.siteid;
      var cache = params.cache || 'default';
      delete params.cache;
      var next = params.next || {};
      delete params.next;
      for (var key in params) {
        if (key != 'entityname' && key != 'filename' && key != 'siteid' && key != 'method') {
          query.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key]));
        }
      }
      return new Promise(function (resolve, reject) {
        self.request({
          async: true,
          type: 'get',
          cache: cache,
          next: next,
          url: self.apiEndpoint + '/content/_path/' + filename + '?' + query.join('&'),
          success: function success(resp) {
            if (resp != null && typeof location != 'undefined' && typeof resp.data != 'undefined' && typeof resp.data.redirect != 'undefined' && typeof resp.data.contentid == 'undefined') {
              if (resp.data.redirect && resp.data.redirect != location.href) {
                location.href = resp.data.redirect;
              } else {
                location.reload(true);
              }
            } else {
              var item = new Mura.entities.Content({}, self);
              item.set(resp.data);
              resolve(item);
            }
          },
          error: function error(resp) {
            if (resp != null && typeof resp.data != 'undefined' && typeof resp.data != 'undefined' && typeof resolve == 'function') {
              var item = new Mura.entities.Content({}, self);
              item.set(resp.data);
              resolve(item);
            } else if (typeof reject == 'function') {
              reject(resp);
            }
          }
        });
      });
    },
    /**
     * findText - Returns content associated with text
     *
     * @param	{type} text 
     * @param	{type} params Object
     * @return {Promise}
     */
    findText: function findText(text, params) {
      var self = this;
      params = params || {};
      params.text = text || params.text || '';
      params.siteid = params.siteid || this.siteid;
      params.method = "findtext";
      var cache = params.cache || 'default';
      delete params.cache;
      var next = params.next || {};
      delete params.next;
      return new Promise(function (resolve, reject) {
        self.request({
          type: 'get',
          url: self.apiEndpoint,
          cache: cache,
          next: next,
          data: params,
          success: function success(resp) {
            var collection = new Mura.EntityCollection(resp.data, self);
            if (typeof resolve == 'function') {
              resolve(collection);
            }
          },
          error: function error(resp) {
            console.log(resp);
          }
        });
      });
    },
    /**
     * getEntity - Returns Mura.Entity instance
     *
     * @param	{string} entityname Entity Name
     * @param	{string} siteid		 Siteid
     * @return {Mura.Entity}
     */
    getEntity: function getEntity(entityname, siteid) {
      if (typeof entityname == 'string') {
        var properties = {
          entityname: entityname.substr(0, 1).toUpperCase() + entityname.substr(1)
        };
        properties.siteid = siteid || this.siteid;
      } else {
        properties = entityname;
        properties.entityname = properties.entityname || 'Content';
        properties.siteid = properties.siteid || this.siteid;
      }
      properties.links = {
        permissions: this.apiEndpoint + properties.entityname + "/permissions"
      };
      if (Mura.entities[properties.entityname]) {
        var entity = new Mura.entities[properties.entityname](properties, this);
        return entity;
      } else {
        var entity = new Mura.Entity(properties, this);
        return entity;
      }
    },
    /**
     * getBean - Returns Mura.Entity instance
     *
     * @param	{string} entityname Entity Name
     * @param	{string} siteid		 Siteid
     * @return {Mura.Entity}
     */
    getBean: function getBean(entityname, siteid) {
      return this.getEntity(entityname, siteid);
    },
    /**
     * declareEntity - Declare Entity with in service factory
     *
     * @param	{object} entityConfig Entity config object
     * @return {Promise}
     */
    declareEntity: function declareEntity(entityConfig) {
      var self = this;
      if (this.getMode().toLowerCase() == 'rest') {
        return new Promise(function (resolve, reject) {
          self.request({
            async: true,
            type: 'POST',
            url: self.apiEndpoint,
            data: {
              method: 'declareEntity',
              entityConfig: encodeURIComponent(JSON.stringify(entityConfig))
            },
            success: function success(resp) {
              if (typeof resolve == 'function' && resp != null && typeof resp.data != 'undefined') {
                resolve(resp.data);
              } else if (typeof reject == 'function' && resp != null && typeof resp.error != 'undefined') {
                resolve(resp);
              } else if (typeof resolve == 'function') {
                resolve(resp);
              }
            }
          });
        });
      } else {
        return new Promise(function (resolve, reject) {
          self.request({
            type: 'POST',
            url: self.apiEndpoint + '?method=generateCSRFTokens',
            data: {
              context: ''
            },
            success: function success(resp) {
              self.request({
                async: true,
                type: 'POST',
                url: self.apiEndpoint,
                data: {
                  method: 'declareEntity',
                  entityConfig: encodeURIComponent(JSON.stringify(entityConfig)),
                  'csrf_token': resp.data.csrf_token,
                  'csrf_token_expires': resp.data.csrf_token_expires
                },
                success: function success(resp) {
                  if (typeof resolve == 'function' && resp != null && typeof resp.data != 'undefined') {
                    resolve(resp.data);
                  } else if (typeof reject == 'function' && resp != null && typeof resp.error != 'undefined') {
                    resolve(resp);
                  } else if (typeof resolve == 'function') {
                    resolve(resp);
                  }
                }
              });
            }
          });
        });
      }
    },
    /**
     * undeclareEntity - Delete entity class from Mura
     *
     * @param	{object} entityName
     * @return {Promise}
     */
    undeclareEntity: function undeclareEntity(entityName, deleteSchema) {
      var self = this;
      deleteSchema = deleteSchema || false;
      if (this.getMode().toLowerCase() == 'rest') {
        return new Promise(function (resolve, reject) {
          self.request({
            async: true,
            type: 'POST',
            url: self.apiEndpoint,
            data: {
              method: 'undeclareEntity',
              entityName: entityName,
              deleteSchema: deleteSchema
            },
            success: function success(resp) {
              if (typeof resolve == 'function' && resp != null && typeof resp.data != 'undefined') {
                resolve(resp.data);
              } else if (typeof reject == 'function' && resp != null && typeof resp.error != 'undefined') {
                resolve(resp);
              } else if (typeof resolve == 'function') {
                resolve(resp);
              }
            }
          });
        });
      } else {
        return new Promise(function (resolve, reject) {
          self.request({
            type: 'POST',
            url: self.apiEndpoint + '?method=generateCSRFTokens',
            data: {
              context: ''
            },
            success: function success(resp) {
              self.request({
                async: true,
                type: 'POST',
                url: self.apiEndpoint,
                data: {
                  method: 'undeclareEntity',
                  entityName: entityName,
                  deleteSchema: deleteSchema,
                  'csrf_token': resp.data.csrf_token,
                  'csrf_token_expires': resp.data.csrf_token_expires
                },
                success: function success(resp) {
                  if (typeof resolve == 'function' && resp != null && typeof resp.data != 'undefined') {
                    resolve(resp.data);
                  } else if (typeof reject == 'function' && resp != null && typeof resp.error != 'undefined') {
                    resolve(resp);
                  } else if (typeof resolve == 'function') {
                    resolve(resp);
                  }
                }
              });
            }
          });
        });
      }
    },
    /**
     * getFeed - Return new instance of Mura.Feed
     *
     * @param	{type} entityname Entity name
     * @return {Mura.Feed}
     */
    getFeed: function getFeed(entityname, siteid) {
      Mura.feeds = Mura.feeds || {};
      siteid = siteid || this.siteid;
      if (typeof entityname === 'string') {
        entityname = entityname.substr(0, 1).toUpperCase() + entityname.substr(1);
        if (Mura.feeds[entityname]) {
          var feed = new Mura.feeds[entityname](siteid, entityname, this);
          return feed;
        }
      }
      var feed = new Mura.Feed(siteid, entityname, this);
      return feed;
    },
    /**
     * getCurrentUser - Return Mura.Entity for current user
     *
     * @param	{object} params Load parameters, fields:listoffields
     * @return {Promise}
     */
    getCurrentUser: function getCurrentUser(params) {
      var self = this;
      params = params || {};
      params.fields = params.fields || '';
      return new Promise(function (resolve, reject) {
        if (self.currentUser) {
          resolve(self.currentUser);
        } else {
          self.request({
            async: true,
            type: 'get',
            url: self.apiEndpoint + 'findCurrentUser?fields=' + params.fields,
            cache: 'no-cache',
            success: function success(resp) {
              if (typeof resolve == 'function') {
                self.currentUser = self.getEntity('user');
                self.currentUser.set(resp.data);
                resolve(self.currentUser);
              }
            },
            error: function error(resp) {
              if (typeof resolve == 'function') {
                self.self = self.getEntity('user');
                self.currentUser.set(resp.data);
                resolve(self.currentUser);
              }
            }
          });
        }
      });
    },
    /**
     * findQuery - Returns Mura.EntityCollection with properties that match params
     *
     * @param	{object} params Object of matching params
     * @return {Promise}
     */
    findQuery: function findQuery(params) {
      var self = this;
      params = params || {};
      params.entityname = params.entityname || 'content';
      params.siteid = params.siteid || this.siteid;
      params.method = params.method || 'findQuery';
      var cache = params.cache || 'default';
      delete params.cache;
      var next = params.next || {};
      delete params.next;
      return new Promise(function (resolve, reject) {
        self.request({
          type: 'get',
          url: self.apiEndpoint,
          cache: cache,
          next: next,
          data: params,
          success: function success(resp) {
            var collection = new Mura.EntityCollection(resp.data, self);
            if (typeof resolve == 'function') {
              resolve(collection);
            }
          },
          error: function error(resp) {
            console.log(resp);
          }
        });
      });
    },
    /**
     * login - Logs user into Mura
     *
     * @param	{string} username Username
     * @param	{string} password Password
     * @param	{string} siteid	 Siteid
     * @return {Promise}
     */
    login: function login(username, password, siteid) {
      siteid = siteid || this.siteid;
      var self = this;
      return new Promise(function (resolve, reject) {
        self.request({
          type: 'post',
          url: self.apiEndpoint + '?method=generateCSRFTokens',
          data: {
            siteid: siteid,
            context: 'login'
          },
          success: function success(resp) {
            self.request({
              async: true,
              type: 'post',
              url: self.apiEndpoint,
              data: {
                siteid: siteid,
                username: username,
                password: password,
                method: 'login',
                'csrf_token': resp.data.csrf_token,
                'csrf_token_expires': resp.data.csrf_token_expires
              },
              success: function success(resp) {
                resolve(resp.data);
              }
            });
          }
        });
      });
    },
    /**
    * openGate - Open's content gate when using MXP
    *
    * @param	{string} contentid Optional: default's to Mura.contentid
    * @return {Promise}
    * @memberof {class
    */
    openGate: function openGate(contentid) {
      var self = this;
      contentid = contentid || Mura.contentid;
      if (contentid) {
        if (this.getMode().toLowerCase() == 'rest') {
          return new Promise(function (resolve, reject) {
            self.request({
              async: true,
              type: 'POST',
              url: self.apiEndpoint + '/gatedasset/open',
              data: {
                contentid: contentid
              },
              success: function success(resp) {
                if (typeof resolve == 'function' && typeof resp.data != 'undefined') {
                  resolve(resp.data);
                } else if (typeof reject == 'function' && typeof resp.error != 'undefined') {
                  resolve(resp);
                } else if (typeof resolve == 'function') {
                  resolve(resp);
                }
              }
            });
          });
        } else {
          return new Promise(function (resolve, reject) {
            self.request({
              type: 'POST',
              url: self.apiEndpoint + '?method=generateCSRFTokens',
              data: {
                context: contentid
              },
              success: function success(resp) {
                self.request({
                  async: true,
                  type: 'POST',
                  url: self.apiEndpoint + '/gatedasset/open',
                  data: {
                    contentid: contentid
                  },
                  success: function success(resp) {
                    if (typeof resolve == 'function' && typeof resp.data != 'undefined') {
                      resolve(resp.data);
                    } else if (typeof reject == 'function' && typeof resp.error != 'undefined') {
                      resolve(resp);
                    } else if (typeof resolve == 'function') {
                      resolve(resp);
                    }
                  }
                });
              }
            });
          });
        }
      }
    },
    /**
     * logout - Logs user out
     *
     * @param	{type} siteid Siteid
     * @return {Promise}
     */
    logout: function logout(siteid) {
      siteid = siteid || this.siteid;
      var self = this;
      return new Promise(function (resolve, reject) {
        self.request({
          async: true,
          type: 'post',
          url: self.apiEndpoint,
          data: {
            siteid: siteid,
            method: 'logout'
          },
          success: function success(resp) {
            resolve(resp.data);
          }
        });
      });
    },
    /**
     * normalizeRequest - I normalize protocol requests
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    normalizeRequest: function normalizeRequest(type, url, data, config) {
      if (_typeof(url) == 'object') {
        data = url.data || {};
        config = url;
        url = url.url;
      } else {
        data = data || {};
        config = config || {};
      }
      config.type = type;
      config.url = url;
      config.data = data || {};
      Mura.normalizeRequestConfig(config);
      var self = this;
      data = data || {};
      return new Promise(function (resolve, reject) {
        if (typeof resolve == 'function') {
          config.success = resolve;
        }
        if (typeof reject == 'function') {
          config.error = reject;
        }
        var normalizedConfig = Mura.extend({}, config);
        return self.request(normalizedConfig);
      });
    },
    /**
     * get - Make GET request
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    get: function get(url, data, config) {
      return this.normalizeRequest('get', url, data, config);
    },
    /**
     * post - Make POST request
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    post: function post(url, data, config) {
      return this.normalizeRequest('post', url, data, config);
    },
    /**
     * put - Make PUT request
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    put: function put(url, data, config) {
      return this.normalizeRequest('put', url, data, config);
    },
    /**
     * update - Make UPDATE request
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    patch: function patch(url, data, config) {
      return this.normalizeRequest('patch', url, data, config);
    },
    /**
     * delete - Make DELETE request
     *
     * @param	{url} url	URL
     * @param	{object} data Data to send to url
     * @return {Promise}
     */
    delete: function _delete(url, data, config) {
      return this.normalizeRequest('delete', url, data, config);
    },
    /**
     * Request Headers
    **/
    requestHeaders: {}
  });
}
module.exports = attach;

/***/ }),

/***/ 58:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  /**
  * Creates a new Mura.Request
  * @name	Mura.Request
  * @class
  * @extends Mura.Core
  * @memberof Mura
  * @param	{object} request		 Siteid
  * @param	{object} response Entity name
  * @param	{object} requestHeaders Optional
  * @return {Mura.Request}	Self
  */

  Mura.Request = Mura.Core.extend( /** @lends Mura.Request.prototype */
  {
    init: function init(request, response, headers, renderMode) {
      this.requestObject = request;
      this.responseObject = response;
      this.requestHeaders = headers || {};
      this.inNode = Mura.isInNode();
      this.renderMode = typeof renderMode != 'undefined' ? renderMode : Mura.getRenderMode();
      return this;
    },
    /**
    * execute - Make ajax request
    *
    * @param	{object} config
    * @return {Promise}
    */
    execute: function execute(config) {
      if (!('type' in config)) {
        config.type = 'GET';
      }
      if (!('data' in config)) {
        config.data = {};
      }
      if (!('headers' in config)) {
        config.headers = {};
      }
      if ('method' in config) {
        config.type = config.method;
      }
      if (!('dataType' in config)) {
        config.dataType = 'default';
      }
      Mura.normalizeRequestConfig(config);
      config.type = config.type.toLowerCase();
      try {
        //if is in node not a FormData obj
        if (this.inNode || !(config.data instanceof FormData)) {
          if (config.type === 'get' && !(typeof config.url === 'string' && config.url.toLowerCase().indexOf('purgecache') > -1) && typeof config.data.purgeCache === 'undefined' && typeof config.data.purgecache === 'undefined') {
            var sourceParams = {};
            if (!this.inNode && typeof location != 'undefined' && location.search) {
              sourceParams = Mura.getQueryStringParams(location.search);
            } else if (typeof this.requestObject != 'undefined' && typeof this.requestObject.url === 'string' && this.requestObject.url) {
              var qa = this.requestObject.url.split("?");
              if (qa.length) {
                var qs = qa[qa.length - 1] || '';
                qs = qs.toString();
                sourceParams = Mura.getQueryStringParams(qs);
              }
            }
            if (typeof sourceParams.purgeCache != 'undefined') {
              config.data.purgeCache = sourceParams.purgeCache;
            } else if (typeof sourceParams.purgecache != 'undefined') {
              config.data.purgecache = sourceParams.purgecache;
            }
          }
        }
      } catch (e) {
        console.log(e);
      }
      if (typeof config.data.httpmethod != 'undefined') {
        config.type = config.data.httpmethod;
        delete config.data.httpmethod;
      }
      if (this.inNode) {
        this.nodeRequest(config);
      } else {
        this.browserRequest(config);
      }
    },
    /**
     * setRequestHeader - Initialiazes feed
     *
     * @param	{string} headerName	Name of header
     * @param	{string} value Header value
     * @return {Mura.RequestContext}						Self
     */
    setRequestHeader: function setRequestHeader(headerName, value) {
      headerName = headerName.toLowerCase();
      this.requestHeaders[headerName] = value;
      return this;
    },
    /**
     * getRequestHeader - Returns a request header value
     *
     * @param	{string} headerName	Name of header
     * @return {string} header Value
     */
    getRequestHeader: function getRequestHeader(headerName) {
      headerName = headerName.toLowerCase();
      if (typeof this.requestHeaders[headerName] != 'undefined') {
        return this.requestHeaders[headerName];
      } else {
        return null;
      }
    },
    /**
     * getRequestHeaders - Returns a request header value
     *
     * @return {object} All Headers
     */
    getRequestHeaders: function getRequestHeaders() {
      return this.requestHeaders;
    },
    nodeRequest: function nodeRequest(config) {
      var _this = this;
      if (typeof this.renderMode != 'undefined') {
        config.renderMode = this.renderMode;
      }
      var self = this;
      if (typeof this.requestObject != 'undefined' && typeof this.requestObject.headers != 'undefined') {
        ['Cookie', 'X-Client_id', 'X-Client_secret', 'X-Access_token', 'Access_Token', 'Authorization', 'User-Agent', 'Referer', 'X-Forwarded-For', 'X-Forwarded-Host', 'X-Forwarded-Proto'].forEach(function (item) {
          if (typeof _this.requestObject.headers[item] != 'undefined') {
            config.headers[item.toLowerCase()] = _this.requestObject.headers[item];
          } else {
            var lcaseItem = item.toLowerCase();
            if (typeof _this.requestObject.headers[lcaseItem] != 'undefined') {
              config.headers[lcaseItem] = _this.requestObject.headers[lcaseItem];
            }
          }
        });
      }
      var h;
      for (h in Mura.requestHeaders) {
        if (Mura.requestHeaders.hasOwnProperty(h)) {
          config.headers[h.toLowerCase()] = Mura.requestHeaders[h];
        }
      }
      for (h in this.requestHeaders) {
        if (this.requestHeaders.hasOwnProperty(h)) {
          config.headers[h.toLowerCase()] = this.requestHeaders[h];
        }
      }
      var nodeProxyHeaders = function nodeProxyHeaders(response) {
        if (typeof self.responseObject != 'undefined') {
          self.responseObject.proxiedResponse = response;
          if (!self.responseObject.headersSent) {
            var incomingHeaders = {};
            response.headers.forEach(function (value, key) {
              incomingHeaders[key.toLowerCase()] = value;
            });
            if (response.statusCode > 300 && response.status < 400) {
              var _header = incomingHeaders['location'];
              if (_header) {
                try {
                  //match casing of mura-next connector
                  self.responseObject.setHeader('location', _header);
                  self.responseObject.statusCode = response.statusCode;
                } catch (e) {
                  console.log('Error setting location header');
                }
              }
            }
            var header = '';
            header = incomingHeaders['cache-control'];
            if (header) {
              try {
                //match casing of mura-next connector
                self.responseObject.setHeader('cache-control', header);
              } catch (e) {
                console.log(e);
                console.log('Error setting Cache-Control header');
              }
            }
            header = incomingHeaders['pragma'];
            if (header) {
              try {
                //match casing of mura-next connector
                self.responseObject.setHeader('pragma', header);
              } catch (e) {
                console.log('Error setting Pragma header');
              }
            }
          }
        }
      };
      var nodeProxyCookies = function nodeProxyCookies(response) {
        var debug = typeof Mura.debug != 'undefined' && Mura.debug;
        if (typeof self.responseObject != 'undefined' && typeof self.requestObject != 'undefined' && typeof self.requestObject.headers != 'undefined') {
          var existingCookies = typeof self.requestObject.headers['cookie'] != 'undefined' ? self.requestObject.headers['cookie'] : '';
          var incomingHeaders = {};
          response.headers.forEach(function (value, key) {
            incomingHeaders[key.toLowerCase()] = value;
          });
          var newSetCookies = incomingHeaders['set-cookie'];
          if (Array.isArray(existingCookies)) {
            if (existingCookies.length) {
              existingCookies = existingCookies[0];
            } else {
              existingCookies = '';
            }
          }
          existingCookies = existingCookies.split("; ");
          if (!Array.isArray(newSetCookies)) {
            if (typeof newSetCookies === 'string') {
              newSetCookies = newSetCookies.split("; ");
            } else {
              newSetCookies = [];
            }
          }
          if (debug) {
            console.log('response cookies:');
            console.log(newSetCookies);
          }
          if (newSetCookies.length) {
            try {
              var setCookieAccumulator = [];
              var existingSetCookie = self.responseObject.getHeader('set-cookie');
              if (!Array.isArray(existingSetCookie)) {
                if (!existingSetCookie) {
                  existingSetCookie = [];
                } else if (typeof existingSetCookie == 'string') {
                  existingSetCookie = [existingSetCookie];
                } else {
                  existingSetCookie = [];
                }
              }
              for (var i = 0; i < existingSetCookie.length; i++) {
                setCookieAccumulator[i] = existingSetCookie[i];
              }
              for (var _i = 0; _i < newSetCookies.length; _i++) {
                setCookieAccumulator[_i] = newSetCookies[_i];
              }
              self.responseObject.setHeader('set-cookie', setCookieAccumulator);
            } catch (e) {
              console.log(e);
            }
          }
          var cookieMap = {};
          var setMap = {};
          var c;
          var tempCookie;
          // pull out existing cookies
          if (existingCookies.length) {
            for (c in existingCookies) {
              tempCookie = existingCookies[c];
              if (typeof tempCookie != 'undefined') {
                tempCookie = existingCookies[c].split(" ")[0].split("=");
                if (tempCookie.length > 1) {
                  cookieMap[tempCookie[0]] = tempCookie[1].split(';')[0];
                }
              }
            }
          }
          if (debug) {
            console.log('existing 1:');
            console.log(cookieMap);
          }
          // pull out new cookies
          if (newSetCookies.length) {
            for (c in newSetCookies) {
              tempCookie = newSetCookies[c];
              if (typeof tempCookie != 'undefined') {
                tempCookie = tempCookie.split(" ")[0].split("=");
                if (tempCookie.length > 1) {
                  cookieMap[tempCookie[0]] = tempCookie[1].split(';')[0];
                }
              }
            }
          }
          if (debug) {
            console.log('existing 2:');
            console.log(cookieMap);
          }
          var cookie = '';
          // put cookies back in in the same order that they came out
          if (existingCookies.length) {
            for (c in existingCookies) {
              tempCookie = existingCookies[c];
              if (typeof tempCookie != 'undefined') {
                tempCookie = tempCookie.split(" ")[0].split("=");
                if (tempCookie.length > 1) {
                  if (cookie != '') {
                    cookie = cookie + "; ";
                  }
                  setMap[tempCookie[0]] = true;
                  cookie = cookie + tempCookie[0] + "=" + cookieMap[tempCookie[0]];
                }
              }
            }
          }
          if (newSetCookies.length) {
            for (c in newSetCookies) {
              tempCookie = newSetCookies[c];
              if (typeof tempCookie != 'undefined') {
                tempCookie = tempCookie.split(" ")[0].split("=");
                if (typeof setMap[tempCookie[0]] == 'undefined' && tempCookie.length > 1) {
                  if (cookie != '') {
                    cookie = cookie + "; ";
                  }
                  setMap[tempCookie[0]] = true;
                  cookie = cookie + tempCookie[0] + "=" + cookieMap[tempCookie[0]];
                }
              }
            }
          }
          self.requestObject.headers['cookie'] = cookie;
          if (debug) {
            console.log('merged cookies:');
            console.log(self.requestObject.headers['cookie']);
          }
        }
      };
      var parsedConfig = this.parseRequestConfig(config);
      fetch(parsedConfig.url, parsedConfig).then(function (response) {
        nodeProxyCookies(response);
        nodeProxyHeaders(response);
        response.text().then(function (body) {
          var result = '';
          try {
            result = JSON.parse.call(null, body);
          } catch (e) {
            result = body;
          }
          config.success(result, response);
        }).catch(function (error) {
          if (response.status >= 500) {
            console.log(error);
            config.error(error);
          } else {
            config.success('', response);
          }
        });
      }, function (response) {
        console.log(response);
        throw new Error(response.statusText);
      });
    },
    browserRequest: function browserRequest(config) {
      var h;
      for (h in Mura.requestHeaders) {
        if (Mura.requestHeaders.hasOwnProperty(h)) {
          config.headers[h.toLowerCase()] = Mura.requestHeaders[h];
        }
      }
      for (h in this.requestHeaders) {
        if (this.requestHeaders.hasOwnProperty(h)) {
          config.headers[h.toLowerCase()] = this.requestHeaders[h];
        }
      }
      var parsedConfig = this.parseRequestConfig(config);
      if (typeof parsedConfig.onUploadProgress == 'function' || typeof parsedConfig.onDownloadProgress == 'function') {
        //Fetch doesn't support progress events
        this.xhrRequest(config);
      } else {
        fetch(parsedConfig.url, parsedConfig).then(function (response) {
          response.text().then(function (body) {
            var result = '';
            try {
              result = JSON.parse.call(null, body);
            } catch (e) {
              result = body;
            }
            config.success(result, response);
          }).catch(function (error) {
            if (response.status >= 500) {
              console.log(error);
              config.error(error);
            } else {
              config.success('', response);
            }
          });
        }, function (response) {
          console.log(response);
          throw new Error(response.statusText);
        });
      }
    },
    xhrRequest: function xhrRequest(config) {
      var _this2 = this;
      var debug = typeof Mura.debug != 'undefined' && Mura.debug;
      for (var h in Mura.requestHeaders) {
        if (Mura.requestHeaders.hasOwnProperty(h)) {
          config.headers[h] = Mura.requestHeaders[h];
        }
      }
      for (var h in this.requestHeaders) {
        if (this.requestHeaders.hasOwnProperty(h)) {
          config.headers[h] = this.requestHeaders[h];
        }
      }
      if (!('xhrFields' in config)) {
        config.xhrFields = {
          withCredentials: true
        };
      }
      if (!('crossDomain' in config)) {
        config.crossDomain = true;
      }
      if (!('async' in config)) {
        config.async = true;
      }
      var req = new XMLHttpRequest();
      if (typeof config.data != 'undefined' && typeof config.data.httpmethod != 'undefined') {
        config.method = params.data.httpmethod;
        delete config.data.httpmethod;
      }
      if (typeof req.addEventListener != 'undefined') {
        if (typeof params.progress == 'function') {
          req.addEventListener("progress", config.progress);
        }
        if (typeof params.abort == 'function') {
          req.addEventListener("abort", config.abort);
        }
      }
      req.onreadystatechange = function () {
        if (req.readyState == 4) {
          if (debug && typeof req.responseText != 'undefined') {
            console.log(req.responseText);
          }
          if (typeof config.error == 'function') {
            try {
              var data = JSON.parse.call(null, req.responseText);
            } catch (e) {
              var data = req.responseText;
            }
            config.error(data);
          } else {
            throw req;
          }
        }
      };
      if (config.method.toLowerCase() != 'get') {
        req.open(config.method.toUpperCase(), config.url, config.async);
        for (var p in config.xhrFields) {
          if (p in req) {
            req[p] = config.xhrFields[p];
          }
        }
        for (var h in config.headers) {
          if (config.headers.hasOwnProperty(h)) {
            req.setRequestHeader(h, config.headers[h]);
          }
        }
        if (config.data instanceof FormData) {
          try {
            req.send(config.data);
          } catch (e) {
            if (typeof config.error == 'function') {
              try {
                var data = JSON.parse.call(null, req.responseText);
              } catch (e) {
                var data = req.responseText;
              }
              config.error(data, e);
            } else {
              throw e;
            }
          }
        } else {
          req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
          setTimeout(function () {
            try {
              req.send(_this2.serializeParams(config.data));
            } catch (e) {
              if (typeof config.error == 'function') {
                try {
                  var data = JSON.parse.call(null, req.responseText);
                } catch (e) {
                  var data = req.responseText;
                }
                config.error(data, e);
              } else {
                throw e;
              }
            }
          }, 0);
        }
      } else {
        req.open(config.method.toUpperCase(), config.url, config.async);
        for (var p in config.xhrFields) {
          if (p in req) {
            req[p] = config.xhrFields[p];
          }
        }
        for (var h in config.headers) {
          if (config.headers.hasOwnProperty(h)) {
            req.setRequestHeader(h, config.headers[h]);
          }
        }
        setTimeout(function () {
          try {
            req.send();
          } catch (e) {
            if (typeof config.error == 'function') {
              if (typeof req.responseText != 'undefined') {
                try {
                  var data = JSON.parse.call(null, req.responseText);
                } catch (e) {
                  var data = req.responseText;
                }
                config.error(data, e);
              } else {
                config.error(req, e);
              }
            } else {
              throw e;
            }
          }
        }, 0);
      }
    },
    serializeParams: function serializeParams(params) {
      var query = [];
      for (var key in params) {
        if (params.hasOwnProperty(key)) {
          var val = params[key];
          if (_typeof(val) == 'object') {
            val = JSON.stringify(val);
          }
          query.push(encodeURIComponent(key) + '=' + encodeURIComponent(val));
        }
      }
      return query.join('&');
    },
    parseRequestConfig: function parseRequestConfig(config) {
      var parsedConfig = {
        method: config.type,
        headers: config.headers,
        url: config.url,
        onUploadProgress: config.progress,
        onDownloadProgress: config.download,
        next: config.next,
        cache: config.cache,
        credentials: "include",
        mode: "cors"
      };
      if (parsedConfig.method.toLowerCase() != 'get') {
        delete parsedConfig['cache-control'];
      }
      var sendJSON = parsedConfig.headers['content-type'] && parsedConfig.headers['content-type'].indexOf('json') > -1;
      var sendFormData = !this.inNode && config.data instanceof FormData;
      if (parsedConfig.method.toLowerCase() == 'get') {
        //GET send params and not data
        var _params = Mura.deepExtend({}, config.data);
        if (typeof _params['muraPointInTime'] == 'undefined' && typeof Mura.pointInTime != 'undefined') {
          _params['muraPointInTime'] = Mura.pointInTime;
        }
        var queryString = this.serializeParams(_params);
        if (config.maxQueryStringLength) {
          if (config.maxQueryStringLength && queryString.length > config.maxQueryStringLength) {
            parsedConfig.headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
            parsedConfig.body = queryString;
            parsedConfig.method = 'post';
          } else {
            if (parsedConfig.url.indexOf('?') > -1) {
              parsedConfig.url += '&' + queryString;
            } else {
              parsedConfig.url += '?' + queryString;
            }
          }
        } else {
          if (parsedConfig.url.indexOf('?') > -1) {
            parsedConfig.url += '&' + queryString;
          } else {
            parsedConfig.url += '?' + queryString;
          }
        }
        return parsedConfig;
      }
      if (sendJSON) {
        parsedConfig.body = JSON.stringify.call(null, Mura.extend({}, config.data));
      } else {
        if (sendFormData) {
          parsedConfig.body = config.data;
        } else {
          parsedConfig.data = Mura.extend({}, config.data);
          if (typeof parsedConfig.data['muraPointInTime'] == 'undefined' && typeof Mura.pointInTime != 'undefined') {
            parsedConfig.data['muraPointInTime'] = Mura.pointInTime;
          }
        }
        if (sendFormData) {
          //We use xhr to send form data when progress handlers are present
          if (!parsedConfig.progress && !parsedConfig.download) {
            delete parsedConfig.headers['content-type'];
          } else {
            parsedConfig.headers['content-type'] = 'multipart/form-data; charset=UTF-8';
          }
        } else {
          parsedConfig.headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
          parsedConfig.data = Mura.extend({}, config.data);
          if (typeof parsedConfig.data['muraPointInTime'] == 'undefined' && typeof Mura.pointInTime != 'undefined') {
            parsedConfig.data['muraPointInTime'] = Mura.pointInTime;
          }
          parsedConfig.body = this.serializeParams(parsedConfig.data);
        }
      }
      return parsedConfig;
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 526:
/***/ (function(module) {

function attach(Mura) {
  if (typeof document != 'undefined' && typeof Mura.styleMap == 'undefined') {
    var tocss = {};
    var CSSStyleDeclaration = document.createElement('div').style;
    var fromArray;
    var toArray;
    var hasError = false;
    for (var s in CSSStyleDeclaration) {
      fromArray = s.split(/(?=[A-Z])/);
      toArray = [];
      for (var i in fromArray) {
        try {
          if (typeof fromArray[i] == 'string') {
            toArray.push(fromArray[i].toLowerCase());
          }
        } catch (e) {
          console.log("error setting style from array", JSON.stringify(fromArray[i]));
        }
      }
      tocss[s] = toArray.join("-");
    }
    var styleMap = {
      tocss: tocss,
      tojs: {}
    };
    for (var s in tocss) {
      try {
        if (typeof s == 'string') {
          styleMap.tojs[s.toLowerCase()] = s;
          styleMap.tocss[s.toLowerCase()] = styleMap.tocss[s];
        }
      } catch (e) {
        console.log("error setting style to array", JSON.stringify(s));
      }
    }
    Mura.styleMap = styleMap;
  }
}
module.exports = attach;

/***/ }),

/***/ 379:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  Mura["templates"] = Mura["templates"] || {};
  Mura["templates"]["checkbox_static"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 18
          },
          "end": {
            "line": 4,
            "column": 29
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 37
          },
          "end": {
            "line": 4,
            "column": 46
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 77
          },
          "end": {
            "line": 4,
            "column": 98
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "			<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxWrapperClass") || (depth0 != null ? lookupProperty(depth0, "checkboxWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 15
          },
          "end": {
            "line": 8,
            "column": 41
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">\r\n				<input type=\"checkbox\" name=\"" + alias4(container.lambda(depths[1] != null ? lookupProperty(depths[1], "name") : depths[1], depth0)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxClass") || (depth0 != null ? lookupProperty(depth0, "checkboxClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 53
          },
          "end": {
            "line": 9,
            "column": 72
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "datarecordid") || (depth0 != null ? lookupProperty(depth0, "datarecordid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "datarecordid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 84
          },
          "end": {
            "line": 9,
            "column": 100
          }
        }
      }) : helper)) + "\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 109
          },
          "end": {
            "line": 9,
            "column": 118
          }
        }
      }) : helper)) + "\" " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(10, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 120
          },
          "end": {
            "line": 9,
            "column": 163
          }
        }
      })) != null ? stack1 : "") + "/>\r\n				<label class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxLabelClass") || (depth0 != null ? lookupProperty(depth0, "checkboxLabelClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxLabelClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 18
          },
          "end": {
            "line": 10,
            "column": 42
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" for=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "datarecordid") || (depth0 != null ? lookupProperty(depth0, "datarecordid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "datarecordid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 55
          },
          "end": {
            "line": 10,
            "column": 71
          }
        }
      }) : helper)) + "\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 73
          },
          "end": {
            "line": 10,
            "column": 82
          }
        }
      }) : helper)) + "</label>\r\n			</div>\r\n";
    },
    "10": function _(container, depth0, helpers, partials, data) {
      return " checked='checked'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n	<div class=\"mura-checkbox-group\">\r\n		<label class=\"mura-group-label\" for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 39
          },
          "end": {
            "line": 3,
            "column": 47
          }
        }
      }) : helper)) + "\">\r\n			" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.program(3, data, 0, blockParams, depths),
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 3
          },
          "end": {
            "line": 4,
            "column": 53
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 53
          },
          "end": {
            "line": 4,
            "column": 111
          }
        }
      })) != null ? stack1 : "") + "\r\n		</label>\r\n		" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 2
          },
          "end": {
            "line": 6,
            "column": 29
          }
        }
      })) != null ? stack1 : "") + "\r\n" + ((stack1 = (lookupProperty(helpers, "eachStatic") || depth0 && lookupProperty(depth0, "eachStatic") || alias2).call(alias1, depth0 != null ? lookupProperty(depth0, "dataset") : depth0, {
        "name": "eachStatic",
        "hash": {},
        "fn": container.program(9, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 2
          },
          "end": {
            "line": 12,
            "column": 17
          }
        }
      })) != null ? stack1 : "") + "	</div>\r\n</div>\r\n";
    },
    "useData": true,
    "useDepths": true
  });
  Mura["templates"]["checkbox"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 18
          },
          "end": {
            "line": 4,
            "column": 29
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 37
          },
          "end": {
            "line": 4,
            "column": 46
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 77
          },
          "end": {
            "line": 4,
            "column": 98
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.lambda,
        alias5 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "			<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxWrapperClass") || (depth0 != null ? lookupProperty(depth0, "checkboxWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 15
          },
          "end": {
            "line": 8,
            "column": 41
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">\r\n				<input source=\"" + alias5(alias4((stack1 = depths[1] != null ? lookupProperty(depths[1], "dataset") : depths[1]) != null ? lookupProperty(stack1, "source") : stack1, depth0)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxClass") || (depth0 != null ? lookupProperty(depth0, "checkboxClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 49
          },
          "end": {
            "line": 9,
            "column": 68
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" type=\"checkbox\" name=\"" + alias5(alias4(depths[1] != null ? lookupProperty(depths[1], "name") : depths[1], depth0)) + "\" id=\"field-" + alias5((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 115
          },
          "end": {
            "line": 9,
            "column": 121
          }
        }
      }) : helper)) + "\" value=\"" + alias5((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 130
          },
          "end": {
            "line": 9,
            "column": 136
          }
        }
      }) : helper)) + "\" " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(10, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 138
          },
          "end": {
            "line": 9,
            "column": 180
          }
        }
      })) != null ? stack1 : "") + "/>\r\n				<label class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "checkboxLabelClass") || (depth0 != null ? lookupProperty(depth0, "checkboxLabelClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "checkboxLabelClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 18
          },
          "end": {
            "line": 10,
            "column": 42
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" for=\"field-" + alias5((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 55
          },
          "end": {
            "line": 10,
            "column": 61
          }
        }
      }) : helper)) + "\">" + alias5((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 63
          },
          "end": {
            "line": 10,
            "column": 72
          }
        }
      }) : helper)) + "</label>\r\n			</div>\r\n";
    },
    "10": function _(container, depth0, helpers, partials, data) {
      return "checked='checked'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n	<div class=\"mura-checkbox-group\">\r\n		<label class=\"mura-group-label\" for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 39
          },
          "end": {
            "line": 3,
            "column": 47
          }
        }
      }) : helper)) + "\">\r\n			" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.program(3, data, 0, blockParams, depths),
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 3
          },
          "end": {
            "line": 4,
            "column": 53
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 53
          },
          "end": {
            "line": 4,
            "column": 111
          }
        }
      })) != null ? stack1 : "") + "\r\n		</label>\r\n		" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 2
          },
          "end": {
            "line": 6,
            "column": 29
          }
        }
      })) != null ? stack1 : "") + "\r\n" + ((stack1 = (lookupProperty(helpers, "eachCheck") || depth0 && lookupProperty(depth0, "eachCheck") || alias2).call(alias1, (stack1 = depth0 != null ? lookupProperty(depth0, "dataset") : depth0) != null ? lookupProperty(stack1, "options") : stack1, depth0 != null ? lookupProperty(depth0, "selected") : depth0, {
        "name": "eachCheck",
        "hash": {},
        "fn": container.program(9, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 2
          },
          "end": {
            "line": 12,
            "column": 16
          }
        }
      })) != null ? stack1 : "") + "	</div>\r\n</div>\r\n";
    },
    "useData": true,
    "useDepths": true
  });
  Mura["templates"]["dropdown_static"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 68
          },
          "end": {
            "line": 2,
            "column": 79
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 87
          },
          "end": {
            "line": 2,
            "column": 96
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 127
          },
          "end": {
            "line": 2,
            "column": 148
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data) {
      return " aria-required=\"true\"";
    },
    "11": function _(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<option data-isother=\"" + alias4((helper = (helper = lookupProperty(helpers, "isother") || (depth0 != null ? lookupProperty(depth0, "isother") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "isother",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 26
          },
          "end": {
            "line": 6,
            "column": 37
          }
        }
      }) : helper)) + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "datarecordid") || (depth0 != null ? lookupProperty(depth0, "datarecordid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "datarecordid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 49
          },
          "end": {
            "line": 6,
            "column": 65
          }
        }
      }) : helper)) + "\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 74
          },
          "end": {
            "line": 6,
            "column": 83
          }
        }
      }) : helper)) + "\" " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(12, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 85
          },
          "end": {
            "line": 6,
            "column": 129
          }
        }
      })) != null ? stack1 : "") + ">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 130
          },
          "end": {
            "line": 6,
            "column": 139
          }
        }
      }) : helper)) + "</option>\n";
    },
    "12": function _(container, depth0, helpers, partials, data) {
      return "selected='selected'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 13
          },
          "end": {
            "line": 1,
            "column": 36
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 48
          },
          "end": {
            "line": 1,
            "column": 56
          }
        }
      }) : helper)) + "-container\">\n		<label for=\"" + alias4((helper = (helper = lookupProperty(helpers, "labelForValue") || (depth0 != null ? lookupProperty(depth0, "labelForValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "labelForValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 14
          },
          "end": {
            "line": 2,
            "column": 31
          }
        }
      }) : helper)) + "\" data-for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 43
          },
          "end": {
            "line": 2,
            "column": 51
          }
        }
      }) : helper)) + "\">" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.program(3, data, 0),
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 53
          },
          "end": {
            "line": 2,
            "column": 103
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 103
          },
          "end": {
            "line": 2,
            "column": 161
          }
        }
      })) != null ? stack1 : "") + "</label>\n		" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 2
          },
          "end": {
            "line": 3,
            "column": 29
          }
        }
      })) != null ? stack1 : "") + "\n		<select " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 10
          },
          "end": {
            "line": 4,
            "column": 37
          }
        }
      }) : helper)) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(9, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 37
          },
          "end": {
            "line": 4,
            "column": 83
          }
        }
      })) != null ? stack1 : "") + ">\n" + ((stack1 = (lookupProperty(helpers, "eachStatic") || depth0 && lookupProperty(depth0, "eachStatic") || alias2).call(alias1, depth0 != null ? lookupProperty(depth0, "dataset") : depth0, {
        "name": "eachStatic",
        "hash": {},
        "fn": container.program(11, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 5,
            "column": 3
          },
          "end": {
            "line": 7,
            "column": 18
          }
        }
      })) != null ? stack1 : "") + "		</select>\n	</div>\n";
    },
    "useData": true
  });
  Mura["templates"]["dropdown"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      return " aria-required=\"true\"";
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 114
          },
          "end": {
            "line": 2,
            "column": 125
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 133
          },
          "end": {
            "line": 2,
            "column": 142
          }
        }
      }) : helper));
    },
    "7": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 173
          },
          "end": {
            "line": 2,
            "column": 194
          }
        }
      }) : helper)) + "</ins>";
    },
    "9": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "11": function _(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "					<option data-isother=\"" + alias4((helper = (helper = lookupProperty(helpers, "isother") || (depth0 != null ? lookupProperty(depth0, "isother") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "isother",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 27
          },
          "end": {
            "line": 6,
            "column": 38
          }
        }
      }) : helper)) + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 50
          },
          "end": {
            "line": 6,
            "column": 56
          }
        }
      }) : helper)) + "\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 65
          },
          "end": {
            "line": 6,
            "column": 71
          }
        }
      }) : helper)) + "\" " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(12, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 73
          },
          "end": {
            "line": 6,
            "column": 117
          }
        }
      })) != null ? stack1 : "") + ">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 118
          },
          "end": {
            "line": 6,
            "column": 127
          }
        }
      }) : helper)) + "</option>\n";
    },
    "12": function _(container, depth0, helpers, partials, data) {
      return "selected='selected'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 13
          },
          "end": {
            "line": 1,
            "column": 36
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 48
          },
          "end": {
            "line": 1,
            "column": 56
          }
        }
      }) : helper)) + "-container\">\n		<label for=\"" + alias4((helper = (helper = lookupProperty(helpers, "labelForValue") || (depth0 != null ? lookupProperty(depth0, "labelForValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "labelForValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 14
          },
          "end": {
            "line": 2,
            "column": 31
          }
        }
      }) : helper)) + "\" data-for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 43
          },
          "end": {
            "line": 2,
            "column": 51
          }
        }
      }) : helper)) + "\"" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 52
          },
          "end": {
            "line": 2,
            "column": 98
          }
        }
      })) != null ? stack1 : "") + ">" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(3, data, 0),
        "inverse": container.program(5, data, 0),
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 99
          },
          "end": {
            "line": 2,
            "column": 149
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 149
          },
          "end": {
            "line": 2,
            "column": 207
          }
        }
      })) != null ? stack1 : "") + "</label>\n		" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(9, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 2
          },
          "end": {
            "line": 3,
            "column": 29
          }
        }
      })) != null ? stack1 : "") + "\n			<select " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 11
          },
          "end": {
            "line": 4,
            "column": 38
          }
        }
      }) : helper)) != null ? stack1 : "") + ">\n" + ((stack1 = lookupProperty(helpers, "each").call(alias1, (stack1 = depth0 != null ? lookupProperty(depth0, "dataset") : depth0) != null ? lookupProperty(stack1, "options") : stack1, {
        "name": "each",
        "hash": {},
        "fn": container.program(11, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 5,
            "column": 4
          },
          "end": {
            "line": 7,
            "column": 13
          }
        }
      })) != null ? stack1 : "") + "			</select>\n	</div>\n";
    },
    "useData": true
  });
  Mura["templates"]["error"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 102
          },
          "end": {
            "line": 1,
            "column": 111
          }
        }
      }) : helper)) + ": ";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div id=\"" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 9
          },
          "end": {
            "line": 1,
            "column": 15
          }
        }
      }) : helper)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "formErrorWrapperClass") || (depth0 != null ? lookupProperty(depth0, "formErrorWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "formErrorWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 24
          },
          "end": {
            "line": 1,
            "column": 51
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" data-field=\"" + alias4((helper = (helper = lookupProperty(helpers, "field") || (depth0 != null ? lookupProperty(depth0, "field") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "field",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 65
          },
          "end": {
            "line": 1,
            "column": 74
          }
        }
      }) : helper)) + "\" role=\"alert\">" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "label") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 89
          },
          "end": {
            "line": 1,
            "column": 120
          }
        }
      })) != null ? stack1 : "") + alias4((helper = (helper = lookupProperty(helpers, "message") || (depth0 != null ? lookupProperty(depth0, "message") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "message",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 120
          },
          "end": {
            "line": 1,
            "column": 131
          }
        }
      }) : helper)) + "</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["file"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 117
          },
          "end": {
            "line": 2,
            "column": 138
          }
        }
      }) : helper)) + "</ins>";
    },
    "3": function _(container, depth0, helpers, partials, data) {
      return " aria-required=\"true\"";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + " mura-form-file-container\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 72
          },
          "end": {
            "line": 1,
            "column": 80
          }
        }
      }) : helper)) + "-container\">\r\n	<label for=\"" + alias4((helper = (helper = lookupProperty(helpers, "labelForValue") || (depth0 != null ? lookupProperty(depth0, "labelForValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "labelForValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 13
          },
          "end": {
            "line": 2,
            "column": 30
          }
        }
      }) : helper)) + " mura-form-file-label\" data-for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 63
          },
          "end": {
            "line": 2,
            "column": 71
          }
        }
      }) : helper)) + "_attachment\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 84
          },
          "end": {
            "line": 2,
            "column": 93
          }
        }
      }) : helper)) + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 93
          },
          "end": {
            "line": 2,
            "column": 151
          }
        }
      })) != null ? stack1 : "") + "</label>\r\n	<input readonly type=\"text\" data-filename=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 44
          },
          "end": {
            "line": 3,
            "column": 52
          }
        }
      }) : helper)) + "_attachment\"" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(3, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 64
          },
          "end": {
            "line": 3,
            "column": 110
          }
        }
      })) != null ? stack1 : "") + " placeholder=\"" + alias4((helper = (helper = lookupProperty(helpers, "filePlaceholder") || (depth0 != null ? lookupProperty(depth0, "filePlaceholder") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "filePlaceholder",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 124
          },
          "end": {
            "line": 3,
            "column": 143
          }
        }
      }) : helper)) + "\" " + ((stack1 = (helper = (helper = lookupProperty(helpers, "fileAttributes") || (depth0 != null ? lookupProperty(depth0, "fileAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "fileAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 145
          },
          "end": {
            "line": 3,
            "column": 165
          }
        }
      }) : helper)) != null ? stack1 : "") + ">\r\n	<input hidden data-filename=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 30
          },
          "end": {
            "line": 4,
            "column": 38
          }
        }
      }) : helper)) + "_attachment\" type=\"file\" " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 63
          },
          "end": {
            "line": 4,
            "column": 90
          }
        }
      }) : helper)) != null ? stack1 : "") + "/>\r\n	<div class=\"mura-form-preview\" style=\"display:none;\">\r\n		<img style=\"display:none;\" id=\"mura-form-preview-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 51
          },
          "end": {
            "line": 6,
            "column": 59
          }
        }
      }) : helper)) + "_attachment\" src=\"\" onerror=\"this.onerror=null;this.src='';this.style.display='none';\">\r\n	</div>\r\n</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["form"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<form id=\"frm" + alias4((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 13
          },
          "end": {
            "line": 1,
            "column": 25
          }
        }
      }) : helper)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "formClass") || (depth0 != null ? lookupProperty(depth0, "formClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "formClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 34
          },
          "end": {
            "line": 1,
            "column": 49
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" novalidate=\"novalidate\" enctype=\"multipart/form-data\">\n<div class=\"error-container-" + alias4((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 28
          },
          "end": {
            "line": 2,
            "column": 40
          }
        }
      }) : helper)) + "\">\n</div>\n<div class=\"field-container-" + alias4((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 28
          },
          "end": {
            "line": 4,
            "column": 40
          }
        }
      }) : helper)) + "\">\n</div>\n<div class=\"paging-container-" + alias4((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 29
          },
          "end": {
            "line": 6,
            "column": 41
          }
        }
      }) : helper)) + "\">\n</div>\n	<input type=\"hidden\" name=\"formid\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 43
          },
          "end": {
            "line": 8,
            "column": 55
          }
        }
      }) : helper)) + "\">\n</form>\n";
    },
    "useData": true
  });
  Mura["templates"]["hidden"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<input type=\"hidden\" name=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 27
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) + "\" " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 37
          },
          "end": {
            "line": 1,
            "column": 64
          }
        }
      }) : helper)) != null ? stack1 : "") + " value=\"" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 72
          },
          "end": {
            "line": 1,
            "column": 81
          }
        }
      }) : helper)) + "\" />			\n";
    },
    "useData": true
  });
  Mura["templates"]["list"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "					<option value=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 20
          },
          "end": {
            "line": 7,
            "column": 28
          }
        }
      }) : helper)) + "\">" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 30
          },
          "end": {
            "line": 7,
            "column": 38
          }
        }
      }) : helper)) + "</option>\n";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<form>\n	<div class=\"mura-control-group\">\n		<label for=\"beanList\">Choose Entity:</label>	\n		<div class=\"form-group-select\">\n			<select type=\"text\" name=\"bean\" id=\"select-bean-value\">\n" + ((stack1 = lookupProperty(helpers, "each").call(depth0 != null ? depth0 : container.nullContext || {}, depth0, {
        "name": "each",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 4
          },
          "end": {
            "line": 8,
            "column": 13
          }
        }
      })) != null ? stack1 : "") + "			</select>\n		</div>\n	</div>\n	<div class=\"mura-control-group\">\n		<button type=\"button\" id=\"select-bean\">Go</button>\n	</div>\n</form>";
    },
    "useData": true
  });
  Mura["templates"]["nested"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"field-container-" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "objectid") || (depth0 != null ? lookupProperty(depth0, "objectid") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "objectid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 28
          },
          "end": {
            "line": 1,
            "column": 40
          }
        }
      }) : helper)) + "\">\r\n\r\n</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["paging"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<button class=\"" + alias4((helper = (helper = lookupProperty(helpers, "class") || (depth0 != null ? lookupProperty(depth0, "class") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "class",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 15
          },
          "end": {
            "line": 1,
            "column": 24
          }
        }
      }) : helper)) + "\" type=\"button\" data-page=\"" + alias4((helper = (helper = lookupProperty(helpers, "page") || (depth0 != null ? lookupProperty(depth0, "page") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "page",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 51
          },
          "end": {
            "line": 1,
            "column": 59
          }
        }
      }) : helper)) + "\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 61
          },
          "end": {
            "line": 1,
            "column": 70
          }
        }
      }) : helper)) + "</button> ";
    },
    "useData": true
  });
  Mura["templates"]["radio_static"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 19
          },
          "end": {
            "line": 4,
            "column": 30
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 38
          },
          "end": {
            "line": 4,
            "column": 47
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 78
          },
          "end": {
            "line": 4,
            "column": 99
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioWrapperClass") || (depth0 != null ? lookupProperty(depth0, "radioWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 16
          },
          "end": {
            "line": 8,
            "column": 39
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">\n					<input type=\"radio\" name=\"" + alias4(container.lambda(depths[1] != null ? lookupProperty(depths[1], "name") : depths[1], depth0)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioClass") || (depth0 != null ? lookupProperty(depth0, "radioClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 51
          },
          "end": {
            "line": 9,
            "column": 67
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "datarecordid") || (depth0 != null ? lookupProperty(depth0, "datarecordid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "datarecordid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 79
          },
          "end": {
            "line": 9,
            "column": 95
          }
        }
      }) : helper)) + "\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 104
          },
          "end": {
            "line": 9,
            "column": 113
          }
        }
      }) : helper)) + "\"  " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(10, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 116
          },
          "end": {
            "line": 9,
            "column": 158
          }
        }
      })) != null ? stack1 : "") + "/>\n					<label for=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "datarecordid") || (depth0 != null ? lookupProperty(depth0, "datarecordid") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "datarecordid",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 23
          },
          "end": {
            "line": 10,
            "column": 39
          }
        }
      }) : helper)) + "\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioLabelClass") || (depth0 != null ? lookupProperty(depth0, "radioLabelClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioLabelClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 48
          },
          "end": {
            "line": 10,
            "column": 69
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 71
          },
          "end": {
            "line": 10,
            "column": 80
          }
        }
      }) : helper)) + "</label>\n				</div>\n";
    },
    "10": function _(container, depth0, helpers, partials, data) {
      return "checked='checked'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 13
          },
          "end": {
            "line": 1,
            "column": 36
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 48
          },
          "end": {
            "line": 1,
            "column": 56
          }
        }
      }) : helper)) + "-container\">\n		<div class=\"mura-radio-group\">\n			<label class=\"mura-group-label\" for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 40
          },
          "end": {
            "line": 3,
            "column": 48
          }
        }
      }) : helper)) + "\">\n				" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.program(3, data, 0, blockParams, depths),
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 4
          },
          "end": {
            "line": 4,
            "column": 54
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 54
          },
          "end": {
            "line": 4,
            "column": 112
          }
        }
      })) != null ? stack1 : "") + "\n			</label>\n			" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 3
          },
          "end": {
            "line": 6,
            "column": 30
          }
        }
      })) != null ? stack1 : "") + "\n" + ((stack1 = (lookupProperty(helpers, "eachStatic") || depth0 && lookupProperty(depth0, "eachStatic") || alias2).call(alias1, depth0 != null ? lookupProperty(depth0, "dataset") : depth0, {
        "name": "eachStatic",
        "hash": {},
        "fn": container.program(9, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 3
          },
          "end": {
            "line": 12,
            "column": 18
          }
        }
      })) != null ? stack1 : "") + "		</div>\n	</div>\n";
    },
    "useData": true,
    "useDepths": true
  });
  Mura["templates"]["radio"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 19
          },
          "end": {
            "line": 4,
            "column": 30
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 38
          },
          "end": {
            "line": 4,
            "column": 47
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 78
          },
          "end": {
            "line": 4,
            "column": 99
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioWrapperClass") || (depth0 != null ? lookupProperty(depth0, "radioWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 16
          },
          "end": {
            "line": 8,
            "column": 39
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">\n					<input type=\"radio\" name=\"" + alias4(container.lambda(depths[1] != null ? lookupProperty(depths[1], "name") : depths[1], depth0)) + "id\" class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioClass") || (depth0 != null ? lookupProperty(depth0, "radioClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 53
          },
          "end": {
            "line": 9,
            "column": 69
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 81
          },
          "end": {
            "line": 9,
            "column": 87
          }
        }
      }) : helper)) + "\" value=\"" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 96
          },
          "end": {
            "line": 9,
            "column": 102
          }
        }
      }) : helper)) + "\" " + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isselected") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(10, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 9,
            "column": 104
          },
          "end": {
            "line": 9,
            "column": 146
          }
        }
      })) != null ? stack1 : "") + "/>\n					<label for=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 23
          },
          "end": {
            "line": 10,
            "column": 29
          }
        }
      }) : helper)) + "\" test1=1 class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "radioLabelClass") || (depth0 != null ? lookupProperty(depth0, "radioLabelClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "radioLabelClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 46
          },
          "end": {
            "line": 10,
            "column": 67
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 10,
            "column": 69
          },
          "end": {
            "line": 10,
            "column": 78
          }
        }
      }) : helper)) + "</label>\n				</div>\n";
    },
    "10": function _(container, depth0, helpers, partials, data) {
      return "checked='checked'";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 13
          },
          "end": {
            "line": 1,
            "column": 36
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 48
          },
          "end": {
            "line": 1,
            "column": 56
          }
        }
      }) : helper)) + "-container\">\n		<div class=\"mura-radio-group\">\n			<label class=\"mura-group-label\" for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 40
          },
          "end": {
            "line": 3,
            "column": 48
          }
        }
      }) : helper)) + "\">\n				" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.program(3, data, 0, blockParams, depths),
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 4
          },
          "end": {
            "line": 4,
            "column": 54
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 54
          },
          "end": {
            "line": 4,
            "column": 112
          }
        }
      })) != null ? stack1 : "") + "\n			</label>\n			" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 6,
            "column": 3
          },
          "end": {
            "line": 6,
            "column": 30
          }
        }
      })) != null ? stack1 : "") + "\n" + ((stack1 = lookupProperty(helpers, "each").call(alias1, (stack1 = depth0 != null ? lookupProperty(depth0, "dataset") : depth0) != null ? lookupProperty(stack1, "options") : stack1, {
        "name": "each",
        "hash": {},
        "fn": container.program(9, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 7,
            "column": 3
          },
          "end": {
            "line": 12,
            "column": 12
          }
        }
      })) != null ? stack1 : "") + "		</div>\n	</div>\n";
    },
    "useData": true,
    "useDepths": true
  });
  Mura["templates"]["section"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n<div class=\"mura-section\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 26
          },
          "end": {
            "line": 2,
            "column": 35
          }
        }
      }) : helper)) + "</div>\r\n<div class=\"mura-divide\"></div>\r\n</div>";
    },
    "useData": true
  });
  Mura["templates"]["success"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "formResponseWrapperClass") || (depth0 != null ? lookupProperty(depth0, "formResponseWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "formResponseWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 42
          }
        }
      }) : helper)) != null ? stack1 : "") + "\">" + ((stack1 = (helper = (helper = lookupProperty(helpers, "responsemessage") || (depth0 != null ? lookupProperty(depth0, "responsemessage") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "responsemessage",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 44
          },
          "end": {
            "line": 1,
            "column": 65
          }
        }
      }) : helper)) != null ? stack1 : "") + "</div>\n";
    },
    "useData": true
  });
  Mura["templates"]["table"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<option value=\"" + alias4((helper = (helper = lookupProperty(helpers, "num") || (depth0 != null ? lookupProperty(depth0, "num") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "num",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 102
          },
          "end": {
            "line": 8,
            "column": 109
          }
        }
      }) : helper)) + "\" " + alias4((helper = (helper = lookupProperty(helpers, "selected") || (depth0 != null ? lookupProperty(depth0, "selected") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "selected",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 111
          },
          "end": {
            "line": 8,
            "column": 123
          }
        }
      }) : helper)) + ">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 124
          },
          "end": {
            "line": 8,
            "column": 133
          }
        }
      }) : helper)) + "</option>";
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "					<option value=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 27,
            "column": 20
          },
          "end": {
            "line": 27,
            "column": 28
          }
        }
      }) : helper)) + "\" " + alias4((helper = (helper = lookupProperty(helpers, "selected") || (depth0 != null ? lookupProperty(depth0, "selected") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "selected",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 27,
            "column": 30
          },
          "end": {
            "line": 27,
            "column": 42
          }
        }
      }) : helper)) + ">" + alias4((helper = (helper = lookupProperty(helpers, "displayName") || (depth0 != null ? lookupProperty(depth0, "displayName") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "displayName",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 27,
            "column": 43
          },
          "end": {
            "line": 27,
            "column": 58
          }
        }
      }) : helper)) + "</option>\n";
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "			<th class='data-sort' data-value='" + alias4((helper = (helper = lookupProperty(helpers, "column") || (depth0 != null ? lookupProperty(depth0, "column") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "column",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 53,
            "column": 37
          },
          "end": {
            "line": 53,
            "column": 47
          }
        }
      }) : helper)) + "'>" + alias4((helper = (helper = lookupProperty(helpers, "displayName") || (depth0 != null ? lookupProperty(depth0, "displayName") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "displayName",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 53,
            "column": 49
          },
          "end": {
            "line": 53,
            "column": 64
          }
        }
      }) : helper)) + "</th>\n";
    },
    "7": function _(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "			<tr class=\"even\">\n" + ((stack1 = (lookupProperty(helpers, "eachColRow") || depth0 && lookupProperty(depth0, "eachColRow") || alias2).call(alias1, depth0, depths[1] != null ? lookupProperty(depths[1], "columns") : depths[1], {
        "name": "eachColRow",
        "hash": {},
        "fn": container.program(8, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 61,
            "column": 4
          },
          "end": {
            "line": 63,
            "column": 19
          }
        }
      })) != null ? stack1 : "") + "				<td>\n" + ((stack1 = (lookupProperty(helpers, "eachColButton") || depth0 && lookupProperty(depth0, "eachColButton") || alias2).call(alias1, depth0, {
        "name": "eachColButton",
        "hash": {},
        "fn": container.program(10, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 65,
            "column": 4
          },
          "end": {
            "line": 67,
            "column": 22
          }
        }
      })) != null ? stack1 : "") + "				</td>\n			</tr>\n";
    },
    "8": function _(container, depth0, helpers, partials, data) {
      return "					<td>" + container.escapeExpression(container.lambda(depth0, depth0)) + "</td>\n";
    },
    "10": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<button type=\"button\" class=\"" + alias4((helper = (helper = lookupProperty(helpers, "type") || (depth0 != null ? lookupProperty(depth0, "type") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "type",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 66,
            "column": 33
          },
          "end": {
            "line": 66,
            "column": 41
          }
        }
      }) : helper)) + "\" data-value=\"" + alias4((helper = (helper = lookupProperty(helpers, "id") || (depth0 != null ? lookupProperty(depth0, "id") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "id",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 66,
            "column": 55
          },
          "end": {
            "line": 66,
            "column": 61
          }
        }
      }) : helper)) + "\" data-pos=\"" + alias4((helper = (helper = lookupProperty(helpers, "index") || data && lookupProperty(data, "index")) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "index",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 66,
            "column": 73
          },
          "end": {
            "line": 66,
            "column": 83
          }
        }
      }) : helper)) + "\">" + alias4((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 66,
            "column": 85
          },
          "end": {
            "line": 66,
            "column": 94
          }
        }
      }) : helper)) + "</button>\n";
    },
    "12": function _(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<button class='data-nav' data-value=\"" + container.escapeExpression(container.lambda((stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "first") : stack1, depth0)) + "\">First</button>\n";
    },
    "14": function _(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<button class='data-nav' data-value=\"" + container.escapeExpression(container.lambda((stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "previous") : stack1, depth0)) + "\">Prev</button>\n";
    },
    "16": function _(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<button class='data-nav' data-value=\"" + container.escapeExpression(container.lambda((stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "next") : stack1, depth0)) + "\">Next</button>\n";
    },
    "18": function _(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "				<button class='data-nav' data-value=\"" + container.escapeExpression(container.lambda((stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "last") : stack1, depth0)) + "\">Last</button>\n";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data, blockParams, depths) {
      var stack1,
        alias1 = container.lambda,
        alias2 = container.escapeExpression,
        alias3 = depth0 != null ? depth0 : container.nullContext || {},
        alias4 = container.hooks.helperMissing,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<div class=\"mura-control-group\">\n		<div id=\"filter-results-container\">\n			<div id=\"date-filters\">\n				<div class=\"control-group\">\n				  <label>From</label>\n				  <div class=\"controls\">\n				  	<input type=\"text\" class=\"datepicker mura-date\" id=\"date1\" name=\"date1\" validate=\"date\" value=\"" + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "fromdate") : stack1, depth0)) + "\">\n				  	<select id=\"hour1\" name=\"hour1\" class=\"mura-date\">" + ((stack1 = (lookupProperty(helpers, "eachHour") || depth0 && lookupProperty(depth0, "eachHour") || alias4).call(alias3, (stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "fromhour") : stack1, {
        "name": "eachHour",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 8,
            "column": 57
          },
          "end": {
            "line": 8,
            "column": 155
          }
        }
      })) != null ? stack1 : "") + "</select></select>\n					</div>\n				</div>\n			\n				<div class=\"control-group\">\n				  <label>To</label>\n				  <div class=\"controls\">\n				  	<input type=\"text\" class=\"datepicker mura-date\" id=\"date2\" name=\"date2\" validate=\"date\" value=\"" + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "todate") : stack1, depth0)) + "\">\n				  	<select id=\"hour2\" name=\"hour2\"  class=\"mura-date\">" + ((stack1 = (lookupProperty(helpers, "eachHour") || depth0 && lookupProperty(depth0, "eachHour") || alias4).call(alias3, (stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "tohour") : stack1, {
        "name": "eachHour",
        "hash": {},
        "fn": container.program(1, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 16,
            "column": 58
          },
          "end": {
            "line": 16,
            "column": 154
          }
        }
      })) != null ? stack1 : "") + "</select></select>\n				   </select>\n					</div>\n				</div>\n			</div>\n					\n			<div class=\"control-group\">\n				<label>Keywords</label>\n				<div class=\"controls\">\n					<select name=\"filterBy\" class=\"mura-date\" id=\"results-filterby\">\n" + ((stack1 = (lookupProperty(helpers, "eachKey") || depth0 && lookupProperty(depth0, "eachKey") || alias4).call(alias3, depth0 != null ? lookupProperty(depth0, "properties") : depth0, (stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "filterby") : stack1, {
        "name": "eachKey",
        "hash": {},
        "fn": container.program(3, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 26,
            "column": 5
          },
          "end": {
            "line": 28,
            "column": 17
          }
        }
      })) != null ? stack1 : "") + "					</select>\n					<input type=\"text\" class=\"mura-half\" name=\"keywords\" id=\"results-keywords\" value=\"" + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "filters") : depth0) != null ? lookupProperty(stack1, "filterkey") : stack1, depth0)) + "\">\n				</div>\n			</div>\n			<div class=\"form-actions\">\n				<button type=\"button\" class=\"btn\" id=\"btn-results-search\" ><i class=\"mi-bar-chart\"></i> View Data</button>\n				<button type=\"button\" class=\"btn\"  id=\"btn-results-download\" ><i class=\"mi-download\"></i> Download</button>\n			</div>\n		</div>\n	<div>\n\n	<ul class=\"metadata\">\n		<li>Page:\n			<strong>" + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "pageindex") : stack1, depth0)) + " of " + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "totalpages") : stack1, depth0)) + "</strong>\n		</li>\n		<li>Total Records:\n			<strong>" + alias2(alias1((stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "totalitems") : stack1, depth0)) + "</strong>\n		</li>\n	</ul>\n\n	<table style=\"width: 100%\" class=\"table\">\n		<thead>\n		<tr>\n" + ((stack1 = lookupProperty(helpers, "each").call(alias3, depth0 != null ? lookupProperty(depth0, "columns") : depth0, {
        "name": "each",
        "hash": {},
        "fn": container.program(5, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 52,
            "column": 2
          },
          "end": {
            "line": 54,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + "			<th></th>\n		</tr>\n		</thead>\n		<tbody>\n" + ((stack1 = lookupProperty(helpers, "each").call(alias3, (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "items") : stack1, {
        "name": "each",
        "hash": {},
        "fn": container.program(7, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 59,
            "column": 2
          },
          "end": {
            "line": 70,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + "		</tbody>\n		<tfoot>\n		<tr>\n			<td>\n" + ((stack1 = lookupProperty(helpers, "if").call(alias3, (stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "first") : stack1, {
        "name": "if",
        "hash": {},
        "fn": container.program(12, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 75,
            "column": 4
          },
          "end": {
            "line": 77,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias3, (stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "previous") : stack1, {
        "name": "if",
        "hash": {},
        "fn": container.program(14, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 78,
            "column": 4
          },
          "end": {
            "line": 80,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias3, (stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "next") : stack1, {
        "name": "if",
        "hash": {},
        "fn": container.program(16, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 81,
            "column": 4
          },
          "end": {
            "line": 83,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias3, (stack1 = (stack1 = depth0 != null ? lookupProperty(depth0, "rows") : depth0) != null ? lookupProperty(stack1, "links") : stack1) != null ? lookupProperty(stack1, "last") : stack1, {
        "name": "if",
        "hash": {},
        "fn": container.program(18, data, 0, blockParams, depths),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 84,
            "column": 4
          },
          "end": {
            "line": 86,
            "column": 11
          }
        }
      })) != null ? stack1 : "") + "			</td>\n		</tfoot>\n	</table>\n</div>";
    },
    "useData": true,
    "useDepths": true
  });
  Mura["templates"]["textarea"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 67
          },
          "end": {
            "line": 2,
            "column": 78
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 86
          },
          "end": {
            "line": 2,
            "column": 95
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 126
          },
          "end": {
            "line": 2,
            "column": 147
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data) {
      return " aria-required=\"true\"";
    },
    "11": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " placeholder=\"" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "placeholder") || (depth0 != null ? lookupProperty(depth0, "placeholder") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "placeholder",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 117
          },
          "end": {
            "line": 4,
            "column": 132
          }
        }
      }) : helper)) + "\"";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n	<label for=\"" + alias4((helper = (helper = lookupProperty(helpers, "labelForValue") || (depth0 != null ? lookupProperty(depth0, "labelForValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "labelForValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 13
          },
          "end": {
            "line": 2,
            "column": 30
          }
        }
      }) : helper)) + "\" data-for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 42
          },
          "end": {
            "line": 2,
            "column": 50
          }
        }
      }) : helper)) + "\">" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.program(3, data, 0),
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 52
          },
          "end": {
            "line": 2,
            "column": 102
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 102
          },
          "end": {
            "line": 2,
            "column": 160
          }
        }
      })) != null ? stack1 : "") + "</label>\r\n	" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 1
          },
          "end": {
            "line": 3,
            "column": 28
          }
        }
      })) != null ? stack1 : "") + "\r\n	<textarea " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 11
          },
          "end": {
            "line": 4,
            "column": 38
          }
        }
      }) : helper)) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(9, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 38
          },
          "end": {
            "line": 4,
            "column": 84
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "placeholder") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(11, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 84
          },
          "end": {
            "line": 4,
            "column": 140
          }
        }
      })) != null ? stack1 : "") + ">" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 141
          },
          "end": {
            "line": 4,
            "column": 150
          }
        }
      }) : helper)) + "</textarea>\r\n</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["textblock"] = Mura.Handlebars.template({
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n<div class=\"mura-form-text\">" + ((stack1 = (helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 28
          },
          "end": {
            "line": 2,
            "column": 39
          }
        }
      }) : helper)) != null ? stack1 : "") + "</div>\r\n</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["textfield"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "summary") || (depth0 != null ? lookupProperty(depth0, "summary") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "summary",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 67
          },
          "end": {
            "line": 2,
            "column": 78
          }
        }
      }) : helper));
    },
    "3": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return container.escapeExpression((helper = (helper = lookupProperty(helpers, "label") || (depth0 != null ? lookupProperty(depth0, "label") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "label",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 86
          },
          "end": {
            "line": 2,
            "column": 95
          }
        }
      }) : helper));
    },
    "5": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " <ins>" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "formRequiredLabel") || (depth0 != null ? lookupProperty(depth0, "formRequiredLabel") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "formRequiredLabel",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 126
          },
          "end": {
            "line": 2,
            "column": 147
          }
        }
      }) : helper)) + "</ins>";
    },
    "7": function _(container, depth0, helpers, partials, data) {
      return "</br>";
    },
    "9": function _(container, depth0, helpers, partials, data) {
      return " aria-required=\"true\"";
    },
    "11": function _(container, depth0, helpers, partials, data) {
      var helper,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return " placeholder=\"" + container.escapeExpression((helper = (helper = lookupProperty(helpers, "placeholder") || (depth0 != null ? lookupProperty(depth0, "placeholder") : depth0)) != null ? helper : container.hooks.helperMissing, typeof helper === "function" ? helper.call(depth0 != null ? depth0 : container.nullContext || {}, {
        "name": "placeholder",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 164
          },
          "end": {
            "line": 4,
            "column": 179
          }
        }
      }) : helper)) + "\"";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "inputWrapperClass") || (depth0 != null ? lookupProperty(depth0, "inputWrapperClass") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "inputWrapperClass",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 35
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" id=\"field-" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 1,
            "column": 47
          },
          "end": {
            "line": 1,
            "column": 55
          }
        }
      }) : helper)) + "-container\">\r\n	<label for=\"" + alias4((helper = (helper = lookupProperty(helpers, "labelForValue") || (depth0 != null ? lookupProperty(depth0, "labelForValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "labelForValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 13
          },
          "end": {
            "line": 2,
            "column": 30
          }
        }
      }) : helper)) + "\" data-for=\"" + alias4((helper = (helper = lookupProperty(helpers, "name") || (depth0 != null ? lookupProperty(depth0, "name") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "name",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 42
          },
          "end": {
            "line": 2,
            "column": 50
          }
        }
      }) : helper)) + "\">" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.program(3, data, 0),
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 52
          },
          "end": {
            "line": 2,
            "column": 102
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(5, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 2,
            "column": 102
          },
          "end": {
            "line": 2,
            "column": 160
          }
        }
      })) != null ? stack1 : "") + "</label>\r\n	" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "summary") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(7, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 1
          },
          "end": {
            "line": 3,
            "column": 28
          }
        }
      })) != null ? stack1 : "") + "\r\n	<input type=\"" + ((stack1 = (helper = (helper = lookupProperty(helpers, "textInputTypeValue") || (depth0 != null ? lookupProperty(depth0, "textInputTypeValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "textInputTypeValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 14
          },
          "end": {
            "line": 4,
            "column": 38
          }
        }
      }) : helper)) != null ? stack1 : "") + "\" " + ((stack1 = (helper = (helper = lookupProperty(helpers, "commonInputAttributes") || (depth0 != null ? lookupProperty(depth0, "commonInputAttributes") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "commonInputAttributes",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 40
          },
          "end": {
            "line": 4,
            "column": 67
          }
        }
      }) : helper)) != null ? stack1 : "") + " value=\"" + alias4((helper = (helper = lookupProperty(helpers, "value") || (depth0 != null ? lookupProperty(depth0, "value") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "value",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 75
          },
          "end": {
            "line": 4,
            "column": 84
          }
        }
      }) : helper)) + "\"" + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "isrequired") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(9, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 85
          },
          "end": {
            "line": 4,
            "column": 131
          }
        }
      })) != null ? stack1 : "") + ((stack1 = lookupProperty(helpers, "if").call(alias1, depth0 != null ? lookupProperty(depth0, "placeholder") : depth0, {
        "name": "if",
        "hash": {},
        "fn": container.program(11, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 4,
            "column": 131
          },
          "end": {
            "line": 4,
            "column": 187
          }
        }
      })) != null ? stack1 : "") + "/>\r\n</div>\r\n";
    },
    "useData": true
  });
  Mura["templates"]["view"] = Mura.Handlebars.template({
    "1": function _(container, depth0, helpers, partials, data) {
      var helper,
        alias1 = depth0 != null ? depth0 : container.nullContext || {},
        alias2 = container.hooks.helperMissing,
        alias3 = "function",
        alias4 = container.escapeExpression,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "	<li>\n		<strong>" + alias4((helper = (helper = lookupProperty(helpers, "displayName") || (depth0 != null ? lookupProperty(depth0, "displayName") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "displayName",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 5,
            "column": 10
          },
          "end": {
            "line": 5,
            "column": 25
          }
        }
      }) : helper)) + ": </strong> " + alias4((helper = (helper = lookupProperty(helpers, "displayValue") || (depth0 != null ? lookupProperty(depth0, "displayValue") : depth0)) != null ? helper : alias2, _typeof(helper) === alias3 ? helper.call(alias1, {
        "name": "displayValue",
        "hash": {},
        "data": data,
        "loc": {
          "start": {
            "line": 5,
            "column": 37
          },
          "end": {
            "line": 5,
            "column": 53
          }
        }
      }) : helper)) + " \n	</li>\n";
    },
    "compiler": [8, ">= 4.3.0"],
    "main": function main(container, depth0, helpers, partials, data) {
      var stack1,
        lookupProperty = container.lookupProperty || function (parent, propertyName) {
          if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
            return parent[propertyName];
          }
          return undefined;
        };
      return "<div class=\"mura-control-group\">\n<ul>\n" + ((stack1 = (lookupProperty(helpers, "eachProp") || depth0 && lookupProperty(depth0, "eachProp") || container.hooks.helperMissing).call(depth0 != null ? depth0 : container.nullContext || {}, depth0, {
        "name": "eachProp",
        "hash": {},
        "fn": container.program(1, data, 0),
        "inverse": container.noop,
        "data": data,
        "loc": {
          "start": {
            "line": 3,
            "column": 0
          },
          "end": {
            "line": 7,
            "column": 13
          }
        }
      })) != null ? stack1 : "") + "</ul>\n<button type=\"button\" class=\"nav-back\">Back</button>\n</div>";
    },
    "useData": true
  });
}
module.exports = attach;

/***/ }),

/***/ 654:
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

var Handlebars = __webpack_require__(834);
var attachHTemplate = __webpack_require__(379);
function attach(Mura) {
  Mura.Handlebars = Handlebars.create();
  Mura.templatesLoaded = false;
  Handlebars.noConflict();
  Mura.templates = Mura.templates || {};
  Mura.templates['meta'] = function (context) {
    if (typeof context.labeltag == 'undefined' || !context.labeltag) {
      context.labeltag = 'h2';
    }
    if (context.label) {
      return '<div class="mura-object-meta-wrapper"><div class="mura-object-meta"><' + Mura.escapeHTML(context.labeltag) + '>' + Mura.escapeHTML(context.label) + '</' + Mura.escapeHTML(context.labeltag) + '></div></div><div class="mura-flex-break"></div>';
    } else {
      return '';
    }
  };
  Mura.templates['content'] = function (context) {
    var html = context.html || context.content || context.source || '';
    if (Array.isArray(html)) {
      html = '';
    }
    return '<div class="mura-object-content">' + html + '</div>';
  };
  Mura.templates['text'] = function (context) {
    context = context || {};
    if (context.label) {
      context.source = context.source || '';
    } else {
      context.source = context.source || '<p></p>';
    }
    return context.source;
  };
  Mura.templates['embed'] = function (context) {
    context = context || {};
    if (context.source) {
      context.source = context.source || '';
    } else {
      context.source = context.source || '<p></p>';
    }
    return context.source;
  };
  Mura.templates['image'] = function (context) {
    context = context || {};
    context.src = context.src || '';
    context.alt = context.alt || '';
    context.caption = context.caption || '';
    context.imagelink = context.imagelink || '';
    context.fit = context.fit || '';
    var source = '';
    var style = '';
    if (!context.src) {
      return '';
    }
    if (context.fit) {
      style = ' style="height:100%;width:100%;object-fit:' + Mura.escapeHTML(context.fit) + ';" data-object-fit="' + Mura.escapeHTML(context.fit) + '" ';
    }
    source = '<img src="' + Mura.escapeHTML(context.src) + '" alt="' + Mura.escapeHTML(context.alt) + '"' + style + ' loading="lazy"/>';
    if (context.imagelink) {
      context.imagelinktarget = context.imagelinktarget || "";
      var targetString = "";
      if (context.imagelinktarget) {
        targetString = ' target="' + Mura.escapeHTML(context.imagelinktarget) + '"';
      }
      source = '<a href="' + Mura.escapeHTML(context.imagelink) + '"' + targetString + '/>' + source + '</a>';
    }
    if (context.caption && context.caption != '<p></p>') {
      source += '<figcaption>' + context.caption + '</figcaption>';
    }
    source = '<figure style="margin:0px">' + source + '</figure>';
    return source;
  };
  attachHTemplate(Mura);
}
module.exports = attach;

/***/ }),

/***/ 324:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Collection
   * @name  Mura.UI.Collection
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Collection = Mura.UI.extend( /** @lends Mura.UI.Collection.prototype */
  {
    defaultLayout: "List",
    layoutInstance: '',
    getLayoutInstance: function getLayoutInstance() {
      if (this.layoutInstance) {
        this.layoutInstance.destroy();
      }
      this.layoutInstance = new Mura.Module[this.context.layout](this.context);
      return this.layoutInstance;
    },
    getCollection: function getCollection() {
      var self = this;
      if (typeof this.context.feed != 'undefined' && typeof this.context.feed.getQuery != 'undefined') {
        return this.context.feed.getQuery();
      } else {
        this.context.source = this.context.source || '';
        if (typeof this.context.nextn != 'undefined') {
          this.context.itemsperpage = this.context.nextn;
        }
        if (typeof this.context.maxitems == 'undefined') {
          this.context.maxitems = 20;
        }
        if (typeof this.context.itemsperpage != 'undefined') {
          this.context.itemsperpage = this.context.nextn;
        }
        if (typeof this.context.expand == 'undefined') {
          this.context.expand = '';
        }
        if (typeof this.context.expanddepth == 'undefined') {
          this.context.expanddepth = 1;
        }
        if (typeof this.context.fields == 'undefined') {
          this.context.fields = '';
        }
        if (typeof this.context.rawcollection != 'undefined') {
          return new Promise(function (resolve, reject) {
            resolve(new Mura.EntityCollection(self.context.rawcollection, Mura._requestcontext));
          });
        } else if (this.context.sourcetype == 'relatedcontent') {
          if (this.context.source == 'custom') {
            if (typeof this.context.items != 'undefined') {
              this.context.items = this.context.items.join();
            }
            if (!this.context.items) {
              this.context.items = Mura.createUUID();
            }
            return Mura.get(Mura.getAPIEndpoint() + 'content', {
              id: this.context.items,
              itemsperpage: this.context.itemsperpage,
              maxitems: this.context.maxitems,
              expand: this.context.expand,
              expanddepth: this.context.expanddepth,
              fields: this.context.fields
            }).then(function (resp) {
              return new Mura.EntityCollection(resp.data, Mura._requestcontext);
            });
          } else if (this.context.source == 'reverse') {
            return Mura.getEntity('content').set({
              'contentid': Mura.contentid,
              'id': Mura.contentid
            }).getRelatedContent('reverse', {
              itemsperpage: this.context.itemsperpage,
              maxitems: this.context.maxitems,
              sortby: this.context.sortby,
              expand: this.context.expand,
              expanddepth: this.context.expanddepth,
              fields: this.context.fields
            });
          } else {
            return Mura.getEntity('content').set({
              'contentid': Mura.contentid,
              'id': Mura.contentid
            }).getRelatedContent(this.context.source, {
              itemsperpage: this.context.itemsperpage,
              maxitems: this.context.maxitems,
              expand: this.context.expand,
              expanddepth: this.context.expanddepth,
              fields: this.context.fields
            });
          }
        } else if (this.context.sourcetype == 'children') {
          return Mura.getFeed('content').where().prop('parentid').isEQ(Mura.contentid).maxItems(100).itemsPerPage(this.context.itemsperpage).expand(this.context.expand).expandDepth(this.context.expanddepth).fields(this.context.fields).getQuery();
        } else {
          return Mura.getFeed('content').where().prop('feedid').isEQ(this.context.source).maxItems(this.context.maxitems).itemsPerPage(this.context.itemsperpage).expand(this.context.expand).expandDepth(this.context.expand).fields(this.context.fields).getQuery();
        }
      }
    },
    renderClient: function renderClient() {
      if (typeof Mura.Module[this.context.layout] == 'undefined') {
        this.context.layout = Mura.firstToUpperCase(this.context.layout);
      }
      if (typeof Mura.Module[this.context.layout] == 'undefined' && Mura.Module[this.defaultLayout] != 'undefined') {
        this.context.layout = this.defaultLayout;
      }
      var self = this;
      if (typeof Mura.Module[this.context.layout] != 'undefined') {
        this.getCollection().then(function (collection) {
          self.context.collection = collection;
          self.getLayoutInstance().renderClient();
        });
      } else {
        this.context.targetEl.innerHTML = "This collection has an undefined layout";
      }
      this.trigger('afterRender');
    },
    renderServer: function renderServer() {
      //has implementation in ui.serverutils
      return '';
    },
    destroy: function destroy() {
      //has implementation in ui.serverutils
      if (this.layoutInstance) {
        this.layoutInstance.destroy();
      }
    }
  });
  Mura.Module.Collection = Mura.UI.Collection;
}
module.exports = attach;

/***/ }),

/***/ 711:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Text
   * @name  Mura.UI.Container
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Container = Mura.UI.extend( /** @lends Mura.DisplayObject.Container.prototype */
  {
    renderClient: function renderClient() {
      var target = Mura(this.context.targetEl);
      if (typeof this.context.items != 'undefined' && !Array.isArray(this.context.items)) {
        try {
          this.context.items = JSON.parse(this.context.items);
        } catch (_unused) {
          console.log(this.context.items);
          delete this.context.items;
        }
      }
      if (!Array.isArray(this.context.items)) {
        this.context.content = this.context.content || '';
        target.html(this.context.content);
      } else {
        this.context.items = this.context.items || [];
        this.context.items.forEach(function (data) {
          //console.log(data)
          data.transient = false;
          if (!Mura.cloning) {
            data.preserveid = true;
          }
          target.appendDisplayObject(data);
          delete data.preserveid;
        });
      }
      this.trigger('afterRender');
    },
    reset: function reset(self, empty) {
      if (empty) {
        self.find('.mura-object:not([data-object="container"])').html('');
        self.find('.frontEndToolsModal').remove();
        self.find('.mura-object-meta').html('');
      }
      var content = self.children('div.mura-object-content');
      if (content.length) {
        var nestedObjects = [];
        content.children('.mura-object').each(function () {
          Mura.resetAsyncObject(this, empty);
          //console.log(Mura(this).data())
          nestedObjects.push(Mura(this).data());
        });
        self.data('items', JSON.stringify(nestedObjects));
        self.removeAttr('data-content');
      }
    }
  });
  Mura.DisplayObject.Container = Mura.UI.Container;
}
module.exports = attach;

/***/ }),

/***/ 397:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Embed
   * @name  Mura.UI.Embed
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Embed = Mura.UI.extend( /** @lends Mura.DisplayObject.Embed.prototype */
  {
    renderClient: function renderClient() {
      Mura(this.context.targetEl).html(Mura.templates['embed'](this.context));
      this.trigger('afterRender');
    },
    renderServer: function renderServer() {
      return Mura.templates['embed'](this.context);
    }
  });
  Mura.DisplayObject.Embed = Mura.UI.Embed;
}
module.exports = attach;

/***/ }),

/***/ 86:
/***/ (function(module) {

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
function attach(Mura) {
  /**
   * Creates a new Mura.UI.Form
   * @name	Mura.UI.Form
   * @class
   * @extends Mura.UI
   * @memberof	Mura
   */

  Mura.UI.Form = Mura.UI.extend( /** @lends Mura.DisplayObject.Form.prototype */
  {
    context: {},
    ormform: false,
    formJSON: {},
    data: {},
    columns: [],
    currentpage: 0,
    entity: {},
    fields: {},
    filters: {},
    datasets: [],
    sortfield: '',
    sortdir: '',
    inlineerrors: true,
    properties: {},
    rendered: {},
    renderqueue: 0,
    //templateList: ['file','error','textblock','checkbox','checkbox_static','dropdown','dropdown_static','radio','radio_static','nested','textarea','textfield','form','paging','list','table','view','hidden','section'],
    formInit: false,
    responsemessage: "",
    rb: {
      generalwrapperclass: "well",
      generalwrapperbodyclass: "",
      formwrapperclass: "well",
      formwrapperbodyclass: "",
      formfieldwrapperclass: "control-group",
      formfieldlabelclass: "control-label",
      formerrorwrapperclass: "",
      formresponsewrapperclass: "",
      formgeneralcontrolclass: "form-control",
      forminputclass: "form-control",
      formselectclass: "form-control",
      formtextareaclass: "form-control",
      formfileclass: "form-control",
      formtextblockclass: "form-control",
      formcheckboxclass: "",
      formcheckboxlabelclass: "checkbox",
      formcheckboxwrapperclass: "",
      formradioclass: "",
      formradiowrapperclass: "",
      formradiolabelclass: "radio",
      formbuttonwrapperclass: "btn-group",
      formbuttoninnerclass: "",
      formbuttonclass: "btn btn-default",
      formrequiredwrapperclass: "",
      formbuttonsubmitclass: "form-submit",
      formbuttonsubmitlabel: "Submit",
      formbuttonsubmitwaitlabel: "Please Wait...",
      formbuttonnextclass: "form-nav",
      formbuttonnextlabel: "Next",
      formbuttonbackclass: "form-nav",
      formbuttonbacklabel: "Back",
      formbuttoncancelclass: "btn-primary pull-right",
      formbuttoncancellabel: "Cancel",
      formrequiredlabel: "Required",
      formfileplaceholder: "Select File"
    },
    renderClient: function renderClient() {
      if (this.context.mode == undefined) {
        this.context.mode = 'form';
      }
      var ident = "mura-form-" + this.context.instanceid;
      this.context.formEl = "#" + ident;
      this.context.html = "<div id='" + ident + "'></div>";
      Mura(this.context.targetEl).html(this.context.html);
      if (this.context.view == 'form') {
        this.getForm();
      } else {
        this.getList();
      }
      return this;
    },
    getTemplates: function getTemplates() {
      var self = this;
      if (self.context.view == 'form') {
        self.loadForm();
      } else {
        self.loadList();
      }

      /*
      if(Mura.templatesLoaded.length){
      	var temp = Mura.templateList.pop();
      		Mura.ajax(
      		{
      			url:Mura.assetpath + '/includes/display_objects/form/templates/' + temp + '.hb',
      			type:'get',
      			xhrFields:{ withCredentials: false },
      			success(data) {
      				Mura.templates[temp] = Mura.Handlebars.compile(data);
      				if(!Mura.templateList.length) {
      					if (self.context.view == 'form') {
      						self.loadForm();
      					} else {
      						self.loadList();
      					}
      				} else {
      					self.getTemplates();
      				}
      			}
      		}
      	);
      	}
      */
    },
    getPageFieldList: function getPageFieldList() {
      var page = this.currentpage;
      var fields = this.formJSON.form.pages[page];
      var result = [];
      for (var f = 0; f < fields.length; f++) {
        //console.log("add: " + self.formJSON.form.fields[fields[f]].name);
        result.push(this.formJSON.form.fields[fields[f]].name);
      }

      //console.log(result);

      return result.join(',');
    },
    renderField: function renderField(fieldtype, field) {
      var self = this;
      var templates = Mura.templates;
      var template = fieldtype;
      if (field.datasetid != "" && self.isormform) field.options = self.formJSON.datasets[field.datasetid].options;else if (field.datasetid != "") {
        field.dataset = self.formJSON.datasets[field.datasetid];
      }
      self.setDefault(fieldtype, field);
      if (fieldtype == "nested") {
        var nested_context = {};
        nested_context.objectid = field.formid;
        nested_context.paging = 'single';
        nested_context.mode = 'nested';
        nested_context.prefix = field.name + '_';
        nested_context.master = this;
        var data = {};
        data.objectid = nested_context.objectid;
        data.formid = nested_context.objectid;
        data.object = 'form';
        data.siteid = self.context.siteid || Mura.siteid;
        data.contentid = Mura.contentid;
        data.contenthistid = Mura.contenthistid;
        Mura.get(Mura.getAPIEndpoint() + '?method=processAsyncObject', data).then(function (resp) {
          var tempContext = Mura.extend({}, nested_context);
          delete tempContext.targetEl;
          var context = Mura.deepExtend({}, tempContext, resp.data);
          context.targetEl = self.context.targetEl;
          Mura(".field-container-" + self.context.objectid, self.context.formEl).append('<div id="nested-' + field.formid + '"></div>');
          var nestedForm = new Mura.UI.Form(context);
          context.formEl = document.getElementById('nested-' + field.formid);
          nestedForm.getForm();

          // var html = Mura.templates[template](field);
          // Mura(".field-container-" + self.context.objectid,self.context.formEl).append(html);
        });
      } else {
        if (fieldtype == "checkbox") {
          if (self.ormform) {
            field.selected = [];
            var ds = self.formJSON.datasets[field.datasetid];
            for (var i in ds.datarecords) {
              if (ds.datarecords[i].selected && ds.datarecords[i].selected == 1) field.selected.push(i);
            }
            field.selected = field.selected.join(",");
          } else {
            template = template + "_static";
          }
        } else if (fieldtype == "dropdown") {
          if (!self.ormform) {
            template = template + "_static";
          }
        } else if (fieldtype == "radio") {
          if (!self.ormform) {
            template = template + "_static";
          }
        }
        var html = Mura.templates[template](field);
        Mura(".field-container-" + self.context.objectid, self.context.formEl).append(html);
      }
    },
    setDefault: function setDefault(fieldtype, field) {
      var self = this;
      switch (fieldtype) {
        case "textfield":
        case "textarea":
          if (self.data[self.context.prefix + field.name]) {
            field.value = self.data[self.context.prefix + field.name];
          }
          break;
        case "checkbox":
          var ds = self.formJSON.datasets[field.datasetid];
          for (var i = 0; i < ds.datarecords.length; i++) {
            if (self.ormform) {
              var sourceid = ds.source + "id";
              ds.datarecords[i].selected = 0;
              ds.datarecords[i].isselected = 0;
              if (self.data[self.context.prefix + field.name].items && self.data[self.context.prefix + field.name].items.length) {
                for (var x = 0; x < self.data[self.context.prefix + field.name].items.length; x++) {
                  if (ds.datarecords[i].id == self.data[self.context.prefix + field.name].items[x][sourceid]) {
                    ds.datarecords[i].isselected = 1;
                    ds.datarecords[i].selected = 1;
                  }
                }
              }
            } else {
              if (self.data[self.context.prefix + field.name] && ds.datarecords[i].value && self.data[self.context.prefix + field.name].indexOf(ds.datarecords[i].value) > -1) {
                ds.datarecords[i].isselected = 1;
                ds.datarecords[i].selected = 1;
              } else {
                ds.datarecords[i].selected = 0;
                ds.datarecords[i].isselected = 0;
              }
            }
          }
          break;
        case "radio":
        case "dropdown":
          var ds = self.formJSON.datasets[field.datasetid];
          for (var i = 0; i < ds.datarecords.length; i++) {
            if (self.ormform) {
              if (ds.datarecords[i].id == self.data[field.name + 'id']) {
                ds.datarecords[i].isselected = 1;
                field.selected = self.data[field.name + 'id'];
              } else {
                ds.datarecords[i].selected = 0;
                ds.datarecords[i].isselected = 0;
              }
            } else {
              if (ds.datarecords[i].value == self.data[self.context.prefix + field.name]) {
                ds.datarecords[i].isselected = 1;
                field.selected = self.data[self.context.prefix + field.name];
              } else {
                ds.datarecords[i].isselected = 0;
              }
            }
          }
          break;
      }
    },
    renderData: function renderData() {
      var self = this;
      if (self.datasets.length == 0) {
        if (self.renderqueue == 0) {
          self.renderForm();
        }
        return;
      }
      var dataset = self.formJSON.datasets[self.datasets.pop()];
      if (dataset.sourcetype && dataset.sourcetype != 'muraorm') {
        self.renderData();
        return;
      }
      if (dataset.sourcetype == 'muraorm') {
        dataset.options = [];
        self.renderqueue++;
        Mura.getFeed(dataset.source).getQuery().then(function (collection) {
          collection.each(function (item) {
            var itemid = item.get('id');
            dataset.datarecordorder.push(itemid);
            dataset.datarecords[itemid] = item.getAll();
            dataset.datarecords[itemid]['value'] = itemid;
            dataset.datarecords[itemid]['datarecordid'] = itemid;
            dataset.datarecords[itemid]['datasetid'] = dataset.datasetid;
            dataset.datarecords[itemid]['isselected'] = 0;
            dataset.options.push(dataset.datarecords[itemid]);
          });
        }).then(function () {
          self.renderqueue--;
          self.renderData();
          if (self.renderqueue == 0) {
            self.renderForm();
          }
        });
      } else {
        if (self.renderqueue == 0) {
          self.renderForm();
        }
      }
    },
    renderForm: function renderForm() {
      var self = this;

      //console.log("render form: " + self.currentpage);
      if (typeof self.context.prefix == 'undefined') {
        self.context.prefix = '';
      }
      Mura(".field-container-" + self.context.objectid, self.context.formEl).empty();
      if (!self.formInit) {
        self.initForm();
      }
      var fields = self.formJSON.form.pages[self.currentpage];
      for (var i = 0; i < fields.length; i++) {
        var field = self.formJSON.form.fields[fields[i]];
        //try {
        if (field.fieldtype.fieldtype != undefined && field.fieldtype.fieldtype != "") {
          self.renderField(field.fieldtype.fieldtype, field);
        }
        //} catch(e){
        //console.log('Error rendering form field:');
        //console.log(field);
        //}
      }

      if (self.ishuman && self.currentpage == self.formJSON.form.pages.length - 1) {
        Mura(".field-container-" + self.context.objectid, self.context.formEl).append(self.ishuman);
      }
      if (self.context.mode == 'form') {
        self.renderPaging();
      }
      Mura.processMarkup(".field-container-" + self.context.objectid, self.context.formEl);
      self.trigger('afterRender');
    },
    renderPaging: function renderPaging() {
      var self = this;
      var submitlabel = typeof self.formJSON.form.formattributes != 'undefined' && typeof self.formJSON.form.formattributes.submitlabel != 'undefined' && self.formJSON.form.formattributes.submitlabel ? self.formJSON.form.formattributes.submitlabel : self.rb.formbuttonsubmitlabel;
      Mura(".error-container-" + self.context.objectid, self.context.formEl).empty();
      Mura(".paging-container-" + self.context.objectid, self.context.formEl).empty();
      if (self.formJSON.form.pages.length == 1) {
        Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
          page: self.currentpage + 1,
          label: submitlabel,
          "class": Mura.trim("mura-form-submit " + self.rb.formbuttonsubmitclass)
        }));
      } else {
        if (self.currentpage == 0) {
          Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
            page: 1,
            label: self.rb.formbuttonnextlabel,
            "class": Mura.trim("mura-form-nav mura-form-next " + self.rb.formbuttonnextclass)
          }));
        } else {
          Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
            page: self.currentpage - 1,
            label: self.rb.formbuttonbacklabel,
            "class": Mura.trim("mura-form-nav mura-form-back " + self.rb.formbuttonbackclass)
          }));
          if (self.currentpage + 1 < self.formJSON.form.pages.length) {
            Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
              page: self.currentpage + 1,
              label: self.rb.formbuttonnextlabel,
              "class": Mura.trim("mura-form-nav mura-form-next " + self.rb.formbuttonnextclass)
            }));
          } else {
            Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
              page: self.currentpage + 1,
              label: submitlabel,
              "class": Mura.trim("mura-form-submit " + self.rb.formbuttonsubmitclass)
            }));
          }
        }
        if (self.backlink != undefined && self.backlink.length) Mura(".paging-container-" + self.context.objectid, self.context.formEl).append(Mura.templates['paging']({
          page: self.currentpage + 1,
          label: self.rb.formbuttoncancellabel,
          "class": Mura.trim("mura-form-nav mura-form-cancel " + self.rb.formbuttoncancelclass)
        }));
      }
      var submitHandler = function submitHandler() {
        self.submitForm();
      };
      Mura(".mura-form-submit", self.context.formEl).off('click', submitHandler).on('click', submitHandler);
      Mura(".mura-form-cancel", self.context.formEl).click(function () {
        self.getTableData(self.backlink);
      });
      var formNavHandler = function formNavHandler(e) {
        if (Mura(e.target).is('.mura-form-submit')) {
          return;
        }
        self.setDataValues();
        var keepGoing = self.onPageSubmit.call(self.context.targetEl);
        if (typeof keepGoing != 'undefined' && !keepGoing) {
          return;
        }
        var button = this;
        if (self.ormform) {
          Mura.getEntity(self.entity).set(self.data).validate(self.getPageFieldList()).then(function (entity) {
            if (entity.hasErrors()) {
              self.showErrors(entity.properties.errors);
            } else {
              self.currentpage = Mura(button).data('page');
              self.renderForm();
            }
          });
        } else {
          var data = Mura.extend({}, self.data, self.context);
          data.validateform = true;
          data.formid = data.objectid;
          data.siteid = data.siteid || Mura.siteid;
          data.fields = self.getPageFieldList();
          delete data.filename;
          delete data.def;
          delete data.ishuman;
          delete data.targetEl;
          delete data.html;
          Mura.ajax({
            type: 'post',
            url: Mura.getAPIEndpoint() + '?method=generateCSRFTokens',
            data: {
              siteid: data.siteid,
              context: data.formid
            },
            success: function success(resp) {
              data['csrf_token_expires'] = resp.data['csrf_token_expires'];
              data['csrf_token'] = resp.data['csrf_token'];
              Mura.post(Mura.getAPIEndpoint() + '?method=processAsyncObject', data).then(function (resp) {
                if (_typeof(resp.data.errors) == 'object' && !Mura.isEmptyObject(resp.data.errors)) {
                  self.showErrors(resp.data.errors);
                } else if (typeof resp.data.redirect != 'undefined') {
                  if (resp.data.redirect && resp.data.redirect != location.href) {
                    location.href = resp.data.redirect;
                  } else {
                    location.reload(true);
                  }
                } else {
                  self.currentpage = Mura(button).data('page');
                  if (self.currentpage >= self.formJSON.form.pages.length) {
                    self.currentpage = self.formJSON.form.pages.length - 1;
                  }
                  self.renderForm();
                }
              });
            }
          });
        }

        /*
        }
        else {
        	console.log('oops!');
        }
        */
      };

      Mura(".mura-form-nav", self.context.formEl).off('click', formNavHandler).on('click', formNavHandler);
      var fileSelectorHandler = function fileSelectorHandler(e) {
        Mura(this).closest('.mura-form-file-container').find('input[type="file"]').trigger('click');
      };
      var fileChangeHandler = function fileChangeHandler(e) {
        var inputEl = Mura(this);
        var fn = inputEl.val().replace(/\\/g, '/').replace(/.*\//, '');
        var fnEl = Mura('.mura-newfile-filename[data-filename="' + inputEl.attr("name") + '"]').val(fn);
        var f = Mura('input[type="file"][data-filename="' + inputEl.attr("name") + '"]').node.files[0];
        var fImg = Mura('img#mura-form-preview-' + inputEl.attr("name"));
        var fUrl = '';
        // file upload
        if (typeof f !== 'undefined') {
          fUrl = window.URL.createObjectURL(f);
          fnEl.val(fn);
          fImg.hide();
          if (f.type.indexOf('image') == 0 && fUrl.length) {
            fImg.attr('src', fUrl).show();
          }
        } else {
          fImg.attr('src', fUrl).hide();
        }
      };
      Mura(self.context.formEl).find('input[type="file"]').off('change', fileChangeHandler).on('change', fileChangeHandler);
      Mura(self.context.formEl).find('.mura-form-preview img, .mura-newfile-filename').off('click', fileSelectorHandler).on('click', fileSelectorHandler);
    },
    setDataValues: function setDataValues() {
      var self = this;
      var multi = {};
      var item = {};
      var valid = [];
      var currentPage = {};
      Mura(".field-container-" + self.context.objectid + " input, .field-container-" + self.context.objectid + " select, .field-container-" + self.context.objectid + " textarea").each(function () {
        currentPage[Mura(this).attr('name')] = true;
        if (Mura(this).is('[type="checkbox"]')) {
          if (multi[Mura(this).attr('name')] == undefined) multi[Mura(this).attr('name')] = [];
          if (this.checked) {
            if (self.ormform) {
              item = {};
              item['id'] = Mura.createUUID();
              item[self.entity + 'id'] = self.data.id;
              item[Mura(this).attr('source') + 'id'] = Mura(this).val();
              item['key'] = Mura(this).val();
              multi[Mura(this).attr('name')].push(item);
            } else {
              multi[Mura(this).attr('name')].push(Mura(this).val());
            }
          }
        } else if (Mura(this).is('[type="radio"]')) {
          if (this.checked) {
            self.data[Mura(this).attr('name')] = Mura(this).val();
            valid[Mura(this).attr('name')] = self.data[name];
          }
        } else {
          self.data[Mura(this).attr('name')] = Mura(this).val();
          valid[Mura(this).attr('name')] = self.data[Mura(this).attr('name')];
        }
      });
      for (var i in multi) {
        if (self.ormform) {
          self.data[i].cascade = "replace";
          self.data[i].items = multi[i];
          valid[i] = self.data[i];
        } else {
          self.data[i] = multi[i].join(",");
          valid[i] = multi[i].join(",");
        }
      }
      var frm = document.getElementById('frm' + self.context.objectid);
      for (var p in currentPage) {
        if (currentPage.hasOwnProperty(p) && typeof self.data[p] != 'undefined') {
          if (p.indexOf("_attachment") > -1 && typeof frm[p] != 'undefined') {
            self.attachments[p] = frm[p].files[0];
          }
        }
      }
      return valid;
    },
    validate: function validate(entity, fields) {
      return true;
    },
    getForm: function getForm(entityid, backlink) {
      var self = this;
      if (entityid != undefined) {
        self.entityid = entityid;
      } else {
        delete self.entityid;
      }
      if (backlink != undefined) {
        self.backlink = backlink;
      } else {
        delete self.backlink;
      }
      self.loadForm();
    },
    loadForm: function loadForm(data) {
      var self = this;
      var formJSON = JSON.parse(self.context.def);

      // old forms
      if (!formJSON.form.pages) {
        formJSON.form.pages = [];
        formJSON.form.pages[0] = formJSON.form.fieldorder;
        formJSON.form.fieldorder = [];
      }
      if (typeof formJSON.datasets != 'undefined') {
        for (var d in formJSON.datasets) {
          if (typeof formJSON.datasets[d].DATARECORDS != 'undefined') {
            formJSON.datasets[d].datarecords = formJSON.datasets[d].DATARECORDS;
            delete formJSON.datasets[d].DATARECORDS;
          }
          if (typeof formJSON.datasets[d].DATARECORDORDER != 'undefined') {
            formJSON.datasets[d].datarecordorder = formJSON.datasets[d].DATARECORDORDER;
            delete formJSON.datasets[d].DATARECORDORDER;
          }
        }
      }
      entityName = self.context.filename.replace(/\W+/g, "");
      self.entity = entityName;
      self.formJSON = formJSON;
      self.fields = formJSON.form.fields;
      self.responsemessage = self.context.responsemessage;
      self.ishuman = self.context.ishuman;
      if (formJSON.form.formattributes && formJSON.form.formattributes.Muraormentities == 1) {
        self.ormform = true;
      }
      for (var i = 0; i < self.formJSON.datasets; i++) {
        self.datasets.push(i);
      }
      if (self.ormform) {
        self.entity = entityName;
        if (self.entityid == undefined) {
          Mura.get(Mura.getAPIEndpoint() + '/' + entityName + '/new?expand=all&ishuman=true').then(function (resp) {
            self.data = resp.data;
            self.renderData();
          });
        } else {
          Mura.get(Mura.getAPIEndpoint() + '/' + entityName + '/' + self.entityid + '?expand=all&ishuman=true').then(function (resp) {
            self.data = resp.data;
            self.renderData();
          });
        }
      } else {
        self.renderData();
      }
    },
    initForm: function initForm() {
      var self = this;
      Mura(self.context.formEl).empty();
      if (self.context.mode != undefined && self.context.mode == 'nested') {
        var html = Mura.templates['nested'](self.context);
      } else {
        var html = Mura.templates['form'](self.context);
      }
      Mura(self.context.formEl).append(html);
      self.currentpage = 0;
      self.attachments = {};
      self.formInit = true;
      Mura.trackEvent({
        category: 'Form',
        action: 'Impression',
        label: self.context.name,
        objectid: self.context.objectid,
        nonInteraction: true
      });
    },
    onSubmit: function onSubmit() {
      return true;
    },
    onPageSubmit: function onPageSubmit() {
      return true;
    },
    submitForm: function submitForm() {
      var self = this;
      var valid = self.setDataValues();
      Mura(".error-container-" + self.context.objectid, self.context.formEl).empty();
      var keepGoing = this.onSubmit.call(this.context.targetEl);
      if (typeof keepGoing != 'undefined' && !keepGoing) {
        return;
      }
      delete self.data.isNew;
      var frm = Mura(self.context.formEl).find('form');
      frm.find('.mura-form-submit').html(self.rb.formbuttonsubmitwaitlabel);
      frm.trigger('formSubmit');

      //console.log('b!');
      var rawdata = Mura.extend({}, self.context, self.data);
      rawdata.saveform = true;
      rawdata.formid = rawdata.objectid;
      rawdata.siteid = self.context.siteid || rawdata.siteid || Mura.siteid;
      rawdata.contentid = Mura.contentid || '';
      rawdata.contenthistid = Mura.contenthistid || '';
      delete rawdata.filename;
      delete rawdata.def;
      delete rawdata.ishuman;
      delete rawdata.targetEl;
      delete rawdata.html;
      var tokenArgs = {
        siteid: rawdata.siteid,
        context: rawdata.formid
      };
      if (rawdata.responsechart) {
        var frm = Mura(self.context.targetEl);
        var polllist = new Array();
        frm.find("input[type='radio']").each(function () {
          polllist.push(Mura(this).val());
        });
        if (polllist.length > 0) {
          rawdata.polllist = polllist.toString();
        }
      }
      var data = new FormData();
      for (var p in rawdata) {
        if (rawdata.hasOwnProperty(p)) {
          if (typeof self.attachments[p] != 'undefined') {
            data.append(p, self.attachments[p]);
          } else {
            data.append(p, rawdata[p]);
          }
        }
      }
      Mura.ajax({
        type: 'post',
        url: Mura.getAPIEndpoint() + '?method=generateCSRFTokens',
        data: tokenArgs,
        success: function success(resp) {
          data.append('csrf_token_expires', resp.data['csrf_token_expires']);
          data.append('csrf_token', resp.data['csrf_token']);
          Mura.post(Mura.getAPIEndpoint() + '?method=processAsyncObject', data).then(function (resp) {
            if (_typeof(resp.data.errors) == 'object' && !Mura.isEmptyObject(resp.data.errors)) {
              self.showErrors(resp.data.errors);
              self.trigger('afterErrorRender');
            } else {
              Mura(self.context.formEl).find('form').trigger('formSubmitSuccess');
              Mura.trackEvent({
                category: 'Form',
                action: 'Conversion',
                label: self.context.name,
                objectid: self.context.objectid
              }).then(function () {
                if (typeof resp.data.redirect != 'undefined') {
                  if (resp.data.redirect && resp.data.redirect != location.href) {
                    location.href = resp.data.redirect;
                  } else {
                    location.reload(true);
                  }
                } else {
                  Mura(self.context.formEl).html(Mura.templates['success'](resp.data));
                  self.trigger('afterResponseRender');
                }
              });
            }
          }, function (resp) {
            self.showErrors({
              "systemerror": "We're sorry, a system error has occurred. Please try again later."
            });
            self.trigger('afterErrorRender');
          });
        }
      });
    },
    showErrors: function showErrors(errors) {
      var self = this;
      var frm = Mura(this.context.formEl);
      var frmErrors = frm.find(".error-container-" + self.context.objectid);
      frm.find('.mura-form-submit').html(self.rb.formbuttonsubmitlabel);
      frm.find('.mura-response-error').remove();
      frm.find('[aria-invalid]').forEach(function () {
        this.removeAttribute('aria-invalid');
        this.removeAttribute('aria-describedby');
      });
      var fieldKeys = Object.keys(self.fields);
      for (var e in errors) {
        var fieldKey = fieldKeys.find(function (key) {
          return self.fields[key].name === e;
        });
        if (fieldKey) {
          var field = self.fields[fieldKey];
          var error = {};
          error.message = errors[e];
          error.selector = '#field-' + field.name;
          error.field = 'field-' + field.name;
          error.label = '';
          error.id = 'e' + Mura.createUUID();
          if (field.cssid) {
            error.selector = '#' + field.cssid;
          }
        } else {
          var error = {};
          error.message = errors[e];
          error.selector = '#field-' + e;
          error.field = 'field-' + e;
          error.label = '';
          error.id = 'e' + Mura.createUUID();
        }
        if (this.inlineerrors) {
          var field = Mura(this.context.formEl).find(error.selector);
          var errorTarget = field;
          var check;
          if (!field.length) {
            field = Mura('label[for="' + e + '"]');
            check = field.parent().find('input');
            if (check.length) {
              field = check;
            }
            errorTarget = field;
            check = field.parent().find('label');
            if (check.length) {
              errorTarget = check;
            }
          }
          if (field.length) {
            field.attr('aria-invalid', true);
            field.attr('aria-describedby', error.id);
            errorTarget.node.insertAdjacentHTML('afterend', Mura.templates['error'](error));
          } else {
            frmErrors.append(Mura.templates['error'](error));
          }
        } else {
          frmErrors.append(Mura.templates['error'](error));
        }
      }
      Mura(self.context.formEl).find('.g-recaptcha-container').each(function (el) {
        grecaptcha.reset(el.getAttribute('data-widgetid'));
      });
      var errorsSel = Mura(this.context.formEl).find('.mura-response-error');
      if (errorsSel.length) {
        var error = errorsSel.first();
        var check = Mura('[aria-describedby="' + error.attr('id') + '"]');
        if (check.length) {
          check.focus();
        } else {
          error.focus();
        }
      }
    },
    cleanProps: function cleanProps(props) {
      var propsOrdered = {};
      var propsRet = {};
      var ct = 100000;
      delete props.isnew;
      delete props.created;
      delete props.lastUpdate;
      delete props.errors;
      delete props.saveErrors;
      delete props.instance;
      delete props.instanceid;
      delete props.frommuracache;
      delete props[self.entity + "id"];
      for (var i in props) {
        if (props[i].orderno != undefined) {
          propsOrdered[props[i].orderno] = props[i];
        } else {
          propsOrdered[ct++] = props[i];
        }
      }
      Object.keys(propsOrdered).sort().forEach(function (v, i) {
        propsRet[v] = propsOrdered[v];
      });
      return propsRet;
    },
    registerHelpers: function registerHelpers() {
      var self = this;
      Mura.extend(self.rb, Mura.rb);
      Mura.Handlebars.registerHelper('eachColRow', function (row, columns, options) {
        var ret = "";
        for (var i = 0; i < columns.length; i++) {
          ret = ret + options.fn(row[columns[i].column]);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachProp', function (data, options) {
        var ret = "";
        var obj = {};
        for (var i in self.properties) {
          obj.displayName = self.properties[i].displayName;
          if (self.properties[i].fieldtype == "one-to-one") {
            obj.displayValue = data[self.properties[i].cfc].val;
          } else obj.displayValue = data[self.properties[i].column];
          ret = ret + options.fn(obj);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachKey', function (properties, by, options) {
        var ret = "";
        var item = "";
        for (var i in properties) {
          item = properties[i];
          if (item.column == by) item.selected = "Selected";
          if (item.rendertype == 'textfield') ret = ret + options.fn(item);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachHour', function (hour, options) {
        var ret = "";
        var h = 0;
        var val = "";
        for (var i = 0; i < 24; i++) {
          if (i == 0) {
            val = {
              label: "12 AM",
              num: i
            };
          } else if (i < 12) {
            h = i;
            val = {
              label: h + " AM",
              num: i
            };
          } else if (i == 12) {
            h = i;
            val = {
              label: h + " PM",
              num: i
            };
          } else {
            h = i - 12;
            val = {
              label: h + " PM",
              num: i
            };
          }
          if (hour == i) val.selected = "selected";
          ret = ret + options.fn(val);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachColButton', function (row, options) {
        var ret = "";
        row.label = 'View';
        row.type = 'data-view';

        // only do view if there are more properties than columns
        if (Object.keys(self.properties).length > self.columns.length) {
          ret = ret + options.fn(row);
        }
        if (self.context.view == 'edit') {
          row.label = 'Edit';
          row.type = 'data-edit';
          ret = ret + options.fn(row);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachCheck', function (checks, selected, options) {
        var ret = "";
        for (var i = 0; i < checks.length; i++) {
          if (selected.indexOf(checks[i].id) > -1) checks[i].isselected = 1;else checks[i].isselected = 0;
          ret = ret + options.fn(checks[i]);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('eachStatic', function (dataset, options) {
        var ret = "";
        for (var i = 0; i < dataset.datarecordorder.length; i++) {
          ret = ret + options.fn(dataset.datarecords[dataset.datarecordorder[i]]);
        }
        return ret;
      });
      Mura.Handlebars.registerHelper('inputWrapperClass', function () {
        var escapeExpression = Mura.Handlebars.escapeExpression;
        var returnString = 'mura-control-group';
        if (self.rb.formfieldwrapperclass) {
          returnString += ' ' + self.rb.formfieldwrapperclass;
        }
        if (this.wrappercssclass) {
          returnString += ' ' + escapeExpression(this.wrappercssclass);
        }
        if (this.isrequired) {
          returnString += ' req';
          if (self.rb.formrequiredwrapperclass) {
            returnString += ' ' + self.rb.formrequiredwrapperclass;
          }
        }
        return returnString;
      });
      Mura.Handlebars.registerHelper('radioLabelClass', function () {
        return self.rb.formradiolabelclass;
      });
      Mura.Handlebars.registerHelper('formErrorWrapperClass', function () {
        if (self.rb.formerrorwrapperclass) {
          return 'mura-response-error' + ' ' + self.rb.formerrorwrapperclass;
        } else {
          return 'mura-response-error';
        }
      });
      Mura.Handlebars.registerHelper('formSuccessWrapperClass', function () {
        if (self.rb.formresponsewrapperclass) {
          return 'mura-response-success' + ' ' + self.rb.formresponsewrapperclass;
        } else {
          return 'mura-response-success';
        }
      });
      Mura.Handlebars.registerHelper('formResponseWrapperClass', function () {
        if (self.rb.formresponsewrapperclass) {
          return 'mura-response-success' + ' ' + self.rb.formresponsewrapperclass;
        } else {
          return 'mura-response-success';
        }
      });
      Mura.Handlebars.registerHelper('radioClass', function () {
        return self.rb.formradioclass;
      });
      Mura.Handlebars.registerHelper('radioWrapperClass', function () {
        return self.rb.formradiowrapperclass;
      });
      Mura.Handlebars.registerHelper('checkboxLabelClass', function () {
        return self.rb.formcheckboxlabelclass;
      });
      Mura.Handlebars.registerHelper('checkboxClass', function () {
        return self.rb.formcheckboxclass;
      });
      Mura.Handlebars.registerHelper('checkboxWrapperClass', function () {
        return self.rb.formcheckboxwrapperclass;
      });
      Mura.Handlebars.registerHelper('formRequiredLabel', function () {
        return self.rb.formrequiredlabel;
      });
      Mura.Handlebars.registerHelper('filePlaceholder', function () {
        var escapeExpression = Mura.Handlebars.escapeExpression;
        if (this.placeholder) {
          return escapeExpression(this.placeholder);
        } else {
          return self.rb.formfileplaceholder;
        }
      });
      Mura.Handlebars.registerHelper('formClass', function () {
        var escapeExpression = Mura.Handlebars.escapeExpression;
        var returnString = 'mura-form';
        if (self.formJSON && self.formJSON.form && self.formJSON.form.formattributes && self.formJSON.form.formattributes.class) {
          returnString += ' ' + escapeExpression(self.formJSON.form.formattributes.class);
        }
        return returnString;
      });
      Mura.Handlebars.registerHelper('textInputTypeValue', function () {
        if (typeof Mura.usehtml5dateinput != 'undefined' && Mura.usehtml5dateinput && typeof this.validatetype != 'undefined' && this.validatetype.toLowerCase() == 'date') {
          return 'date';
        } else {
          return 'text';
        }
      });
      Mura.Handlebars.registerHelper('labelForValue', function () {
        //id, class, title, size
        var escapeExpression = Mura.Handlebars.escapeExpression;
        if (this.cssid) {
          return escapeExpression(this.cssid);
        } else {
          return "field-" + escapeExpression(this.name);
        }
        return returnString;
      });
      Mura.Handlebars.registerHelper('commonInputAttributes', function () {
        //id, class, title, size
        var escapeExpression = Mura.Handlebars.escapeExpression;
        if (typeof this.fieldtype != 'undefined' && this.fieldtype.fieldtype == 'file') {
          var returnString = 'name="' + escapeExpression(self.context.prefix + this.name) + '_attachment"';
        } else {
          var returnString = 'name="' + escapeExpression(self.context.prefix + this.name) + '"';
        }
        if (this.cssid) {
          returnString += ' id="' + escapeExpression(this.cssid) + '"';
        } else {
          returnString += ' id="field-' + escapeExpression(self.context.prefix + this.name) + '"';
        }
        returnString += ' class="';
        if (this.cssclass) {
          returnString += escapeExpression(this.cssclass) + ' ';
        }
        if (this.fieldtype == 'radio' || this.fieldtype == 'radio_static') {
          returnString += self.rb.formradioclass;
        } else if (this.fieldtype == 'checkbox' || this.fieldtype == 'checkbox_static') {
          returnString += self.rb.formcheckboxclass;
        } else if (this.fieldtype == 'file') {
          returnString += self.rb.formfileclass;
        } else if (this.fieldtype == 'textarea') {
          returnString += self.rb.formtextareaclass;
        } else if (this.fieldtype == 'dropdown' || this.fieldtype == 'dropdown_static') {
          returnString += self.rb.formselectclass;
        } else if (this.fieldtype == 'textblock') {
          returnString += self.rb.formtextblockclass;
        } else {
          returnString += self.rb.forminputclass;
        }
        returnString += '"';
        if (this.tooltip) {
          returnString += ' title="' + escapeExpression(this.tooltip) + '"';
        }
        if (this.size) {
          returnString += ' size="' + escapeExpression(this.size) + '"';
        }
        if (this.multiple) {
          returnString += ' multiple';
        }
        if (typeof Mura.usehtml5dateinput != 'undefined' && Mura.usehtml5dateinput && typeof this.validatetype != 'undefined' && this.validatetype.toLowerCase() == 'date') {
          returnString += ' data-date-format="' + Mura.dateformat + '"';
        }
        return returnString;
      });
      Mura.Handlebars.registerHelper('fileAttributes', function () {
        //id, class, title, size
        var escapeExpression = Mura.Handlebars.escapeExpression;
        var returnString = '';
        if (this.cssid) {
          returnString += ' id="' + escapeExpression(this.cssid) + '"';
        } else {
          returnString += ' id="field-' + escapeExpression(self.context.prefix + this.name) + '"';
        }
        returnString += ' class="mura-newfile-filename ';
        if (this.cssclass) {
          returnString += escapeExpression(this.cssclass) + ' ';
        }
        returnString += self.rb.forminputclass;
        returnString += '"';
        if (this.tooltip) {
          returnString += ' title="' + escapeExpression(this.tooltip) + '"';
        }
        return returnString;
      });
    }
  });

  //Legacy for early adopter backwords support
  Mura.DisplayObject.Form = Mura.UI.Form;
}
module.exports = attach;

/***/ }),

/***/ 180:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Text
   * @name  Mura.UI.Hr
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Hr = Mura.UI.extend( /** @lends Mura.DisplayObject.Hr.prototype */
  {
    renderClient: function renderClient() {
      Mura(this.context.targetEl).html("<hr>");
      this.trigger('afterRender');
    },
    renderServer: function renderServer() {
      return "<hr>";
    }
  });
  Mura.DisplayObject.Hr = Mura.UI.Hr;
}
module.exports = attach;

/***/ }),

/***/ 876:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Text
   * @name  Mura.UI.Image
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Image = Mura.UI.extend( /** @lends Mura.DisplayObject.Image.prototype */
  {
    renderClient: function renderClient() {
      Mura(this.context.targetEl).html(Mura.templates['image'](this.context));
      this.trigger('afterRender');
    },
    renderServer: function renderServer() {
      return Mura.templates['image'](this.context);
    }
  });
  Mura.DisplayObject.Image = Mura.UI.Image;
}
module.exports = attach;

/***/ }),

/***/ 789:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI instance
   * @name Mura.UI
   * @class
   * @extends  Mura.Core
   * @memberof Mura
   */

  Mura.UI = Mura.Core.extend( /** @lends Mura.UI.prototype */
  {
    rb: {},
    context: {},
    onAfterRender: function onAfterRender() {},
    onBeforeRender: function onBeforeRender() {},
    trigger: function trigger(eventName) {
      var $eventName = eventName.toLowerCase();
      if (typeof this.context.targetEl != 'undefined') {
        var obj = Mura(this.context.targetEl).closest('.mura-object');
        if (obj.length && typeof obj.node != 'undefined') {
          if (typeof this.handlers[$eventName] != 'undefined') {
            var $handlers = this.handlers[$eventName];
            for (var i = 0; i < $handlers.length; i++) {
              if (typeof $handlers[i].call == 'undefined') {
                $handlers[i](this);
              } else {
                $handlers[i].call(this, this);
              }
            }
          }
          if (typeof this[eventName] == 'function') {
            if (typeof this[eventName].call == 'undefined') {
              this[eventName](this);
            } else {
              this[eventName].call(this, this);
            }
          }
          var fnName = 'on' + eventName.substring(0, 1).toUpperCase() + eventName.substring(1, eventName.length);
          if (typeof this[fnName] == 'function') {
            if (typeof this[fnName].call == 'undefined') {
              this[fnName](this);
            } else {
              this[fnName].call(this, this);
            }
          }
        }
      }
      return this;
    },
    /* This method is deprecated, use renderClient and renderServer instead */render: function render() {
      Mura(this.context.targetEl).html(Mura.templates[context.object](this.context));
      this.trigger('afterRender');
      return this;
    },
    /*
    	This method's current implementation is to support backward compatibility
    		Typically it would look like:
    		Mura(this.context.targetEl).html(Mura.templates[context.object](this.context));
    	this.trigger('afterRender');
    */
    renderClient: function renderClient() {
      return this.render();
    },
    renderServer: function renderServer() {
      return '';
    },
    hydrate: function hydrate() {},
    destroy: function destroy() {},
    reset: function reset(self, empty) {},
    init: function init(args) {
      this.context = args;
      this.registerHelpers();
      return this;
    },
    registerHelpers: function registerHelpers() {}
  });
}
module.exports = attach;

/***/ }),

/***/ 943:
/***/ (function(module) {

function attach(Mura) {
  /**
   * Creates a new Mura.UI.Text
   * @name  Mura.UI.Text
   * @class
   * @extends Mura.UI
   * @memberof  Mura
   */

  Mura.UI.Text = Mura.UI.extend( /** @lends Mura.DisplayObject.Text.prototype */
  {
    renderClient: function renderClient() {
      var _this = this;
      this.context.sourcetype = this.context.sourcetype || 'custom';
      if (this.context.sourcetype == 'component' && this.context.source) {
        if (Mura.isUUID(this.context.source)) {
          var loadbykey = 'contentid';
        } else {
          var loadbykey = 'tile';
        }
        Mura.getEntity('content').loadBy(loadbykey, this.context.source, {
          fields: 'body',
          type: 'component'
        }).then(function (content) {
          if (content.get('body')) {
            Mura(_this.context.targetEl).html(_this.deserialize(content.get('body')));
          } else if (_this.context.label) {
            Mura(_this.context.targetEl).html('');
          } else {
            Mura(_this.context.targetEl).html('<p></p>');
          }
          _this.trigger('afterRender');
        });
      } else {
        Mura(this.context.targetEl).html(Mura.templates['text'](this.context));
        this.trigger('afterRender');
      }
    },
    renderServer: function renderServer() {
      this.context.sourcetype = this.context.sourcetype || 'custom';
      if (this.context.sourcetype == 'custom') {
        return this.deserialize(this.context.source);
      } else {
        return '<p></p>';
      }
    },
    deserialize: function deserialize(source) {
      return source;
    }
  });
  Mura.DisplayObject.Text = Mura.UI.Text;
}
module.exports = attach;

/***/ }),

/***/ 808:
/***/ (function(module) {

function attach(Mura) {
  /**
  * Creates a new Mura.entities.User
  * @name Mura.entities.User
  * @class
  * @extends Mura.Entity
  * @memberof Mura
  * @param	{object} properties Object containing values to set into object
  * @return {Mura.entities.User}
  */

  Mura.entities.User = Mura.Entity.extend( /** @lends Mura.entities.User.prototype */
  {
    /**
     * isInGroup - Returns if the CURRENT USER is in a group
     *
     * @param	{string} group	Name of group
     * @param	{boolean} isPublic	If you want to check public or private (system) groups
     * @return {boolean}
     */
    isInGroup: function isInGroup(group, siteid, isPublic) {
      siteid = siteid || Mura.siteid;
      var a = this.get('memberships');
      if (!Array.isArray(a)) {
        console.log('Method design for use with currentuser() only');
        return false;
      }
      if (typeof isPublic != 'undefined') {
        return a.indexOf(group + ";" + siteid + ";" + isPublic) >= 0;
      } else {
        return a.indexOf(group + ";" + siteid + ";0") >= 0 || a.indexOf(group + ";" + siteid + ";1") >= 0;
      }
    },
    /**
     * isSuperUser - Returns if the CURRENT USER is a super user
     *
     * @return {boolean}
     */
    isSuperUser: function isSuperUser() {
      var a = this.get('memberships');
      if (!Array.isArray(a)) {
        console.log('Method design for use with currentuser() only');
        return false;
      }
      return a.indexOf('S2') >= 0;
    },
    /**
     * isAdminUser - Returns if the CURRENT USER is a admin user
     *
     * @return {boolean}
     */
    isAdminUser: function isAdminUser(siteid) {
      siteid = siteid || Mura.siteid;
      var a = this.get('memberships');
      if (!Array.isArray(a)) {
        console.log('Method design for use with currentuser() only');
        return false;
      }
      return this.isSuperUser() || a.indexOf("Admin;" + siteid + ";0") >= 0;
    },
    /**
     * isSystemUser - Returns if the CURRENT USER is a system/adminstrative user
     *
     * @return {boolean}
     */
    isSystemUser: function isSystemUser(siteid) {
      siteid = siteid || Mura.siteid;
      var a = this.get('memberships');
      if (!Array.isArray(a)) {
        console.log('Method design for use with currentuser() only');
        return false;
      }
      return this.isAdminUser() || a.indexOf("S2IsPrivate;" + siteid) >= 0;
    },
    /**
     * isLoggedIn - Returns if the CURRENT USER is logged in
     *
     * @return {boolean}
     */
    isLoggedIn: function isLoggedIn() {
      var a = this.get('isloggedin');
      if (a === '') {
        return false;
      } else {
        return a;
      }
    }
  });
}
module.exports = attach;

/***/ }),

/***/ 579:
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

if (!(typeof process !== 'undefined' && {}.toString.call(process) === '[object process]' || typeof document == 'undefined')) {
  __webpack_require__(56);
}
__webpack_require__(905);
var Mura = __webpack_require__(248)();
module.exports = Mura;

/***/ }),

/***/ 905:
/***/ (function() {

(function(self) {

var irrelevant = (function (exports) {

  var support = {
    searchParams: 'URLSearchParams' in self,
    iterable: 'Symbol' in self && 'iterator' in Symbol,
    blob:
      'FileReader' in self &&
      'Blob' in self &&
      (function() {
        try {
          new Blob();
          return true
        } catch (e) {
          return false
        }
      })(),
    formData: 'FormData' in self,
    arrayBuffer: 'ArrayBuffer' in self
  };

  function isDataView(obj) {
    return obj && DataView.prototype.isPrototypeOf(obj)
  }

  if (support.arrayBuffer) {
    var viewClasses = [
      '[object Int8Array]',
      '[object Uint8Array]',
      '[object Uint8ClampedArray]',
      '[object Int16Array]',
      '[object Uint16Array]',
      '[object Int32Array]',
      '[object Uint32Array]',
      '[object Float32Array]',
      '[object Float64Array]'
    ];

    var isArrayBufferView =
      ArrayBuffer.isView ||
      function(obj) {
        return obj && viewClasses.indexOf(Object.prototype.toString.call(obj)) > -1
      };
  }

  function normalizeName(name) {
    if (typeof name !== 'string') {
      name = String(name);
    }
    if (/[^a-z0-9\-#$%&'*+.^_`|~]/i.test(name)) {
      throw new TypeError('Invalid character in header field name')
    }
    return name.toLowerCase()
  }

  function normalizeValue(value) {
    if (typeof value !== 'string') {
      value = String(value);
    }
    return value
  }

  // Build a destructive iterator for the value list
  function iteratorFor(items) {
    var iterator = {
      next: function() {
        var value = items.shift();
        return {done: value === undefined, value: value}
      }
    };

    if (support.iterable) {
      iterator[Symbol.iterator] = function() {
        return iterator
      };
    }

    return iterator
  }

  function Headers(headers) {
    this.map = {};

    if (headers instanceof Headers) {
      headers.forEach(function(value, name) {
        this.append(name, value);
      }, this);
    } else if (Array.isArray(headers)) {
      headers.forEach(function(header) {
        this.append(header[0], header[1]);
      }, this);
    } else if (headers) {
      Object.getOwnPropertyNames(headers).forEach(function(name) {
        this.append(name, headers[name]);
      }, this);
    }
  }

  Headers.prototype.append = function(name, value) {
    name = normalizeName(name);
    value = normalizeValue(value);
    var oldValue = this.map[name];
    this.map[name] = oldValue ? oldValue + ', ' + value : value;
  };

  Headers.prototype['delete'] = function(name) {
    delete this.map[normalizeName(name)];
  };

  Headers.prototype.get = function(name) {
    name = normalizeName(name);
    return this.has(name) ? this.map[name] : null
  };

  Headers.prototype.has = function(name) {
    return this.map.hasOwnProperty(normalizeName(name))
  };

  Headers.prototype.set = function(name, value) {
    this.map[normalizeName(name)] = normalizeValue(value);
  };

  Headers.prototype.forEach = function(callback, thisArg) {
    for (var name in this.map) {
      if (this.map.hasOwnProperty(name)) {
        callback.call(thisArg, this.map[name], name, this);
      }
    }
  };

  Headers.prototype.keys = function() {
    var items = [];
    this.forEach(function(value, name) {
      items.push(name);
    });
    return iteratorFor(items)
  };

  Headers.prototype.values = function() {
    var items = [];
    this.forEach(function(value) {
      items.push(value);
    });
    return iteratorFor(items)
  };

  Headers.prototype.entries = function() {
    var items = [];
    this.forEach(function(value, name) {
      items.push([name, value]);
    });
    return iteratorFor(items)
  };

  if (support.iterable) {
    Headers.prototype[Symbol.iterator] = Headers.prototype.entries;
  }

  function consumed(body) {
    if (body.bodyUsed) {
      return Promise.reject(new TypeError('Already read'))
    }
    body.bodyUsed = true;
  }

  function fileReaderReady(reader) {
    return new Promise(function(resolve, reject) {
      reader.onload = function() {
        resolve(reader.result);
      };
      reader.onerror = function() {
        reject(reader.error);
      };
    })
  }

  function readBlobAsArrayBuffer(blob) {
    var reader = new FileReader();
    var promise = fileReaderReady(reader);
    reader.readAsArrayBuffer(blob);
    return promise
  }

  function readBlobAsText(blob) {
    var reader = new FileReader();
    var promise = fileReaderReady(reader);
    reader.readAsText(blob);
    return promise
  }

  function readArrayBufferAsText(buf) {
    var view = new Uint8Array(buf);
    var chars = new Array(view.length);

    for (var i = 0; i < view.length; i++) {
      chars[i] = String.fromCharCode(view[i]);
    }
    return chars.join('')
  }

  function bufferClone(buf) {
    if (buf.slice) {
      return buf.slice(0)
    } else {
      var view = new Uint8Array(buf.byteLength);
      view.set(new Uint8Array(buf));
      return view.buffer
    }
  }

  function Body() {
    this.bodyUsed = false;

    this._initBody = function(body) {
      this._bodyInit = body;
      if (!body) {
        this._bodyText = '';
      } else if (typeof body === 'string') {
        this._bodyText = body;
      } else if (support.blob && Blob.prototype.isPrototypeOf(body)) {
        this._bodyBlob = body;
      } else if (support.formData && FormData.prototype.isPrototypeOf(body)) {
        this._bodyFormData = body;
      } else if (support.searchParams && URLSearchParams.prototype.isPrototypeOf(body)) {
        this._bodyText = body.toString();
      } else if (support.arrayBuffer && support.blob && isDataView(body)) {
        this._bodyArrayBuffer = bufferClone(body.buffer);
        // IE 10-11 can't handle a DataView body.
        this._bodyInit = new Blob([this._bodyArrayBuffer]);
      } else if (support.arrayBuffer && (ArrayBuffer.prototype.isPrototypeOf(body) || isArrayBufferView(body))) {
        this._bodyArrayBuffer = bufferClone(body);
      } else {
        this._bodyText = body = Object.prototype.toString.call(body);
      }

      if (!this.headers.get('content-type')) {
        if (typeof body === 'string') {
          this.headers.set('content-type', 'text/plain;charset=UTF-8');
        } else if (this._bodyBlob && this._bodyBlob.type) {
          this.headers.set('content-type', this._bodyBlob.type);
        } else if (support.searchParams && URLSearchParams.prototype.isPrototypeOf(body)) {
          this.headers.set('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
        }
      }
    };

    if (support.blob) {
      this.blob = function() {
        var rejected = consumed(this);
        if (rejected) {
          return rejected
        }

        if (this._bodyBlob) {
          return Promise.resolve(this._bodyBlob)
        } else if (this._bodyArrayBuffer) {
          return Promise.resolve(new Blob([this._bodyArrayBuffer]))
        } else if (this._bodyFormData) {
          throw new Error('could not read FormData body as blob')
        } else {
          return Promise.resolve(new Blob([this._bodyText]))
        }
      };

      this.arrayBuffer = function() {
        if (this._bodyArrayBuffer) {
          return consumed(this) || Promise.resolve(this._bodyArrayBuffer)
        } else {
          return this.blob().then(readBlobAsArrayBuffer)
        }
      };
    }

    this.text = function() {
      var rejected = consumed(this);
      if (rejected) {
        return rejected
      }

      if (this._bodyBlob) {
        return readBlobAsText(this._bodyBlob)
      } else if (this._bodyArrayBuffer) {
        return Promise.resolve(readArrayBufferAsText(this._bodyArrayBuffer))
      } else if (this._bodyFormData) {
        throw new Error('could not read FormData body as text')
      } else {
        return Promise.resolve(this._bodyText)
      }
    };

    if (support.formData) {
      this.formData = function() {
        return this.text().then(decode)
      };
    }

    this.json = function() {
      return this.text().then(JSON.parse)
    };

    return this
  }

  // HTTP methods whose capitalization should be normalized
  var methods = ['DELETE', 'GET', 'HEAD', 'OPTIONS', 'POST', 'PUT'];

  function normalizeMethod(method) {
    var upcased = method.toUpperCase();
    return methods.indexOf(upcased) > -1 ? upcased : method
  }

  function Request(input, options) {
    options = options || {};
    var body = options.body;

    if (input instanceof Request) {
      if (input.bodyUsed) {
        throw new TypeError('Already read')
      }
      this.url = input.url;
      this.credentials = input.credentials;
      if (!options.headers) {
        this.headers = new Headers(input.headers);
      }
      this.method = input.method;
      this.mode = input.mode;
      this.signal = input.signal;
      if (!body && input._bodyInit != null) {
        body = input._bodyInit;
        input.bodyUsed = true;
      }
    } else {
      this.url = String(input);
    }

    this.credentials = options.credentials || this.credentials || 'same-origin';
    if (options.headers || !this.headers) {
      this.headers = new Headers(options.headers);
    }
    this.method = normalizeMethod(options.method || this.method || 'GET');
    this.mode = options.mode || this.mode || null;
    this.signal = options.signal || this.signal;
    this.referrer = null;

    if ((this.method === 'GET' || this.method === 'HEAD') && body) {
      throw new TypeError('Body not allowed for GET or HEAD requests')
    }
    this._initBody(body);
  }

  Request.prototype.clone = function() {
    return new Request(this, {body: this._bodyInit})
  };

  function decode(body) {
    var form = new FormData();
    body
      .trim()
      .split('&')
      .forEach(function(bytes) {
        if (bytes) {
          var split = bytes.split('=');
          var name = split.shift().replace(/\+/g, ' ');
          var value = split.join('=').replace(/\+/g, ' ');
          form.append(decodeURIComponent(name), decodeURIComponent(value));
        }
      });
    return form
  }

  function parseHeaders(rawHeaders) {
    var headers = new Headers();
    // Replace instances of \r\n and \n followed by at least one space or horizontal tab with a space
    // https://tools.ietf.org/html/rfc7230#section-3.2
    var preProcessedHeaders = rawHeaders.replace(/\r?\n[\t ]+/g, ' ');
    preProcessedHeaders.split(/\r?\n/).forEach(function(line) {
      var parts = line.split(':');
      var key = parts.shift().trim();
      if (key) {
        var value = parts.join(':').trim();
        headers.append(key, value);
      }
    });
    return headers
  }

  Body.call(Request.prototype);

  function Response(bodyInit, options) {
    if (!options) {
      options = {};
    }

    this.type = 'default';
    this.status = options.status === undefined ? 200 : options.status;
    this.ok = this.status >= 200 && this.status < 300;
    this.statusText = 'statusText' in options ? options.statusText : 'OK';
    this.headers = new Headers(options.headers);
    this.url = options.url || '';
    this._initBody(bodyInit);
  }

  Body.call(Response.prototype);

  Response.prototype.clone = function() {
    return new Response(this._bodyInit, {
      status: this.status,
      statusText: this.statusText,
      headers: new Headers(this.headers),
      url: this.url
    })
  };

  Response.error = function() {
    var response = new Response(null, {status: 0, statusText: ''});
    response.type = 'error';
    return response
  };

  var redirectStatuses = [301, 302, 303, 307, 308];

  Response.redirect = function(url, status) {
    if (redirectStatuses.indexOf(status) === -1) {
      throw new RangeError('Invalid status code')
    }

    return new Response(null, {status: status, headers: {location: url}})
  };

  exports.DOMException = self.DOMException;
  try {
    new exports.DOMException();
  } catch (err) {
    exports.DOMException = function(message, name) {
      this.message = message;
      this.name = name;
      var error = Error(message);
      this.stack = error.stack;
    };
    exports.DOMException.prototype = Object.create(Error.prototype);
    exports.DOMException.prototype.constructor = exports.DOMException;
  }

  function fetch(input, init) {
    return new Promise(function(resolve, reject) {
      var request = new Request(input, init);

      if (request.signal && request.signal.aborted) {
        return reject(new exports.DOMException('Aborted', 'AbortError'))
      }

      var xhr = new XMLHttpRequest();

      function abortXhr() {
        xhr.abort();
      }

      xhr.onload = function() {
        var options = {
          status: xhr.status,
          statusText: xhr.statusText,
          headers: parseHeaders(xhr.getAllResponseHeaders() || '')
        };
        options.url = 'responseURL' in xhr ? xhr.responseURL : options.headers.get('X-Request-URL');
        var body = 'response' in xhr ? xhr.response : xhr.responseText;
        resolve(new Response(body, options));
      };

      xhr.onerror = function() {
        reject(new TypeError('Network request failed'));
      };

      xhr.ontimeout = function() {
        reject(new TypeError('Network request failed'));
      };

      xhr.onabort = function() {
        reject(new exports.DOMException('Aborted', 'AbortError'));
      };

      xhr.open(request.method, request.url, true);

      if (request.credentials === 'include') {
        xhr.withCredentials = true;
      } else if (request.credentials === 'omit') {
        xhr.withCredentials = false;
      }

      if ('responseType' in xhr && support.blob) {
        xhr.responseType = 'blob';
      }

      request.headers.forEach(function(value, name) {
        xhr.setRequestHeader(name, value);
      });

      if (request.signal) {
        request.signal.addEventListener('abort', abortXhr);

        xhr.onreadystatechange = function() {
          // DONE (success or failure)
          if (xhr.readyState === 4) {
            request.signal.removeEventListener('abort', abortXhr);
          }
        };
      }

      xhr.send(typeof request._bodyInit === 'undefined' ? null : request._bodyInit);
    })
  }

  fetch.polyfill = true;

  if (!self.fetch) {
    self.fetch = fetch;
    self.Headers = Headers;
    self.Request = Request;
    self.Response = Response;
  }

  exports.Headers = Headers;
  exports.Request = Request;
  exports.Response = Response;
  exports.fetch = fetch;

  Object.defineProperty(exports, '__esModule', { value: true });

  return exports;

})({});
})(typeof self !== 'undefined' ? self : this);


/***/ }),

/***/ 834:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

// istanbul ignore next

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _handlebarsBase = __webpack_require__(67);

var base = _interopRequireWildcard(_handlebarsBase);

// Each of these augment the Handlebars object. No need to setup here.
// (This is done to easily share code between commonjs and browse envs)

var _handlebarsSafeString = __webpack_require__(558);

var _handlebarsSafeString2 = _interopRequireDefault(_handlebarsSafeString);

var _handlebarsException = __webpack_require__(728);

var _handlebarsException2 = _interopRequireDefault(_handlebarsException);

var _handlebarsUtils = __webpack_require__(392);

var Utils = _interopRequireWildcard(_handlebarsUtils);

var _handlebarsRuntime = __webpack_require__(628);

var runtime = _interopRequireWildcard(_handlebarsRuntime);

var _handlebarsNoConflict = __webpack_require__(982);

var _handlebarsNoConflict2 = _interopRequireDefault(_handlebarsNoConflict);

// For compatibility and usage outside of module systems, make the Handlebars object a namespace
function create() {
  var hb = new base.HandlebarsEnvironment();

  Utils.extend(hb, base);
  hb.SafeString = _handlebarsSafeString2['default'];
  hb.Exception = _handlebarsException2['default'];
  hb.Utils = Utils;
  hb.escapeExpression = Utils.escapeExpression;

  hb.VM = runtime;
  hb.template = function (spec) {
    return runtime.template(spec, hb);
  };

  return hb;
}

var inst = create();
inst.create = create;

_handlebarsNoConflict2['default'](inst);

inst['default'] = inst;

exports["default"] = inst;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uL2xpYi9oYW5kbGViYXJzLnJ1bnRpbWUuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7OEJBQXNCLG1CQUFtQjs7SUFBN0IsSUFBSTs7Ozs7b0NBSU8sMEJBQTBCOzs7O21DQUMzQix3QkFBd0I7Ozs7K0JBQ3ZCLG9CQUFvQjs7SUFBL0IsS0FBSzs7aUNBQ1Esc0JBQXNCOztJQUFuQyxPQUFPOztvQ0FFSSwwQkFBMEI7Ozs7O0FBR2pELFNBQVMsTUFBTSxHQUFHO0FBQ2hCLE1BQUksRUFBRSxHQUFHLElBQUksSUFBSSxDQUFDLHFCQUFxQixFQUFFLENBQUM7O0FBRTFDLE9BQUssQ0FBQyxNQUFNLENBQUMsRUFBRSxFQUFFLElBQUksQ0FBQyxDQUFDO0FBQ3ZCLElBQUUsQ0FBQyxVQUFVLG9DQUFhLENBQUM7QUFDM0IsSUFBRSxDQUFDLFNBQVMsbUNBQVksQ0FBQztBQUN6QixJQUFFLENBQUMsS0FBSyxHQUFHLEtBQUssQ0FBQztBQUNqQixJQUFFLENBQUMsZ0JBQWdCLEdBQUcsS0FBSyxDQUFDLGdCQUFnQixDQUFDOztBQUU3QyxJQUFFLENBQUMsRUFBRSxHQUFHLE9BQU8sQ0FBQztBQUNoQixJQUFFLENBQUMsUUFBUSxHQUFHLFVBQVMsSUFBSSxFQUFFO0FBQzNCLFdBQU8sT0FBTyxDQUFDLFFBQVEsQ0FBQyxJQUFJLEVBQUUsRUFBRSxDQUFDLENBQUM7R0FDbkMsQ0FBQzs7QUFFRixTQUFPLEVBQUUsQ0FBQztDQUNYOztBQUVELElBQUksSUFBSSxHQUFHLE1BQU0sRUFBRSxDQUFDO0FBQ3BCLElBQUksQ0FBQyxNQUFNLEdBQUcsTUFBTSxDQUFDOztBQUVyQixrQ0FBVyxJQUFJLENBQUMsQ0FBQzs7QUFFakIsSUFBSSxDQUFDLFNBQVMsQ0FBQyxHQUFHLElBQUksQ0FBQzs7cUJBRVIsSUFBSSIsImZpbGUiOiJoYW5kbGViYXJzLnJ1bnRpbWUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBiYXNlIGZyb20gJy4vaGFuZGxlYmFycy9iYXNlJztcblxuLy8gRWFjaCBvZiB0aGVzZSBhdWdtZW50IHRoZSBIYW5kbGViYXJzIG9iamVjdC4gTm8gbmVlZCB0byBzZXR1cCBoZXJlLlxuLy8gKFRoaXMgaXMgZG9uZSB0byBlYXNpbHkgc2hhcmUgY29kZSBiZXR3ZWVuIGNvbW1vbmpzIGFuZCBicm93c2UgZW52cylcbmltcG9ydCBTYWZlU3RyaW5nIGZyb20gJy4vaGFuZGxlYmFycy9zYWZlLXN0cmluZyc7XG5pbXBvcnQgRXhjZXB0aW9uIGZyb20gJy4vaGFuZGxlYmFycy9leGNlcHRpb24nO1xuaW1wb3J0ICogYXMgVXRpbHMgZnJvbSAnLi9oYW5kbGViYXJzL3V0aWxzJztcbmltcG9ydCAqIGFzIHJ1bnRpbWUgZnJvbSAnLi9oYW5kbGViYXJzL3J1bnRpbWUnO1xuXG5pbXBvcnQgbm9Db25mbGljdCBmcm9tICcuL2hhbmRsZWJhcnMvbm8tY29uZmxpY3QnO1xuXG4vLyBGb3IgY29tcGF0aWJpbGl0eSBhbmQgdXNhZ2Ugb3V0c2lkZSBvZiBtb2R1bGUgc3lzdGVtcywgbWFrZSB0aGUgSGFuZGxlYmFycyBvYmplY3QgYSBuYW1lc3BhY2VcbmZ1bmN0aW9uIGNyZWF0ZSgpIHtcbiAgbGV0IGhiID0gbmV3IGJhc2UuSGFuZGxlYmFyc0Vudmlyb25tZW50KCk7XG5cbiAgVXRpbHMuZXh0ZW5kKGhiLCBiYXNlKTtcbiAgaGIuU2FmZVN0cmluZyA9IFNhZmVTdHJpbmc7XG4gIGhiLkV4Y2VwdGlvbiA9IEV4Y2VwdGlvbjtcbiAgaGIuVXRpbHMgPSBVdGlscztcbiAgaGIuZXNjYXBlRXhwcmVzc2lvbiA9IFV0aWxzLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgaGIuVk0gPSBydW50aW1lO1xuICBoYi50ZW1wbGF0ZSA9IGZ1bmN0aW9uKHNwZWMpIHtcbiAgICByZXR1cm4gcnVudGltZS50ZW1wbGF0ZShzcGVjLCBoYik7XG4gIH07XG5cbiAgcmV0dXJuIGhiO1xufVxuXG5sZXQgaW5zdCA9IGNyZWF0ZSgpO1xuaW5zdC5jcmVhdGUgPSBjcmVhdGU7XG5cbm5vQ29uZmxpY3QoaW5zdCk7XG5cbmluc3RbJ2RlZmF1bHQnXSA9IGluc3Q7XG5cbmV4cG9ydCBkZWZhdWx0IGluc3Q7XG4iXX0=


/***/ }),

/***/ 67:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.HandlebarsEnvironment = HandlebarsEnvironment;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(392);

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

var _helpers = __webpack_require__(638);

var _decorators = __webpack_require__(881);

var _logger = __webpack_require__(37);

var _logger2 = _interopRequireDefault(_logger);

var _internalProtoAccess = __webpack_require__(293);

var VERSION = '4.7.7';
exports.VERSION = VERSION;
var COMPILER_REVISION = 8;
exports.COMPILER_REVISION = COMPILER_REVISION;
var LAST_COMPATIBLE_COMPILER_REVISION = 7;

exports.LAST_COMPATIBLE_COMPILER_REVISION = LAST_COMPATIBLE_COMPILER_REVISION;
var REVISION_CHANGES = {
  1: '<= 1.0.rc.2', // 1.0.rc.2 is actually rev2 but doesn't report it
  2: '== 1.0.0-rc.3',
  3: '== 1.0.0-rc.4',
  4: '== 1.x.x',
  5: '== 2.0.0-alpha.x',
  6: '>= 2.0.0-beta.1',
  7: '>= 4.0.0 <4.3.0',
  8: '>= 4.3.0'
};

exports.REVISION_CHANGES = REVISION_CHANGES;
var objectType = '[object Object]';

function HandlebarsEnvironment(helpers, partials, decorators) {
  this.helpers = helpers || {};
  this.partials = partials || {};
  this.decorators = decorators || {};

  _helpers.registerDefaultHelpers(this);
  _decorators.registerDefaultDecorators(this);
}

HandlebarsEnvironment.prototype = {
  constructor: HandlebarsEnvironment,

  logger: _logger2['default'],
  log: _logger2['default'].log,

  registerHelper: function registerHelper(name, fn) {
    if (_utils.toString.call(name) === objectType) {
      if (fn) {
        throw new _exception2['default']('Arg not supported with multiple helpers');
      }
      _utils.extend(this.helpers, name);
    } else {
      this.helpers[name] = fn;
    }
  },
  unregisterHelper: function unregisterHelper(name) {
    delete this.helpers[name];
  },

  registerPartial: function registerPartial(name, partial) {
    if (_utils.toString.call(name) === objectType) {
      _utils.extend(this.partials, name);
    } else {
      if (typeof partial === 'undefined') {
        throw new _exception2['default']('Attempting to register a partial called "' + name + '" as undefined');
      }
      this.partials[name] = partial;
    }
  },
  unregisterPartial: function unregisterPartial(name) {
    delete this.partials[name];
  },

  registerDecorator: function registerDecorator(name, fn) {
    if (_utils.toString.call(name) === objectType) {
      if (fn) {
        throw new _exception2['default']('Arg not supported with multiple decorators');
      }
      _utils.extend(this.decorators, name);
    } else {
      this.decorators[name] = fn;
    }
  },
  unregisterDecorator: function unregisterDecorator(name) {
    delete this.decorators[name];
  },
  /**
   * Reset the memory of illegal property accesses that have already been logged.
   * @deprecated should only be used in handlebars test-cases
   */
  resetLoggedPropertyAccesses: function resetLoggedPropertyAccesses() {
    _internalProtoAccess.resetLoggedProperties();
  }
};

var log = _logger2['default'].log;

exports.log = log;
exports.createFrame = _utils.createFrame;
exports.logger = _logger2['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2Jhc2UuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7cUJBQThDLFNBQVM7O3lCQUNqQyxhQUFhOzs7O3VCQUNJLFdBQVc7OzBCQUNSLGNBQWM7O3NCQUNyQyxVQUFVOzs7O21DQUNTLHlCQUF5Qjs7QUFFeEQsSUFBTSxPQUFPLEdBQUcsT0FBTyxDQUFDOztBQUN4QixJQUFNLGlCQUFpQixHQUFHLENBQUMsQ0FBQzs7QUFDNUIsSUFBTSxpQ0FBaUMsR0FBRyxDQUFDLENBQUM7OztBQUU1QyxJQUFNLGdCQUFnQixHQUFHO0FBQzlCLEdBQUMsRUFBRSxhQUFhO0FBQ2hCLEdBQUMsRUFBRSxlQUFlO0FBQ2xCLEdBQUMsRUFBRSxlQUFlO0FBQ2xCLEdBQUMsRUFBRSxVQUFVO0FBQ2IsR0FBQyxFQUFFLGtCQUFrQjtBQUNyQixHQUFDLEVBQUUsaUJBQWlCO0FBQ3BCLEdBQUMsRUFBRSxpQkFBaUI7QUFDcEIsR0FBQyxFQUFFLFVBQVU7Q0FDZCxDQUFDOzs7QUFFRixJQUFNLFVBQVUsR0FBRyxpQkFBaUIsQ0FBQzs7QUFFOUIsU0FBUyxxQkFBcUIsQ0FBQyxPQUFPLEVBQUUsUUFBUSxFQUFFLFVBQVUsRUFBRTtBQUNuRSxNQUFJLENBQUMsT0FBTyxHQUFHLE9BQU8sSUFBSSxFQUFFLENBQUM7QUFDN0IsTUFBSSxDQUFDLFFBQVEsR0FBRyxRQUFRLElBQUksRUFBRSxDQUFDO0FBQy9CLE1BQUksQ0FBQyxVQUFVLEdBQUcsVUFBVSxJQUFJLEVBQUUsQ0FBQzs7QUFFbkMsa0NBQXVCLElBQUksQ0FBQyxDQUFDO0FBQzdCLHdDQUEwQixJQUFJLENBQUMsQ0FBQztDQUNqQzs7QUFFRCxxQkFBcUIsQ0FBQyxTQUFTLEdBQUc7QUFDaEMsYUFBVyxFQUFFLHFCQUFxQjs7QUFFbEMsUUFBTSxxQkFBUTtBQUNkLEtBQUcsRUFBRSxvQkFBTyxHQUFHOztBQUVmLGdCQUFjLEVBQUUsd0JBQVMsSUFBSSxFQUFFLEVBQUUsRUFBRTtBQUNqQyxRQUFJLGdCQUFTLElBQUksQ0FBQyxJQUFJLENBQUMsS0FBSyxVQUFVLEVBQUU7QUFDdEMsVUFBSSxFQUFFLEVBQUU7QUFDTixjQUFNLDJCQUFjLHlDQUF5QyxDQUFDLENBQUM7T0FDaEU7QUFDRCxvQkFBTyxJQUFJLENBQUMsT0FBTyxFQUFFLElBQUksQ0FBQyxDQUFDO0tBQzVCLE1BQU07QUFDTCxVQUFJLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxHQUFHLEVBQUUsQ0FBQztLQUN6QjtHQUNGO0FBQ0Qsa0JBQWdCLEVBQUUsMEJBQVMsSUFBSSxFQUFFO0FBQy9CLFdBQU8sSUFBSSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztHQUMzQjs7QUFFRCxpQkFBZSxFQUFFLHlCQUFTLElBQUksRUFBRSxPQUFPLEVBQUU7QUFDdkMsUUFBSSxnQkFBUyxJQUFJLENBQUMsSUFBSSxDQUFDLEtBQUssVUFBVSxFQUFFO0FBQ3RDLG9CQUFPLElBQUksQ0FBQyxRQUFRLEVBQUUsSUFBSSxDQUFDLENBQUM7S0FDN0IsTUFBTTtBQUNMLFVBQUksT0FBTyxPQUFPLEtBQUssV0FBVyxFQUFFO0FBQ2xDLGNBQU0seUVBQ3dDLElBQUksb0JBQ2pELENBQUM7T0FDSDtBQUNELFVBQUksQ0FBQyxRQUFRLENBQUMsSUFBSSxDQUFDLEdBQUcsT0FBTyxDQUFDO0tBQy9CO0dBQ0Y7QUFDRCxtQkFBaUIsRUFBRSwyQkFBUyxJQUFJLEVBQUU7QUFDaEMsV0FBTyxJQUFJLENBQUMsUUFBUSxDQUFDLElBQUksQ0FBQyxDQUFDO0dBQzVCOztBQUVELG1CQUFpQixFQUFFLDJCQUFTLElBQUksRUFBRSxFQUFFLEVBQUU7QUFDcEMsUUFBSSxnQkFBUyxJQUFJLENBQUMsSUFBSSxDQUFDLEtBQUssVUFBVSxFQUFFO0FBQ3RDLFVBQUksRUFBRSxFQUFFO0FBQ04sY0FBTSwyQkFBYyw0Q0FBNEMsQ0FBQyxDQUFDO09BQ25FO0FBQ0Qsb0JBQU8sSUFBSSxDQUFDLFVBQVUsRUFBRSxJQUFJLENBQUMsQ0FBQztLQUMvQixNQUFNO0FBQ0wsVUFBSSxDQUFDLFVBQVUsQ0FBQyxJQUFJLENBQUMsR0FBRyxFQUFFLENBQUM7S0FDNUI7R0FDRjtBQUNELHFCQUFtQixFQUFFLDZCQUFTLElBQUksRUFBRTtBQUNsQyxXQUFPLElBQUksQ0FBQyxVQUFVLENBQUMsSUFBSSxDQUFDLENBQUM7R0FDOUI7Ozs7O0FBS0QsNkJBQTJCLEVBQUEsdUNBQUc7QUFDNUIsZ0RBQXVCLENBQUM7R0FDekI7Q0FDRixDQUFDOztBQUVLLElBQUksR0FBRyxHQUFHLG9CQUFPLEdBQUcsQ0FBQzs7O1FBRW5CLFdBQVc7UUFBRSxNQUFNIiwiZmlsZSI6ImJhc2UuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBjcmVhdGVGcmFtZSwgZXh0ZW5kLCB0b1N0cmluZyB9IGZyb20gJy4vdXRpbHMnO1xuaW1wb3J0IEV4Y2VwdGlvbiBmcm9tICcuL2V4Y2VwdGlvbic7XG5pbXBvcnQgeyByZWdpc3RlckRlZmF1bHRIZWxwZXJzIH0gZnJvbSAnLi9oZWxwZXJzJztcbmltcG9ydCB7IHJlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnMgfSBmcm9tICcuL2RlY29yYXRvcnMnO1xuaW1wb3J0IGxvZ2dlciBmcm9tICcuL2xvZ2dlcic7XG5pbXBvcnQgeyByZXNldExvZ2dlZFByb3BlcnRpZXMgfSBmcm9tICcuL2ludGVybmFsL3Byb3RvLWFjY2Vzcyc7XG5cbmV4cG9ydCBjb25zdCBWRVJTSU9OID0gJzQuNy43JztcbmV4cG9ydCBjb25zdCBDT01QSUxFUl9SRVZJU0lPTiA9IDg7XG5leHBvcnQgY29uc3QgTEFTVF9DT01QQVRJQkxFX0NPTVBJTEVSX1JFVklTSU9OID0gNztcblxuZXhwb3J0IGNvbnN0IFJFVklTSU9OX0NIQU5HRVMgPSB7XG4gIDE6ICc8PSAxLjAucmMuMicsIC8vIDEuMC5yYy4yIGlzIGFjdHVhbGx5IHJldjIgYnV0IGRvZXNuJ3QgcmVwb3J0IGl0XG4gIDI6ICc9PSAxLjAuMC1yYy4zJyxcbiAgMzogJz09IDEuMC4wLXJjLjQnLFxuICA0OiAnPT0gMS54LngnLFxuICA1OiAnPT0gMi4wLjAtYWxwaGEueCcsXG4gIDY6ICc+PSAyLjAuMC1iZXRhLjEnLFxuICA3OiAnPj0gNC4wLjAgPDQuMy4wJyxcbiAgODogJz49IDQuMy4wJ1xufTtcblxuY29uc3Qgb2JqZWN0VHlwZSA9ICdbb2JqZWN0IE9iamVjdF0nO1xuXG5leHBvcnQgZnVuY3Rpb24gSGFuZGxlYmFyc0Vudmlyb25tZW50KGhlbHBlcnMsIHBhcnRpYWxzLCBkZWNvcmF0b3JzKSB7XG4gIHRoaXMuaGVscGVycyA9IGhlbHBlcnMgfHwge307XG4gIHRoaXMucGFydGlhbHMgPSBwYXJ0aWFscyB8fCB7fTtcbiAgdGhpcy5kZWNvcmF0b3JzID0gZGVjb3JhdG9ycyB8fCB7fTtcblxuICByZWdpc3RlckRlZmF1bHRIZWxwZXJzKHRoaXMpO1xuICByZWdpc3RlckRlZmF1bHREZWNvcmF0b3JzKHRoaXMpO1xufVxuXG5IYW5kbGViYXJzRW52aXJvbm1lbnQucHJvdG90eXBlID0ge1xuICBjb25zdHJ1Y3RvcjogSGFuZGxlYmFyc0Vudmlyb25tZW50LFxuXG4gIGxvZ2dlcjogbG9nZ2VyLFxuICBsb2c6IGxvZ2dlci5sb2csXG5cbiAgcmVnaXN0ZXJIZWxwZXI6IGZ1bmN0aW9uKG5hbWUsIGZuKSB7XG4gICAgaWYgKHRvU3RyaW5nLmNhbGwobmFtZSkgPT09IG9iamVjdFR5cGUpIHtcbiAgICAgIGlmIChmbikge1xuICAgICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdBcmcgbm90IHN1cHBvcnRlZCB3aXRoIG11bHRpcGxlIGhlbHBlcnMnKTtcbiAgICAgIH1cbiAgICAgIGV4dGVuZCh0aGlzLmhlbHBlcnMsIG5hbWUpO1xuICAgIH0gZWxzZSB7XG4gICAgICB0aGlzLmhlbHBlcnNbbmFtZV0gPSBmbjtcbiAgICB9XG4gIH0sXG4gIHVucmVnaXN0ZXJIZWxwZXI6IGZ1bmN0aW9uKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5oZWxwZXJzW25hbWVdO1xuICB9LFxuXG4gIHJlZ2lzdGVyUGFydGlhbDogZnVuY3Rpb24obmFtZSwgcGFydGlhbCkge1xuICAgIGlmICh0b1N0cmluZy5jYWxsKG5hbWUpID09PSBvYmplY3RUeXBlKSB7XG4gICAgICBleHRlbmQodGhpcy5wYXJ0aWFscywgbmFtZSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIGlmICh0eXBlb2YgcGFydGlhbCA9PT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgICAgdGhyb3cgbmV3IEV4Y2VwdGlvbihcbiAgICAgICAgICBgQXR0ZW1wdGluZyB0byByZWdpc3RlciBhIHBhcnRpYWwgY2FsbGVkIFwiJHtuYW1lfVwiIGFzIHVuZGVmaW5lZGBcbiAgICAgICAgKTtcbiAgICAgIH1cbiAgICAgIHRoaXMucGFydGlhbHNbbmFtZV0gPSBwYXJ0aWFsO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlclBhcnRpYWw6IGZ1bmN0aW9uKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5wYXJ0aWFsc1tuYW1lXTtcbiAgfSxcblxuICByZWdpc3RlckRlY29yYXRvcjogZnVuY3Rpb24obmFtZSwgZm4pIHtcbiAgICBpZiAodG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgaWYgKGZuKSB7XG4gICAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ0FyZyBub3Qgc3VwcG9ydGVkIHdpdGggbXVsdGlwbGUgZGVjb3JhdG9ycycpO1xuICAgICAgfVxuICAgICAgZXh0ZW5kKHRoaXMuZGVjb3JhdG9ycywgbmFtZSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMuZGVjb3JhdG9yc1tuYW1lXSA9IGZuO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlckRlY29yYXRvcjogZnVuY3Rpb24obmFtZSkge1xuICAgIGRlbGV0ZSB0aGlzLmRlY29yYXRvcnNbbmFtZV07XG4gIH0sXG4gIC8qKlxuICAgKiBSZXNldCB0aGUgbWVtb3J5IG9mIGlsbGVnYWwgcHJvcGVydHkgYWNjZXNzZXMgdGhhdCBoYXZlIGFscmVhZHkgYmVlbiBsb2dnZWQuXG4gICAqIEBkZXByZWNhdGVkIHNob3VsZCBvbmx5IGJlIHVzZWQgaW4gaGFuZGxlYmFycyB0ZXN0LWNhc2VzXG4gICAqL1xuICByZXNldExvZ2dlZFByb3BlcnR5QWNjZXNzZXMoKSB7XG4gICAgcmVzZXRMb2dnZWRQcm9wZXJ0aWVzKCk7XG4gIH1cbn07XG5cbmV4cG9ydCBsZXQgbG9nID0gbG9nZ2VyLmxvZztcblxuZXhwb3J0IHsgY3JlYXRlRnJhbWUsIGxvZ2dlciB9O1xuIl19


/***/ }),

/***/ 881:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.registerDefaultDecorators = registerDefaultDecorators;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _decoratorsInline = __webpack_require__(670);

var _decoratorsInline2 = _interopRequireDefault(_decoratorsInline);

function registerDefaultDecorators(instance) {
  _decoratorsInline2['default'](instance);
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2RlY29yYXRvcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Z0NBQTJCLHFCQUFxQjs7OztBQUV6QyxTQUFTLHlCQUF5QixDQUFDLFFBQVEsRUFBRTtBQUNsRCxnQ0FBZSxRQUFRLENBQUMsQ0FBQztDQUMxQiIsImZpbGUiOiJkZWNvcmF0b3JzLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHJlZ2lzdGVySW5saW5lIGZyb20gJy4vZGVjb3JhdG9ycy9pbmxpbmUnO1xuXG5leHBvcnQgZnVuY3Rpb24gcmVnaXN0ZXJEZWZhdWx0RGVjb3JhdG9ycyhpbnN0YW5jZSkge1xuICByZWdpc3RlcklubGluZShpbnN0YW5jZSk7XG59XG4iXX0=


/***/ }),

/***/ 670:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(392);

exports["default"] = function (instance) {
  instance.registerDecorator('inline', function (fn, props, container, options) {
    var ret = fn;
    if (!props.partials) {
      props.partials = {};
      ret = function (context, options) {
        // Create a new partials stack frame prior to exec.
        var original = container.partials;
        container.partials = _utils.extend({}, original, props.partials);
        var ret = fn(context, options);
        container.partials = original;
        return ret;
      };
    }

    props.partials[options.args[0]] = options.fn;

    return ret;
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2RlY29yYXRvcnMvaW5saW5lLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQXVCLFVBQVU7O3FCQUVsQixVQUFTLFFBQVEsRUFBRTtBQUNoQyxVQUFRLENBQUMsaUJBQWlCLENBQUMsUUFBUSxFQUFFLFVBQVMsRUFBRSxFQUFFLEtBQUssRUFBRSxTQUFTLEVBQUUsT0FBTyxFQUFFO0FBQzNFLFFBQUksR0FBRyxHQUFHLEVBQUUsQ0FBQztBQUNiLFFBQUksQ0FBQyxLQUFLLENBQUMsUUFBUSxFQUFFO0FBQ25CLFdBQUssQ0FBQyxRQUFRLEdBQUcsRUFBRSxDQUFDO0FBQ3BCLFNBQUcsR0FBRyxVQUFTLE9BQU8sRUFBRSxPQUFPLEVBQUU7O0FBRS9CLFlBQUksUUFBUSxHQUFHLFNBQVMsQ0FBQyxRQUFRLENBQUM7QUFDbEMsaUJBQVMsQ0FBQyxRQUFRLEdBQUcsY0FBTyxFQUFFLEVBQUUsUUFBUSxFQUFFLEtBQUssQ0FBQyxRQUFRLENBQUMsQ0FBQztBQUMxRCxZQUFJLEdBQUcsR0FBRyxFQUFFLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO0FBQy9CLGlCQUFTLENBQUMsUUFBUSxHQUFHLFFBQVEsQ0FBQztBQUM5QixlQUFPLEdBQUcsQ0FBQztPQUNaLENBQUM7S0FDSDs7QUFFRCxTQUFLLENBQUMsUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUMsR0FBRyxPQUFPLENBQUMsRUFBRSxDQUFDOztBQUU3QyxXQUFPLEdBQUcsQ0FBQztHQUNaLENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6ImlubGluZS5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IGV4dGVuZCB9IGZyb20gJy4uL3V0aWxzJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJEZWNvcmF0b3IoJ2lubGluZScsIGZ1bmN0aW9uKGZuLCBwcm9wcywgY29udGFpbmVyLCBvcHRpb25zKSB7XG4gICAgbGV0IHJldCA9IGZuO1xuICAgIGlmICghcHJvcHMucGFydGlhbHMpIHtcbiAgICAgIHByb3BzLnBhcnRpYWxzID0ge307XG4gICAgICByZXQgPSBmdW5jdGlvbihjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgICAgIC8vIENyZWF0ZSBhIG5ldyBwYXJ0aWFscyBzdGFjayBmcmFtZSBwcmlvciB0byBleGVjLlxuICAgICAgICBsZXQgb3JpZ2luYWwgPSBjb250YWluZXIucGFydGlhbHM7XG4gICAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IGV4dGVuZCh7fSwgb3JpZ2luYWwsIHByb3BzLnBhcnRpYWxzKTtcbiAgICAgICAgbGV0IHJldCA9IGZuKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgICAgICBjb250YWluZXIucGFydGlhbHMgPSBvcmlnaW5hbDtcbiAgICAgICAgcmV0dXJuIHJldDtcbiAgICAgIH07XG4gICAgfVxuXG4gICAgcHJvcHMucGFydGlhbHNbb3B0aW9ucy5hcmdzWzBdXSA9IG9wdGlvbnMuZm47XG5cbiAgICByZXR1cm4gcmV0O1xuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ 728:
/***/ (function(module, exports) {

"use strict";


exports.__esModule = true;
var errorProps = ['description', 'fileName', 'lineNumber', 'endLineNumber', 'message', 'name', 'number', 'stack'];

function Exception(message, node) {
  var loc = node && node.loc,
      line = undefined,
      endLineNumber = undefined,
      column = undefined,
      endColumn = undefined;

  if (loc) {
    line = loc.start.line;
    endLineNumber = loc.end.line;
    column = loc.start.column;
    endColumn = loc.end.column;

    message += ' - ' + line + ':' + column;
  }

  var tmp = Error.prototype.constructor.call(this, message);

  // Unfortunately errors are not enumerable in Chrome (at least), so `for prop in tmp` doesn't work.
  for (var idx = 0; idx < errorProps.length; idx++) {
    this[errorProps[idx]] = tmp[errorProps[idx]];
  }

  /* istanbul ignore else */
  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, Exception);
  }

  try {
    if (loc) {
      this.lineNumber = line;
      this.endLineNumber = endLineNumber;

      // Work around issue under safari where we can't directly set the column value
      /* istanbul ignore next */
      if (Object.defineProperty) {
        Object.defineProperty(this, 'column', {
          value: column,
          enumerable: true
        });
        Object.defineProperty(this, 'endColumn', {
          value: endColumn,
          enumerable: true
        });
      } else {
        this.column = column;
        this.endColumn = endColumn;
      }
    }
  } catch (nop) {
    /* Ignore if the browser is very particular */
  }
}

Exception.prototype = new Error();

exports["default"] = Exception;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2V4Y2VwdGlvbi5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7QUFBQSxJQUFNLFVBQVUsR0FBRyxDQUNqQixhQUFhLEVBQ2IsVUFBVSxFQUNWLFlBQVksRUFDWixlQUFlLEVBQ2YsU0FBUyxFQUNULE1BQU0sRUFDTixRQUFRLEVBQ1IsT0FBTyxDQUNSLENBQUM7O0FBRUYsU0FBUyxTQUFTLENBQUMsT0FBTyxFQUFFLElBQUksRUFBRTtBQUNoQyxNQUFJLEdBQUcsR0FBRyxJQUFJLElBQUksSUFBSSxDQUFDLEdBQUc7TUFDeEIsSUFBSSxZQUFBO01BQ0osYUFBYSxZQUFBO01BQ2IsTUFBTSxZQUFBO01BQ04sU0FBUyxZQUFBLENBQUM7O0FBRVosTUFBSSxHQUFHLEVBQUU7QUFDUCxRQUFJLEdBQUcsR0FBRyxDQUFDLEtBQUssQ0FBQyxJQUFJLENBQUM7QUFDdEIsaUJBQWEsR0FBRyxHQUFHLENBQUMsR0FBRyxDQUFDLElBQUksQ0FBQztBQUM3QixVQUFNLEdBQUcsR0FBRyxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUM7QUFDMUIsYUFBUyxHQUFHLEdBQUcsQ0FBQyxHQUFHLENBQUMsTUFBTSxDQUFDOztBQUUzQixXQUFPLElBQUksS0FBSyxHQUFHLElBQUksR0FBRyxHQUFHLEdBQUcsTUFBTSxDQUFDO0dBQ3hDOztBQUVELE1BQUksR0FBRyxHQUFHLEtBQUssQ0FBQyxTQUFTLENBQUMsV0FBVyxDQUFDLElBQUksQ0FBQyxJQUFJLEVBQUUsT0FBTyxDQUFDLENBQUM7OztBQUcxRCxPQUFLLElBQUksR0FBRyxHQUFHLENBQUMsRUFBRSxHQUFHLEdBQUcsVUFBVSxDQUFDLE1BQU0sRUFBRSxHQUFHLEVBQUUsRUFBRTtBQUNoRCxRQUFJLENBQUMsVUFBVSxDQUFDLEdBQUcsQ0FBQyxDQUFDLEdBQUcsR0FBRyxDQUFDLFVBQVUsQ0FBQyxHQUFHLENBQUMsQ0FBQyxDQUFDO0dBQzlDOzs7QUFHRCxNQUFJLEtBQUssQ0FBQyxpQkFBaUIsRUFBRTtBQUMzQixTQUFLLENBQUMsaUJBQWlCLENBQUMsSUFBSSxFQUFFLFNBQVMsQ0FBQyxDQUFDO0dBQzFDOztBQUVELE1BQUk7QUFDRixRQUFJLEdBQUcsRUFBRTtBQUNQLFVBQUksQ0FBQyxVQUFVLEdBQUcsSUFBSSxDQUFDO0FBQ3ZCLFVBQUksQ0FBQyxhQUFhLEdBQUcsYUFBYSxDQUFDOzs7O0FBSW5DLFVBQUksTUFBTSxDQUFDLGNBQWMsRUFBRTtBQUN6QixjQUFNLENBQUMsY0FBYyxDQUFDLElBQUksRUFBRSxRQUFRLEVBQUU7QUFDcEMsZUFBSyxFQUFFLE1BQU07QUFDYixvQkFBVSxFQUFFLElBQUk7U0FDakIsQ0FBQyxDQUFDO0FBQ0gsY0FBTSxDQUFDLGNBQWMsQ0FBQyxJQUFJLEVBQUUsV0FBVyxFQUFFO0FBQ3ZDLGVBQUssRUFBRSxTQUFTO0FBQ2hCLG9CQUFVLEVBQUUsSUFBSTtTQUNqQixDQUFDLENBQUM7T0FDSixNQUFNO0FBQ0wsWUFBSSxDQUFDLE1BQU0sR0FBRyxNQUFNLENBQUM7QUFDckIsWUFBSSxDQUFDLFNBQVMsR0FBRyxTQUFTLENBQUM7T0FDNUI7S0FDRjtHQUNGLENBQUMsT0FBTyxHQUFHLEVBQUU7O0dBRWI7Q0FDRjs7QUFFRCxTQUFTLENBQUMsU0FBUyxHQUFHLElBQUksS0FBSyxFQUFFLENBQUM7O3FCQUVuQixTQUFTIiwiZmlsZSI6ImV4Y2VwdGlvbi5qcyIsInNvdXJjZXNDb250ZW50IjpbImNvbnN0IGVycm9yUHJvcHMgPSBbXG4gICdkZXNjcmlwdGlvbicsXG4gICdmaWxlTmFtZScsXG4gICdsaW5lTnVtYmVyJyxcbiAgJ2VuZExpbmVOdW1iZXInLFxuICAnbWVzc2FnZScsXG4gICduYW1lJyxcbiAgJ251bWJlcicsXG4gICdzdGFjaydcbl07XG5cbmZ1bmN0aW9uIEV4Y2VwdGlvbihtZXNzYWdlLCBub2RlKSB7XG4gIGxldCBsb2MgPSBub2RlICYmIG5vZGUubG9jLFxuICAgIGxpbmUsXG4gICAgZW5kTGluZU51bWJlcixcbiAgICBjb2x1bW4sXG4gICAgZW5kQ29sdW1uO1xuXG4gIGlmIChsb2MpIHtcbiAgICBsaW5lID0gbG9jLnN0YXJ0LmxpbmU7XG4gICAgZW5kTGluZU51bWJlciA9IGxvYy5lbmQubGluZTtcbiAgICBjb2x1bW4gPSBsb2Muc3RhcnQuY29sdW1uO1xuICAgIGVuZENvbHVtbiA9IGxvYy5lbmQuY29sdW1uO1xuXG4gICAgbWVzc2FnZSArPSAnIC0gJyArIGxpbmUgKyAnOicgKyBjb2x1bW47XG4gIH1cblxuICBsZXQgdG1wID0gRXJyb3IucHJvdG90eXBlLmNvbnN0cnVjdG9yLmNhbGwodGhpcywgbWVzc2FnZSk7XG5cbiAgLy8gVW5mb3J0dW5hdGVseSBlcnJvcnMgYXJlIG5vdCBlbnVtZXJhYmxlIGluIENocm9tZSAoYXQgbGVhc3QpLCBzbyBgZm9yIHByb3AgaW4gdG1wYCBkb2Vzbid0IHdvcmsuXG4gIGZvciAobGV0IGlkeCA9IDA7IGlkeCA8IGVycm9yUHJvcHMubGVuZ3RoOyBpZHgrKykge1xuICAgIHRoaXNbZXJyb3JQcm9wc1tpZHhdXSA9IHRtcFtlcnJvclByb3BzW2lkeF1dO1xuICB9XG5cbiAgLyogaXN0YW5idWwgaWdub3JlIGVsc2UgKi9cbiAgaWYgKEVycm9yLmNhcHR1cmVTdGFja1RyYWNlKSB7XG4gICAgRXJyb3IuY2FwdHVyZVN0YWNrVHJhY2UodGhpcywgRXhjZXB0aW9uKTtcbiAgfVxuXG4gIHRyeSB7XG4gICAgaWYgKGxvYykge1xuICAgICAgdGhpcy5saW5lTnVtYmVyID0gbGluZTtcbiAgICAgIHRoaXMuZW5kTGluZU51bWJlciA9IGVuZExpbmVOdW1iZXI7XG5cbiAgICAgIC8vIFdvcmsgYXJvdW5kIGlzc3VlIHVuZGVyIHNhZmFyaSB3aGVyZSB3ZSBjYW4ndCBkaXJlY3RseSBzZXQgdGhlIGNvbHVtbiB2YWx1ZVxuICAgICAgLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbiAgICAgIGlmIChPYmplY3QuZGVmaW5lUHJvcGVydHkpIHtcbiAgICAgICAgT2JqZWN0LmRlZmluZVByb3BlcnR5KHRoaXMsICdjb2x1bW4nLCB7XG4gICAgICAgICAgdmFsdWU6IGNvbHVtbixcbiAgICAgICAgICBlbnVtZXJhYmxlOiB0cnVlXG4gICAgICAgIH0pO1xuICAgICAgICBPYmplY3QuZGVmaW5lUHJvcGVydHkodGhpcywgJ2VuZENvbHVtbicsIHtcbiAgICAgICAgICB2YWx1ZTogZW5kQ29sdW1uLFxuICAgICAgICAgIGVudW1lcmFibGU6IHRydWVcbiAgICAgICAgfSk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmNvbHVtbiA9IGNvbHVtbjtcbiAgICAgICAgdGhpcy5lbmRDb2x1bW4gPSBlbmRDb2x1bW47XG4gICAgICB9XG4gICAgfVxuICB9IGNhdGNoIChub3ApIHtcbiAgICAvKiBJZ25vcmUgaWYgdGhlIGJyb3dzZXIgaXMgdmVyeSBwYXJ0aWN1bGFyICovXG4gIH1cbn1cblxuRXhjZXB0aW9uLnByb3RvdHlwZSA9IG5ldyBFcnJvcigpO1xuXG5leHBvcnQgZGVmYXVsdCBFeGNlcHRpb247XG4iXX0=


/***/ }),

/***/ 638:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.registerDefaultHelpers = registerDefaultHelpers;
exports.moveHelperToHooks = moveHelperToHooks;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _helpersBlockHelperMissing = __webpack_require__(342);

var _helpersBlockHelperMissing2 = _interopRequireDefault(_helpersBlockHelperMissing);

var _helpersEach = __webpack_require__(822);

var _helpersEach2 = _interopRequireDefault(_helpersEach);

var _helpersHelperMissing = __webpack_require__(909);

var _helpersHelperMissing2 = _interopRequireDefault(_helpersHelperMissing);

var _helpersIf = __webpack_require__(405);

var _helpersIf2 = _interopRequireDefault(_helpersIf);

var _helpersLog = __webpack_require__(702);

var _helpersLog2 = _interopRequireDefault(_helpersLog);

var _helpersLookup = __webpack_require__(593);

var _helpersLookup2 = _interopRequireDefault(_helpersLookup);

var _helpersWith = __webpack_require__(978);

var _helpersWith2 = _interopRequireDefault(_helpersWith);

function registerDefaultHelpers(instance) {
  _helpersBlockHelperMissing2['default'](instance);
  _helpersEach2['default'](instance);
  _helpersHelperMissing2['default'](instance);
  _helpersIf2['default'](instance);
  _helpersLog2['default'](instance);
  _helpersLookup2['default'](instance);
  _helpersWith2['default'](instance);
}

function moveHelperToHooks(instance, helperName, keepHelper) {
  if (instance.helpers[helperName]) {
    instance.hooks[helperName] = instance.helpers[helperName];
    if (!keepHelper) {
      delete instance.helpers[helperName];
    }
  }
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7O3lDQUF1QyxnQ0FBZ0M7Ozs7MkJBQzlDLGdCQUFnQjs7OztvQ0FDUCwwQkFBMEI7Ozs7eUJBQ3JDLGNBQWM7Ozs7MEJBQ2IsZUFBZTs7Ozs2QkFDWixrQkFBa0I7Ozs7MkJBQ3BCLGdCQUFnQjs7OztBQUVsQyxTQUFTLHNCQUFzQixDQUFDLFFBQVEsRUFBRTtBQUMvQyx5Q0FBMkIsUUFBUSxDQUFDLENBQUM7QUFDckMsMkJBQWEsUUFBUSxDQUFDLENBQUM7QUFDdkIsb0NBQXNCLFFBQVEsQ0FBQyxDQUFDO0FBQ2hDLHlCQUFXLFFBQVEsQ0FBQyxDQUFDO0FBQ3JCLDBCQUFZLFFBQVEsQ0FBQyxDQUFDO0FBQ3RCLDZCQUFlLFFBQVEsQ0FBQyxDQUFDO0FBQ3pCLDJCQUFhLFFBQVEsQ0FBQyxDQUFDO0NBQ3hCOztBQUVNLFNBQVMsaUJBQWlCLENBQUMsUUFBUSxFQUFFLFVBQVUsRUFBRSxVQUFVLEVBQUU7QUFDbEUsTUFBSSxRQUFRLENBQUMsT0FBTyxDQUFDLFVBQVUsQ0FBQyxFQUFFO0FBQ2hDLFlBQVEsQ0FBQyxLQUFLLENBQUMsVUFBVSxDQUFDLEdBQUcsUUFBUSxDQUFDLE9BQU8sQ0FBQyxVQUFVLENBQUMsQ0FBQztBQUMxRCxRQUFJLENBQUMsVUFBVSxFQUFFO0FBQ2YsYUFBTyxRQUFRLENBQUMsT0FBTyxDQUFDLFVBQVUsQ0FBQyxDQUFDO0tBQ3JDO0dBQ0Y7Q0FDRiIsImZpbGUiOiJoZWxwZXJzLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHJlZ2lzdGVyQmxvY2tIZWxwZXJNaXNzaW5nIGZyb20gJy4vaGVscGVycy9ibG9jay1oZWxwZXItbWlzc2luZyc7XG5pbXBvcnQgcmVnaXN0ZXJFYWNoIGZyb20gJy4vaGVscGVycy9lYWNoJztcbmltcG9ydCByZWdpc3RlckhlbHBlck1pc3NpbmcgZnJvbSAnLi9oZWxwZXJzL2hlbHBlci1taXNzaW5nJztcbmltcG9ydCByZWdpc3RlcklmIGZyb20gJy4vaGVscGVycy9pZic7XG5pbXBvcnQgcmVnaXN0ZXJMb2cgZnJvbSAnLi9oZWxwZXJzL2xvZyc7XG5pbXBvcnQgcmVnaXN0ZXJMb29rdXAgZnJvbSAnLi9oZWxwZXJzL2xvb2t1cCc7XG5pbXBvcnQgcmVnaXN0ZXJXaXRoIGZyb20gJy4vaGVscGVycy93aXRoJztcblxuZXhwb3J0IGZ1bmN0aW9uIHJlZ2lzdGVyRGVmYXVsdEhlbHBlcnMoaW5zdGFuY2UpIHtcbiAgcmVnaXN0ZXJCbG9ja0hlbHBlck1pc3NpbmcoaW5zdGFuY2UpO1xuICByZWdpc3RlckVhY2goaW5zdGFuY2UpO1xuICByZWdpc3RlckhlbHBlck1pc3NpbmcoaW5zdGFuY2UpO1xuICByZWdpc3RlcklmKGluc3RhbmNlKTtcbiAgcmVnaXN0ZXJMb2coaW5zdGFuY2UpO1xuICByZWdpc3Rlckxvb2t1cChpbnN0YW5jZSk7XG4gIHJlZ2lzdGVyV2l0aChpbnN0YW5jZSk7XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBtb3ZlSGVscGVyVG9Ib29rcyhpbnN0YW5jZSwgaGVscGVyTmFtZSwga2VlcEhlbHBlcikge1xuICBpZiAoaW5zdGFuY2UuaGVscGVyc1toZWxwZXJOYW1lXSkge1xuICAgIGluc3RhbmNlLmhvb2tzW2hlbHBlck5hbWVdID0gaW5zdGFuY2UuaGVscGVyc1toZWxwZXJOYW1lXTtcbiAgICBpZiAoIWtlZXBIZWxwZXIpIHtcbiAgICAgIGRlbGV0ZSBpbnN0YW5jZS5oZWxwZXJzW2hlbHBlck5hbWVdO1xuICAgIH1cbiAgfVxufVxuIl19


/***/ }),

/***/ 342:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(392);

exports["default"] = function (instance) {
  instance.registerHelper('blockHelperMissing', function (context, options) {
    var inverse = options.inverse,
        fn = options.fn;

    if (context === true) {
      return fn(this);
    } else if (context === false || context == null) {
      return inverse(this);
    } else if (_utils.isArray(context)) {
      if (context.length > 0) {
        if (options.ids) {
          options.ids = [options.name];
        }

        return instance.helpers.each(context, options);
      } else {
        return inverse(this);
      }
    } else {
      if (options.data && options.ids) {
        var data = _utils.createFrame(options.data);
        data.contextPath = _utils.appendContextPath(options.data.contextPath, options.name);
        options = { data: data };
      }

      return fn(context, options);
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvYmxvY2staGVscGVyLW1pc3NpbmcuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7OztxQkFBd0QsVUFBVTs7cUJBRW5ELFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsb0JBQW9CLEVBQUUsVUFBUyxPQUFPLEVBQUUsT0FBTyxFQUFFO0FBQ3ZFLFFBQUksT0FBTyxHQUFHLE9BQU8sQ0FBQyxPQUFPO1FBQzNCLEVBQUUsR0FBRyxPQUFPLENBQUMsRUFBRSxDQUFDOztBQUVsQixRQUFJLE9BQU8sS0FBSyxJQUFJLEVBQUU7QUFDcEIsYUFBTyxFQUFFLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDakIsTUFBTSxJQUFJLE9BQU8sS0FBSyxLQUFLLElBQUksT0FBTyxJQUFJLElBQUksRUFBRTtBQUMvQyxhQUFPLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUN0QixNQUFNLElBQUksZUFBUSxPQUFPLENBQUMsRUFBRTtBQUMzQixVQUFJLE9BQU8sQ0FBQyxNQUFNLEdBQUcsQ0FBQyxFQUFFO0FBQ3RCLFlBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUNmLGlCQUFPLENBQUMsR0FBRyxHQUFHLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO1NBQzlCOztBQUVELGVBQU8sUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO09BQ2hELE1BQU07QUFDTCxlQUFPLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztPQUN0QjtLQUNGLE1BQU07QUFDTCxVQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUMvQixZQUFJLElBQUksR0FBRyxtQkFBWSxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7QUFDckMsWUFBSSxDQUFDLFdBQVcsR0FBRyx5QkFDakIsT0FBTyxDQUFDLElBQUksQ0FBQyxXQUFXLEVBQ3hCLE9BQU8sQ0FBQyxJQUFJLENBQ2IsQ0FBQztBQUNGLGVBQU8sR0FBRyxFQUFFLElBQUksRUFBRSxJQUFJLEVBQUUsQ0FBQztPQUMxQjs7QUFFRCxhQUFPLEVBQUUsQ0FBQyxPQUFPLEVBQUUsT0FBTyxDQUFDLENBQUM7S0FDN0I7R0FDRixDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJibG9jay1oZWxwZXItbWlzc2luZy5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IGFwcGVuZENvbnRleHRQYXRoLCBjcmVhdGVGcmFtZSwgaXNBcnJheSB9IGZyb20gJy4uL3V0aWxzJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2Jsb2NrSGVscGVyTWlzc2luZycsIGZ1bmN0aW9uKGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBsZXQgaW52ZXJzZSA9IG9wdGlvbnMuaW52ZXJzZSxcbiAgICAgIGZuID0gb3B0aW9ucy5mbjtcblxuICAgIGlmIChjb250ZXh0ID09PSB0cnVlKSB7XG4gICAgICByZXR1cm4gZm4odGhpcyk7XG4gICAgfSBlbHNlIGlmIChjb250ZXh0ID09PSBmYWxzZSB8fCBjb250ZXh0ID09IG51bGwpIHtcbiAgICAgIHJldHVybiBpbnZlcnNlKHRoaXMpO1xuICAgIH0gZWxzZSBpZiAoaXNBcnJheShjb250ZXh0KSkge1xuICAgICAgaWYgKGNvbnRleHQubGVuZ3RoID4gMCkge1xuICAgICAgICBpZiAob3B0aW9ucy5pZHMpIHtcbiAgICAgICAgICBvcHRpb25zLmlkcyA9IFtvcHRpb25zLm5hbWVdO1xuICAgICAgICB9XG5cbiAgICAgICAgcmV0dXJuIGluc3RhbmNlLmhlbHBlcnMuZWFjaChjb250ZXh0LCBvcHRpb25zKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHJldHVybiBpbnZlcnNlKHRoaXMpO1xuICAgICAgfVxuICAgIH0gZWxzZSB7XG4gICAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIGxldCBkYXRhID0gY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IGFwcGVuZENvbnRleHRQYXRoKFxuICAgICAgICAgIG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCxcbiAgICAgICAgICBvcHRpb25zLm5hbWVcbiAgICAgICAgKTtcbiAgICAgICAgb3B0aW9ucyA9IHsgZGF0YTogZGF0YSB9O1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gZm4oY29udGV4dCwgb3B0aW9ucyk7XG4gICAgfVxuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ 822:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(392);

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

exports["default"] = function (instance) {
  instance.registerHelper('each', function (context, options) {
    if (!options) {
      throw new _exception2['default']('Must pass iterator to #each');
    }

    var fn = options.fn,
        inverse = options.inverse,
        i = 0,
        ret = '',
        data = undefined,
        contextPath = undefined;

    if (options.data && options.ids) {
      contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]) + '.';
    }

    if (_utils.isFunction(context)) {
      context = context.call(this);
    }

    if (options.data) {
      data = _utils.createFrame(options.data);
    }

    function execIteration(field, index, last) {
      if (data) {
        data.key = field;
        data.index = index;
        data.first = index === 0;
        data.last = !!last;

        if (contextPath) {
          data.contextPath = contextPath + field;
        }
      }

      ret = ret + fn(context[field], {
        data: data,
        blockParams: _utils.blockParams([context[field], field], [contextPath + field, null])
      });
    }

    if (context && typeof context === 'object') {
      if (_utils.isArray(context)) {
        for (var j = context.length; i < j; i++) {
          if (i in context) {
            execIteration(i, i, i === context.length - 1);
          }
        }
      } else if (__webpack_require__.g.Symbol && context[__webpack_require__.g.Symbol.iterator]) {
        var newContext = [];
        var iterator = context[__webpack_require__.g.Symbol.iterator]();
        for (var it = iterator.next(); !it.done; it = iterator.next()) {
          newContext.push(it.value);
        }
        context = newContext;
        for (var j = context.length; i < j; i++) {
          execIteration(i, i, i === context.length - 1);
        }
      } else {
        (function () {
          var priorKey = undefined;

          Object.keys(context).forEach(function (key) {
            // We're running the iterations one step out of sync so we can detect
            // the last iteration without have to scan the object twice and create
            // an itermediate keys array.
            if (priorKey !== undefined) {
              execIteration(priorKey, i - 1);
            }
            priorKey = key;
            i++;
          });
          if (priorKey !== undefined) {
            execIteration(priorKey, i - 1, true);
          }
        })();
      }
    }

    if (i === 0) {
      ret = inverse(this);
    }

    return ret;
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvZWFjaC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7Ozs7O3FCQU1PLFVBQVU7O3lCQUNLLGNBQWM7Ozs7cUJBRXJCLFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsTUFBTSxFQUFFLFVBQVMsT0FBTyxFQUFFLE9BQU8sRUFBRTtBQUN6RCxRQUFJLENBQUMsT0FBTyxFQUFFO0FBQ1osWUFBTSwyQkFBYyw2QkFBNkIsQ0FBQyxDQUFDO0tBQ3BEOztBQUVELFFBQUksRUFBRSxHQUFHLE9BQU8sQ0FBQyxFQUFFO1FBQ2pCLE9BQU8sR0FBRyxPQUFPLENBQUMsT0FBTztRQUN6QixDQUFDLEdBQUcsQ0FBQztRQUNMLEdBQUcsR0FBRyxFQUFFO1FBQ1IsSUFBSSxZQUFBO1FBQ0osV0FBVyxZQUFBLENBQUM7O0FBRWQsUUFBSSxPQUFPLENBQUMsSUFBSSxJQUFJLE9BQU8sQ0FBQyxHQUFHLEVBQUU7QUFDL0IsaUJBQVcsR0FDVCx5QkFBa0IsT0FBTyxDQUFDLElBQUksQ0FBQyxXQUFXLEVBQUUsT0FBTyxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUMsQ0FBQyxHQUFHLEdBQUcsQ0FBQztLQUNyRTs7QUFFRCxRQUFJLGtCQUFXLE9BQU8sQ0FBQyxFQUFFO0FBQ3ZCLGFBQU8sR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQzlCOztBQUVELFFBQUksT0FBTyxDQUFDLElBQUksRUFBRTtBQUNoQixVQUFJLEdBQUcsbUJBQVksT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQ2xDOztBQUVELGFBQVMsYUFBYSxDQUFDLEtBQUssRUFBRSxLQUFLLEVBQUUsSUFBSSxFQUFFO0FBQ3pDLFVBQUksSUFBSSxFQUFFO0FBQ1IsWUFBSSxDQUFDLEdBQUcsR0FBRyxLQUFLLENBQUM7QUFDakIsWUFBSSxDQUFDLEtBQUssR0FBRyxLQUFLLENBQUM7QUFDbkIsWUFBSSxDQUFDLEtBQUssR0FBRyxLQUFLLEtBQUssQ0FBQyxDQUFDO0FBQ3pCLFlBQUksQ0FBQyxJQUFJLEdBQUcsQ0FBQyxDQUFDLElBQUksQ0FBQzs7QUFFbkIsWUFBSSxXQUFXLEVBQUU7QUFDZixjQUFJLENBQUMsV0FBVyxHQUFHLFdBQVcsR0FBRyxLQUFLLENBQUM7U0FDeEM7T0FDRjs7QUFFRCxTQUFHLEdBQ0QsR0FBRyxHQUNILEVBQUUsQ0FBQyxPQUFPLENBQUMsS0FBSyxDQUFDLEVBQUU7QUFDakIsWUFBSSxFQUFFLElBQUk7QUFDVixtQkFBVyxFQUFFLG1CQUNYLENBQUMsT0FBTyxDQUFDLEtBQUssQ0FBQyxFQUFFLEtBQUssQ0FBQyxFQUN2QixDQUFDLFdBQVcsR0FBRyxLQUFLLEVBQUUsSUFBSSxDQUFDLENBQzVCO09BQ0YsQ0FBQyxDQUFDO0tBQ047O0FBRUQsUUFBSSxPQUFPLElBQUksT0FBTyxPQUFPLEtBQUssUUFBUSxFQUFFO0FBQzFDLFVBQUksZUFBUSxPQUFPLENBQUMsRUFBRTtBQUNwQixhQUFLLElBQUksQ0FBQyxHQUFHLE9BQU8sQ0FBQyxNQUFNLEVBQUUsQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUN2QyxjQUFJLENBQUMsSUFBSSxPQUFPLEVBQUU7QUFDaEIseUJBQWEsQ0FBQyxDQUFDLEVBQUUsQ0FBQyxFQUFFLENBQUMsS0FBSyxPQUFPLENBQUMsTUFBTSxHQUFHLENBQUMsQ0FBQyxDQUFDO1dBQy9DO1NBQ0Y7T0FDRixNQUFNLElBQUksTUFBTSxDQUFDLE1BQU0sSUFBSSxPQUFPLENBQUMsTUFBTSxDQUFDLE1BQU0sQ0FBQyxRQUFRLENBQUMsRUFBRTtBQUMzRCxZQUFNLFVBQVUsR0FBRyxFQUFFLENBQUM7QUFDdEIsWUFBTSxRQUFRLEdBQUcsT0FBTyxDQUFDLE1BQU0sQ0FBQyxNQUFNLENBQUMsUUFBUSxDQUFDLEVBQUUsQ0FBQztBQUNuRCxhQUFLLElBQUksRUFBRSxHQUFHLFFBQVEsQ0FBQyxJQUFJLEVBQUUsRUFBRSxDQUFDLEVBQUUsQ0FBQyxJQUFJLEVBQUUsRUFBRSxHQUFHLFFBQVEsQ0FBQyxJQUFJLEVBQUUsRUFBRTtBQUM3RCxvQkFBVSxDQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsS0FBSyxDQUFDLENBQUM7U0FDM0I7QUFDRCxlQUFPLEdBQUcsVUFBVSxDQUFDO0FBQ3JCLGFBQUssSUFBSSxDQUFDLEdBQUcsT0FBTyxDQUFDLE1BQU0sRUFBRSxDQUFDLEdBQUcsQ0FBQyxFQUFFLENBQUMsRUFBRSxFQUFFO0FBQ3ZDLHVCQUFhLENBQUMsQ0FBQyxFQUFFLENBQUMsRUFBRSxDQUFDLEtBQUssT0FBTyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQztTQUMvQztPQUNGLE1BQU07O0FBQ0wsY0FBSSxRQUFRLFlBQUEsQ0FBQzs7QUFFYixnQkFBTSxDQUFDLElBQUksQ0FBQyxPQUFPLENBQUMsQ0FBQyxPQUFPLENBQUMsVUFBQSxHQUFHLEVBQUk7Ozs7QUFJbEMsZ0JBQUksUUFBUSxLQUFLLFNBQVMsRUFBRTtBQUMxQiwyQkFBYSxDQUFDLFFBQVEsRUFBRSxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUM7YUFDaEM7QUFDRCxvQkFBUSxHQUFHLEdBQUcsQ0FBQztBQUNmLGFBQUMsRUFBRSxDQUFDO1dBQ0wsQ0FBQyxDQUFDO0FBQ0gsY0FBSSxRQUFRLEtBQUssU0FBUyxFQUFFO0FBQzFCLHlCQUFhLENBQUMsUUFBUSxFQUFFLENBQUMsR0FBRyxDQUFDLEVBQUUsSUFBSSxDQUFDLENBQUM7V0FDdEM7O09BQ0Y7S0FDRjs7QUFFRCxRQUFJLENBQUMsS0FBSyxDQUFDLEVBQUU7QUFDWCxTQUFHLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQ3JCOztBQUVELFdBQU8sR0FBRyxDQUFDO0dBQ1osQ0FBQyxDQUFDO0NBQ0oiLCJmaWxlIjoiZWFjaC5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7XG4gIGFwcGVuZENvbnRleHRQYXRoLFxuICBibG9ja1BhcmFtcyxcbiAgY3JlYXRlRnJhbWUsXG4gIGlzQXJyYXksXG4gIGlzRnVuY3Rpb25cbn0gZnJvbSAnLi4vdXRpbHMnO1xuaW1wb3J0IEV4Y2VwdGlvbiBmcm9tICcuLi9leGNlcHRpb24nO1xuXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbihpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignZWFjaCcsIGZ1bmN0aW9uKGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAoIW9wdGlvbnMpIHtcbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ011c3QgcGFzcyBpdGVyYXRvciB0byAjZWFjaCcpO1xuICAgIH1cblxuICAgIGxldCBmbiA9IG9wdGlvbnMuZm4sXG4gICAgICBpbnZlcnNlID0gb3B0aW9ucy5pbnZlcnNlLFxuICAgICAgaSA9IDAsXG4gICAgICByZXQgPSAnJyxcbiAgICAgIGRhdGEsXG4gICAgICBjb250ZXh0UGF0aDtcblxuICAgIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5pZHMpIHtcbiAgICAgIGNvbnRleHRQYXRoID1cbiAgICAgICAgYXBwZW5kQ29udGV4dFBhdGgob3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoLCBvcHRpb25zLmlkc1swXSkgKyAnLic7XG4gICAgfVxuXG4gICAgaWYgKGlzRnVuY3Rpb24oY29udGV4dCkpIHtcbiAgICAgIGNvbnRleHQgPSBjb250ZXh0LmNhbGwodGhpcyk7XG4gICAgfVxuXG4gICAgaWYgKG9wdGlvbnMuZGF0YSkge1xuICAgICAgZGF0YSA9IGNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gZXhlY0l0ZXJhdGlvbihmaWVsZCwgaW5kZXgsIGxhc3QpIHtcbiAgICAgIGlmIChkYXRhKSB7XG4gICAgICAgIGRhdGEua2V5ID0gZmllbGQ7XG4gICAgICAgIGRhdGEuaW5kZXggPSBpbmRleDtcbiAgICAgICAgZGF0YS5maXJzdCA9IGluZGV4ID09PSAwO1xuICAgICAgICBkYXRhLmxhc3QgPSAhIWxhc3Q7XG5cbiAgICAgICAgaWYgKGNvbnRleHRQYXRoKSB7XG4gICAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IGNvbnRleHRQYXRoICsgZmllbGQ7XG4gICAgICAgIH1cbiAgICAgIH1cblxuICAgICAgcmV0ID1cbiAgICAgICAgcmV0ICtcbiAgICAgICAgZm4oY29udGV4dFtmaWVsZF0sIHtcbiAgICAgICAgICBkYXRhOiBkYXRhLFxuICAgICAgICAgIGJsb2NrUGFyYW1zOiBibG9ja1BhcmFtcyhcbiAgICAgICAgICAgIFtjb250ZXh0W2ZpZWxkXSwgZmllbGRdLFxuICAgICAgICAgICAgW2NvbnRleHRQYXRoICsgZmllbGQsIG51bGxdXG4gICAgICAgICAgKVxuICAgICAgICB9KTtcbiAgICB9XG5cbiAgICBpZiAoY29udGV4dCAmJiB0eXBlb2YgY29udGV4dCA9PT0gJ29iamVjdCcpIHtcbiAgICAgIGlmIChpc0FycmF5KGNvbnRleHQpKSB7XG4gICAgICAgIGZvciAobGV0IGogPSBjb250ZXh0Lmxlbmd0aDsgaSA8IGo7IGkrKykge1xuICAgICAgICAgIGlmIChpIGluIGNvbnRleHQpIHtcbiAgICAgICAgICAgIGV4ZWNJdGVyYXRpb24oaSwgaSwgaSA9PT0gY29udGV4dC5sZW5ndGggLSAxKTtcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSBpZiAoZ2xvYmFsLlN5bWJvbCAmJiBjb250ZXh0W2dsb2JhbC5TeW1ib2wuaXRlcmF0b3JdKSB7XG4gICAgICAgIGNvbnN0IG5ld0NvbnRleHQgPSBbXTtcbiAgICAgICAgY29uc3QgaXRlcmF0b3IgPSBjb250ZXh0W2dsb2JhbC5TeW1ib2wuaXRlcmF0b3JdKCk7XG4gICAgICAgIGZvciAobGV0IGl0ID0gaXRlcmF0b3IubmV4dCgpOyAhaXQuZG9uZTsgaXQgPSBpdGVyYXRvci5uZXh0KCkpIHtcbiAgICAgICAgICBuZXdDb250ZXh0LnB1c2goaXQudmFsdWUpO1xuICAgICAgICB9XG4gICAgICAgIGNvbnRleHQgPSBuZXdDb250ZXh0O1xuICAgICAgICBmb3IgKGxldCBqID0gY29udGV4dC5sZW5ndGg7IGkgPCBqOyBpKyspIHtcbiAgICAgICAgICBleGVjSXRlcmF0aW9uKGksIGksIGkgPT09IGNvbnRleHQubGVuZ3RoIC0gMSk7XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGxldCBwcmlvcktleTtcblxuICAgICAgICBPYmplY3Qua2V5cyhjb250ZXh0KS5mb3JFYWNoKGtleSA9PiB7XG4gICAgICAgICAgLy8gV2UncmUgcnVubmluZyB0aGUgaXRlcmF0aW9ucyBvbmUgc3RlcCBvdXQgb2Ygc3luYyBzbyB3ZSBjYW4gZGV0ZWN0XG4gICAgICAgICAgLy8gdGhlIGxhc3QgaXRlcmF0aW9uIHdpdGhvdXQgaGF2ZSB0byBzY2FuIHRoZSBvYmplY3QgdHdpY2UgYW5kIGNyZWF0ZVxuICAgICAgICAgIC8vIGFuIGl0ZXJtZWRpYXRlIGtleXMgYXJyYXkuXG4gICAgICAgICAgaWYgKHByaW9yS2V5ICE9PSB1bmRlZmluZWQpIHtcbiAgICAgICAgICAgIGV4ZWNJdGVyYXRpb24ocHJpb3JLZXksIGkgLSAxKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcHJpb3JLZXkgPSBrZXk7XG4gICAgICAgICAgaSsrO1xuICAgICAgICB9KTtcbiAgICAgICAgaWYgKHByaW9yS2V5ICE9PSB1bmRlZmluZWQpIHtcbiAgICAgICAgICBleGVjSXRlcmF0aW9uKHByaW9yS2V5LCBpIC0gMSwgdHJ1ZSk7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG5cbiAgICBpZiAoaSA9PT0gMCkge1xuICAgICAgcmV0ID0gaW52ZXJzZSh0aGlzKTtcbiAgICB9XG5cbiAgICByZXR1cm4gcmV0O1xuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ 909:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

exports["default"] = function (instance) {
  instance.registerHelper('helperMissing', function () /* [args, ]options */{
    if (arguments.length === 1) {
      // A missing field in a {{foo}} construct.
      return undefined;
    } else {
      // Someone is actually trying to call something, blow up.
      throw new _exception2['default']('Missing helper: "' + arguments[arguments.length - 1].name + '"');
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvaGVscGVyLW1pc3NpbmcuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozt5QkFBc0IsY0FBYzs7OztxQkFFckIsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxlQUFlLEVBQUUsaUNBQWdDO0FBQ3ZFLFFBQUksU0FBUyxDQUFDLE1BQU0sS0FBSyxDQUFDLEVBQUU7O0FBRTFCLGFBQU8sU0FBUyxDQUFDO0tBQ2xCLE1BQU07O0FBRUwsWUFBTSwyQkFDSixtQkFBbUIsR0FBRyxTQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQyxJQUFJLEdBQUcsR0FBRyxDQUNqRSxDQUFDO0tBQ0g7R0FDRixDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJoZWxwZXItbWlzc2luZy5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCBFeGNlcHRpb24gZnJvbSAnLi4vZXhjZXB0aW9uJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2hlbHBlck1pc3NpbmcnLCBmdW5jdGlvbigvKiBbYXJncywgXW9wdGlvbnMgKi8pIHtcbiAgICBpZiAoYXJndW1lbnRzLmxlbmd0aCA9PT0gMSkge1xuICAgICAgLy8gQSBtaXNzaW5nIGZpZWxkIGluIGEge3tmb299fSBjb25zdHJ1Y3QuXG4gICAgICByZXR1cm4gdW5kZWZpbmVkO1xuICAgIH0gZWxzZSB7XG4gICAgICAvLyBTb21lb25lIGlzIGFjdHVhbGx5IHRyeWluZyB0byBjYWxsIHNvbWV0aGluZywgYmxvdyB1cC5cbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oXG4gICAgICAgICdNaXNzaW5nIGhlbHBlcjogXCInICsgYXJndW1lbnRzW2FyZ3VtZW50cy5sZW5ndGggLSAxXS5uYW1lICsgJ1wiJ1xuICAgICAgKTtcbiAgICB9XG4gIH0pO1xufVxuIl19


/***/ }),

/***/ 405:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(392);

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

exports["default"] = function (instance) {
  instance.registerHelper('if', function (conditional, options) {
    if (arguments.length != 2) {
      throw new _exception2['default']('#if requires exactly one argument');
    }
    if (_utils.isFunction(conditional)) {
      conditional = conditional.call(this);
    }

    // Default behavior is to render the positive path if the value is truthy and not empty.
    // The `includeZero` option may be set to treat the condtional as purely not empty based on the
    // behavior of isEmpty. Effectively this determines if 0 is handled by the positive path or negative.
    if (!options.hash.includeZero && !conditional || _utils.isEmpty(conditional)) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  });

  instance.registerHelper('unless', function (conditional, options) {
    if (arguments.length != 2) {
      throw new _exception2['default']('#unless requires exactly one argument');
    }
    return instance.helpers['if'].call(this, conditional, {
      fn: options.inverse,
      inverse: options.fn,
      hash: options.hash
    });
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvaWYuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7OztxQkFBb0MsVUFBVTs7eUJBQ3hCLGNBQWM7Ozs7cUJBRXJCLFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsSUFBSSxFQUFFLFVBQVMsV0FBVyxFQUFFLE9BQU8sRUFBRTtBQUMzRCxRQUFJLFNBQVMsQ0FBQyxNQUFNLElBQUksQ0FBQyxFQUFFO0FBQ3pCLFlBQU0sMkJBQWMsbUNBQW1DLENBQUMsQ0FBQztLQUMxRDtBQUNELFFBQUksa0JBQVcsV0FBVyxDQUFDLEVBQUU7QUFDM0IsaUJBQVcsR0FBRyxXQUFXLENBQUMsSUFBSSxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQ3RDOzs7OztBQUtELFFBQUksQUFBQyxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsV0FBVyxJQUFJLENBQUMsV0FBVyxJQUFLLGVBQVEsV0FBVyxDQUFDLEVBQUU7QUFDdkUsYUFBTyxPQUFPLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQzlCLE1BQU07QUFDTCxhQUFPLE9BQU8sQ0FBQyxFQUFFLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDekI7R0FDRixDQUFDLENBQUM7O0FBRUgsVUFBUSxDQUFDLGNBQWMsQ0FBQyxRQUFRLEVBQUUsVUFBUyxXQUFXLEVBQUUsT0FBTyxFQUFFO0FBQy9ELFFBQUksU0FBUyxDQUFDLE1BQU0sSUFBSSxDQUFDLEVBQUU7QUFDekIsWUFBTSwyQkFBYyx1Q0FBdUMsQ0FBQyxDQUFDO0tBQzlEO0FBQ0QsV0FBTyxRQUFRLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLElBQUksQ0FBQyxJQUFJLEVBQUUsV0FBVyxFQUFFO0FBQ3BELFFBQUUsRUFBRSxPQUFPLENBQUMsT0FBTztBQUNuQixhQUFPLEVBQUUsT0FBTyxDQUFDLEVBQUU7QUFDbkIsVUFBSSxFQUFFLE9BQU8sQ0FBQyxJQUFJO0tBQ25CLENBQUMsQ0FBQztHQUNKLENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6ImlmLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgaXNFbXB0eSwgaXNGdW5jdGlvbiB9IGZyb20gJy4uL3V0aWxzJztcbmltcG9ydCBFeGNlcHRpb24gZnJvbSAnLi4vZXhjZXB0aW9uJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2lmJywgZnVuY3Rpb24oY29uZGl0aW9uYWwsIG9wdGlvbnMpIHtcbiAgICBpZiAoYXJndW1lbnRzLmxlbmd0aCAhPSAyKSB7XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCcjaWYgcmVxdWlyZXMgZXhhY3RseSBvbmUgYXJndW1lbnQnKTtcbiAgICB9XG4gICAgaWYgKGlzRnVuY3Rpb24oY29uZGl0aW9uYWwpKSB7XG4gICAgICBjb25kaXRpb25hbCA9IGNvbmRpdGlvbmFsLmNhbGwodGhpcyk7XG4gICAgfVxuXG4gICAgLy8gRGVmYXVsdCBiZWhhdmlvciBpcyB0byByZW5kZXIgdGhlIHBvc2l0aXZlIHBhdGggaWYgdGhlIHZhbHVlIGlzIHRydXRoeSBhbmQgbm90IGVtcHR5LlxuICAgIC8vIFRoZSBgaW5jbHVkZVplcm9gIG9wdGlvbiBtYXkgYmUgc2V0IHRvIHRyZWF0IHRoZSBjb25kdGlvbmFsIGFzIHB1cmVseSBub3QgZW1wdHkgYmFzZWQgb24gdGhlXG4gICAgLy8gYmVoYXZpb3Igb2YgaXNFbXB0eS4gRWZmZWN0aXZlbHkgdGhpcyBkZXRlcm1pbmVzIGlmIDAgaXMgaGFuZGxlZCBieSB0aGUgcG9zaXRpdmUgcGF0aCBvciBuZWdhdGl2ZS5cbiAgICBpZiAoKCFvcHRpb25zLmhhc2guaW5jbHVkZVplcm8gJiYgIWNvbmRpdGlvbmFsKSB8fCBpc0VtcHR5KGNvbmRpdGlvbmFsKSkge1xuICAgICAgcmV0dXJuIG9wdGlvbnMuaW52ZXJzZSh0aGlzKTtcbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIG9wdGlvbnMuZm4odGhpcyk7XG4gICAgfVxuICB9KTtcblxuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcigndW5sZXNzJywgZnVuY3Rpb24oY29uZGl0aW9uYWwsIG9wdGlvbnMpIHtcbiAgICBpZiAoYXJndW1lbnRzLmxlbmd0aCAhPSAyKSB7XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCcjdW5sZXNzIHJlcXVpcmVzIGV4YWN0bHkgb25lIGFyZ3VtZW50Jyk7XG4gICAgfVxuICAgIHJldHVybiBpbnN0YW5jZS5oZWxwZXJzWydpZiddLmNhbGwodGhpcywgY29uZGl0aW9uYWwsIHtcbiAgICAgIGZuOiBvcHRpb25zLmludmVyc2UsXG4gICAgICBpbnZlcnNlOiBvcHRpb25zLmZuLFxuICAgICAgaGFzaDogb3B0aW9ucy5oYXNoXG4gICAgfSk7XG4gIH0pO1xufVxuIl19


/***/ }),

/***/ 702:
/***/ (function(module, exports) {

"use strict";


exports.__esModule = true;

exports["default"] = function (instance) {
  instance.registerHelper('log', function () /* message, options */{
    var args = [undefined],
        options = arguments[arguments.length - 1];
    for (var i = 0; i < arguments.length - 1; i++) {
      args.push(arguments[i]);
    }

    var level = 1;
    if (options.hash.level != null) {
      level = options.hash.level;
    } else if (options.data && options.data.level != null) {
      level = options.data.level;
    }
    args[0] = level;

    instance.log.apply(instance, args);
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvbG9nLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQWUsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxLQUFLLEVBQUUsa0NBQWlDO0FBQzlELFFBQUksSUFBSSxHQUFHLENBQUMsU0FBUyxDQUFDO1FBQ3BCLE9BQU8sR0FBRyxTQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQztBQUM1QyxTQUFLLElBQUksQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEdBQUcsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLEVBQUUsQ0FBQyxFQUFFLEVBQUU7QUFDN0MsVUFBSSxDQUFDLElBQUksQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDLENBQUMsQ0FBQztLQUN6Qjs7QUFFRCxRQUFJLEtBQUssR0FBRyxDQUFDLENBQUM7QUFDZCxRQUFJLE9BQU8sQ0FBQyxJQUFJLENBQUMsS0FBSyxJQUFJLElBQUksRUFBRTtBQUM5QixXQUFLLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxLQUFLLENBQUM7S0FDNUIsTUFBTSxJQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLElBQUksQ0FBQyxLQUFLLElBQUksSUFBSSxFQUFFO0FBQ3JELFdBQUssR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQztLQUM1QjtBQUNELFFBQUksQ0FBQyxDQUFDLENBQUMsR0FBRyxLQUFLLENBQUM7O0FBRWhCLFlBQVEsQ0FBQyxHQUFHLE1BQUEsQ0FBWixRQUFRLEVBQVEsSUFBSSxDQUFDLENBQUM7R0FDdkIsQ0FBQyxDQUFDO0NBQ0oiLCJmaWxlIjoibG9nLmpzIiwic291cmNlc0NvbnRlbnQiOlsiZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2xvZycsIGZ1bmN0aW9uKC8qIG1lc3NhZ2UsIG9wdGlvbnMgKi8pIHtcbiAgICBsZXQgYXJncyA9IFt1bmRlZmluZWRdLFxuICAgICAgb3B0aW9ucyA9IGFyZ3VtZW50c1thcmd1bWVudHMubGVuZ3RoIC0gMV07XG4gICAgZm9yIChsZXQgaSA9IDA7IGkgPCBhcmd1bWVudHMubGVuZ3RoIC0gMTsgaSsrKSB7XG4gICAgICBhcmdzLnB1c2goYXJndW1lbnRzW2ldKTtcbiAgICB9XG5cbiAgICBsZXQgbGV2ZWwgPSAxO1xuICAgIGlmIChvcHRpb25zLmhhc2gubGV2ZWwgIT0gbnVsbCkge1xuICAgICAgbGV2ZWwgPSBvcHRpb25zLmhhc2gubGV2ZWw7XG4gICAgfSBlbHNlIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5kYXRhLmxldmVsICE9IG51bGwpIHtcbiAgICAgIGxldmVsID0gb3B0aW9ucy5kYXRhLmxldmVsO1xuICAgIH1cbiAgICBhcmdzWzBdID0gbGV2ZWw7XG5cbiAgICBpbnN0YW5jZS5sb2coLi4uYXJncyk7XG4gIH0pO1xufVxuIl19


/***/ }),

/***/ 593:
/***/ (function(module, exports) {

"use strict";


exports.__esModule = true;

exports["default"] = function (instance) {
  instance.registerHelper('lookup', function (obj, field, options) {
    if (!obj) {
      // Note for 5.0: Change to "obj == null" in 5.0
      return obj;
    }
    return options.lookupProperty(obj, field);
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvbG9va3VwLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQWUsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxRQUFRLEVBQUUsVUFBUyxHQUFHLEVBQUUsS0FBSyxFQUFFLE9BQU8sRUFBRTtBQUM5RCxRQUFJLENBQUMsR0FBRyxFQUFFOztBQUVSLGFBQU8sR0FBRyxDQUFDO0tBQ1o7QUFDRCxXQUFPLE9BQU8sQ0FBQyxjQUFjLENBQUMsR0FBRyxFQUFFLEtBQUssQ0FBQyxDQUFDO0dBQzNDLENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6Imxvb2t1cC5qcyIsInNvdXJjZXNDb250ZW50IjpbImV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdsb29rdXAnLCBmdW5jdGlvbihvYmosIGZpZWxkLCBvcHRpb25zKSB7XG4gICAgaWYgKCFvYmopIHtcbiAgICAgIC8vIE5vdGUgZm9yIDUuMDogQ2hhbmdlIHRvIFwib2JqID09IG51bGxcIiBpbiA1LjBcbiAgICAgIHJldHVybiBvYmo7XG4gICAgfVxuICAgIHJldHVybiBvcHRpb25zLmxvb2t1cFByb3BlcnR5KG9iaiwgZmllbGQpO1xuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ 978:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(392);

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

exports["default"] = function (instance) {
  instance.registerHelper('with', function (context, options) {
    if (arguments.length != 2) {
      throw new _exception2['default']('#with requires exactly one argument');
    }
    if (_utils.isFunction(context)) {
      context = context.call(this);
    }

    var fn = options.fn;

    if (!_utils.isEmpty(context)) {
      var data = options.data;
      if (options.data && options.ids) {
        data = _utils.createFrame(options.data);
        data.contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]);
      }

      return fn(context, {
        data: data,
        blockParams: _utils.blockParams([context], [data && data.contextPath])
      });
    } else {
      return options.inverse(this);
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvd2l0aC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7Ozs7O3FCQU1PLFVBQVU7O3lCQUNLLGNBQWM7Ozs7cUJBRXJCLFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsTUFBTSxFQUFFLFVBQVMsT0FBTyxFQUFFLE9BQU8sRUFBRTtBQUN6RCxRQUFJLFNBQVMsQ0FBQyxNQUFNLElBQUksQ0FBQyxFQUFFO0FBQ3pCLFlBQU0sMkJBQWMscUNBQXFDLENBQUMsQ0FBQztLQUM1RDtBQUNELFFBQUksa0JBQVcsT0FBTyxDQUFDLEVBQUU7QUFDdkIsYUFBTyxHQUFHLE9BQU8sQ0FBQyxJQUFJLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDOUI7O0FBRUQsUUFBSSxFQUFFLEdBQUcsT0FBTyxDQUFDLEVBQUUsQ0FBQzs7QUFFcEIsUUFBSSxDQUFDLGVBQVEsT0FBTyxDQUFDLEVBQUU7QUFDckIsVUFBSSxJQUFJLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQztBQUN4QixVQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUMvQixZQUFJLEdBQUcsbUJBQVksT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0FBQ2pDLFlBQUksQ0FBQyxXQUFXLEdBQUcseUJBQ2pCLE9BQU8sQ0FBQyxJQUFJLENBQUMsV0FBVyxFQUN4QixPQUFPLENBQUMsR0FBRyxDQUFDLENBQUMsQ0FBQyxDQUNmLENBQUM7T0FDSDs7QUFFRCxhQUFPLEVBQUUsQ0FBQyxPQUFPLEVBQUU7QUFDakIsWUFBSSxFQUFFLElBQUk7QUFDVixtQkFBVyxFQUFFLG1CQUFZLENBQUMsT0FBTyxDQUFDLEVBQUUsQ0FBQyxJQUFJLElBQUksSUFBSSxDQUFDLFdBQVcsQ0FBQyxDQUFDO09BQ2hFLENBQUMsQ0FBQztLQUNKLE1BQU07QUFDTCxhQUFPLE9BQU8sQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDOUI7R0FDRixDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJ3aXRoLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHtcbiAgYXBwZW5kQ29udGV4dFBhdGgsXG4gIGJsb2NrUGFyYW1zLFxuICBjcmVhdGVGcmFtZSxcbiAgaXNFbXB0eSxcbiAgaXNGdW5jdGlvblxufSBmcm9tICcuLi91dGlscyc7XG5pbXBvcnQgRXhjZXB0aW9uIGZyb20gJy4uL2V4Y2VwdGlvbic7XG5cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCd3aXRoJywgZnVuY3Rpb24oY29udGV4dCwgb3B0aW9ucykge1xuICAgIGlmIChhcmd1bWVudHMubGVuZ3RoICE9IDIpIHtcbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJyN3aXRoIHJlcXVpcmVzIGV4YWN0bHkgb25lIGFyZ3VtZW50Jyk7XG4gICAgfVxuICAgIGlmIChpc0Z1bmN0aW9uKGNvbnRleHQpKSB7XG4gICAgICBjb250ZXh0ID0gY29udGV4dC5jYWxsKHRoaXMpO1xuICAgIH1cblxuICAgIGxldCBmbiA9IG9wdGlvbnMuZm47XG5cbiAgICBpZiAoIWlzRW1wdHkoY29udGV4dCkpIHtcbiAgICAgIGxldCBkYXRhID0gb3B0aW9ucy5kYXRhO1xuICAgICAgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmlkcykge1xuICAgICAgICBkYXRhID0gY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IGFwcGVuZENvbnRleHRQYXRoKFxuICAgICAgICAgIG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCxcbiAgICAgICAgICBvcHRpb25zLmlkc1swXVxuICAgICAgICApO1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gZm4oY29udGV4dCwge1xuICAgICAgICBkYXRhOiBkYXRhLFxuICAgICAgICBibG9ja1BhcmFtczogYmxvY2tQYXJhbXMoW2NvbnRleHRdLCBbZGF0YSAmJiBkYXRhLmNvbnRleHRQYXRoXSlcbiAgICAgIH0pO1xuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4gb3B0aW9ucy5pbnZlcnNlKHRoaXMpO1xuICAgIH1cbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ 572:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.createNewLookupObject = createNewLookupObject;

var _utils = __webpack_require__(392);

/**
 * Create a new object with "null"-prototype to avoid truthy results on prototype properties.
 * The resulting object can be used with "object[property]" to check if a property exists
 * @param {...object} sources a varargs parameter of source objects that will be merged
 * @returns {object}
 */

function createNewLookupObject() {
  for (var _len = arguments.length, sources = Array(_len), _key = 0; _key < _len; _key++) {
    sources[_key] = arguments[_key];
  }

  return _utils.extend.apply(undefined, [Object.create(null)].concat(sources));
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2ludGVybmFsL2NyZWF0ZS1uZXctbG9va3VwLW9iamVjdC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7OztxQkFBdUIsVUFBVTs7Ozs7Ozs7O0FBUTFCLFNBQVMscUJBQXFCLEdBQWE7b0NBQVQsT0FBTztBQUFQLFdBQU87OztBQUM5QyxTQUFPLGdDQUFPLE1BQU0sQ0FBQyxNQUFNLENBQUMsSUFBSSxDQUFDLFNBQUssT0FBTyxFQUFDLENBQUM7Q0FDaEQiLCJmaWxlIjoiY3JlYXRlLW5ldy1sb29rdXAtb2JqZWN0LmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgZXh0ZW5kIH0gZnJvbSAnLi4vdXRpbHMnO1xuXG4vKipcbiAqIENyZWF0ZSBhIG5ldyBvYmplY3Qgd2l0aCBcIm51bGxcIi1wcm90b3R5cGUgdG8gYXZvaWQgdHJ1dGh5IHJlc3VsdHMgb24gcHJvdG90eXBlIHByb3BlcnRpZXMuXG4gKiBUaGUgcmVzdWx0aW5nIG9iamVjdCBjYW4gYmUgdXNlZCB3aXRoIFwib2JqZWN0W3Byb3BlcnR5XVwiIHRvIGNoZWNrIGlmIGEgcHJvcGVydHkgZXhpc3RzXG4gKiBAcGFyYW0gey4uLm9iamVjdH0gc291cmNlcyBhIHZhcmFyZ3MgcGFyYW1ldGVyIG9mIHNvdXJjZSBvYmplY3RzIHRoYXQgd2lsbCBiZSBtZXJnZWRcbiAqIEByZXR1cm5zIHtvYmplY3R9XG4gKi9cbmV4cG9ydCBmdW5jdGlvbiBjcmVhdGVOZXdMb29rdXBPYmplY3QoLi4uc291cmNlcykge1xuICByZXR1cm4gZXh0ZW5kKE9iamVjdC5jcmVhdGUobnVsbCksIC4uLnNvdXJjZXMpO1xufVxuIl19


/***/ }),

/***/ 293:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.createProtoAccessControl = createProtoAccessControl;
exports.resultIsAllowed = resultIsAllowed;
exports.resetLoggedProperties = resetLoggedProperties;
// istanbul ignore next

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _createNewLookupObject = __webpack_require__(572);

var _logger = __webpack_require__(37);

var logger = _interopRequireWildcard(_logger);

var loggedProperties = Object.create(null);

function createProtoAccessControl(runtimeOptions) {
  var defaultMethodWhiteList = Object.create(null);
  defaultMethodWhiteList['constructor'] = false;
  defaultMethodWhiteList['__defineGetter__'] = false;
  defaultMethodWhiteList['__defineSetter__'] = false;
  defaultMethodWhiteList['__lookupGetter__'] = false;

  var defaultPropertyWhiteList = Object.create(null);
  // eslint-disable-next-line no-proto
  defaultPropertyWhiteList['__proto__'] = false;

  return {
    properties: {
      whitelist: _createNewLookupObject.createNewLookupObject(defaultPropertyWhiteList, runtimeOptions.allowedProtoProperties),
      defaultValue: runtimeOptions.allowProtoPropertiesByDefault
    },
    methods: {
      whitelist: _createNewLookupObject.createNewLookupObject(defaultMethodWhiteList, runtimeOptions.allowedProtoMethods),
      defaultValue: runtimeOptions.allowProtoMethodsByDefault
    }
  };
}

function resultIsAllowed(result, protoAccessControl, propertyName) {
  if (typeof result === 'function') {
    return checkWhiteList(protoAccessControl.methods, propertyName);
  } else {
    return checkWhiteList(protoAccessControl.properties, propertyName);
  }
}

function checkWhiteList(protoAccessControlForType, propertyName) {
  if (protoAccessControlForType.whitelist[propertyName] !== undefined) {
    return protoAccessControlForType.whitelist[propertyName] === true;
  }
  if (protoAccessControlForType.defaultValue !== undefined) {
    return protoAccessControlForType.defaultValue;
  }
  logUnexpecedPropertyAccessOnce(propertyName);
  return false;
}

function logUnexpecedPropertyAccessOnce(propertyName) {
  if (loggedProperties[propertyName] !== true) {
    loggedProperties[propertyName] = true;
    logger.log('error', 'Handlebars: Access has been denied to resolve the property "' + propertyName + '" because it is not an "own property" of its parent.\n' + 'You can add a runtime option to disable the check or this warning:\n' + 'See https://handlebarsjs.com/api-reference/runtime-options.html#options-to-control-prototype-access for details');
  }
}

function resetLoggedProperties() {
  Object.keys(loggedProperties).forEach(function (propertyName) {
    delete loggedProperties[propertyName];
  });
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2ludGVybmFsL3Byb3RvLWFjY2Vzcy5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7O3FDQUFzQyw0QkFBNEI7O3NCQUMxQyxXQUFXOztJQUF2QixNQUFNOztBQUVsQixJQUFNLGdCQUFnQixHQUFHLE1BQU0sQ0FBQyxNQUFNLENBQUMsSUFBSSxDQUFDLENBQUM7O0FBRXRDLFNBQVMsd0JBQXdCLENBQUMsY0FBYyxFQUFFO0FBQ3ZELE1BQUksc0JBQXNCLEdBQUcsTUFBTSxDQUFDLE1BQU0sQ0FBQyxJQUFJLENBQUMsQ0FBQztBQUNqRCx3QkFBc0IsQ0FBQyxhQUFhLENBQUMsR0FBRyxLQUFLLENBQUM7QUFDOUMsd0JBQXNCLENBQUMsa0JBQWtCLENBQUMsR0FBRyxLQUFLLENBQUM7QUFDbkQsd0JBQXNCLENBQUMsa0JBQWtCLENBQUMsR0FBRyxLQUFLLENBQUM7QUFDbkQsd0JBQXNCLENBQUMsa0JBQWtCLENBQUMsR0FBRyxLQUFLLENBQUM7O0FBRW5ELE1BQUksd0JBQXdCLEdBQUcsTUFBTSxDQUFDLE1BQU0sQ0FBQyxJQUFJLENBQUMsQ0FBQzs7QUFFbkQsMEJBQXdCLENBQUMsV0FBVyxDQUFDLEdBQUcsS0FBSyxDQUFDOztBQUU5QyxTQUFPO0FBQ0wsY0FBVSxFQUFFO0FBQ1YsZUFBUyxFQUFFLDZDQUNULHdCQUF3QixFQUN4QixjQUFjLENBQUMsc0JBQXNCLENBQ3RDO0FBQ0Qsa0JBQVksRUFBRSxjQUFjLENBQUMsNkJBQTZCO0tBQzNEO0FBQ0QsV0FBTyxFQUFFO0FBQ1AsZUFBUyxFQUFFLDZDQUNULHNCQUFzQixFQUN0QixjQUFjLENBQUMsbUJBQW1CLENBQ25DO0FBQ0Qsa0JBQVksRUFBRSxjQUFjLENBQUMsMEJBQTBCO0tBQ3hEO0dBQ0YsQ0FBQztDQUNIOztBQUVNLFNBQVMsZUFBZSxDQUFDLE1BQU0sRUFBRSxrQkFBa0IsRUFBRSxZQUFZLEVBQUU7QUFDeEUsTUFBSSxPQUFPLE1BQU0sS0FBSyxVQUFVLEVBQUU7QUFDaEMsV0FBTyxjQUFjLENBQUMsa0JBQWtCLENBQUMsT0FBTyxFQUFFLFlBQVksQ0FBQyxDQUFDO0dBQ2pFLE1BQU07QUFDTCxXQUFPLGNBQWMsQ0FBQyxrQkFBa0IsQ0FBQyxVQUFVLEVBQUUsWUFBWSxDQUFDLENBQUM7R0FDcEU7Q0FDRjs7QUFFRCxTQUFTLGNBQWMsQ0FBQyx5QkFBeUIsRUFBRSxZQUFZLEVBQUU7QUFDL0QsTUFBSSx5QkFBeUIsQ0FBQyxTQUFTLENBQUMsWUFBWSxDQUFDLEtBQUssU0FBUyxFQUFFO0FBQ25FLFdBQU8seUJBQXlCLENBQUMsU0FBUyxDQUFDLFlBQVksQ0FBQyxLQUFLLElBQUksQ0FBQztHQUNuRTtBQUNELE1BQUkseUJBQXlCLENBQUMsWUFBWSxLQUFLLFNBQVMsRUFBRTtBQUN4RCxXQUFPLHlCQUF5QixDQUFDLFlBQVksQ0FBQztHQUMvQztBQUNELGdDQUE4QixDQUFDLFlBQVksQ0FBQyxDQUFDO0FBQzdDLFNBQU8sS0FBSyxDQUFDO0NBQ2Q7O0FBRUQsU0FBUyw4QkFBOEIsQ0FBQyxZQUFZLEVBQUU7QUFDcEQsTUFBSSxnQkFBZ0IsQ0FBQyxZQUFZLENBQUMsS0FBSyxJQUFJLEVBQUU7QUFDM0Msb0JBQWdCLENBQUMsWUFBWSxDQUFDLEdBQUcsSUFBSSxDQUFDO0FBQ3RDLFVBQU0sQ0FBQyxHQUFHLENBQ1IsT0FBTyxFQUNQLGlFQUErRCxZQUFZLG9JQUNILG9IQUMyQyxDQUNwSCxDQUFDO0dBQ0g7Q0FDRjs7QUFFTSxTQUFTLHFCQUFxQixHQUFHO0FBQ3RDLFFBQU0sQ0FBQyxJQUFJLENBQUMsZ0JBQWdCLENBQUMsQ0FBQyxPQUFPLENBQUMsVUFBQSxZQUFZLEVBQUk7QUFDcEQsV0FBTyxnQkFBZ0IsQ0FBQyxZQUFZLENBQUMsQ0FBQztHQUN2QyxDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJwcm90by1hY2Nlc3MuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBjcmVhdGVOZXdMb29rdXBPYmplY3QgfSBmcm9tICcuL2NyZWF0ZS1uZXctbG9va3VwLW9iamVjdCc7XG5pbXBvcnQgKiBhcyBsb2dnZXIgZnJvbSAnLi4vbG9nZ2VyJztcblxuY29uc3QgbG9nZ2VkUHJvcGVydGllcyA9IE9iamVjdC5jcmVhdGUobnVsbCk7XG5cbmV4cG9ydCBmdW5jdGlvbiBjcmVhdGVQcm90b0FjY2Vzc0NvbnRyb2wocnVudGltZU9wdGlvbnMpIHtcbiAgbGV0IGRlZmF1bHRNZXRob2RXaGl0ZUxpc3QgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuICBkZWZhdWx0TWV0aG9kV2hpdGVMaXN0Wydjb25zdHJ1Y3RvciddID0gZmFsc2U7XG4gIGRlZmF1bHRNZXRob2RXaGl0ZUxpc3RbJ19fZGVmaW5lR2V0dGVyX18nXSA9IGZhbHNlO1xuICBkZWZhdWx0TWV0aG9kV2hpdGVMaXN0WydfX2RlZmluZVNldHRlcl9fJ10gPSBmYWxzZTtcbiAgZGVmYXVsdE1ldGhvZFdoaXRlTGlzdFsnX19sb29rdXBHZXR0ZXJfXyddID0gZmFsc2U7XG5cbiAgbGV0IGRlZmF1bHRQcm9wZXJ0eVdoaXRlTGlzdCA9IE9iamVjdC5jcmVhdGUobnVsbCk7XG4gIC8vIGVzbGludC1kaXNhYmxlLW5leHQtbGluZSBuby1wcm90b1xuICBkZWZhdWx0UHJvcGVydHlXaGl0ZUxpc3RbJ19fcHJvdG9fXyddID0gZmFsc2U7XG5cbiAgcmV0dXJuIHtcbiAgICBwcm9wZXJ0aWVzOiB7XG4gICAgICB3aGl0ZWxpc3Q6IGNyZWF0ZU5ld0xvb2t1cE9iamVjdChcbiAgICAgICAgZGVmYXVsdFByb3BlcnR5V2hpdGVMaXN0LFxuICAgICAgICBydW50aW1lT3B0aW9ucy5hbGxvd2VkUHJvdG9Qcm9wZXJ0aWVzXG4gICAgICApLFxuICAgICAgZGVmYXVsdFZhbHVlOiBydW50aW1lT3B0aW9ucy5hbGxvd1Byb3RvUHJvcGVydGllc0J5RGVmYXVsdFxuICAgIH0sXG4gICAgbWV0aG9kczoge1xuICAgICAgd2hpdGVsaXN0OiBjcmVhdGVOZXdMb29rdXBPYmplY3QoXG4gICAgICAgIGRlZmF1bHRNZXRob2RXaGl0ZUxpc3QsXG4gICAgICAgIHJ1bnRpbWVPcHRpb25zLmFsbG93ZWRQcm90b01ldGhvZHNcbiAgICAgICksXG4gICAgICBkZWZhdWx0VmFsdWU6IHJ1bnRpbWVPcHRpb25zLmFsbG93UHJvdG9NZXRob2RzQnlEZWZhdWx0XG4gICAgfVxuICB9O1xufVxuXG5leHBvcnQgZnVuY3Rpb24gcmVzdWx0SXNBbGxvd2VkKHJlc3VsdCwgcHJvdG9BY2Nlc3NDb250cm9sLCBwcm9wZXJ0eU5hbWUpIHtcbiAgaWYgKHR5cGVvZiByZXN1bHQgPT09ICdmdW5jdGlvbicpIHtcbiAgICByZXR1cm4gY2hlY2tXaGl0ZUxpc3QocHJvdG9BY2Nlc3NDb250cm9sLm1ldGhvZHMsIHByb3BlcnR5TmFtZSk7XG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIGNoZWNrV2hpdGVMaXN0KHByb3RvQWNjZXNzQ29udHJvbC5wcm9wZXJ0aWVzLCBwcm9wZXJ0eU5hbWUpO1xuICB9XG59XG5cbmZ1bmN0aW9uIGNoZWNrV2hpdGVMaXN0KHByb3RvQWNjZXNzQ29udHJvbEZvclR5cGUsIHByb3BlcnR5TmFtZSkge1xuICBpZiAocHJvdG9BY2Nlc3NDb250cm9sRm9yVHlwZS53aGl0ZWxpc3RbcHJvcGVydHlOYW1lXSAhPT0gdW5kZWZpbmVkKSB7XG4gICAgcmV0dXJuIHByb3RvQWNjZXNzQ29udHJvbEZvclR5cGUud2hpdGVsaXN0W3Byb3BlcnR5TmFtZV0gPT09IHRydWU7XG4gIH1cbiAgaWYgKHByb3RvQWNjZXNzQ29udHJvbEZvclR5cGUuZGVmYXVsdFZhbHVlICE9PSB1bmRlZmluZWQpIHtcbiAgICByZXR1cm4gcHJvdG9BY2Nlc3NDb250cm9sRm9yVHlwZS5kZWZhdWx0VmFsdWU7XG4gIH1cbiAgbG9nVW5leHBlY2VkUHJvcGVydHlBY2Nlc3NPbmNlKHByb3BlcnR5TmFtZSk7XG4gIHJldHVybiBmYWxzZTtcbn1cblxuZnVuY3Rpb24gbG9nVW5leHBlY2VkUHJvcGVydHlBY2Nlc3NPbmNlKHByb3BlcnR5TmFtZSkge1xuICBpZiAobG9nZ2VkUHJvcGVydGllc1twcm9wZXJ0eU5hbWVdICE9PSB0cnVlKSB7XG4gICAgbG9nZ2VkUHJvcGVydGllc1twcm9wZXJ0eU5hbWVdID0gdHJ1ZTtcbiAgICBsb2dnZXIubG9nKFxuICAgICAgJ2Vycm9yJyxcbiAgICAgIGBIYW5kbGViYXJzOiBBY2Nlc3MgaGFzIGJlZW4gZGVuaWVkIHRvIHJlc29sdmUgdGhlIHByb3BlcnR5IFwiJHtwcm9wZXJ0eU5hbWV9XCIgYmVjYXVzZSBpdCBpcyBub3QgYW4gXCJvd24gcHJvcGVydHlcIiBvZiBpdHMgcGFyZW50LlxcbmAgK1xuICAgICAgICBgWW91IGNhbiBhZGQgYSBydW50aW1lIG9wdGlvbiB0byBkaXNhYmxlIHRoZSBjaGVjayBvciB0aGlzIHdhcm5pbmc6XFxuYCArXG4gICAgICAgIGBTZWUgaHR0cHM6Ly9oYW5kbGViYXJzanMuY29tL2FwaS1yZWZlcmVuY2UvcnVudGltZS1vcHRpb25zLmh0bWwjb3B0aW9ucy10by1jb250cm9sLXByb3RvdHlwZS1hY2Nlc3MgZm9yIGRldGFpbHNgXG4gICAgKTtcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gcmVzZXRMb2dnZWRQcm9wZXJ0aWVzKCkge1xuICBPYmplY3Qua2V5cyhsb2dnZWRQcm9wZXJ0aWVzKS5mb3JFYWNoKHByb3BlcnR5TmFtZSA9PiB7XG4gICAgZGVsZXRlIGxvZ2dlZFByb3BlcnRpZXNbcHJvcGVydHlOYW1lXTtcbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ 5:
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.wrapHelper = wrapHelper;

function wrapHelper(helper, transformOptionsFn) {
  if (typeof helper !== 'function') {
    // This should not happen, but apparently it does in https://github.com/wycats/handlebars.js/issues/1639
    // We try to make the wrapper least-invasive by not wrapping it, if the helper is not a function.
    return helper;
  }
  var wrapper = function wrapper() /* dynamic arguments */{
    var options = arguments[arguments.length - 1];
    arguments[arguments.length - 1] = transformOptionsFn(options);
    return helper.apply(this, arguments);
  };
  return wrapper;
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2ludGVybmFsL3dyYXBIZWxwZXIuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7QUFBTyxTQUFTLFVBQVUsQ0FBQyxNQUFNLEVBQUUsa0JBQWtCLEVBQUU7QUFDckQsTUFBSSxPQUFPLE1BQU0sS0FBSyxVQUFVLEVBQUU7OztBQUdoQyxXQUFPLE1BQU0sQ0FBQztHQUNmO0FBQ0QsTUFBSSxPQUFPLEdBQUcsU0FBVixPQUFPLDBCQUFxQztBQUM5QyxRQUFNLE9BQU8sR0FBRyxTQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQztBQUNoRCxhQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsR0FBRyxrQkFBa0IsQ0FBQyxPQUFPLENBQUMsQ0FBQztBQUM5RCxXQUFPLE1BQU0sQ0FBQyxLQUFLLENBQUMsSUFBSSxFQUFFLFNBQVMsQ0FBQyxDQUFDO0dBQ3RDLENBQUM7QUFDRixTQUFPLE9BQU8sQ0FBQztDQUNoQiIsImZpbGUiOiJ3cmFwSGVscGVyLmpzIiwic291cmNlc0NvbnRlbnQiOlsiZXhwb3J0IGZ1bmN0aW9uIHdyYXBIZWxwZXIoaGVscGVyLCB0cmFuc2Zvcm1PcHRpb25zRm4pIHtcbiAgaWYgKHR5cGVvZiBoZWxwZXIgIT09ICdmdW5jdGlvbicpIHtcbiAgICAvLyBUaGlzIHNob3VsZCBub3QgaGFwcGVuLCBidXQgYXBwYXJlbnRseSBpdCBkb2VzIGluIGh0dHBzOi8vZ2l0aHViLmNvbS93eWNhdHMvaGFuZGxlYmFycy5qcy9pc3N1ZXMvMTYzOVxuICAgIC8vIFdlIHRyeSB0byBtYWtlIHRoZSB3cmFwcGVyIGxlYXN0LWludmFzaXZlIGJ5IG5vdCB3cmFwcGluZyBpdCwgaWYgdGhlIGhlbHBlciBpcyBub3QgYSBmdW5jdGlvbi5cbiAgICByZXR1cm4gaGVscGVyO1xuICB9XG4gIGxldCB3cmFwcGVyID0gZnVuY3Rpb24oLyogZHluYW1pYyBhcmd1bWVudHMgKi8pIHtcbiAgICBjb25zdCBvcHRpb25zID0gYXJndW1lbnRzW2FyZ3VtZW50cy5sZW5ndGggLSAxXTtcbiAgICBhcmd1bWVudHNbYXJndW1lbnRzLmxlbmd0aCAtIDFdID0gdHJhbnNmb3JtT3B0aW9uc0ZuKG9wdGlvbnMpO1xuICAgIHJldHVybiBoZWxwZXIuYXBwbHkodGhpcywgYXJndW1lbnRzKTtcbiAgfTtcbiAgcmV0dXJuIHdyYXBwZXI7XG59XG4iXX0=


/***/ }),

/***/ 37:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(392);

var logger = {
  methodMap: ['debug', 'info', 'warn', 'error'],
  level: 'info',

  // Maps a given level value to the `methodMap` indexes above.
  lookupLevel: function lookupLevel(level) {
    if (typeof level === 'string') {
      var levelMap = _utils.indexOf(logger.methodMap, level.toLowerCase());
      if (levelMap >= 0) {
        level = levelMap;
      } else {
        level = parseInt(level, 10);
      }
    }

    return level;
  },

  // Can be overridden in the host environment
  log: function log(level) {
    level = logger.lookupLevel(level);

    if (typeof console !== 'undefined' && logger.lookupLevel(logger.level) <= level) {
      var method = logger.methodMap[level];
      // eslint-disable-next-line no-console
      if (!console[method]) {
        method = 'log';
      }

      for (var _len = arguments.length, message = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
        message[_key - 1] = arguments[_key];
      }

      console[method].apply(console, message); // eslint-disable-line no-console
    }
  }
};

exports["default"] = logger;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2xvZ2dlci5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7O3FCQUF3QixTQUFTOztBQUVqQyxJQUFJLE1BQU0sR0FBRztBQUNYLFdBQVMsRUFBRSxDQUFDLE9BQU8sRUFBRSxNQUFNLEVBQUUsTUFBTSxFQUFFLE9BQU8sQ0FBQztBQUM3QyxPQUFLLEVBQUUsTUFBTTs7O0FBR2IsYUFBVyxFQUFFLHFCQUFTLEtBQUssRUFBRTtBQUMzQixRQUFJLE9BQU8sS0FBSyxLQUFLLFFBQVEsRUFBRTtBQUM3QixVQUFJLFFBQVEsR0FBRyxlQUFRLE1BQU0sQ0FBQyxTQUFTLEVBQUUsS0FBSyxDQUFDLFdBQVcsRUFBRSxDQUFDLENBQUM7QUFDOUQsVUFBSSxRQUFRLElBQUksQ0FBQyxFQUFFO0FBQ2pCLGFBQUssR0FBRyxRQUFRLENBQUM7T0FDbEIsTUFBTTtBQUNMLGFBQUssR0FBRyxRQUFRLENBQUMsS0FBSyxFQUFFLEVBQUUsQ0FBQyxDQUFDO09BQzdCO0tBQ0Y7O0FBRUQsV0FBTyxLQUFLLENBQUM7R0FDZDs7O0FBR0QsS0FBRyxFQUFFLGFBQVMsS0FBSyxFQUFjO0FBQy9CLFNBQUssR0FBRyxNQUFNLENBQUMsV0FBVyxDQUFDLEtBQUssQ0FBQyxDQUFDOztBQUVsQyxRQUNFLE9BQU8sT0FBTyxLQUFLLFdBQVcsSUFDOUIsTUFBTSxDQUFDLFdBQVcsQ0FBQyxNQUFNLENBQUMsS0FBSyxDQUFDLElBQUksS0FBSyxFQUN6QztBQUNBLFVBQUksTUFBTSxHQUFHLE1BQU0sQ0FBQyxTQUFTLENBQUMsS0FBSyxDQUFDLENBQUM7O0FBRXJDLFVBQUksQ0FBQyxPQUFPLENBQUMsTUFBTSxDQUFDLEVBQUU7QUFDcEIsY0FBTSxHQUFHLEtBQUssQ0FBQztPQUNoQjs7d0NBWG1CLE9BQU87QUFBUCxlQUFPOzs7QUFZM0IsYUFBTyxDQUFDLE1BQU0sT0FBQyxDQUFmLE9BQU8sRUFBWSxPQUFPLENBQUMsQ0FBQztLQUM3QjtHQUNGO0NBQ0YsQ0FBQzs7cUJBRWEsTUFBTSIsImZpbGUiOiJsb2dnZXIuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBpbmRleE9mIH0gZnJvbSAnLi91dGlscyc7XG5cbmxldCBsb2dnZXIgPSB7XG4gIG1ldGhvZE1hcDogWydkZWJ1ZycsICdpbmZvJywgJ3dhcm4nLCAnZXJyb3InXSxcbiAgbGV2ZWw6ICdpbmZvJyxcblxuICAvLyBNYXBzIGEgZ2l2ZW4gbGV2ZWwgdmFsdWUgdG8gdGhlIGBtZXRob2RNYXBgIGluZGV4ZXMgYWJvdmUuXG4gIGxvb2t1cExldmVsOiBmdW5jdGlvbihsZXZlbCkge1xuICAgIGlmICh0eXBlb2YgbGV2ZWwgPT09ICdzdHJpbmcnKSB7XG4gICAgICBsZXQgbGV2ZWxNYXAgPSBpbmRleE9mKGxvZ2dlci5tZXRob2RNYXAsIGxldmVsLnRvTG93ZXJDYXNlKCkpO1xuICAgICAgaWYgKGxldmVsTWFwID49IDApIHtcbiAgICAgICAgbGV2ZWwgPSBsZXZlbE1hcDtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGxldmVsID0gcGFyc2VJbnQobGV2ZWwsIDEwKTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICByZXR1cm4gbGV2ZWw7XG4gIH0sXG5cbiAgLy8gQ2FuIGJlIG92ZXJyaWRkZW4gaW4gdGhlIGhvc3QgZW52aXJvbm1lbnRcbiAgbG9nOiBmdW5jdGlvbihsZXZlbCwgLi4ubWVzc2FnZSkge1xuICAgIGxldmVsID0gbG9nZ2VyLmxvb2t1cExldmVsKGxldmVsKTtcblxuICAgIGlmIChcbiAgICAgIHR5cGVvZiBjb25zb2xlICE9PSAndW5kZWZpbmVkJyAmJlxuICAgICAgbG9nZ2VyLmxvb2t1cExldmVsKGxvZ2dlci5sZXZlbCkgPD0gbGV2ZWxcbiAgICApIHtcbiAgICAgIGxldCBtZXRob2QgPSBsb2dnZXIubWV0aG9kTWFwW2xldmVsXTtcbiAgICAgIC8vIGVzbGludC1kaXNhYmxlLW5leHQtbGluZSBuby1jb25zb2xlXG4gICAgICBpZiAoIWNvbnNvbGVbbWV0aG9kXSkge1xuICAgICAgICBtZXRob2QgPSAnbG9nJztcbiAgICAgIH1cbiAgICAgIGNvbnNvbGVbbWV0aG9kXSguLi5tZXNzYWdlKTsgLy8gZXNsaW50LWRpc2FibGUtbGluZSBuby1jb25zb2xlXG4gICAgfVxuICB9XG59O1xuXG5leHBvcnQgZGVmYXVsdCBsb2dnZXI7XG4iXX0=


/***/ }),

/***/ 982:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

exports["default"] = function (Handlebars) {
  /* istanbul ignore next */
  var root = typeof __webpack_require__.g !== 'undefined' ? __webpack_require__.g : window,
      $Handlebars = root.Handlebars;
  /* istanbul ignore next */
  Handlebars.noConflict = function () {
    if (root.Handlebars === Handlebars) {
      root.Handlebars = $Handlebars;
    }
    return Handlebars;
  };
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL25vLWNvbmZsaWN0LmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQWUsVUFBUyxVQUFVLEVBQUU7O0FBRWxDLE1BQUksSUFBSSxHQUFHLE9BQU8sTUFBTSxLQUFLLFdBQVcsR0FBRyxNQUFNLEdBQUcsTUFBTTtNQUN4RCxXQUFXLEdBQUcsSUFBSSxDQUFDLFVBQVUsQ0FBQzs7QUFFaEMsWUFBVSxDQUFDLFVBQVUsR0FBRyxZQUFXO0FBQ2pDLFFBQUksSUFBSSxDQUFDLFVBQVUsS0FBSyxVQUFVLEVBQUU7QUFDbEMsVUFBSSxDQUFDLFVBQVUsR0FBRyxXQUFXLENBQUM7S0FDL0I7QUFDRCxXQUFPLFVBQVUsQ0FBQztHQUNuQixDQUFDO0NBQ0giLCJmaWxlIjoibm8tY29uZmxpY3QuanMiLCJzb3VyY2VzQ29udGVudCI6WyJleHBvcnQgZGVmYXVsdCBmdW5jdGlvbihIYW5kbGViYXJzKSB7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIGxldCByb290ID0gdHlwZW9mIGdsb2JhbCAhPT0gJ3VuZGVmaW5lZCcgPyBnbG9iYWwgOiB3aW5kb3csXG4gICAgJEhhbmRsZWJhcnMgPSByb290LkhhbmRsZWJhcnM7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIEhhbmRsZWJhcnMubm9Db25mbGljdCA9IGZ1bmN0aW9uKCkge1xuICAgIGlmIChyb290LkhhbmRsZWJhcnMgPT09IEhhbmRsZWJhcnMpIHtcbiAgICAgIHJvb3QuSGFuZGxlYmFycyA9ICRIYW5kbGViYXJzO1xuICAgIH1cbiAgICByZXR1cm4gSGFuZGxlYmFycztcbiAgfTtcbn1cbiJdfQ==


/***/ }),

/***/ 628:
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.checkRevision = checkRevision;
exports.template = template;
exports.wrapProgram = wrapProgram;
exports.resolvePartial = resolvePartial;
exports.invokePartial = invokePartial;
exports.noop = noop;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

// istanbul ignore next

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _utils = __webpack_require__(392);

var Utils = _interopRequireWildcard(_utils);

var _exception = __webpack_require__(728);

var _exception2 = _interopRequireDefault(_exception);

var _base = __webpack_require__(67);

var _helpers = __webpack_require__(638);

var _internalWrapHelper = __webpack_require__(5);

var _internalProtoAccess = __webpack_require__(293);

function checkRevision(compilerInfo) {
  var compilerRevision = compilerInfo && compilerInfo[0] || 1,
      currentRevision = _base.COMPILER_REVISION;

  if (compilerRevision >= _base.LAST_COMPATIBLE_COMPILER_REVISION && compilerRevision <= _base.COMPILER_REVISION) {
    return;
  }

  if (compilerRevision < _base.LAST_COMPATIBLE_COMPILER_REVISION) {
    var runtimeVersions = _base.REVISION_CHANGES[currentRevision],
        compilerVersions = _base.REVISION_CHANGES[compilerRevision];
    throw new _exception2['default']('Template was precompiled with an older version of Handlebars than the current runtime. ' + 'Please update your precompiler to a newer version (' + runtimeVersions + ') or downgrade your runtime to an older version (' + compilerVersions + ').');
  } else {
    // Use the embedded version info since the runtime doesn't know about this revision yet
    throw new _exception2['default']('Template was precompiled with a newer version of Handlebars than the current runtime. ' + 'Please update your runtime to a newer version (' + compilerInfo[1] + ').');
  }
}

function template(templateSpec, env) {
  /* istanbul ignore next */
  if (!env) {
    throw new _exception2['default']('No environment passed to template');
  }
  if (!templateSpec || !templateSpec.main) {
    throw new _exception2['default']('Unknown template object: ' + typeof templateSpec);
  }

  templateSpec.main.decorator = templateSpec.main_d;

  // Note: Using env.VM references rather than local var references throughout this section to allow
  // for external users to override these as pseudo-supported APIs.
  env.VM.checkRevision(templateSpec.compiler);

  // backwards compatibility for precompiled templates with compiler-version 7 (<4.3.0)
  var templateWasPrecompiledWithCompilerV7 = templateSpec.compiler && templateSpec.compiler[0] === 7;

  function invokePartialWrapper(partial, context, options) {
    if (options.hash) {
      context = Utils.extend({}, context, options.hash);
      if (options.ids) {
        options.ids[0] = true;
      }
    }
    partial = env.VM.resolvePartial.call(this, partial, context, options);

    var extendedOptions = Utils.extend({}, options, {
      hooks: this.hooks,
      protoAccessControl: this.protoAccessControl
    });

    var result = env.VM.invokePartial.call(this, partial, context, extendedOptions);

    if (result == null && env.compile) {
      options.partials[options.name] = env.compile(partial, templateSpec.compilerOptions, env);
      result = options.partials[options.name](context, extendedOptions);
    }
    if (result != null) {
      if (options.indent) {
        var lines = result.split('\n');
        for (var i = 0, l = lines.length; i < l; i++) {
          if (!lines[i] && i + 1 === l) {
            break;
          }

          lines[i] = options.indent + lines[i];
        }
        result = lines.join('\n');
      }
      return result;
    } else {
      throw new _exception2['default']('The partial ' + options.name + ' could not be compiled when running in runtime-only mode');
    }
  }

  // Just add water
  var container = {
    strict: function strict(obj, name, loc) {
      if (!obj || !(name in obj)) {
        throw new _exception2['default']('"' + name + '" not defined in ' + obj, {
          loc: loc
        });
      }
      return container.lookupProperty(obj, name);
    },
    lookupProperty: function lookupProperty(parent, propertyName) {
      var result = parent[propertyName];
      if (result == null) {
        return result;
      }
      if (Object.prototype.hasOwnProperty.call(parent, propertyName)) {
        return result;
      }

      if (_internalProtoAccess.resultIsAllowed(result, container.protoAccessControl, propertyName)) {
        return result;
      }
      return undefined;
    },
    lookup: function lookup(depths, name) {
      var len = depths.length;
      for (var i = 0; i < len; i++) {
        var result = depths[i] && container.lookupProperty(depths[i], name);
        if (result != null) {
          return depths[i][name];
        }
      }
    },
    lambda: function lambda(current, context) {
      return typeof current === 'function' ? current.call(context) : current;
    },

    escapeExpression: Utils.escapeExpression,
    invokePartial: invokePartialWrapper,

    fn: function fn(i) {
      var ret = templateSpec[i];
      ret.decorator = templateSpec[i + '_d'];
      return ret;
    },

    programs: [],
    program: function program(i, data, declaredBlockParams, blockParams, depths) {
      var programWrapper = this.programs[i],
          fn = this.fn(i);
      if (data || depths || blockParams || declaredBlockParams) {
        programWrapper = wrapProgram(this, i, fn, data, declaredBlockParams, blockParams, depths);
      } else if (!programWrapper) {
        programWrapper = this.programs[i] = wrapProgram(this, i, fn);
      }
      return programWrapper;
    },

    data: function data(value, depth) {
      while (value && depth--) {
        value = value._parent;
      }
      return value;
    },
    mergeIfNeeded: function mergeIfNeeded(param, common) {
      var obj = param || common;

      if (param && common && param !== common) {
        obj = Utils.extend({}, common, param);
      }

      return obj;
    },
    // An empty object to use as replacement for null-contexts
    nullContext: Object.seal({}),

    noop: env.VM.noop,
    compilerInfo: templateSpec.compiler
  };

  function ret(context) {
    var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

    var data = options.data;

    ret._setup(options);
    if (!options.partial && templateSpec.useData) {
      data = initData(context, data);
    }
    var depths = undefined,
        blockParams = templateSpec.useBlockParams ? [] : undefined;
    if (templateSpec.useDepths) {
      if (options.depths) {
        depths = context != options.depths[0] ? [context].concat(options.depths) : options.depths;
      } else {
        depths = [context];
      }
    }

    function main(context /*, options*/) {
      return '' + templateSpec.main(container, context, container.helpers, container.partials, data, blockParams, depths);
    }

    main = executeDecorators(templateSpec.main, main, container, options.depths || [], data, blockParams);
    return main(context, options);
  }

  ret.isTop = true;

  ret._setup = function (options) {
    if (!options.partial) {
      var mergedHelpers = Utils.extend({}, env.helpers, options.helpers);
      wrapHelpersToPassLookupProperty(mergedHelpers, container);
      container.helpers = mergedHelpers;

      if (templateSpec.usePartial) {
        // Use mergeIfNeeded here to prevent compiling global partials multiple times
        container.partials = container.mergeIfNeeded(options.partials, env.partials);
      }
      if (templateSpec.usePartial || templateSpec.useDecorators) {
        container.decorators = Utils.extend({}, env.decorators, options.decorators);
      }

      container.hooks = {};
      container.protoAccessControl = _internalProtoAccess.createProtoAccessControl(options);

      var keepHelperInHelpers = options.allowCallsToHelperMissing || templateWasPrecompiledWithCompilerV7;
      _helpers.moveHelperToHooks(container, 'helperMissing', keepHelperInHelpers);
      _helpers.moveHelperToHooks(container, 'blockHelperMissing', keepHelperInHelpers);
    } else {
      container.protoAccessControl = options.protoAccessControl; // internal option
      container.helpers = options.helpers;
      container.partials = options.partials;
      container.decorators = options.decorators;
      container.hooks = options.hooks;
    }
  };

  ret._child = function (i, data, blockParams, depths) {
    if (templateSpec.useBlockParams && !blockParams) {
      throw new _exception2['default']('must pass block params');
    }
    if (templateSpec.useDepths && !depths) {
      throw new _exception2['default']('must pass parent depths');
    }

    return wrapProgram(container, i, templateSpec[i], data, 0, blockParams, depths);
  };
  return ret;
}

function wrapProgram(container, i, fn, data, declaredBlockParams, blockParams, depths) {
  function prog(context) {
    var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

    var currentDepths = depths;
    if (depths && context != depths[0] && !(context === container.nullContext && depths[0] === null)) {
      currentDepths = [context].concat(depths);
    }

    return fn(container, context, container.helpers, container.partials, options.data || data, blockParams && [options.blockParams].concat(blockParams), currentDepths);
  }

  prog = executeDecorators(fn, prog, container, depths, data, blockParams);

  prog.program = i;
  prog.depth = depths ? depths.length : 0;
  prog.blockParams = declaredBlockParams || 0;
  return prog;
}

/**
 * This is currently part of the official API, therefore implementation details should not be changed.
 */

function resolvePartial(partial, context, options) {
  if (!partial) {
    if (options.name === '@partial-block') {
      partial = options.data['partial-block'];
    } else {
      partial = options.partials[options.name];
    }
  } else if (!partial.call && !options.name) {
    // This is a dynamic partial that returned a string
    options.name = partial;
    partial = options.partials[partial];
  }
  return partial;
}

function invokePartial(partial, context, options) {
  // Use the current closure context to save the partial-block if this partial
  var currentPartialBlock = options.data && options.data['partial-block'];
  options.partial = true;
  if (options.ids) {
    options.data.contextPath = options.ids[0] || options.data.contextPath;
  }

  var partialBlock = undefined;
  if (options.fn && options.fn !== noop) {
    (function () {
      options.data = _base.createFrame(options.data);
      // Wrapper function to get access to currentPartialBlock from the closure
      var fn = options.fn;
      partialBlock = options.data['partial-block'] = function partialBlockWrapper(context) {
        var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

        // Restore the partial-block from the closure for the execution of the block
        // i.e. the part inside the block of the partial call.
        options.data = _base.createFrame(options.data);
        options.data['partial-block'] = currentPartialBlock;
        return fn(context, options);
      };
      if (fn.partials) {
        options.partials = Utils.extend({}, options.partials, fn.partials);
      }
    })();
  }

  if (partial === undefined && partialBlock) {
    partial = partialBlock;
  }

  if (partial === undefined) {
    throw new _exception2['default']('The partial ' + options.name + ' could not be found');
  } else if (partial instanceof Function) {
    return partial(context, options);
  }
}

function noop() {
  return '';
}

function initData(context, data) {
  if (!data || !('root' in data)) {
    data = data ? _base.createFrame(data) : {};
    data.root = context;
  }
  return data;
}

function executeDecorators(fn, prog, container, depths, data, blockParams) {
  if (fn.decorator) {
    var props = {};
    prog = fn.decorator(prog, props, container, depths && depths[0], data, blockParams, depths);
    Utils.extend(prog, props);
  }
  return prog;
}

function wrapHelpersToPassLookupProperty(mergedHelpers, container) {
  Object.keys(mergedHelpers).forEach(function (helperName) {
    var helper = mergedHelpers[helperName];
    mergedHelpers[helperName] = passLookupPropertyOption(helper, container);
  });
}

function passLookupPropertyOption(helper, container) {
  var lookupProperty = container.lookupProperty;
  return _internalWrapHelper.wrapHelper(helper, function (options) {
    return Utils.extend({ lookupProperty: lookupProperty }, options);
  });
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3J1bnRpbWUuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7cUJBQXVCLFNBQVM7O0lBQXBCLEtBQUs7O3lCQUNLLGFBQWE7Ozs7b0JBTTVCLFFBQVE7O3VCQUNtQixXQUFXOztrQ0FDbEIsdUJBQXVCOzttQ0FJM0MseUJBQXlCOztBQUV6QixTQUFTLGFBQWEsQ0FBQyxZQUFZLEVBQUU7QUFDMUMsTUFBTSxnQkFBZ0IsR0FBRyxBQUFDLFlBQVksSUFBSSxZQUFZLENBQUMsQ0FBQyxDQUFDLElBQUssQ0FBQztNQUM3RCxlQUFlLDBCQUFvQixDQUFDOztBQUV0QyxNQUNFLGdCQUFnQiwyQ0FBcUMsSUFDckQsZ0JBQWdCLDJCQUFxQixFQUNyQztBQUNBLFdBQU87R0FDUjs7QUFFRCxNQUFJLGdCQUFnQiwwQ0FBb0MsRUFBRTtBQUN4RCxRQUFNLGVBQWUsR0FBRyx1QkFBaUIsZUFBZSxDQUFDO1FBQ3ZELGdCQUFnQixHQUFHLHVCQUFpQixnQkFBZ0IsQ0FBQyxDQUFDO0FBQ3hELFVBQU0sMkJBQ0oseUZBQXlGLEdBQ3ZGLHFEQUFxRCxHQUNyRCxlQUFlLEdBQ2YsbURBQW1ELEdBQ25ELGdCQUFnQixHQUNoQixJQUFJLENBQ1AsQ0FBQztHQUNILE1BQU07O0FBRUwsVUFBTSwyQkFDSix3RkFBd0YsR0FDdEYsaURBQWlELEdBQ2pELFlBQVksQ0FBQyxDQUFDLENBQUMsR0FDZixJQUFJLENBQ1AsQ0FBQztHQUNIO0NBQ0Y7O0FBRU0sU0FBUyxRQUFRLENBQUMsWUFBWSxFQUFFLEdBQUcsRUFBRTs7QUFFMUMsTUFBSSxDQUFDLEdBQUcsRUFBRTtBQUNSLFVBQU0sMkJBQWMsbUNBQW1DLENBQUMsQ0FBQztHQUMxRDtBQUNELE1BQUksQ0FBQyxZQUFZLElBQUksQ0FBQyxZQUFZLENBQUMsSUFBSSxFQUFFO0FBQ3ZDLFVBQU0sMkJBQWMsMkJBQTJCLEdBQUcsT0FBTyxZQUFZLENBQUMsQ0FBQztHQUN4RTs7QUFFRCxjQUFZLENBQUMsSUFBSSxDQUFDLFNBQVMsR0FBRyxZQUFZLENBQUMsTUFBTSxDQUFDOzs7O0FBSWxELEtBQUcsQ0FBQyxFQUFFLENBQUMsYUFBYSxDQUFDLFlBQVksQ0FBQyxRQUFRLENBQUMsQ0FBQzs7O0FBRzVDLE1BQU0sb0NBQW9DLEdBQ3hDLFlBQVksQ0FBQyxRQUFRLElBQUksWUFBWSxDQUFDLFFBQVEsQ0FBQyxDQUFDLENBQUMsS0FBSyxDQUFDLENBQUM7O0FBRTFELFdBQVMsb0JBQW9CLENBQUMsT0FBTyxFQUFFLE9BQU8sRUFBRSxPQUFPLEVBQUU7QUFDdkQsUUFBSSxPQUFPLENBQUMsSUFBSSxFQUFFO0FBQ2hCLGFBQU8sR0FBRyxLQUFLLENBQUMsTUFBTSxDQUFDLEVBQUUsRUFBRSxPQUFPLEVBQUUsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0FBQ2xELFVBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUNmLGVBQU8sQ0FBQyxHQUFHLENBQUMsQ0FBQyxDQUFDLEdBQUcsSUFBSSxDQUFDO09BQ3ZCO0tBQ0Y7QUFDRCxXQUFPLEdBQUcsR0FBRyxDQUFDLEVBQUUsQ0FBQyxjQUFjLENBQUMsSUFBSSxDQUFDLElBQUksRUFBRSxPQUFPLEVBQUUsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDOztBQUV0RSxRQUFJLGVBQWUsR0FBRyxLQUFLLENBQUMsTUFBTSxDQUFDLEVBQUUsRUFBRSxPQUFPLEVBQUU7QUFDOUMsV0FBSyxFQUFFLElBQUksQ0FBQyxLQUFLO0FBQ2pCLHdCQUFrQixFQUFFLElBQUksQ0FBQyxrQkFBa0I7S0FDNUMsQ0FBQyxDQUFDOztBQUVILFFBQUksTUFBTSxHQUFHLEdBQUcsQ0FBQyxFQUFFLENBQUMsYUFBYSxDQUFDLElBQUksQ0FDcEMsSUFBSSxFQUNKLE9BQU8sRUFDUCxPQUFPLEVBQ1AsZUFBZSxDQUNoQixDQUFDOztBQUVGLFFBQUksTUFBTSxJQUFJLElBQUksSUFBSSxHQUFHLENBQUMsT0FBTyxFQUFFO0FBQ2pDLGFBQU8sQ0FBQyxRQUFRLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxHQUFHLEdBQUcsQ0FBQyxPQUFPLENBQzFDLE9BQU8sRUFDUCxZQUFZLENBQUMsZUFBZSxFQUM1QixHQUFHLENBQ0osQ0FBQztBQUNGLFlBQU0sR0FBRyxPQUFPLENBQUMsUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxPQUFPLEVBQUUsZUFBZSxDQUFDLENBQUM7S0FDbkU7QUFDRCxRQUFJLE1BQU0sSUFBSSxJQUFJLEVBQUU7QUFDbEIsVUFBSSxPQUFPLENBQUMsTUFBTSxFQUFFO0FBQ2xCLFlBQUksS0FBSyxHQUFHLE1BQU0sQ0FBQyxLQUFLLENBQUMsSUFBSSxDQUFDLENBQUM7QUFDL0IsYUFBSyxJQUFJLENBQUMsR0FBRyxDQUFDLEVBQUUsQ0FBQyxHQUFHLEtBQUssQ0FBQyxNQUFNLEVBQUUsQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUM1QyxjQUFJLENBQUMsS0FBSyxDQUFDLENBQUMsQ0FBQyxJQUFJLENBQUMsR0FBRyxDQUFDLEtBQUssQ0FBQyxFQUFFO0FBQzVCLGtCQUFNO1dBQ1A7O0FBRUQsZUFBSyxDQUFDLENBQUMsQ0FBQyxHQUFHLE9BQU8sQ0FBQyxNQUFNLEdBQUcsS0FBSyxDQUFDLENBQUMsQ0FBQyxDQUFDO1NBQ3RDO0FBQ0QsY0FBTSxHQUFHLEtBQUssQ0FBQyxJQUFJLENBQUMsSUFBSSxDQUFDLENBQUM7T0FDM0I7QUFDRCxhQUFPLE1BQU0sQ0FBQztLQUNmLE1BQU07QUFDTCxZQUFNLDJCQUNKLGNBQWMsR0FDWixPQUFPLENBQUMsSUFBSSxHQUNaLDBEQUEwRCxDQUM3RCxDQUFDO0tBQ0g7R0FDRjs7O0FBR0QsTUFBSSxTQUFTLEdBQUc7QUFDZCxVQUFNLEVBQUUsZ0JBQVMsR0FBRyxFQUFFLElBQUksRUFBRSxHQUFHLEVBQUU7QUFDL0IsVUFBSSxDQUFDLEdBQUcsSUFBSSxFQUFFLElBQUksSUFBSSxHQUFHLENBQUEsQUFBQyxFQUFFO0FBQzFCLGNBQU0sMkJBQWMsR0FBRyxHQUFHLElBQUksR0FBRyxtQkFBbUIsR0FBRyxHQUFHLEVBQUU7QUFDMUQsYUFBRyxFQUFFLEdBQUc7U0FDVCxDQUFDLENBQUM7T0FDSjtBQUNELGFBQU8sU0FBUyxDQUFDLGNBQWMsQ0FBQyxHQUFHLEVBQUUsSUFBSSxDQUFDLENBQUM7S0FDNUM7QUFDRCxrQkFBYyxFQUFFLHdCQUFTLE1BQU0sRUFBRSxZQUFZLEVBQUU7QUFDN0MsVUFBSSxNQUFNLEdBQUcsTUFBTSxDQUFDLFlBQVksQ0FBQyxDQUFDO0FBQ2xDLFVBQUksTUFBTSxJQUFJLElBQUksRUFBRTtBQUNsQixlQUFPLE1BQU0sQ0FBQztPQUNmO0FBQ0QsVUFBSSxNQUFNLENBQUMsU0FBUyxDQUFDLGNBQWMsQ0FBQyxJQUFJLENBQUMsTUFBTSxFQUFFLFlBQVksQ0FBQyxFQUFFO0FBQzlELGVBQU8sTUFBTSxDQUFDO09BQ2Y7O0FBRUQsVUFBSSxxQ0FBZ0IsTUFBTSxFQUFFLFNBQVMsQ0FBQyxrQkFBa0IsRUFBRSxZQUFZLENBQUMsRUFBRTtBQUN2RSxlQUFPLE1BQU0sQ0FBQztPQUNmO0FBQ0QsYUFBTyxTQUFTLENBQUM7S0FDbEI7QUFDRCxVQUFNLEVBQUUsZ0JBQVMsTUFBTSxFQUFFLElBQUksRUFBRTtBQUM3QixVQUFNLEdBQUcsR0FBRyxNQUFNLENBQUMsTUFBTSxDQUFDO0FBQzFCLFdBQUssSUFBSSxDQUFDLEdBQUcsQ0FBQyxFQUFFLENBQUMsR0FBRyxHQUFHLEVBQUUsQ0FBQyxFQUFFLEVBQUU7QUFDNUIsWUFBSSxNQUFNLEdBQUcsTUFBTSxDQUFDLENBQUMsQ0FBQyxJQUFJLFNBQVMsQ0FBQyxjQUFjLENBQUMsTUFBTSxDQUFDLENBQUMsQ0FBQyxFQUFFLElBQUksQ0FBQyxDQUFDO0FBQ3BFLFlBQUksTUFBTSxJQUFJLElBQUksRUFBRTtBQUNsQixpQkFBTyxNQUFNLENBQUMsQ0FBQyxDQUFDLENBQUMsSUFBSSxDQUFDLENBQUM7U0FDeEI7T0FDRjtLQUNGO0FBQ0QsVUFBTSxFQUFFLGdCQUFTLE9BQU8sRUFBRSxPQUFPLEVBQUU7QUFDakMsYUFBTyxPQUFPLE9BQU8sS0FBSyxVQUFVLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxPQUFPLENBQUMsR0FBRyxPQUFPLENBQUM7S0FDeEU7O0FBRUQsb0JBQWdCLEVBQUUsS0FBSyxDQUFDLGdCQUFnQjtBQUN4QyxpQkFBYSxFQUFFLG9CQUFvQjs7QUFFbkMsTUFBRSxFQUFFLFlBQVMsQ0FBQyxFQUFFO0FBQ2QsVUFBSSxHQUFHLEdBQUcsWUFBWSxDQUFDLENBQUMsQ0FBQyxDQUFDO0FBQzFCLFNBQUcsQ0FBQyxTQUFTLEdBQUcsWUFBWSxDQUFDLENBQUMsR0FBRyxJQUFJLENBQUMsQ0FBQztBQUN2QyxhQUFPLEdBQUcsQ0FBQztLQUNaOztBQUVELFlBQVEsRUFBRSxFQUFFO0FBQ1osV0FBTyxFQUFFLGlCQUFTLENBQUMsRUFBRSxJQUFJLEVBQUUsbUJBQW1CLEVBQUUsV0FBVyxFQUFFLE1BQU0sRUFBRTtBQUNuRSxVQUFJLGNBQWMsR0FBRyxJQUFJLENBQUMsUUFBUSxDQUFDLENBQUMsQ0FBQztVQUNuQyxFQUFFLEdBQUcsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLENBQUMsQ0FBQztBQUNsQixVQUFJLElBQUksSUFBSSxNQUFNLElBQUksV0FBVyxJQUFJLG1CQUFtQixFQUFFO0FBQ3hELHNCQUFjLEdBQUcsV0FBVyxDQUMxQixJQUFJLEVBQ0osQ0FBQyxFQUNELEVBQUUsRUFDRixJQUFJLEVBQ0osbUJBQW1CLEVBQ25CLFdBQVcsRUFDWCxNQUFNLENBQ1AsQ0FBQztPQUNILE1BQU0sSUFBSSxDQUFDLGNBQWMsRUFBRTtBQUMxQixzQkFBYyxHQUFHLElBQUksQ0FBQyxRQUFRLENBQUMsQ0FBQyxDQUFDLEdBQUcsV0FBVyxDQUFDLElBQUksRUFBRSxDQUFDLEVBQUUsRUFBRSxDQUFDLENBQUM7T0FDOUQ7QUFDRCxhQUFPLGNBQWMsQ0FBQztLQUN2Qjs7QUFFRCxRQUFJLEVBQUUsY0FBUyxLQUFLLEVBQUUsS0FBSyxFQUFFO0FBQzNCLGFBQU8sS0FBSyxJQUFJLEtBQUssRUFBRSxFQUFFO0FBQ3ZCLGFBQUssR0FBRyxLQUFLLENBQUMsT0FBTyxDQUFDO09BQ3ZCO0FBQ0QsYUFBTyxLQUFLLENBQUM7S0FDZDtBQUNELGlCQUFhLEVBQUUsdUJBQVMsS0FBSyxFQUFFLE1BQU0sRUFBRTtBQUNyQyxVQUFJLEdBQUcsR0FBRyxLQUFLLElBQUksTUFBTSxDQUFDOztBQUUxQixVQUFJLEtBQUssSUFBSSxNQUFNLElBQUksS0FBSyxLQUFLLE1BQU0sRUFBRTtBQUN2QyxXQUFHLEdBQUcsS0FBSyxDQUFDLE1BQU0sQ0FBQyxFQUFFLEVBQUUsTUFBTSxFQUFFLEtBQUssQ0FBQyxDQUFDO09BQ3ZDOztBQUVELGFBQU8sR0FBRyxDQUFDO0tBQ1o7O0FBRUQsZUFBVyxFQUFFLE1BQU0sQ0FBQyxJQUFJLENBQUMsRUFBRSxDQUFDOztBQUU1QixRQUFJLEVBQUUsR0FBRyxDQUFDLEVBQUUsQ0FBQyxJQUFJO0FBQ2pCLGdCQUFZLEVBQUUsWUFBWSxDQUFDLFFBQVE7R0FDcEMsQ0FBQzs7QUFFRixXQUFTLEdBQUcsQ0FBQyxPQUFPLEVBQWdCO1FBQWQsT0FBTyx5REFBRyxFQUFFOztBQUNoQyxRQUFJLElBQUksR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDOztBQUV4QixPQUFHLENBQUMsTUFBTSxDQUFDLE9BQU8sQ0FBQyxDQUFDO0FBQ3BCLFFBQUksQ0FBQyxPQUFPLENBQUMsT0FBTyxJQUFJLFlBQVksQ0FBQyxPQUFPLEVBQUU7QUFDNUMsVUFBSSxHQUFHLFFBQVEsQ0FBQyxPQUFPLEVBQUUsSUFBSSxDQUFDLENBQUM7S0FDaEM7QUFDRCxRQUFJLE1BQU0sWUFBQTtRQUNSLFdBQVcsR0FBRyxZQUFZLENBQUMsY0FBYyxHQUFHLEVBQUUsR0FBRyxTQUFTLENBQUM7QUFDN0QsUUFBSSxZQUFZLENBQUMsU0FBUyxFQUFFO0FBQzFCLFVBQUksT0FBTyxDQUFDLE1BQU0sRUFBRTtBQUNsQixjQUFNLEdBQ0osT0FBTyxJQUFJLE9BQU8sQ0FBQyxNQUFNLENBQUMsQ0FBQyxDQUFDLEdBQ3hCLENBQUMsT0FBTyxDQUFDLENBQUMsTUFBTSxDQUFDLE9BQU8sQ0FBQyxNQUFNLENBQUMsR0FDaEMsT0FBTyxDQUFDLE1BQU0sQ0FBQztPQUN0QixNQUFNO0FBQ0wsY0FBTSxHQUFHLENBQUMsT0FBTyxDQUFDLENBQUM7T0FDcEI7S0FDRjs7QUFFRCxhQUFTLElBQUksQ0FBQyxPQUFPLGdCQUFnQjtBQUNuQyxhQUNFLEVBQUUsR0FDRixZQUFZLENBQUMsSUFBSSxDQUNmLFNBQVMsRUFDVCxPQUFPLEVBQ1AsU0FBUyxDQUFDLE9BQU8sRUFDakIsU0FBUyxDQUFDLFFBQVEsRUFDbEIsSUFBSSxFQUNKLFdBQVcsRUFDWCxNQUFNLENBQ1AsQ0FDRDtLQUNIOztBQUVELFFBQUksR0FBRyxpQkFBaUIsQ0FDdEIsWUFBWSxDQUFDLElBQUksRUFDakIsSUFBSSxFQUNKLFNBQVMsRUFDVCxPQUFPLENBQUMsTUFBTSxJQUFJLEVBQUUsRUFDcEIsSUFBSSxFQUNKLFdBQVcsQ0FDWixDQUFDO0FBQ0YsV0FBTyxJQUFJLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO0dBQy9COztBQUVELEtBQUcsQ0FBQyxLQUFLLEdBQUcsSUFBSSxDQUFDOztBQUVqQixLQUFHLENBQUMsTUFBTSxHQUFHLFVBQVMsT0FBTyxFQUFFO0FBQzdCLFFBQUksQ0FBQyxPQUFPLENBQUMsT0FBTyxFQUFFO0FBQ3BCLFVBQUksYUFBYSxHQUFHLEtBQUssQ0FBQyxNQUFNLENBQUMsRUFBRSxFQUFFLEdBQUcsQ0FBQyxPQUFPLEVBQUUsT0FBTyxDQUFDLE9BQU8sQ0FBQyxDQUFDO0FBQ25FLHFDQUErQixDQUFDLGFBQWEsRUFBRSxTQUFTLENBQUMsQ0FBQztBQUMxRCxlQUFTLENBQUMsT0FBTyxHQUFHLGFBQWEsQ0FBQzs7QUFFbEMsVUFBSSxZQUFZLENBQUMsVUFBVSxFQUFFOztBQUUzQixpQkFBUyxDQUFDLFFBQVEsR0FBRyxTQUFTLENBQUMsYUFBYSxDQUMxQyxPQUFPLENBQUMsUUFBUSxFQUNoQixHQUFHLENBQUMsUUFBUSxDQUNiLENBQUM7T0FDSDtBQUNELFVBQUksWUFBWSxDQUFDLFVBQVUsSUFBSSxZQUFZLENBQUMsYUFBYSxFQUFFO0FBQ3pELGlCQUFTLENBQUMsVUFBVSxHQUFHLEtBQUssQ0FBQyxNQUFNLENBQ2pDLEVBQUUsRUFDRixHQUFHLENBQUMsVUFBVSxFQUNkLE9BQU8sQ0FBQyxVQUFVLENBQ25CLENBQUM7T0FDSDs7QUFFRCxlQUFTLENBQUMsS0FBSyxHQUFHLEVBQUUsQ0FBQztBQUNyQixlQUFTLENBQUMsa0JBQWtCLEdBQUcsOENBQXlCLE9BQU8sQ0FBQyxDQUFDOztBQUVqRSxVQUFJLG1CQUFtQixHQUNyQixPQUFPLENBQUMseUJBQXlCLElBQ2pDLG9DQUFvQyxDQUFDO0FBQ3ZDLGlDQUFrQixTQUFTLEVBQUUsZUFBZSxFQUFFLG1CQUFtQixDQUFDLENBQUM7QUFDbkUsaUNBQWtCLFNBQVMsRUFBRSxvQkFBb0IsRUFBRSxtQkFBbUIsQ0FBQyxDQUFDO0tBQ3pFLE1BQU07QUFDTCxlQUFTLENBQUMsa0JBQWtCLEdBQUcsT0FBTyxDQUFDLGtCQUFrQixDQUFDO0FBQzFELGVBQVMsQ0FBQyxPQUFPLEdBQUcsT0FBTyxDQUFDLE9BQU8sQ0FBQztBQUNwQyxlQUFTLENBQUMsUUFBUSxHQUFHLE9BQU8sQ0FBQyxRQUFRLENBQUM7QUFDdEMsZUFBUyxDQUFDLFVBQVUsR0FBRyxPQUFPLENBQUMsVUFBVSxDQUFDO0FBQzFDLGVBQVMsQ0FBQyxLQUFLLEdBQUcsT0FBTyxDQUFDLEtBQUssQ0FBQztLQUNqQztHQUNGLENBQUM7O0FBRUYsS0FBRyxDQUFDLE1BQU0sR0FBRyxVQUFTLENBQUMsRUFBRSxJQUFJLEVBQUUsV0FBVyxFQUFFLE1BQU0sRUFBRTtBQUNsRCxRQUFJLFlBQVksQ0FBQyxjQUFjLElBQUksQ0FBQyxXQUFXLEVBQUU7QUFDL0MsWUFBTSwyQkFBYyx3QkFBd0IsQ0FBQyxDQUFDO0tBQy9DO0FBQ0QsUUFBSSxZQUFZLENBQUMsU0FBUyxJQUFJLENBQUMsTUFBTSxFQUFFO0FBQ3JDLFlBQU0sMkJBQWMseUJBQXlCLENBQUMsQ0FBQztLQUNoRDs7QUFFRCxXQUFPLFdBQVcsQ0FDaEIsU0FBUyxFQUNULENBQUMsRUFDRCxZQUFZLENBQUMsQ0FBQyxDQUFDLEVBQ2YsSUFBSSxFQUNKLENBQUMsRUFDRCxXQUFXLEVBQ1gsTUFBTSxDQUNQLENBQUM7R0FDSCxDQUFDO0FBQ0YsU0FBTyxHQUFHLENBQUM7Q0FDWjs7QUFFTSxTQUFTLFdBQVcsQ0FDekIsU0FBUyxFQUNULENBQUMsRUFDRCxFQUFFLEVBQ0YsSUFBSSxFQUNKLG1CQUFtQixFQUNuQixXQUFXLEVBQ1gsTUFBTSxFQUNOO0FBQ0EsV0FBUyxJQUFJLENBQUMsT0FBTyxFQUFnQjtRQUFkLE9BQU8seURBQUcsRUFBRTs7QUFDakMsUUFBSSxhQUFhLEdBQUcsTUFBTSxDQUFDO0FBQzNCLFFBQ0UsTUFBTSxJQUNOLE9BQU8sSUFBSSxNQUFNLENBQUMsQ0FBQyxDQUFDLElBQ3BCLEVBQUUsT0FBTyxLQUFLLFNBQVMsQ0FBQyxXQUFXLElBQUksTUFBTSxDQUFDLENBQUMsQ0FBQyxLQUFLLElBQUksQ0FBQSxBQUFDLEVBQzFEO0FBQ0EsbUJBQWEsR0FBRyxDQUFDLE9BQU8sQ0FBQyxDQUFDLE1BQU0sQ0FBQyxNQUFNLENBQUMsQ0FBQztLQUMxQzs7QUFFRCxXQUFPLEVBQUUsQ0FDUCxTQUFTLEVBQ1QsT0FBTyxFQUNQLFNBQVMsQ0FBQyxPQUFPLEVBQ2pCLFNBQVMsQ0FBQyxRQUFRLEVBQ2xCLE9BQU8sQ0FBQyxJQUFJLElBQUksSUFBSSxFQUNwQixXQUFXLElBQUksQ0FBQyxPQUFPLENBQUMsV0FBVyxDQUFDLENBQUMsTUFBTSxDQUFDLFdBQVcsQ0FBQyxFQUN4RCxhQUFhLENBQ2QsQ0FBQztHQUNIOztBQUVELE1BQUksR0FBRyxpQkFBaUIsQ0FBQyxFQUFFLEVBQUUsSUFBSSxFQUFFLFNBQVMsRUFBRSxNQUFNLEVBQUUsSUFBSSxFQUFFLFdBQVcsQ0FBQyxDQUFDOztBQUV6RSxNQUFJLENBQUMsT0FBTyxHQUFHLENBQUMsQ0FBQztBQUNqQixNQUFJLENBQUMsS0FBSyxHQUFHLE1BQU0sR0FBRyxNQUFNLENBQUMsTUFBTSxHQUFHLENBQUMsQ0FBQztBQUN4QyxNQUFJLENBQUMsV0FBVyxHQUFHLG1CQUFtQixJQUFJLENBQUMsQ0FBQztBQUM1QyxTQUFPLElBQUksQ0FBQztDQUNiOzs7Ozs7QUFLTSxTQUFTLGNBQWMsQ0FBQyxPQUFPLEVBQUUsT0FBTyxFQUFFLE9BQU8sRUFBRTtBQUN4RCxNQUFJLENBQUMsT0FBTyxFQUFFO0FBQ1osUUFBSSxPQUFPLENBQUMsSUFBSSxLQUFLLGdCQUFnQixFQUFFO0FBQ3JDLGFBQU8sR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLGVBQWUsQ0FBQyxDQUFDO0tBQ3pDLE1BQU07QUFDTCxhQUFPLEdBQUcsT0FBTyxDQUFDLFFBQVEsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDMUM7R0FDRixNQUFNLElBQUksQ0FBQyxPQUFPLENBQUMsSUFBSSxJQUFJLENBQUMsT0FBTyxDQUFDLElBQUksRUFBRTs7QUFFekMsV0FBTyxDQUFDLElBQUksR0FBRyxPQUFPLENBQUM7QUFDdkIsV0FBTyxHQUFHLE9BQU8sQ0FBQyxRQUFRLENBQUMsT0FBTyxDQUFDLENBQUM7R0FDckM7QUFDRCxTQUFPLE9BQU8sQ0FBQztDQUNoQjs7QUFFTSxTQUFTLGFBQWEsQ0FBQyxPQUFPLEVBQUUsT0FBTyxFQUFFLE9BQU8sRUFBRTs7QUFFdkQsTUFBTSxtQkFBbUIsR0FBRyxPQUFPLENBQUMsSUFBSSxJQUFJLE9BQU8sQ0FBQyxJQUFJLENBQUMsZUFBZSxDQUFDLENBQUM7QUFDMUUsU0FBTyxDQUFDLE9BQU8sR0FBRyxJQUFJLENBQUM7QUFDdkIsTUFBSSxPQUFPLENBQUMsR0FBRyxFQUFFO0FBQ2YsV0FBTyxDQUFDLElBQUksQ0FBQyxXQUFXLEdBQUcsT0FBTyxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUMsSUFBSSxPQUFPLENBQUMsSUFBSSxDQUFDLFdBQVcsQ0FBQztHQUN2RTs7QUFFRCxNQUFJLFlBQVksWUFBQSxDQUFDO0FBQ2pCLE1BQUksT0FBTyxDQUFDLEVBQUUsSUFBSSxPQUFPLENBQUMsRUFBRSxLQUFLLElBQUksRUFBRTs7QUFDckMsYUFBTyxDQUFDLElBQUksR0FBRyxrQkFBWSxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7O0FBRXpDLFVBQUksRUFBRSxHQUFHLE9BQU8sQ0FBQyxFQUFFLENBQUM7QUFDcEIsa0JBQVksR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLGVBQWUsQ0FBQyxHQUFHLFNBQVMsbUJBQW1CLENBQ3pFLE9BQU8sRUFFUDtZQURBLE9BQU8seURBQUcsRUFBRTs7OztBQUlaLGVBQU8sQ0FBQyxJQUFJLEdBQUcsa0JBQVksT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0FBQ3pDLGVBQU8sQ0FBQyxJQUFJLENBQUMsZUFBZSxDQUFDLEdBQUcsbUJBQW1CLENBQUM7QUFDcEQsZUFBTyxFQUFFLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO09BQzdCLENBQUM7QUFDRixVQUFJLEVBQUUsQ0FBQyxRQUFRLEVBQUU7QUFDZixlQUFPLENBQUMsUUFBUSxHQUFHLEtBQUssQ0FBQyxNQUFNLENBQUMsRUFBRSxFQUFFLE9BQU8sQ0FBQyxRQUFRLEVBQUUsRUFBRSxDQUFDLFFBQVEsQ0FBQyxDQUFDO09BQ3BFOztHQUNGOztBQUVELE1BQUksT0FBTyxLQUFLLFNBQVMsSUFBSSxZQUFZLEVBQUU7QUFDekMsV0FBTyxHQUFHLFlBQVksQ0FBQztHQUN4Qjs7QUFFRCxNQUFJLE9BQU8sS0FBSyxTQUFTLEVBQUU7QUFDekIsVUFBTSwyQkFBYyxjQUFjLEdBQUcsT0FBTyxDQUFDLElBQUksR0FBRyxxQkFBcUIsQ0FBQyxDQUFDO0dBQzVFLE1BQU0sSUFBSSxPQUFPLFlBQVksUUFBUSxFQUFFO0FBQ3RDLFdBQU8sT0FBTyxDQUFDLE9BQU8sRUFBRSxPQUFPLENBQUMsQ0FBQztHQUNsQztDQUNGOztBQUVNLFNBQVMsSUFBSSxHQUFHO0FBQ3JCLFNBQU8sRUFBRSxDQUFDO0NBQ1g7O0FBRUQsU0FBUyxRQUFRLENBQUMsT0FBTyxFQUFFLElBQUksRUFBRTtBQUMvQixNQUFJLENBQUMsSUFBSSxJQUFJLEVBQUUsTUFBTSxJQUFJLElBQUksQ0FBQSxBQUFDLEVBQUU7QUFDOUIsUUFBSSxHQUFHLElBQUksR0FBRyxrQkFBWSxJQUFJLENBQUMsR0FBRyxFQUFFLENBQUM7QUFDckMsUUFBSSxDQUFDLElBQUksR0FBRyxPQUFPLENBQUM7R0FDckI7QUFDRCxTQUFPLElBQUksQ0FBQztDQUNiOztBQUVELFNBQVMsaUJBQWlCLENBQUMsRUFBRSxFQUFFLElBQUksRUFBRSxTQUFTLEVBQUUsTUFBTSxFQUFFLElBQUksRUFBRSxXQUFXLEVBQUU7QUFDekUsTUFBSSxFQUFFLENBQUMsU0FBUyxFQUFFO0FBQ2hCLFFBQUksS0FBSyxHQUFHLEVBQUUsQ0FBQztBQUNmLFFBQUksR0FBRyxFQUFFLENBQUMsU0FBUyxDQUNqQixJQUFJLEVBQ0osS0FBSyxFQUNMLFNBQVMsRUFDVCxNQUFNLElBQUksTUFBTSxDQUFDLENBQUMsQ0FBQyxFQUNuQixJQUFJLEVBQ0osV0FBVyxFQUNYLE1BQU0sQ0FDUCxDQUFDO0FBQ0YsU0FBSyxDQUFDLE1BQU0sQ0FBQyxJQUFJLEVBQUUsS0FBSyxDQUFDLENBQUM7R0FDM0I7QUFDRCxTQUFPLElBQUksQ0FBQztDQUNiOztBQUVELFNBQVMsK0JBQStCLENBQUMsYUFBYSxFQUFFLFNBQVMsRUFBRTtBQUNqRSxRQUFNLENBQUMsSUFBSSxDQUFDLGFBQWEsQ0FBQyxDQUFDLE9BQU8sQ0FBQyxVQUFBLFVBQVUsRUFBSTtBQUMvQyxRQUFJLE1BQU0sR0FBRyxhQUFhLENBQUMsVUFBVSxDQUFDLENBQUM7QUFDdkMsaUJBQWEsQ0FBQyxVQUFVLENBQUMsR0FBRyx3QkFBd0IsQ0FBQyxNQUFNLEVBQUUsU0FBUyxDQUFDLENBQUM7R0FDekUsQ0FBQyxDQUFDO0NBQ0o7O0FBRUQsU0FBUyx3QkFBd0IsQ0FBQyxNQUFNLEVBQUUsU0FBUyxFQUFFO0FBQ25ELE1BQU0sY0FBYyxHQUFHLFNBQVMsQ0FBQyxjQUFjLENBQUM7QUFDaEQsU0FBTywrQkFBVyxNQUFNLEVBQUUsVUFBQSxPQUFPLEVBQUk7QUFDbkMsV0FBTyxLQUFLLENBQUMsTUFBTSxDQUFDLEVBQUUsY0FBYyxFQUFkLGNBQWMsRUFBRSxFQUFFLE9BQU8sQ0FBQyxDQUFDO0dBQ2xELENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6InJ1bnRpbWUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBVdGlscyBmcm9tICcuL3V0aWxzJztcbmltcG9ydCBFeGNlcHRpb24gZnJvbSAnLi9leGNlcHRpb24nO1xuaW1wb3J0IHtcbiAgQ09NUElMRVJfUkVWSVNJT04sXG4gIGNyZWF0ZUZyYW1lLFxuICBMQVNUX0NPTVBBVElCTEVfQ09NUElMRVJfUkVWSVNJT04sXG4gIFJFVklTSU9OX0NIQU5HRVNcbn0gZnJvbSAnLi9iYXNlJztcbmltcG9ydCB7IG1vdmVIZWxwZXJUb0hvb2tzIH0gZnJvbSAnLi9oZWxwZXJzJztcbmltcG9ydCB7IHdyYXBIZWxwZXIgfSBmcm9tICcuL2ludGVybmFsL3dyYXBIZWxwZXInO1xuaW1wb3J0IHtcbiAgY3JlYXRlUHJvdG9BY2Nlc3NDb250cm9sLFxuICByZXN1bHRJc0FsbG93ZWRcbn0gZnJvbSAnLi9pbnRlcm5hbC9wcm90by1hY2Nlc3MnO1xuXG5leHBvcnQgZnVuY3Rpb24gY2hlY2tSZXZpc2lvbihjb21waWxlckluZm8pIHtcbiAgY29uc3QgY29tcGlsZXJSZXZpc2lvbiA9IChjb21waWxlckluZm8gJiYgY29tcGlsZXJJbmZvWzBdKSB8fCAxLFxuICAgIGN1cnJlbnRSZXZpc2lvbiA9IENPTVBJTEVSX1JFVklTSU9OO1xuXG4gIGlmIChcbiAgICBjb21waWxlclJldmlzaW9uID49IExBU1RfQ09NUEFUSUJMRV9DT01QSUxFUl9SRVZJU0lPTiAmJlxuICAgIGNvbXBpbGVyUmV2aXNpb24gPD0gQ09NUElMRVJfUkVWSVNJT05cbiAgKSB7XG4gICAgcmV0dXJuO1xuICB9XG5cbiAgaWYgKGNvbXBpbGVyUmV2aXNpb24gPCBMQVNUX0NPTVBBVElCTEVfQ09NUElMRVJfUkVWSVNJT04pIHtcbiAgICBjb25zdCBydW50aW1lVmVyc2lvbnMgPSBSRVZJU0lPTl9DSEFOR0VTW2N1cnJlbnRSZXZpc2lvbl0sXG4gICAgICBjb21waWxlclZlcnNpb25zID0gUkVWSVNJT05fQ0hBTkdFU1tjb21waWxlclJldmlzaW9uXTtcbiAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKFxuICAgICAgJ1RlbXBsYXRlIHdhcyBwcmVjb21waWxlZCB3aXRoIGFuIG9sZGVyIHZlcnNpb24gb2YgSGFuZGxlYmFycyB0aGFuIHRoZSBjdXJyZW50IHJ1bnRpbWUuICcgK1xuICAgICAgICAnUGxlYXNlIHVwZGF0ZSB5b3VyIHByZWNvbXBpbGVyIHRvIGEgbmV3ZXIgdmVyc2lvbiAoJyArXG4gICAgICAgIHJ1bnRpbWVWZXJzaW9ucyArXG4gICAgICAgICcpIG9yIGRvd25ncmFkZSB5b3VyIHJ1bnRpbWUgdG8gYW4gb2xkZXIgdmVyc2lvbiAoJyArXG4gICAgICAgIGNvbXBpbGVyVmVyc2lvbnMgK1xuICAgICAgICAnKS4nXG4gICAgKTtcbiAgfSBlbHNlIHtcbiAgICAvLyBVc2UgdGhlIGVtYmVkZGVkIHZlcnNpb24gaW5mbyBzaW5jZSB0aGUgcnVudGltZSBkb2Vzbid0IGtub3cgYWJvdXQgdGhpcyByZXZpc2lvbiB5ZXRcbiAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKFxuICAgICAgJ1RlbXBsYXRlIHdhcyBwcmVjb21waWxlZCB3aXRoIGEgbmV3ZXIgdmVyc2lvbiBvZiBIYW5kbGViYXJzIHRoYW4gdGhlIGN1cnJlbnQgcnVudGltZS4gJyArXG4gICAgICAgICdQbGVhc2UgdXBkYXRlIHlvdXIgcnVudGltZSB0byBhIG5ld2VyIHZlcnNpb24gKCcgK1xuICAgICAgICBjb21waWxlckluZm9bMV0gK1xuICAgICAgICAnKS4nXG4gICAgKTtcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gdGVtcGxhdGUodGVtcGxhdGVTcGVjLCBlbnYpIHtcbiAgLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbiAgaWYgKCFlbnYpIHtcbiAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdObyBlbnZpcm9ubWVudCBwYXNzZWQgdG8gdGVtcGxhdGUnKTtcbiAgfVxuICBpZiAoIXRlbXBsYXRlU3BlYyB8fCAhdGVtcGxhdGVTcGVjLm1haW4pIHtcbiAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdVbmtub3duIHRlbXBsYXRlIG9iamVjdDogJyArIHR5cGVvZiB0ZW1wbGF0ZVNwZWMpO1xuICB9XG5cbiAgdGVtcGxhdGVTcGVjLm1haW4uZGVjb3JhdG9yID0gdGVtcGxhdGVTcGVjLm1haW5fZDtcblxuICAvLyBOb3RlOiBVc2luZyBlbnYuVk0gcmVmZXJlbmNlcyByYXRoZXIgdGhhbiBsb2NhbCB2YXIgcmVmZXJlbmNlcyB0aHJvdWdob3V0IHRoaXMgc2VjdGlvbiB0byBhbGxvd1xuICAvLyBmb3IgZXh0ZXJuYWwgdXNlcnMgdG8gb3ZlcnJpZGUgdGhlc2UgYXMgcHNldWRvLXN1cHBvcnRlZCBBUElzLlxuICBlbnYuVk0uY2hlY2tSZXZpc2lvbih0ZW1wbGF0ZVNwZWMuY29tcGlsZXIpO1xuXG4gIC8vIGJhY2t3YXJkcyBjb21wYXRpYmlsaXR5IGZvciBwcmVjb21waWxlZCB0ZW1wbGF0ZXMgd2l0aCBjb21waWxlci12ZXJzaW9uIDcgKDw0LjMuMClcbiAgY29uc3QgdGVtcGxhdGVXYXNQcmVjb21waWxlZFdpdGhDb21waWxlclY3ID1cbiAgICB0ZW1wbGF0ZVNwZWMuY29tcGlsZXIgJiYgdGVtcGxhdGVTcGVjLmNvbXBpbGVyWzBdID09PSA3O1xuXG4gIGZ1bmN0aW9uIGludm9rZVBhcnRpYWxXcmFwcGVyKHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAob3B0aW9ucy5oYXNoKSB7XG4gICAgICBjb250ZXh0ID0gVXRpbHMuZXh0ZW5kKHt9LCBjb250ZXh0LCBvcHRpb25zLmhhc2gpO1xuICAgICAgaWYgKG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIG9wdGlvbnMuaWRzWzBdID0gdHJ1ZTtcbiAgICAgIH1cbiAgICB9XG4gICAgcGFydGlhbCA9IGVudi5WTS5yZXNvbHZlUGFydGlhbC5jYWxsKHRoaXMsIHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpO1xuXG4gICAgbGV0IGV4dGVuZGVkT3B0aW9ucyA9IFV0aWxzLmV4dGVuZCh7fSwgb3B0aW9ucywge1xuICAgICAgaG9va3M6IHRoaXMuaG9va3MsXG4gICAgICBwcm90b0FjY2Vzc0NvbnRyb2w6IHRoaXMucHJvdG9BY2Nlc3NDb250cm9sXG4gICAgfSk7XG5cbiAgICBsZXQgcmVzdWx0ID0gZW52LlZNLmludm9rZVBhcnRpYWwuY2FsbChcbiAgICAgIHRoaXMsXG4gICAgICBwYXJ0aWFsLFxuICAgICAgY29udGV4dCxcbiAgICAgIGV4dGVuZGVkT3B0aW9uc1xuICAgICk7XG5cbiAgICBpZiAocmVzdWx0ID09IG51bGwgJiYgZW52LmNvbXBpbGUpIHtcbiAgICAgIG9wdGlvbnMucGFydGlhbHNbb3B0aW9ucy5uYW1lXSA9IGVudi5jb21waWxlKFxuICAgICAgICBwYXJ0aWFsLFxuICAgICAgICB0ZW1wbGF0ZVNwZWMuY29tcGlsZXJPcHRpb25zLFxuICAgICAgICBlbnZcbiAgICAgICk7XG4gICAgICByZXN1bHQgPSBvcHRpb25zLnBhcnRpYWxzW29wdGlvbnMubmFtZV0oY29udGV4dCwgZXh0ZW5kZWRPcHRpb25zKTtcbiAgICB9XG4gICAgaWYgKHJlc3VsdCAhPSBudWxsKSB7XG4gICAgICBpZiAob3B0aW9ucy5pbmRlbnQpIHtcbiAgICAgICAgbGV0IGxpbmVzID0gcmVzdWx0LnNwbGl0KCdcXG4nKTtcbiAgICAgICAgZm9yIChsZXQgaSA9IDAsIGwgPSBsaW5lcy5sZW5ndGg7IGkgPCBsOyBpKyspIHtcbiAgICAgICAgICBpZiAoIWxpbmVzW2ldICYmIGkgKyAxID09PSBsKSB7XG4gICAgICAgICAgICBicmVhaztcbiAgICAgICAgICB9XG5cbiAgICAgICAgICBsaW5lc1tpXSA9IG9wdGlvbnMuaW5kZW50ICsgbGluZXNbaV07XG4gICAgICAgIH1cbiAgICAgICAgcmVzdWx0ID0gbGluZXMuam9pbignXFxuJyk7XG4gICAgICB9XG4gICAgICByZXR1cm4gcmVzdWx0O1xuICAgIH0gZWxzZSB7XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKFxuICAgICAgICAnVGhlIHBhcnRpYWwgJyArXG4gICAgICAgICAgb3B0aW9ucy5uYW1lICtcbiAgICAgICAgICAnIGNvdWxkIG5vdCBiZSBjb21waWxlZCB3aGVuIHJ1bm5pbmcgaW4gcnVudGltZS1vbmx5IG1vZGUnXG4gICAgICApO1xuICAgIH1cbiAgfVxuXG4gIC8vIEp1c3QgYWRkIHdhdGVyXG4gIGxldCBjb250YWluZXIgPSB7XG4gICAgc3RyaWN0OiBmdW5jdGlvbihvYmosIG5hbWUsIGxvYykge1xuICAgICAgaWYgKCFvYmogfHwgIShuYW1lIGluIG9iaikpIHtcbiAgICAgICAgdGhyb3cgbmV3IEV4Y2VwdGlvbignXCInICsgbmFtZSArICdcIiBub3QgZGVmaW5lZCBpbiAnICsgb2JqLCB7XG4gICAgICAgICAgbG9jOiBsb2NcbiAgICAgICAgfSk7XG4gICAgICB9XG4gICAgICByZXR1cm4gY29udGFpbmVyLmxvb2t1cFByb3BlcnR5KG9iaiwgbmFtZSk7XG4gICAgfSxcbiAgICBsb29rdXBQcm9wZXJ0eTogZnVuY3Rpb24ocGFyZW50LCBwcm9wZXJ0eU5hbWUpIHtcbiAgICAgIGxldCByZXN1bHQgPSBwYXJlbnRbcHJvcGVydHlOYW1lXTtcbiAgICAgIGlmIChyZXN1bHQgPT0gbnVsbCkge1xuICAgICAgICByZXR1cm4gcmVzdWx0O1xuICAgICAgfVxuICAgICAgaWYgKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChwYXJlbnQsIHByb3BlcnR5TmFtZSkpIHtcbiAgICAgICAgcmV0dXJuIHJlc3VsdDtcbiAgICAgIH1cblxuICAgICAgaWYgKHJlc3VsdElzQWxsb3dlZChyZXN1bHQsIGNvbnRhaW5lci5wcm90b0FjY2Vzc0NvbnRyb2wsIHByb3BlcnR5TmFtZSkpIHtcbiAgICAgICAgcmV0dXJuIHJlc3VsdDtcbiAgICAgIH1cbiAgICAgIHJldHVybiB1bmRlZmluZWQ7XG4gICAgfSxcbiAgICBsb29rdXA6IGZ1bmN0aW9uKGRlcHRocywgbmFtZSkge1xuICAgICAgY29uc3QgbGVuID0gZGVwdGhzLmxlbmd0aDtcbiAgICAgIGZvciAobGV0IGkgPSAwOyBpIDwgbGVuOyBpKyspIHtcbiAgICAgICAgbGV0IHJlc3VsdCA9IGRlcHRoc1tpXSAmJiBjb250YWluZXIubG9va3VwUHJvcGVydHkoZGVwdGhzW2ldLCBuYW1lKTtcbiAgICAgICAgaWYgKHJlc3VsdCAhPSBudWxsKSB7XG4gICAgICAgICAgcmV0dXJuIGRlcHRoc1tpXVtuYW1lXTtcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH0sXG4gICAgbGFtYmRhOiBmdW5jdGlvbihjdXJyZW50LCBjb250ZXh0KSB7XG4gICAgICByZXR1cm4gdHlwZW9mIGN1cnJlbnQgPT09ICdmdW5jdGlvbicgPyBjdXJyZW50LmNhbGwoY29udGV4dCkgOiBjdXJyZW50O1xuICAgIH0sXG5cbiAgICBlc2NhcGVFeHByZXNzaW9uOiBVdGlscy5lc2NhcGVFeHByZXNzaW9uLFxuICAgIGludm9rZVBhcnRpYWw6IGludm9rZVBhcnRpYWxXcmFwcGVyLFxuXG4gICAgZm46IGZ1bmN0aW9uKGkpIHtcbiAgICAgIGxldCByZXQgPSB0ZW1wbGF0ZVNwZWNbaV07XG4gICAgICByZXQuZGVjb3JhdG9yID0gdGVtcGxhdGVTcGVjW2kgKyAnX2QnXTtcbiAgICAgIHJldHVybiByZXQ7XG4gICAgfSxcblxuICAgIHByb2dyYW1zOiBbXSxcbiAgICBwcm9ncmFtOiBmdW5jdGlvbihpLCBkYXRhLCBkZWNsYXJlZEJsb2NrUGFyYW1zLCBibG9ja1BhcmFtcywgZGVwdGhzKSB7XG4gICAgICBsZXQgcHJvZ3JhbVdyYXBwZXIgPSB0aGlzLnByb2dyYW1zW2ldLFxuICAgICAgICBmbiA9IHRoaXMuZm4oaSk7XG4gICAgICBpZiAoZGF0YSB8fCBkZXB0aHMgfHwgYmxvY2tQYXJhbXMgfHwgZGVjbGFyZWRCbG9ja1BhcmFtcykge1xuICAgICAgICBwcm9ncmFtV3JhcHBlciA9IHdyYXBQcm9ncmFtKFxuICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgaSxcbiAgICAgICAgICBmbixcbiAgICAgICAgICBkYXRhLFxuICAgICAgICAgIGRlY2xhcmVkQmxvY2tQYXJhbXMsXG4gICAgICAgICAgYmxvY2tQYXJhbXMsXG4gICAgICAgICAgZGVwdGhzXG4gICAgICAgICk7XG4gICAgICB9IGVsc2UgaWYgKCFwcm9ncmFtV3JhcHBlcikge1xuICAgICAgICBwcm9ncmFtV3JhcHBlciA9IHRoaXMucHJvZ3JhbXNbaV0gPSB3cmFwUHJvZ3JhbSh0aGlzLCBpLCBmbik7XG4gICAgICB9XG4gICAgICByZXR1cm4gcHJvZ3JhbVdyYXBwZXI7XG4gICAgfSxcblxuICAgIGRhdGE6IGZ1bmN0aW9uKHZhbHVlLCBkZXB0aCkge1xuICAgICAgd2hpbGUgKHZhbHVlICYmIGRlcHRoLS0pIHtcbiAgICAgICAgdmFsdWUgPSB2YWx1ZS5fcGFyZW50O1xuICAgICAgfVxuICAgICAgcmV0dXJuIHZhbHVlO1xuICAgIH0sXG4gICAgbWVyZ2VJZk5lZWRlZDogZnVuY3Rpb24ocGFyYW0sIGNvbW1vbikge1xuICAgICAgbGV0IG9iaiA9IHBhcmFtIHx8IGNvbW1vbjtcblxuICAgICAgaWYgKHBhcmFtICYmIGNvbW1vbiAmJiBwYXJhbSAhPT0gY29tbW9uKSB7XG4gICAgICAgIG9iaiA9IFV0aWxzLmV4dGVuZCh7fSwgY29tbW9uLCBwYXJhbSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiBvYmo7XG4gICAgfSxcbiAgICAvLyBBbiBlbXB0eSBvYmplY3QgdG8gdXNlIGFzIHJlcGxhY2VtZW50IGZvciBudWxsLWNvbnRleHRzXG4gICAgbnVsbENvbnRleHQ6IE9iamVjdC5zZWFsKHt9KSxcblxuICAgIG5vb3A6IGVudi5WTS5ub29wLFxuICAgIGNvbXBpbGVySW5mbzogdGVtcGxhdGVTcGVjLmNvbXBpbGVyXG4gIH07XG5cbiAgZnVuY3Rpb24gcmV0KGNvbnRleHQsIG9wdGlvbnMgPSB7fSkge1xuICAgIGxldCBkYXRhID0gb3B0aW9ucy5kYXRhO1xuXG4gICAgcmV0Ll9zZXR1cChvcHRpb25zKTtcbiAgICBpZiAoIW9wdGlvbnMucGFydGlhbCAmJiB0ZW1wbGF0ZVNwZWMudXNlRGF0YSkge1xuICAgICAgZGF0YSA9IGluaXREYXRhKGNvbnRleHQsIGRhdGEpO1xuICAgIH1cbiAgICBsZXQgZGVwdGhzLFxuICAgICAgYmxvY2tQYXJhbXMgPSB0ZW1wbGF0ZVNwZWMudXNlQmxvY2tQYXJhbXMgPyBbXSA6IHVuZGVmaW5lZDtcbiAgICBpZiAodGVtcGxhdGVTcGVjLnVzZURlcHRocykge1xuICAgICAgaWYgKG9wdGlvbnMuZGVwdGhzKSB7XG4gICAgICAgIGRlcHRocyA9XG4gICAgICAgICAgY29udGV4dCAhPSBvcHRpb25zLmRlcHRoc1swXVxuICAgICAgICAgICAgPyBbY29udGV4dF0uY29uY2F0KG9wdGlvbnMuZGVwdGhzKVxuICAgICAgICAgICAgOiBvcHRpb25zLmRlcHRocztcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGRlcHRocyA9IFtjb250ZXh0XTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICBmdW5jdGlvbiBtYWluKGNvbnRleHQgLyosIG9wdGlvbnMqLykge1xuICAgICAgcmV0dXJuIChcbiAgICAgICAgJycgK1xuICAgICAgICB0ZW1wbGF0ZVNwZWMubWFpbihcbiAgICAgICAgICBjb250YWluZXIsXG4gICAgICAgICAgY29udGV4dCxcbiAgICAgICAgICBjb250YWluZXIuaGVscGVycyxcbiAgICAgICAgICBjb250YWluZXIucGFydGlhbHMsXG4gICAgICAgICAgZGF0YSxcbiAgICAgICAgICBibG9ja1BhcmFtcyxcbiAgICAgICAgICBkZXB0aHNcbiAgICAgICAgKVxuICAgICAgKTtcbiAgICB9XG5cbiAgICBtYWluID0gZXhlY3V0ZURlY29yYXRvcnMoXG4gICAgICB0ZW1wbGF0ZVNwZWMubWFpbixcbiAgICAgIG1haW4sXG4gICAgICBjb250YWluZXIsXG4gICAgICBvcHRpb25zLmRlcHRocyB8fCBbXSxcbiAgICAgIGRhdGEsXG4gICAgICBibG9ja1BhcmFtc1xuICAgICk7XG4gICAgcmV0dXJuIG1haW4oY29udGV4dCwgb3B0aW9ucyk7XG4gIH1cblxuICByZXQuaXNUb3AgPSB0cnVlO1xuXG4gIHJldC5fc2V0dXAgPSBmdW5jdGlvbihvcHRpb25zKSB7XG4gICAgaWYgKCFvcHRpb25zLnBhcnRpYWwpIHtcbiAgICAgIGxldCBtZXJnZWRIZWxwZXJzID0gVXRpbHMuZXh0ZW5kKHt9LCBlbnYuaGVscGVycywgb3B0aW9ucy5oZWxwZXJzKTtcbiAgICAgIHdyYXBIZWxwZXJzVG9QYXNzTG9va3VwUHJvcGVydHkobWVyZ2VkSGVscGVycywgY29udGFpbmVyKTtcbiAgICAgIGNvbnRhaW5lci5oZWxwZXJzID0gbWVyZ2VkSGVscGVycztcblxuICAgICAgaWYgKHRlbXBsYXRlU3BlYy51c2VQYXJ0aWFsKSB7XG4gICAgICAgIC8vIFVzZSBtZXJnZUlmTmVlZGVkIGhlcmUgdG8gcHJldmVudCBjb21waWxpbmcgZ2xvYmFsIHBhcnRpYWxzIG11bHRpcGxlIHRpbWVzXG4gICAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IGNvbnRhaW5lci5tZXJnZUlmTmVlZGVkKFxuICAgICAgICAgIG9wdGlvbnMucGFydGlhbHMsXG4gICAgICAgICAgZW52LnBhcnRpYWxzXG4gICAgICAgICk7XG4gICAgICB9XG4gICAgICBpZiAodGVtcGxhdGVTcGVjLnVzZVBhcnRpYWwgfHwgdGVtcGxhdGVTcGVjLnVzZURlY29yYXRvcnMpIHtcbiAgICAgICAgY29udGFpbmVyLmRlY29yYXRvcnMgPSBVdGlscy5leHRlbmQoXG4gICAgICAgICAge30sXG4gICAgICAgICAgZW52LmRlY29yYXRvcnMsXG4gICAgICAgICAgb3B0aW9ucy5kZWNvcmF0b3JzXG4gICAgICAgICk7XG4gICAgICB9XG5cbiAgICAgIGNvbnRhaW5lci5ob29rcyA9IHt9O1xuICAgICAgY29udGFpbmVyLnByb3RvQWNjZXNzQ29udHJvbCA9IGNyZWF0ZVByb3RvQWNjZXNzQ29udHJvbChvcHRpb25zKTtcblxuICAgICAgbGV0IGtlZXBIZWxwZXJJbkhlbHBlcnMgPVxuICAgICAgICBvcHRpb25zLmFsbG93Q2FsbHNUb0hlbHBlck1pc3NpbmcgfHxcbiAgICAgICAgdGVtcGxhdGVXYXNQcmVjb21waWxlZFdpdGhDb21waWxlclY3O1xuICAgICAgbW92ZUhlbHBlclRvSG9va3MoY29udGFpbmVyLCAnaGVscGVyTWlzc2luZycsIGtlZXBIZWxwZXJJbkhlbHBlcnMpO1xuICAgICAgbW92ZUhlbHBlclRvSG9va3MoY29udGFpbmVyLCAnYmxvY2tIZWxwZXJNaXNzaW5nJywga2VlcEhlbHBlckluSGVscGVycyk7XG4gICAgfSBlbHNlIHtcbiAgICAgIGNvbnRhaW5lci5wcm90b0FjY2Vzc0NvbnRyb2wgPSBvcHRpb25zLnByb3RvQWNjZXNzQ29udHJvbDsgLy8gaW50ZXJuYWwgb3B0aW9uXG4gICAgICBjb250YWluZXIuaGVscGVycyA9IG9wdGlvbnMuaGVscGVycztcbiAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IG9wdGlvbnMucGFydGlhbHM7XG4gICAgICBjb250YWluZXIuZGVjb3JhdG9ycyA9IG9wdGlvbnMuZGVjb3JhdG9ycztcbiAgICAgIGNvbnRhaW5lci5ob29rcyA9IG9wdGlvbnMuaG9va3M7XG4gICAgfVxuICB9O1xuXG4gIHJldC5fY2hpbGQgPSBmdW5jdGlvbihpLCBkYXRhLCBibG9ja1BhcmFtcywgZGVwdGhzKSB7XG4gICAgaWYgKHRlbXBsYXRlU3BlYy51c2VCbG9ja1BhcmFtcyAmJiAhYmxvY2tQYXJhbXMpIHtcbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ211c3QgcGFzcyBibG9jayBwYXJhbXMnKTtcbiAgICB9XG4gICAgaWYgKHRlbXBsYXRlU3BlYy51c2VEZXB0aHMgJiYgIWRlcHRocykge1xuICAgICAgdGhyb3cgbmV3IEV4Y2VwdGlvbignbXVzdCBwYXNzIHBhcmVudCBkZXB0aHMnKTtcbiAgICB9XG5cbiAgICByZXR1cm4gd3JhcFByb2dyYW0oXG4gICAgICBjb250YWluZXIsXG4gICAgICBpLFxuICAgICAgdGVtcGxhdGVTcGVjW2ldLFxuICAgICAgZGF0YSxcbiAgICAgIDAsXG4gICAgICBibG9ja1BhcmFtcyxcbiAgICAgIGRlcHRoc1xuICAgICk7XG4gIH07XG4gIHJldHVybiByZXQ7XG59XG5cbmV4cG9ydCBmdW5jdGlvbiB3cmFwUHJvZ3JhbShcbiAgY29udGFpbmVyLFxuICBpLFxuICBmbixcbiAgZGF0YSxcbiAgZGVjbGFyZWRCbG9ja1BhcmFtcyxcbiAgYmxvY2tQYXJhbXMsXG4gIGRlcHRoc1xuKSB7XG4gIGZ1bmN0aW9uIHByb2coY29udGV4dCwgb3B0aW9ucyA9IHt9KSB7XG4gICAgbGV0IGN1cnJlbnREZXB0aHMgPSBkZXB0aHM7XG4gICAgaWYgKFxuICAgICAgZGVwdGhzICYmXG4gICAgICBjb250ZXh0ICE9IGRlcHRoc1swXSAmJlxuICAgICAgIShjb250ZXh0ID09PSBjb250YWluZXIubnVsbENvbnRleHQgJiYgZGVwdGhzWzBdID09PSBudWxsKVxuICAgICkge1xuICAgICAgY3VycmVudERlcHRocyA9IFtjb250ZXh0XS5jb25jYXQoZGVwdGhzKTtcbiAgICB9XG5cbiAgICByZXR1cm4gZm4oXG4gICAgICBjb250YWluZXIsXG4gICAgICBjb250ZXh0LFxuICAgICAgY29udGFpbmVyLmhlbHBlcnMsXG4gICAgICBjb250YWluZXIucGFydGlhbHMsXG4gICAgICBvcHRpb25zLmRhdGEgfHwgZGF0YSxcbiAgICAgIGJsb2NrUGFyYW1zICYmIFtvcHRpb25zLmJsb2NrUGFyYW1zXS5jb25jYXQoYmxvY2tQYXJhbXMpLFxuICAgICAgY3VycmVudERlcHRoc1xuICAgICk7XG4gIH1cblxuICBwcm9nID0gZXhlY3V0ZURlY29yYXRvcnMoZm4sIHByb2csIGNvbnRhaW5lciwgZGVwdGhzLCBkYXRhLCBibG9ja1BhcmFtcyk7XG5cbiAgcHJvZy5wcm9ncmFtID0gaTtcbiAgcHJvZy5kZXB0aCA9IGRlcHRocyA/IGRlcHRocy5sZW5ndGggOiAwO1xuICBwcm9nLmJsb2NrUGFyYW1zID0gZGVjbGFyZWRCbG9ja1BhcmFtcyB8fCAwO1xuICByZXR1cm4gcHJvZztcbn1cblxuLyoqXG4gKiBUaGlzIGlzIGN1cnJlbnRseSBwYXJ0IG9mIHRoZSBvZmZpY2lhbCBBUEksIHRoZXJlZm9yZSBpbXBsZW1lbnRhdGlvbiBkZXRhaWxzIHNob3VsZCBub3QgYmUgY2hhbmdlZC5cbiAqL1xuZXhwb3J0IGZ1bmN0aW9uIHJlc29sdmVQYXJ0aWFsKHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgaWYgKCFwYXJ0aWFsKSB7XG4gICAgaWYgKG9wdGlvbnMubmFtZSA9PT0gJ0BwYXJ0aWFsLWJsb2NrJykge1xuICAgICAgcGFydGlhbCA9IG9wdGlvbnMuZGF0YVsncGFydGlhbC1ibG9jayddO1xuICAgIH0gZWxzZSB7XG4gICAgICBwYXJ0aWFsID0gb3B0aW9ucy5wYXJ0aWFsc1tvcHRpb25zLm5hbWVdO1xuICAgIH1cbiAgfSBlbHNlIGlmICghcGFydGlhbC5jYWxsICYmICFvcHRpb25zLm5hbWUpIHtcbiAgICAvLyBUaGlzIGlzIGEgZHluYW1pYyBwYXJ0aWFsIHRoYXQgcmV0dXJuZWQgYSBzdHJpbmdcbiAgICBvcHRpb25zLm5hbWUgPSBwYXJ0aWFsO1xuICAgIHBhcnRpYWwgPSBvcHRpb25zLnBhcnRpYWxzW3BhcnRpYWxdO1xuICB9XG4gIHJldHVybiBwYXJ0aWFsO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gaW52b2tlUGFydGlhbChwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKSB7XG4gIC8vIFVzZSB0aGUgY3VycmVudCBjbG9zdXJlIGNvbnRleHQgdG8gc2F2ZSB0aGUgcGFydGlhbC1ibG9jayBpZiB0aGlzIHBhcnRpYWxcbiAgY29uc3QgY3VycmVudFBhcnRpYWxCbG9jayA9IG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXTtcbiAgb3B0aW9ucy5wYXJ0aWFsID0gdHJ1ZTtcbiAgaWYgKG9wdGlvbnMuaWRzKSB7XG4gICAgb3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoID0gb3B0aW9ucy5pZHNbMF0gfHwgb3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoO1xuICB9XG5cbiAgbGV0IHBhcnRpYWxCbG9jaztcbiAgaWYgKG9wdGlvbnMuZm4gJiYgb3B0aW9ucy5mbiAhPT0gbm9vcCkge1xuICAgIG9wdGlvbnMuZGF0YSA9IGNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgLy8gV3JhcHBlciBmdW5jdGlvbiB0byBnZXQgYWNjZXNzIHRvIGN1cnJlbnRQYXJ0aWFsQmxvY2sgZnJvbSB0aGUgY2xvc3VyZVxuICAgIGxldCBmbiA9IG9wdGlvbnMuZm47XG4gICAgcGFydGlhbEJsb2NrID0gb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ10gPSBmdW5jdGlvbiBwYXJ0aWFsQmxvY2tXcmFwcGVyKFxuICAgICAgY29udGV4dCxcbiAgICAgIG9wdGlvbnMgPSB7fVxuICAgICkge1xuICAgICAgLy8gUmVzdG9yZSB0aGUgcGFydGlhbC1ibG9jayBmcm9tIHRoZSBjbG9zdXJlIGZvciB0aGUgZXhlY3V0aW9uIG9mIHRoZSBibG9ja1xuICAgICAgLy8gaS5lLiB0aGUgcGFydCBpbnNpZGUgdGhlIGJsb2NrIG9mIHRoZSBwYXJ0aWFsIGNhbGwuXG4gICAgICBvcHRpb25zLmRhdGEgPSBjcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgICAgb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ10gPSBjdXJyZW50UGFydGlhbEJsb2NrO1xuICAgICAgcmV0dXJuIGZuKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgIH07XG4gICAgaWYgKGZuLnBhcnRpYWxzKSB7XG4gICAgICBvcHRpb25zLnBhcnRpYWxzID0gVXRpbHMuZXh0ZW5kKHt9LCBvcHRpb25zLnBhcnRpYWxzLCBmbi5wYXJ0aWFscyk7XG4gICAgfVxuICB9XG5cbiAgaWYgKHBhcnRpYWwgPT09IHVuZGVmaW5lZCAmJiBwYXJ0aWFsQmxvY2spIHtcbiAgICBwYXJ0aWFsID0gcGFydGlhbEJsb2NrO1xuICB9XG5cbiAgaWYgKHBhcnRpYWwgPT09IHVuZGVmaW5lZCkge1xuICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ1RoZSBwYXJ0aWFsICcgKyBvcHRpb25zLm5hbWUgKyAnIGNvdWxkIG5vdCBiZSBmb3VuZCcpO1xuICB9IGVsc2UgaWYgKHBhcnRpYWwgaW5zdGFuY2VvZiBGdW5jdGlvbikge1xuICAgIHJldHVybiBwYXJ0aWFsKGNvbnRleHQsIG9wdGlvbnMpO1xuICB9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBub29wKCkge1xuICByZXR1cm4gJyc7XG59XG5cbmZ1bmN0aW9uIGluaXREYXRhKGNvbnRleHQsIGRhdGEpIHtcbiAgaWYgKCFkYXRhIHx8ICEoJ3Jvb3QnIGluIGRhdGEpKSB7XG4gICAgZGF0YSA9IGRhdGEgPyBjcmVhdGVGcmFtZShkYXRhKSA6IHt9O1xuICAgIGRhdGEucm9vdCA9IGNvbnRleHQ7XG4gIH1cbiAgcmV0dXJuIGRhdGE7XG59XG5cbmZ1bmN0aW9uIGV4ZWN1dGVEZWNvcmF0b3JzKGZuLCBwcm9nLCBjb250YWluZXIsIGRlcHRocywgZGF0YSwgYmxvY2tQYXJhbXMpIHtcbiAgaWYgKGZuLmRlY29yYXRvcikge1xuICAgIGxldCBwcm9wcyA9IHt9O1xuICAgIHByb2cgPSBmbi5kZWNvcmF0b3IoXG4gICAgICBwcm9nLFxuICAgICAgcHJvcHMsXG4gICAgICBjb250YWluZXIsXG4gICAgICBkZXB0aHMgJiYgZGVwdGhzWzBdLFxuICAgICAgZGF0YSxcbiAgICAgIGJsb2NrUGFyYW1zLFxuICAgICAgZGVwdGhzXG4gICAgKTtcbiAgICBVdGlscy5leHRlbmQocHJvZywgcHJvcHMpO1xuICB9XG4gIHJldHVybiBwcm9nO1xufVxuXG5mdW5jdGlvbiB3cmFwSGVscGVyc1RvUGFzc0xvb2t1cFByb3BlcnR5KG1lcmdlZEhlbHBlcnMsIGNvbnRhaW5lcikge1xuICBPYmplY3Qua2V5cyhtZXJnZWRIZWxwZXJzKS5mb3JFYWNoKGhlbHBlck5hbWUgPT4ge1xuICAgIGxldCBoZWxwZXIgPSBtZXJnZWRIZWxwZXJzW2hlbHBlck5hbWVdO1xuICAgIG1lcmdlZEhlbHBlcnNbaGVscGVyTmFtZV0gPSBwYXNzTG9va3VwUHJvcGVydHlPcHRpb24oaGVscGVyLCBjb250YWluZXIpO1xuICB9KTtcbn1cblxuZnVuY3Rpb24gcGFzc0xvb2t1cFByb3BlcnR5T3B0aW9uKGhlbHBlciwgY29udGFpbmVyKSB7XG4gIGNvbnN0IGxvb2t1cFByb3BlcnR5ID0gY29udGFpbmVyLmxvb2t1cFByb3BlcnR5O1xuICByZXR1cm4gd3JhcEhlbHBlcihoZWxwZXIsIG9wdGlvbnMgPT4ge1xuICAgIHJldHVybiBVdGlscy5leHRlbmQoeyBsb29rdXBQcm9wZXJ0eSB9LCBvcHRpb25zKTtcbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ 558:
/***/ (function(module, exports) {

"use strict";
// Build out our basic SafeString type


exports.__esModule = true;
function SafeString(string) {
  this.string = string;
}

SafeString.prototype.toString = SafeString.prototype.toHTML = function () {
  return '' + this.string;
};

exports["default"] = SafeString;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3NhZmUtc3RyaW5nLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7QUFDQSxTQUFTLFVBQVUsQ0FBQyxNQUFNLEVBQUU7QUFDMUIsTUFBSSxDQUFDLE1BQU0sR0FBRyxNQUFNLENBQUM7Q0FDdEI7O0FBRUQsVUFBVSxDQUFDLFNBQVMsQ0FBQyxRQUFRLEdBQUcsVUFBVSxDQUFDLFNBQVMsQ0FBQyxNQUFNLEdBQUcsWUFBVztBQUN2RSxTQUFPLEVBQUUsR0FBRyxJQUFJLENBQUMsTUFBTSxDQUFDO0NBQ3pCLENBQUM7O3FCQUVhLFVBQVUiLCJmaWxlIjoic2FmZS1zdHJpbmcuanMiLCJzb3VyY2VzQ29udGVudCI6WyIvLyBCdWlsZCBvdXQgb3VyIGJhc2ljIFNhZmVTdHJpbmcgdHlwZVxuZnVuY3Rpb24gU2FmZVN0cmluZyhzdHJpbmcpIHtcbiAgdGhpcy5zdHJpbmcgPSBzdHJpbmc7XG59XG5cblNhZmVTdHJpbmcucHJvdG90eXBlLnRvU3RyaW5nID0gU2FmZVN0cmluZy5wcm90b3R5cGUudG9IVE1MID0gZnVuY3Rpb24oKSB7XG4gIHJldHVybiAnJyArIHRoaXMuc3RyaW5nO1xufTtcblxuZXhwb3J0IGRlZmF1bHQgU2FmZVN0cmluZztcbiJdfQ==


/***/ }),

/***/ 392:
/***/ (function(__unused_webpack_module, exports) {

"use strict";


exports.__esModule = true;
exports.extend = extend;
exports.indexOf = indexOf;
exports.escapeExpression = escapeExpression;
exports.isEmpty = isEmpty;
exports.createFrame = createFrame;
exports.blockParams = blockParams;
exports.appendContextPath = appendContextPath;
var escape = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

var badChars = /[&<>"'`=]/g,
    possible = /[&<>"'`=]/;

function escapeChar(chr) {
  return escape[chr];
}

function extend(obj /* , ...source */) {
  for (var i = 1; i < arguments.length; i++) {
    for (var key in arguments[i]) {
      if (Object.prototype.hasOwnProperty.call(arguments[i], key)) {
        obj[key] = arguments[i][key];
      }
    }
  }

  return obj;
}

var toString = Object.prototype.toString;

exports.toString = toString;
// Sourced from lodash
// https://github.com/bestiejs/lodash/blob/master/LICENSE.txt
/* eslint-disable func-style */
var isFunction = function isFunction(value) {
  return typeof value === 'function';
};
// fallback for older versions of Chrome and Safari
/* istanbul ignore next */
if (isFunction(/x/)) {
  exports.isFunction = isFunction = function (value) {
    return typeof value === 'function' && toString.call(value) === '[object Function]';
  };
}
exports.isFunction = isFunction;

/* eslint-enable func-style */

/* istanbul ignore next */
var isArray = Array.isArray || function (value) {
  return value && typeof value === 'object' ? toString.call(value) === '[object Array]' : false;
};

exports.isArray = isArray;
// Older IE versions do not directly support indexOf so we must implement our own, sadly.

function indexOf(array, value) {
  for (var i = 0, len = array.length; i < len; i++) {
    if (array[i] === value) {
      return i;
    }
  }
  return -1;
}

function escapeExpression(string) {
  if (typeof string !== 'string') {
    // don't escape SafeStrings, since they're already safe
    if (string && string.toHTML) {
      return string.toHTML();
    } else if (string == null) {
      return '';
    } else if (!string) {
      return string + '';
    }

    // Force a string conversion as this will be done by the append regardless and
    // the regex test will do this transparently behind the scenes, causing issues if
    // an object's to string has escaped characters in it.
    string = '' + string;
  }

  if (!possible.test(string)) {
    return string;
  }
  return string.replace(badChars, escapeChar);
}

function isEmpty(value) {
  if (!value && value !== 0) {
    return true;
  } else if (isArray(value) && value.length === 0) {
    return true;
  } else {
    return false;
  }
}

function createFrame(object) {
  var frame = extend({}, object);
  frame._parent = object;
  return frame;
}

function blockParams(params, ids) {
  params.path = ids;
  return params;
}

function appendContextPath(contextPath, id) {
  return (contextPath ? contextPath + '.' : '') + id;
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3V0aWxzLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7QUFBQSxJQUFNLE1BQU0sR0FBRztBQUNiLEtBQUcsRUFBRSxPQUFPO0FBQ1osS0FBRyxFQUFFLE1BQU07QUFDWCxLQUFHLEVBQUUsTUFBTTtBQUNYLEtBQUcsRUFBRSxRQUFRO0FBQ2IsS0FBRyxFQUFFLFFBQVE7QUFDYixLQUFHLEVBQUUsUUFBUTtBQUNiLEtBQUcsRUFBRSxRQUFRO0NBQ2QsQ0FBQzs7QUFFRixJQUFNLFFBQVEsR0FBRyxZQUFZO0lBQzNCLFFBQVEsR0FBRyxXQUFXLENBQUM7O0FBRXpCLFNBQVMsVUFBVSxDQUFDLEdBQUcsRUFBRTtBQUN2QixTQUFPLE1BQU0sQ0FBQyxHQUFHLENBQUMsQ0FBQztDQUNwQjs7QUFFTSxTQUFTLE1BQU0sQ0FBQyxHQUFHLG9CQUFvQjtBQUM1QyxPQUFLLElBQUksQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEdBQUcsU0FBUyxDQUFDLE1BQU0sRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUN6QyxTQUFLLElBQUksR0FBRyxJQUFJLFNBQVMsQ0FBQyxDQUFDLENBQUMsRUFBRTtBQUM1QixVQUFJLE1BQU0sQ0FBQyxTQUFTLENBQUMsY0FBYyxDQUFDLElBQUksQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDLEVBQUUsR0FBRyxDQUFDLEVBQUU7QUFDM0QsV0FBRyxDQUFDLEdBQUcsQ0FBQyxHQUFHLFNBQVMsQ0FBQyxDQUFDLENBQUMsQ0FBQyxHQUFHLENBQUMsQ0FBQztPQUM5QjtLQUNGO0dBQ0Y7O0FBRUQsU0FBTyxHQUFHLENBQUM7Q0FDWjs7QUFFTSxJQUFJLFFBQVEsR0FBRyxNQUFNLENBQUMsU0FBUyxDQUFDLFFBQVEsQ0FBQzs7Ozs7O0FBS2hELElBQUksVUFBVSxHQUFHLG9CQUFTLEtBQUssRUFBRTtBQUMvQixTQUFPLE9BQU8sS0FBSyxLQUFLLFVBQVUsQ0FBQztDQUNwQyxDQUFDOzs7QUFHRixJQUFJLFVBQVUsQ0FBQyxHQUFHLENBQUMsRUFBRTtBQUNuQixVQU9PLFVBQVUsR0FQakIsVUFBVSxHQUFHLFVBQVMsS0FBSyxFQUFFO0FBQzNCLFdBQ0UsT0FBTyxLQUFLLEtBQUssVUFBVSxJQUMzQixRQUFRLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxLQUFLLG1CQUFtQixDQUM1QztHQUNILENBQUM7Q0FDSDtRQUNRLFVBQVUsR0FBVixVQUFVOzs7OztBQUlaLElBQU0sT0FBTyxHQUNsQixLQUFLLENBQUMsT0FBTyxJQUNiLFVBQVMsS0FBSyxFQUFFO0FBQ2QsU0FBTyxLQUFLLElBQUksT0FBTyxLQUFLLEtBQUssUUFBUSxHQUNyQyxRQUFRLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxLQUFLLGdCQUFnQixHQUN6QyxLQUFLLENBQUM7Q0FDWCxDQUFDOzs7OztBQUdHLFNBQVMsT0FBTyxDQUFDLEtBQUssRUFBRSxLQUFLLEVBQUU7QUFDcEMsT0FBSyxJQUFJLENBQUMsR0FBRyxDQUFDLEVBQUUsR0FBRyxHQUFHLEtBQUssQ0FBQyxNQUFNLEVBQUUsQ0FBQyxHQUFHLEdBQUcsRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUNoRCxRQUFJLEtBQUssQ0FBQyxDQUFDLENBQUMsS0FBSyxLQUFLLEVBQUU7QUFDdEIsYUFBTyxDQUFDLENBQUM7S0FDVjtHQUNGO0FBQ0QsU0FBTyxDQUFDLENBQUMsQ0FBQztDQUNYOztBQUVNLFNBQVMsZ0JBQWdCLENBQUMsTUFBTSxFQUFFO0FBQ3ZDLE1BQUksT0FBTyxNQUFNLEtBQUssUUFBUSxFQUFFOztBQUU5QixRQUFJLE1BQU0sSUFBSSxNQUFNLENBQUMsTUFBTSxFQUFFO0FBQzNCLGFBQU8sTUFBTSxDQUFDLE1BQU0sRUFBRSxDQUFDO0tBQ3hCLE1BQU0sSUFBSSxNQUFNLElBQUksSUFBSSxFQUFFO0FBQ3pCLGFBQU8sRUFBRSxDQUFDO0tBQ1gsTUFBTSxJQUFJLENBQUMsTUFBTSxFQUFFO0FBQ2xCLGFBQU8sTUFBTSxHQUFHLEVBQUUsQ0FBQztLQUNwQjs7Ozs7QUFLRCxVQUFNLEdBQUcsRUFBRSxHQUFHLE1BQU0sQ0FBQztHQUN0Qjs7QUFFRCxNQUFJLENBQUMsUUFBUSxDQUFDLElBQUksQ0FBQyxNQUFNLENBQUMsRUFBRTtBQUMxQixXQUFPLE1BQU0sQ0FBQztHQUNmO0FBQ0QsU0FBTyxNQUFNLENBQUMsT0FBTyxDQUFDLFFBQVEsRUFBRSxVQUFVLENBQUMsQ0FBQztDQUM3Qzs7QUFFTSxTQUFTLE9BQU8sQ0FBQyxLQUFLLEVBQUU7QUFDN0IsTUFBSSxDQUFDLEtBQUssSUFBSSxLQUFLLEtBQUssQ0FBQyxFQUFFO0FBQ3pCLFdBQU8sSUFBSSxDQUFDO0dBQ2IsTUFBTSxJQUFJLE9BQU8sQ0FBQyxLQUFLLENBQUMsSUFBSSxLQUFLLENBQUMsTUFBTSxLQUFLLENBQUMsRUFBRTtBQUMvQyxXQUFPLElBQUksQ0FBQztHQUNiLE1BQU07QUFDTCxXQUFPLEtBQUssQ0FBQztHQUNkO0NBQ0Y7O0FBRU0sU0FBUyxXQUFXLENBQUMsTUFBTSxFQUFFO0FBQ2xDLE1BQUksS0FBSyxHQUFHLE1BQU0sQ0FBQyxFQUFFLEVBQUUsTUFBTSxDQUFDLENBQUM7QUFDL0IsT0FBSyxDQUFDLE9BQU8sR0FBRyxNQUFNLENBQUM7QUFDdkIsU0FBTyxLQUFLLENBQUM7Q0FDZDs7QUFFTSxTQUFTLFdBQVcsQ0FBQyxNQUFNLEVBQUUsR0FBRyxFQUFFO0FBQ3ZDLFFBQU0sQ0FBQyxJQUFJLEdBQUcsR0FBRyxDQUFDO0FBQ2xCLFNBQU8sTUFBTSxDQUFDO0NBQ2Y7O0FBRU0sU0FBUyxpQkFBaUIsQ0FBQyxXQUFXLEVBQUUsRUFBRSxFQUFFO0FBQ2pELFNBQU8sQ0FBQyxXQUFXLEdBQUcsV0FBVyxHQUFHLEdBQUcsR0FBRyxFQUFFLENBQUEsR0FBSSxFQUFFLENBQUM7Q0FDcEQiLCJmaWxlIjoidXRpbHMuanMiLCJzb3VyY2VzQ29udGVudCI6WyJjb25zdCBlc2NhcGUgPSB7XG4gICcmJzogJyZhbXA7JyxcbiAgJzwnOiAnJmx0OycsXG4gICc+JzogJyZndDsnLFxuICAnXCInOiAnJnF1b3Q7JyxcbiAgXCInXCI6ICcmI3gyNzsnLFxuICAnYCc6ICcmI3g2MDsnLFxuICAnPSc6ICcmI3gzRDsnXG59O1xuXG5jb25zdCBiYWRDaGFycyA9IC9bJjw+XCInYD1dL2csXG4gIHBvc3NpYmxlID0gL1smPD5cIidgPV0vO1xuXG5mdW5jdGlvbiBlc2NhcGVDaGFyKGNocikge1xuICByZXR1cm4gZXNjYXBlW2Nocl07XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBleHRlbmQob2JqIC8qICwgLi4uc291cmNlICovKSB7XG4gIGZvciAobGV0IGkgPSAxOyBpIDwgYXJndW1lbnRzLmxlbmd0aDsgaSsrKSB7XG4gICAgZm9yIChsZXQga2V5IGluIGFyZ3VtZW50c1tpXSkge1xuICAgICAgaWYgKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChhcmd1bWVudHNbaV0sIGtleSkpIHtcbiAgICAgICAgb2JqW2tleV0gPSBhcmd1bWVudHNbaV1ba2V5XTtcbiAgICAgIH1cbiAgICB9XG4gIH1cblxuICByZXR1cm4gb2JqO1xufVxuXG5leHBvcnQgbGV0IHRvU3RyaW5nID0gT2JqZWN0LnByb3RvdHlwZS50b1N0cmluZztcblxuLy8gU291cmNlZCBmcm9tIGxvZGFzaFxuLy8gaHR0cHM6Ly9naXRodWIuY29tL2Jlc3RpZWpzL2xvZGFzaC9ibG9iL21hc3Rlci9MSUNFTlNFLnR4dFxuLyogZXNsaW50LWRpc2FibGUgZnVuYy1zdHlsZSAqL1xubGV0IGlzRnVuY3Rpb24gPSBmdW5jdGlvbih2YWx1ZSkge1xuICByZXR1cm4gdHlwZW9mIHZhbHVlID09PSAnZnVuY3Rpb24nO1xufTtcbi8vIGZhbGxiYWNrIGZvciBvbGRlciB2ZXJzaW9ucyBvZiBDaHJvbWUgYW5kIFNhZmFyaVxuLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbmlmIChpc0Z1bmN0aW9uKC94LykpIHtcbiAgaXNGdW5jdGlvbiA9IGZ1bmN0aW9uKHZhbHVlKSB7XG4gICAgcmV0dXJuIChcbiAgICAgIHR5cGVvZiB2YWx1ZSA9PT0gJ2Z1bmN0aW9uJyAmJlxuICAgICAgdG9TdHJpbmcuY2FsbCh2YWx1ZSkgPT09ICdbb2JqZWN0IEZ1bmN0aW9uXSdcbiAgICApO1xuICB9O1xufVxuZXhwb3J0IHsgaXNGdW5jdGlvbiB9O1xuLyogZXNsaW50LWVuYWJsZSBmdW5jLXN0eWxlICovXG5cbi8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG5leHBvcnQgY29uc3QgaXNBcnJheSA9XG4gIEFycmF5LmlzQXJyYXkgfHxcbiAgZnVuY3Rpb24odmFsdWUpIHtcbiAgICByZXR1cm4gdmFsdWUgJiYgdHlwZW9mIHZhbHVlID09PSAnb2JqZWN0J1xuICAgICAgPyB0b1N0cmluZy5jYWxsKHZhbHVlKSA9PT0gJ1tvYmplY3QgQXJyYXldJ1xuICAgICAgOiBmYWxzZTtcbiAgfTtcblxuLy8gT2xkZXIgSUUgdmVyc2lvbnMgZG8gbm90IGRpcmVjdGx5IHN1cHBvcnQgaW5kZXhPZiBzbyB3ZSBtdXN0IGltcGxlbWVudCBvdXIgb3duLCBzYWRseS5cbmV4cG9ydCBmdW5jdGlvbiBpbmRleE9mKGFycmF5LCB2YWx1ZSkge1xuICBmb3IgKGxldCBpID0gMCwgbGVuID0gYXJyYXkubGVuZ3RoOyBpIDwgbGVuOyBpKyspIHtcbiAgICBpZiAoYXJyYXlbaV0gPT09IHZhbHVlKSB7XG4gICAgICByZXR1cm4gaTtcbiAgICB9XG4gIH1cbiAgcmV0dXJuIC0xO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gZXNjYXBlRXhwcmVzc2lvbihzdHJpbmcpIHtcbiAgaWYgKHR5cGVvZiBzdHJpbmcgIT09ICdzdHJpbmcnKSB7XG4gICAgLy8gZG9uJ3QgZXNjYXBlIFNhZmVTdHJpbmdzLCBzaW5jZSB0aGV5J3JlIGFscmVhZHkgc2FmZVxuICAgIGlmIChzdHJpbmcgJiYgc3RyaW5nLnRvSFRNTCkge1xuICAgICAgcmV0dXJuIHN0cmluZy50b0hUTUwoKTtcbiAgICB9IGVsc2UgaWYgKHN0cmluZyA9PSBudWxsKSB7XG4gICAgICByZXR1cm4gJyc7XG4gICAgfSBlbHNlIGlmICghc3RyaW5nKSB7XG4gICAgICByZXR1cm4gc3RyaW5nICsgJyc7XG4gICAgfVxuXG4gICAgLy8gRm9yY2UgYSBzdHJpbmcgY29udmVyc2lvbiBhcyB0aGlzIHdpbGwgYmUgZG9uZSBieSB0aGUgYXBwZW5kIHJlZ2FyZGxlc3MgYW5kXG4gICAgLy8gdGhlIHJlZ2V4IHRlc3Qgd2lsbCBkbyB0aGlzIHRyYW5zcGFyZW50bHkgYmVoaW5kIHRoZSBzY2VuZXMsIGNhdXNpbmcgaXNzdWVzIGlmXG4gICAgLy8gYW4gb2JqZWN0J3MgdG8gc3RyaW5nIGhhcyBlc2NhcGVkIGNoYXJhY3RlcnMgaW4gaXQuXG4gICAgc3RyaW5nID0gJycgKyBzdHJpbmc7XG4gIH1cblxuICBpZiAoIXBvc3NpYmxlLnRlc3Qoc3RyaW5nKSkge1xuICAgIHJldHVybiBzdHJpbmc7XG4gIH1cbiAgcmV0dXJuIHN0cmluZy5yZXBsYWNlKGJhZENoYXJzLCBlc2NhcGVDaGFyKTtcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGlzRW1wdHkodmFsdWUpIHtcbiAgaWYgKCF2YWx1ZSAmJiB2YWx1ZSAhPT0gMCkge1xuICAgIHJldHVybiB0cnVlO1xuICB9IGVsc2UgaWYgKGlzQXJyYXkodmFsdWUpICYmIHZhbHVlLmxlbmd0aCA9PT0gMCkge1xuICAgIHJldHVybiB0cnVlO1xuICB9IGVsc2Uge1xuICAgIHJldHVybiBmYWxzZTtcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gY3JlYXRlRnJhbWUob2JqZWN0KSB7XG4gIGxldCBmcmFtZSA9IGV4dGVuZCh7fSwgb2JqZWN0KTtcbiAgZnJhbWUuX3BhcmVudCA9IG9iamVjdDtcbiAgcmV0dXJuIGZyYW1lO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gYmxvY2tQYXJhbXMocGFyYW1zLCBpZHMpIHtcbiAgcGFyYW1zLnBhdGggPSBpZHM7XG4gIHJldHVybiBwYXJhbXM7XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBhcHBlbmRDb250ZXh0UGF0aChjb250ZXh0UGF0aCwgaWQpIHtcbiAgcmV0dXJuIChjb250ZXh0UGF0aCA/IGNvbnRleHRQYXRoICsgJy4nIDogJycpICsgaWQ7XG59XG4iXX0=


/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/global */
/******/ 	!function() {
/******/ 		__webpack_require__.g = (function() {
/******/ 			if (typeof globalThis === 'object') return globalThis;
/******/ 			try {
/******/ 				return this || new Function('return this')();
/******/ 			} catch (e) {
/******/ 				if (typeof window === 'object') return window;
/******/ 			}
/******/ 		})();
/******/ 	}();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module is referenced by other modules so it can't be inlined
/******/ 	var __webpack_exports__ = __webpack_require__(579);
/******/ 	
/******/ 	return __webpack_exports__;
/******/ })()
;
});
//# sourceMappingURL=mura.js.map