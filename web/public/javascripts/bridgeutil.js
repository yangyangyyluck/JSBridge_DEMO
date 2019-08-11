function detectBridgeLoaded(cb) {
  if (window.smtBridge) {
    cb(window.smtBridge);
  } else {
    loaded(cb);
  }
}

function loaded(cb) {
  document.addEventListener('smt_bridge_ready', _ => {
    cb(window.smtBridge);
  });

  const iframe = document.createElement("iframe");
  iframe.src = 'smt://__loaded__';
  iframe.style.display = 'none';
  document.documentElement.appendChild(iframe);
}