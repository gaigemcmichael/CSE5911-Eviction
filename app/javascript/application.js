// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "channels";

(function () {
  if (window.__navToggleInit) return;

  function onDocumentClick(e) {
    // click on the hamburger
    const toggle = e.target.closest('#navbar-toggle');
    if (toggle) {
      e.preventDefault();
      const menu = document.querySelector('.navbar-menu');
      if (menu) menu.classList.toggle('active');
      return;
    }

    // click on any menu link and then close mobile menu
    const menuLink = e.target.closest('.navbar-menu a');
    if (menuLink) {
      const menu = document.querySelector('.navbar-menu');
      if (menu) menu.classList.remove('active');
    }
  }

  function init() {
    if (window.__navToggleInit) return;
    document.addEventListener('click', onDocumentClick);
    window.__navToggleInit = true;
  }

  // initialize on normal page load and Turbo/Turbolinks loads
  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbo:load', init);
  document.addEventListener('turbolinks:load', init);
})();
