(window.webpackJsonp=window.webpackJsonp||[]).push([["chunk-a296"],{OKuS:function(t,e,n){"use strict";n("yMvl")},UR5J:function(t,e,n){"use strict";n.r(e);var l={name:"Relays",components:{RebootButton:n("rIUS").a},data:function(){return{newRelay:""}},computed:{getLabelWidth:function(){return this.isDesktop?"130px":"85px"},isDesktop:function(){return"desktop"===this.$store.state.app.device},loading:function(){return this.$store.state.relays.loading},relays:function(){return this.$store.state.relays.fetchedRelays}},mounted:function(){this.$store.dispatch("FetchRelays")},methods:{followRelay:function(){this.$store.dispatch("AddRelay",this.newRelay),this.newRelay=""},deleteRelay:function(t){this.$store.dispatch("DeleteRelay",t)}}},a=(n("OKuS"),n("KHd+")),s=Object(a.a)(l,function(){var t=this,e=t._self._c;return t.loading?t._e():e("div",{staticClass:"relays-container"},[e("div",{staticClass:"relays-header-container"},[e("h1",[t._v("\n      "+t._s(t.$t("relays.relays"))+"\n    ")]),t._v(" "),e("reboot-button")],1),t._v(" "),e("div",{staticClass:"follow-relay-container"},[e("el-input",{staticClass:"follow-relay",attrs:{placeholder:t.$t("relays.followRelay")},nativeOn:{keyup:function(e){return!e.type.indexOf("key")&&t._k(e.keyCode,"enter",13,e.key,"Enter")?null:t.followRelay.apply(null,arguments)}},model:{value:t.newRelay,callback:function(e){t.newRelay=e},expression:"newRelay"}}),t._v(" "),e("el-button",{nativeOn:{click:function(e){return t.followRelay.apply(null,arguments)}}},[t._v(t._s(t.$t("relays.follow")))])],1),t._v(" "),e("el-table",{attrs:{data:t.relays}},[e("el-table-column",{attrs:{label:t.$t("relays.instanceUrl"),prop:"actor"}}),t._v(" "),e("el-table-column",{attrs:{label:t.$t("relays.followedBack"),width:t.getLabelWidth,prop:"followed_back",align:"center"},scopedSlots:t._u([{key:"default",fn:function(t){return[e("i",{class:t.row.followed_back?"el-icon-check":"el-icon-minus"})]}}],null,!1,237257305)}),t._v(" "),e("el-table-column",{attrs:{label:t.$t("table.actions"),width:t.getLabelWidth,fixed:"right",align:"center"},scopedSlots:t._u([{key:"default",fn:function(n){return[e("el-button",{attrs:{type:"text",size:"small"},nativeOn:{click:function(e){return t.deleteRelay(n.row.actor)}}},[t._v("\n          "+t._s(t.$t("table.unfollow"))+"\n        ")])]}}],null,!1,877363589)})],1)],1)},[],!1,null,null,null);e.default=s.exports},rIUS:function(t,e,n){"use strict";var l=n("yXPU"),a=n.n(l),s=n("o0o1"),o=n.n(s),r=n("mSNy"),i={name:"RebootButton",computed:{needReboot:function(){return this.$store.state.app.needReboot}},methods:{restartApp:function(){var t=this;return a()(o.a.mark(function e(){return o.a.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.prev=0,e.next=3,t.$store.dispatch("RestartApplication");case 3:e.next=8;break;case 5:return e.prev=5,e.t0=e.catch(0),e.abrupt("return");case 8:t.$message({type:"success",message:r.a.t("settings.restartSuccess")});case 9:case"end":return e.stop()}},e,null,[[0,5]])}))()}}},c=n("KHd+"),u=Object(c.a)(i,function(){var t=this._self._c;return this.needReboot?t("el-tooltip",{attrs:{content:this.$t("settings.restartApp"),placement:"bottom-end"}},[t("el-button",{staticClass:"reboot-button",attrs:{type:"warning"},on:{click:this.restartApp}},[t("span",[t("i",{staticClass:"el-icon-refresh"}),this._v("\n      "+this._s(this.$t("settings.instanceReboot"))+"\n    ")])])],1):this._e()},[],!1,null,null,null);e.a=u.exports},yMvl:function(t,e,n){}}]);
//# sourceMappingURL=chunk-a296.53fd9783.js.map