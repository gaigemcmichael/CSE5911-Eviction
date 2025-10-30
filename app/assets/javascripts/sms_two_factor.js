
document.addEventListener('DOMContentLoaded', function() {
  const codeInput = document.getElementById('verification-code');
  const resendBtn = document.getElementById('resend-btn');
  const resendTimer = document.getElementById('resend-timer');
  const countdown = document.getElementById('countdown');
  const resendForm = document.getElementById('resend-form');
  
  
  if (codeInput) {
    
    setTimeout(() => {
      codeInput.focus();
    }, 300);
    
    codeInput.addEventListener('input', function(e) {
      
      this.value = this.value.replace(/\D/g, '');
      
      // Limit to 6 digits
      if (this.value.length > 6) {
        this.value = this.value.slice(0, 6);
      }
      
      
      if (this.value.length > 0) {
        this.classList.add('has-content');
      } else {
        this.classList.remove('has-content');
      }
      
      
      if (this.value.length === 6) {
        this.classList.add('is-valid');
        this.classList.remove('is-invalid');
        
        
        setTimeout(() => {
          this.form.submit();
        }, 600);
      } else if (this.value.length > 0) {
        this.classList.remove('is-valid', 'is-invalid');
      }
    });
    
    
    codeInput.addEventListener('blur', function() {
      if (this.value.length > 0 && this.value.length < 6) {
        this.classList.add('is-invalid');
      }
    });
    
    
    codeInput.addEventListener('focus', function() {
      this.classList.remove('is-invalid');
    });
    
    
    codeInput.addEventListener('paste', function(e) {
      e.preventDefault();
      const paste = (e.clipboardData || window.clipboardData).getData('text');
      const digits = paste.replace(/\D/g, '').slice(0, 6);
      this.value = digits;
      
     
      this.dispatchEvent(new Event('input'));
    });
  }
  
  
  if (resendBtn && resendTimer && countdown) {
    resendForm.addEventListener('submit', function(e) {
      
      resendBtn.classList.add('loading');
      startResendCooldown();
    });
    
    function startResendCooldown() {
      let timeLeft = 30;
      resendBtn.disabled = true;
      resendBtn.classList.add('disabled');
      resendTimer.style.display = 'block';
      
      
      resendTimer.style.opacity = '0';
      resendTimer.style.transform = 'translateY(-10px)';
      setTimeout(() => {
        resendTimer.style.transition = 'all 0.3s ease';
        resendTimer.style.opacity = '1';
        resendTimer.style.transform = 'translateY(0)';
      }, 100);
      
      const timer = setInterval(() => {
        timeLeft--;
        countdown.textContent = timeLeft;
        
        
        if (timeLeft <= 10) {
          countdown.style.color = 'var(--sms-warning)';
          countdown.style.fontWeight = 'bold';
        }
        
        if (timeLeft <= 0) {
          clearInterval(timer);
          resendBtn.disabled = false;
          resendBtn.classList.remove('disabled', 'loading');
          
          
          resendTimer.style.opacity = '0';
          resendTimer.style.transform = 'translateY(-10px)';
          setTimeout(() => {
            resendTimer.style.display = 'none';
            countdown.style.color = '';
            countdown.style.fontWeight = '';
          }, 300);
        }
      }, 1000);
    }
  }
  
  
  const forms = document.querySelectorAll('.needs-validation');
  Array.from(forms).forEach(form => {
    form.addEventListener('submit', function(event) {
      const submitBtn = this.querySelector('input[type="submit"], button[type="submit"]');
      
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
        
        
        form.style.animation = 'shake 0.5s ease-in-out';
        setTimeout(() => {
          form.style.animation = '';
        }, 500);
      } else if (submitBtn) {
       
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
      }
      
      form.classList.add('was-validated');
    });
  });
  
  
  document.addEventListener('keydown', function(e) {
    
    if (e.key === 'Escape') {
      const backLink = document.querySelector('a[href*="login"], a[href*="session"]');
      if (backLink) {
        backLink.click();
      }
    }
    
    
    if (e.key === 'Enter' && document.activeElement === resendBtn) {
      e.preventDefault();
      resendForm.submit();
    }
  });
  
  
  function addProgressiveEnhancements() {
    
    document.documentElement.style.scrollBehavior = 'smooth';
    
    
    const focusableElements = document.querySelectorAll(
      'input, button, a[href], [tabindex]:not([tabindex="-1"])'
    );
    
    if (focusableElements.length > 0) {
      const firstElement = focusableElements[0];
      const lastElement = focusableElements[focusableElements.length - 1];
      
      document.addEventListener('keydown', function(e) {
        if (e.key === 'Tab') {
          if (e.shiftKey) {
            if (document.activeElement === firstElement) {
              e.preventDefault();
              lastElement.focus();
            }
          } else {
            if (document.activeElement === lastElement) {
              e.preventDefault();
              firstElement.focus();
            }
          }
        }
      });
    }
  }
  
  
  addProgressiveEnhancements();
  
  
  function addConnectionStatus() {
    window.addEventListener('online', function() {
      showToast('Connection restored', 'success');
    });
    
    window.addEventListener('offline', function() {
      showToast('Connection lost - please check your internet', 'warning');
    });
  }
  
  
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `sms-toast sms-toast-${type}`;
    toast.innerHTML = `
      <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'} me-2"></i>
      ${message}
    `;
    
    
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: ${type === 'success' ? 'var(--sms-success)' : type === 'warning' ? 'var(--sms-warning)' : 'var(--sms-info)'};
      color: white;
      padding: 1rem 1.5rem;
      border-radius: var(--sms-border-radius-sm);
      box-shadow: var(--sms-shadow-lg);
      z-index: 1000;
      transform: translateX(100%);
      transition: transform 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
   
    setTimeout(() => {
      toast.style.transform = 'translateX(0)';
    }, 100);
    
    
    setTimeout(() => {
      toast.style.transform = 'translateX(100%)';
      setTimeout(() => {
        document.body.removeChild(toast);
      }, 300);
    }, 3000);
  }
  
  
  addConnectionStatus();
  
  
  if ('performance' in window) {
    window.addEventListener('load', function() {
      const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
      if (loadTime > 3000) {
        console.log('Page loaded slowly:', loadTime + 'ms');
      }
    });
  }
});