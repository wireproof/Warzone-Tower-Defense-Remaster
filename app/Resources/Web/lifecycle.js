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
