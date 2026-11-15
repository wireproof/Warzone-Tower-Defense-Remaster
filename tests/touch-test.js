var window={};var events=[];function PointerEvent(type,init){this.type=type;Object.assign(this,init)}
// Convert a single touch into a mouse-style hover followed by one click.
// This avoids repeatedly placing towers while the finger is moving.
(function () {
  'use strict';
  const STAGE_W = 833, STAGE_H = 607;
  function stagePoint(rect, x, y) {
    const scale = Math.min(rect.width / STAGE_W, rect.height / STAGE_H);
    if (!scale) return null;
    return {x:(x-rect.left-(rect.width-STAGE_W*scale)/2)/scale,
            y:(y-rect.top-(rect.height-STAGE_H*scale)/2)/scale};
  }
  function inArsenal(p) { return p && p.x >= 0 && p.x < 320 && p.y >= 510 && p.y < 607; }
  function inField(p) { return p && p.x >= 0 && p.x < 833 && p.y >= 0 && p.y < 490; }
  function attach(player) {
    let touch = null;
    function canvas() { return player.shadowRoot && player.shadowRoot.querySelector('canvas'); }
    function send(type, e, x, y, buttons) {
      const target = canvas(); if (!target) return;
      target.dispatchEvent(new PointerEvent(type, {bubbles:true,cancelable:true,composed:true,
        pointerId:1,pointerType:'mouse',isPrimary:true,clientX:x,clientY:y,button:0,buttons}));
    }
    function swallow(e) { e.preventDefault(); e.stopImmediatePropagation(); }
    function click(e,x,y) { send('pointermove',e,x,y,0); send('pointerdown',e,x,y,1); send('pointerup',e,x,y,0); }
    player.addEventListener('pointerdown', e => {
      if ((!e.isTrusted && !window.__warzoneTestInput) || e.pointerType !== 'touch' || !e.isPrimary || touch || !canvas()) return;
      const rect=player.getBoundingClientRect(), point=stagePoint(rect,e.clientX,e.clientY);
      if (!inArsenal(point) && !inField(point)) return;
      touch={id:e.pointerId, arsenal:!!inArsenal(point), x:e.clientX,y:e.clientY};
      swallow(e);
      if (touch.arsenal) click(e,e.clientX,e.clientY);
      else send('pointermove',e,e.clientX,e.clientY,0);
      try { player.setPointerCapture(e.pointerId); } catch (_) {}
    }, true);
    player.addEventListener('pointermove', e => {
      if (!touch || (!e.isTrusted && !window.__warzoneTestInput) || e.pointerId !== touch.id) return;
      swallow(e); send('pointermove',e,e.clientX,e.clientY,0);
    }, true);
    player.addEventListener('pointerup', e => {
      if (!touch || (!e.isTrusted && !window.__warzoneTestInput) || e.pointerId !== touch.id) return;
      const start=touch; touch=null; swallow(e);
      const point=stagePoint(player.getBoundingClientRect(),e.clientX,e.clientY);
      if (inField(point)) click(e,e.clientX,e.clientY);
      // Arsenal taps were already sent on touch down; no second click.
    }, true);
    player.addEventListener('pointercancel', e => {
      if (!touch || (!e.isTrusted && !window.__warzoneTestInput) || e.pointerId !== touch.id) return;
      touch=null; swallow(e);
    }, true);
  }
  window.WarzoneTouch={attach,stagePoint,inArsenal,inField};
})();
function assert(b,m){if(!b)throw Error(m)}
let handlers={},canvas={dispatchEvent(e){events.push(e.type)}},player={shadowRoot:{querySelector(){return canvas}},getBoundingClientRect(){return {left:0,top:0,width:833,height:607}},addEventListener(n,f){handlers[n]=f},setPointerCapture(){}};
window.WarzoneTouch.attach(player);
function e(x,y){return {isTrusted:true,pointerType:'touch',isPrimary:true,pointerId:4,clientX:x,clientY:y,preventDefault(){this.prevented=true},stopImmediatePropagation(){}}}
let a=e(300,200);handlers.pointerdown(a);handlers.pointermove(e(400,200));handlers.pointermove(e(450,200));assert(events.filter(x=>x==='pointerdown').length===0,'no placement while dragging');let b=e(500,200);handlers.pointerup(b);assert(events.filter(x=>x==='pointerdown').length===1,'one placement on release');
events.length=0;a=e(45,550);handlers.pointerdown(a);handlers.pointerup(e(45,550));assert(events.filter(x=>x==='pointerdown').length===1,'arsenal tap once');
events.length=0;a=e(45,550);handlers.pointerdown(a);handlers.pointermove(e(250,200));handlers.pointerup(e(300,200));assert(events.filter(x=>x==='pointerdown').length===2,'arsenal selection and one map placement');
print('touch gesture checks passed');
