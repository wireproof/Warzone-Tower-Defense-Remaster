var window = {};
var document = { hidden: false, handlers: {}, addEventListener: function (n,f) { this.handlers[n] = f; } };
class AudioMock { constructor(){ this.state='running'; this.suspends=0; this.resumes=0; } suspend(){this.suspends++;this.state='suspended';return Promise.resolve();} resume(){this.resumes++;this.state='running';return Promise.resolve();} }
window.AudioContext=AudioMock;
// Keep the Flash timeline and Web Audio in step with the native app lifecycle.
(function () {
  'use strict';
  const contexts = new Set();
  let toResume = new Set(), player = null, loaded = false;
  let nativeActive = true, pausedByLifecycle = false, wasPlaying = false;
  const OriginalAudioContext = window.AudioContext || window.webkitAudioContext;
  if (OriginalAudioContext) {
    class TrackedAudioContext extends OriginalAudioContext {
      constructor(...args) { super(...args); contexts.add(this); }
    }
    if (window.AudioContext) window.AudioContext = TrackedAudioContext;
    if (window.webkitAudioContext) window.webkitAudioContext = TrackedAudioContext;
  }
  function sync() {
    const active = nativeActive && !document.hidden;
    if (!active) {
      if (!pausedByLifecycle) {
        pausedByLifecycle = true;
        if (loaded && player) {
          const api = player.ruffle();
          wasPlaying = !!api.isPlaying;
          if (wasPlaying) api.pause();
        }
      }
      contexts.forEach(context => {
        if (context.state === 'running') {
          toResume.add(context);
          Promise.resolve(context.suspend()).catch(() => {});
        }
      });
    } else if (pausedByLifecycle) {
      pausedByLifecycle = false;
      const resume = toResume; toResume = new Set();
      resume.forEach(context => Promise.resolve(context.resume()).catch(() => {}));
      if (loaded && player && wasPlaying) player.ruffle().play();
      wasPlaying = false;
    }
  }
  window.WarzoneLifecycle = {
    setActive(active) { nativeActive = !!active; sync(); },
    setPlayer(value) { player = value; },
    didLoad() {
      loaded = true;
      // Loading can complete after the application has already become inactive.
      if (pausedByLifecycle && player) {
        const api = player.ruffle(); wasPlaying = !!api.isPlaying;
        if (wasPlaying) api.pause();
      }
      sync();
    }
  };
  document.addEventListener('visibilitychange', sync);
})();
function assert(x,m){if(!x)throw Error(m)}
let ctx = new window.AudioContext(), api={isPlaying:true, pause(){this.isPlaying=false;},play(){this.isPlaying=true;}}, player={ruffle(){return api;}};
window.WarzoneLifecycle.setPlayer(player);window.WarzoneLifecycle.didLoad();
window.WarzoneLifecycle.setActive(false);assert(!api.isPlaying && ctx.state==='suspended','background did not pause');
window.WarzoneLifecycle.setActive(false);assert(ctx.suspends===1,'repeated pause');
window.WarzoneLifecycle.setActive(true);assert(api.isPlaying && ctx.state==='running','foreground did not resume');
api.isPlaying=false;window.WarzoneLifecycle.setActive(false);window.WarzoneLifecycle.setActive(true);assert(!api.isPlaying,'resumed manually paused game');
api.isPlaying=true;document.hidden=true;document.handlers.visibilitychange();assert(!api.isPlaying,'hidden page did not pause');document.hidden=false;document.handlers.visibilitychange();assert(api.isPlaying,'visible page did not resume');
print('Lifecycle tests passed');
