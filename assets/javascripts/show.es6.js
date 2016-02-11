'use strict';

window.onload = () => {
  var copyBtn = document.getElementById('js-btn-copy');
  var urlForm = document.getElementById('js-image-url');

  copyBtn.addEventListener('click', () => {
    urlForm.focus();
    urlForm.select();
    document.execCommand('copy');
  });
};
