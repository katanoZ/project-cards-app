if (window.location.hash && window.location.hash == '#_=_') {
  history.replaceState('', document.title, window.location.pathname);
}
