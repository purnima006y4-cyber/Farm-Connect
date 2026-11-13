/**
 * FarmConnect - Premium Frontend Interactivity, Micro-interactions & Toast System
 * Vanilla JavaScript (ES6+), zero external runtime dependencies.
 */

// Global FarmConnect namespace
window.FarmConnect = window.FarmConnect || {};

document.addEventListener('DOMContentLoaded', function () {
    initNavigation();
    initAlerts();
    initRegisterTabs();
    initQuantitySteppers();
    initStarRatings();
    initFileValidation();
    initModals();
    initUserDropdown();
    initAddToCartAjax();
    initStatCounters();
    initImageFadeIn();
    initRecentlyViewed();
    initBackToTop();
});

/**
 * Toast Notification System
 */
window.FarmConnect.showToast = function (message, type = 'success', duration = 3500) {
    let container = document.getElementById('fcToastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'fcToastContainer';
        container.className = 'fc-toast-container';
        container.setAttribute('aria-live', 'polite');
        container.setAttribute('aria-atomic', 'true');
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `fc-toast fc-toast-${type}`;

    let iconSvg = '';
    if (type === 'success') {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>';
    } else if (type === 'error' || type === 'danger') {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>';
    } else {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>';
    }

    toast.innerHTML = `
        <div class="fc-toast-content">
            <span class="fc-toast-icon">${iconSvg}</span>
            <span class="fc-toast-message">${escapeHtml(message)}</span>
        </div>
        <button type="button" class="fc-toast-close" aria-label="Dismiss">&times;</button>
    `;

    container.appendChild(toast);

    // Trigger entry animation
    requestAnimationFrame(() => {
        toast.classList.add('is-visible');
    });

    const closeBtn = toast.querySelector('.fc-toast-close');
    let timer = setTimeout(() => dismissToast(toast), duration);

    closeBtn.addEventListener('click', () => {
        clearTimeout(timer);
        dismissToast(toast);
    });

    function dismissToast(el) {
        el.classList.remove('is-visible');
        el.classList.add('is-leaving');
        setTimeout(() => {
            if (el.parentNode) {
                el.parentNode.removeChild(el);
            }
        }, 300);
    }
};

function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

/**
 * Intercept Add-to-Cart with Smooth Toast & Animated Cart Counter
 */
function initAddToCartAjax() {
    document.addEventListener('submit', function (e) {
        const form = e.target.closest('.fc-add-cart-form');
        if (!form) return;

        // Check if browser supports FormData & fetch
        if (window.fetch && window.FormData) {
            e.preventDefault();
            const submitBtn = form.querySelector('button[type="submit"]');
            const origText = submitBtn ? submitBtn.innerHTML : '';
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = 'Adding...';
            }

            const formData = new FormData(form);
            const prodName = form.getAttribute('data-product-name') || 'Produce item';
            const qty = formData.get('quantity') || '1';

            fetch(form.action, {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => {
                if (response.redirected && response.url.indexOf('/login') !== -1) {
                    window.location.href = response.url;
                    return;
                }
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = '✓ Added';
                    setTimeout(() => {
                        submitBtn.innerHTML = origText;
                    }, 1400);
                }

                // Show elegant confirmation toast
                window.FarmConnect.showToast(`Added ${qty}x ${prodName} to basket! 🧺`, 'success');

                // Animate and increment cart pill count if present
                const cartPill = document.querySelector('.fc-cart-pill');
                if (cartPill) {
                    let countBadge = cartPill.querySelector('.fc-cart-count');
                    if (!countBadge) {
                        countBadge = document.createElement('span');
                        countBadge.className = 'fc-cart-count';
                        countBadge.textContent = '0';
                        cartPill.appendChild(countBadge);
                    }
                    const currentCount = parseInt(countBadge.textContent.trim() || '0', 10);
                    countBadge.textContent = currentCount + 1;
                    countBadge.classList.add('bump');
                    setTimeout(() => countBadge.classList.remove('bump'), 400);
                }
            })
            .catch(err => {
                console.warn('AJAX cart add failed, falling back to form submit:', err);
                form.submit();
            });
        }
    });
}

/**
 * Animated Stat Counters for Dashboards
 */
function initStatCounters() {
    const statElements = document.querySelectorAll('.fc-stat-value');
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return; // Respect reduced motion
    }

    statElements.forEach(el => {
        const text = el.textContent.trim();
        // Match pure integer or float count
        const match = text.match(/^([\D]*)(\d+(?:\.\d+)?)(.*)$/);
        if (match) {
            const prefix = match[1];
            const target = parseFloat(match[2]);
            const suffix = match[3];
            const isFloat = match[2].includes('.');
            const duration = 750;
            const startTime = performance.now();

            function updateCounter(currentTime) {
                const elapsed = currentTime - startTime;
                const progress = Math.min(elapsed / duration, 1);
                // Ease out quad
                const easeOut = 1 - (1 - progress) * (1 - progress);
                const current = target * easeOut;

                if (isFloat) {
                    el.textContent = `${prefix}${current.toFixed(2)}${suffix}`;
                } else {
                    el.textContent = `${prefix}${Math.floor(current)}${suffix}`;
                }

                if (progress < 1) {
                    requestAnimationFrame(updateCounter);
                } else {
                    el.textContent = text; // Final exact text
                }
            }

            requestAnimationFrame(updateCounter);
        }
    });
}

/**
 * Responsive Mobile Navigation Toggle
 */
function initNavigation() {
    const navToggle = document.querySelector('.fc-nav-toggle');
    const navLinks = document.querySelector('.fc-nav-actions');

    if (navToggle && navLinks) {
        navToggle.addEventListener('click', function () {
            const isExpanded = navToggle.getAttribute('aria-expanded') === 'true';
            navToggle.setAttribute('aria-expanded', !isExpanded);
            navLinks.classList.toggle('is-open');
        });

        // Close navigation when clicking outside on mobile
        document.addEventListener('click', function (e) {
            if (!navToggle.contains(e.target) && !navLinks.contains(e.target) && navLinks.classList.contains('is-open')) {
                navLinks.classList.remove('is-open');
                navToggle.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // Dashboard sidebar mobile toggle
    const sidebarToggle = document.getElementById('fcSidebarToggle');
    const sidebar = document.getElementById('fcSidebar');
    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function () {
            sidebar.classList.toggle('is-open');
        });
    }
}

/**
 * User Dropdown Menu Toggle with Keyboard Navigation
 */
function initUserDropdown() {
    const trigger = document.getElementById('fcUserTrigger');
    const dropdown = document.getElementById('fcUserDropdown');
    const menu = document.getElementById('fcDropdownMenu');

    if (trigger && dropdown && menu) {
        trigger.addEventListener('click', function (e) {
            e.stopPropagation();
            const isOpen = dropdown.classList.contains('is-open');
            if (isOpen) {
                closeDropdown();
            } else {
                openDropdown();
            }
        });

        document.addEventListener('click', function (e) {
            if (!dropdown.contains(e.target)) {
                closeDropdown();
            }
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && dropdown.classList.contains('is-open')) {
                closeDropdown();
                trigger.focus();
            }
        });

        function openDropdown() {
            dropdown.classList.add('is-open');
            menu.classList.add('is-open');
            trigger.setAttribute('aria-expanded', 'true');
        }

        function closeDropdown() {
            dropdown.classList.remove('is-open');
            menu.classList.remove('is-open');
            trigger.setAttribute('aria-expanded', 'false');
        }

        // Close dropdown when any item inside is clicked
        menu.addEventListener('click', function(e) {
            const link = e.target.closest('a');
            if (link) {
                closeDropdown();
            }
        });

        // Keyboard arrow navigation
        dropdown.addEventListener('keydown', function(e) {
            if (!dropdown.classList.contains('is-open')) return;
            const items = Array.from(menu.querySelectorAll('a[role="menuitem"], .fc-dropdown-item'));
            if (!items.length) return;

            const currentIndex = items.indexOf(document.activeElement);
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                const nextIndex = (currentIndex + 1) % items.length;
                items[nextIndex].focus();
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                const prevIndex = (currentIndex - 1 + items.length) % items.length;
                items[prevIndex].focus();
            } else if (e.key === 'Tab') {
                closeDropdown();
            }
        });
    }
}

/**
 * Alert Notifications: Close button & auto-dismiss after 5s
 */
function initAlerts() {
    const alerts = document.querySelectorAll('.fc-alert, .alert');
    alerts.forEach(function (alert) {
        let timer = setTimeout(function () {
            dismissAlert(alert);
        }, 5000);

        alert.addEventListener('mouseenter', function () {
            clearTimeout(timer);
        });

        const closeBtn = alert.querySelector('.fc-alert-close, .alert-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                dismissAlert(alert);
            });
        }
    });

    function dismissAlert(el) {
        el.style.transition = 'opacity 0.3s ease, transform 0.3s ease, max-height 0.3s ease';
        el.style.opacity = '0';
        el.style.transform = 'translateY(-6px)';
        setTimeout(function () {
            if (el.parentNode) {
                el.parentNode.removeChild(el);
            }
        }, 300);
    }
}

/**
 * Register Page: Role Switcher Tabs (Customer vs Farmer)
 */
function initRegisterTabs() {
    const roleTabs = document.querySelectorAll('.fc-role-tab');
    const farmerFields = document.getElementById('farmerFields');
    const roleInput = document.getElementById('roleInput');

    if (roleTabs.length > 0 && roleInput) {
        roleTabs.forEach(function (tab) {
            tab.addEventListener('click', function () {
                const selectedRole = tab.getAttribute('data-role');
                roleTabs.forEach(t => t.classList.remove('active'));
                tab.classList.add('active');

                roleInput.value = selectedRole;

                if (selectedRole === 'FARMER') {
                    if (farmerFields) {
                        farmerFields.style.display = 'block';
                        const inputs = farmerFields.querySelectorAll('input, select');
                        inputs.forEach(i => {
                            if (i.id !== 'verifiedDoc') i.required = true;
                        });
                    }
                } else {
                    if (farmerFields) {
                        farmerFields.style.display = 'none';
                        const inputs = farmerFields.querySelectorAll('input, select');
                        inputs.forEach(i => i.required = false);
                    }
                }
            });
        });
    }

    // Password match validation
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', function (e) {
            const pwd = document.getElementById('password');
            const confirmPwd = document.getElementById('confirmPassword');
            if (pwd && confirmPwd && pwd.value !== confirmPwd.value) {
                e.preventDefault();
                window.FarmConnect.showToast('Passwords do not match. Please re-enter your password.', 'error');
                confirmPwd.focus();
            }
        });
    }
}

/**
 * Quantity Steppers (+ / - buttons) for Cart & Product Details
 */
function initQuantitySteppers() {
    const steppers = document.querySelectorAll('.fc-quantity-stepper');
    steppers.forEach(function (stepper) {
        const input = stepper.querySelector('input[type="number"]');
        const minusBtn = stepper.querySelector('button[data-action="decrement"]');
        const plusBtn = stepper.querySelector('button[data-action="increment"]');

        if (!input) return;

        const min = parseInt(input.getAttribute('min') || '1', 10);
        const max = parseInt(input.getAttribute('max') || '999999', 10);

        if (minusBtn) {
            minusBtn.addEventListener('click', function (e) {
                e.preventDefault();
                let currentVal = parseInt(input.value || '1', 10);
                if (currentVal > min) {
                    input.value = currentVal - 1;
                    input.dispatchEvent(new Event('change'));
                }
            });
        }

        if (plusBtn) {
            plusBtn.addEventListener('click', function (e) {
                e.preventDefault();
                let currentVal = parseInt(input.value || '1', 10);
                if (currentVal < max) {
                    input.value = currentVal + 1;
                    input.dispatchEvent(new Event('change'));
                }
            });
        }
    });
}

/**
 * Interactive Star Rating Widget
 */
function initStarRatings() {
    const starContainers = document.querySelectorAll('.fc-rating-picker');
    starContainers.forEach(function (container) {
        const stars = container.querySelectorAll('.fc-rating-star');
        const input = container.querySelector('input[name="rating"]');

        stars.forEach(function (star, index) {
            star.addEventListener('click', function () {
                const rating = index + 1;
                if (input) input.value = rating;

                stars.forEach(function (s, i) {
                    if (i < rating) {
                        s.classList.add('active');
                        s.style.color = '#eab308';
                    } else {
                        s.classList.remove('active');
                        s.style.color = '#cbd5e1';
                    }
                });
            });

            star.addEventListener('mouseenter', function () {
                const hoverRating = index + 1;
                stars.forEach(function (s, i) {
                    s.style.color = i < hoverRating ? '#facc15' : '#cbd5e1';
                });
            });
        });

        container.addEventListener('mouseleave', function () {
            const currentVal = parseInt(input ? input.value : '0', 10);
            stars.forEach(function (s, i) {
                s.style.color = i < currentVal ? '#eab308' : '#cbd5e1';
            });
        });
    });
}

/**
 * File Upload Size & Format Validation (Max 2MB, JPG/PNG)
 */
function initFileValidation() {
    const fileInputs = document.querySelectorAll('input[type="file"][accept*="image"]');
    const MAX_SIZE_BYTES = 2 * 1024 * 1024; // 2 MB

    fileInputs.forEach(function (input) {
        input.addEventListener('change', function () {
            if (this.files && this.files[0]) {
                const file = this.files[0];
                const validTypes = ['image/jpeg', 'image/jpg', 'image/png'];

                if (!validTypes.includes(file.type.toLowerCase())) {
                    window.FarmConnect.showToast('Invalid file format. Please upload a JPG or PNG image.', 'error');
                    this.value = '';
                    return;
                }

                if (file.size > MAX_SIZE_BYTES) {
                    window.FarmConnect.showToast(`File too large (${(file.size / (1024 * 1024)).toFixed(2)} MB). Maximum allowed size is 2 MB.`, 'error');
                    this.value = '';
                    return;
                }
            }
        });
    });
}

/**
 * Modal Dialog Controller for Complaints & Disclaimers
 */
function initModals() {
    document.querySelectorAll('[data-fc-modal-open]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            const modalId = btn.getAttribute('data-fc-modal-open');
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.classList.add('is-open');
                modal.setAttribute('aria-hidden', 'false');
                document.body.style.overflow = 'hidden';
            }
        });
    });

    document.querySelectorAll('[data-fc-modal-close]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            closeAllModals();
        });
    });

    document.querySelectorAll('.fc-modal-backdrop').forEach(function (backdrop) {
        backdrop.addEventListener('click', function (e) {
            if (e.target === backdrop) {
                closeAllModals();
            }
        });
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeAllModals();
        }
    });

    function closeAllModals() {
        document.querySelectorAll('.fc-modal-backdrop.is-open').forEach(function (modal) {
            modal.classList.remove('is-open');
            modal.setAttribute('aria-hidden', 'true');
        });
        document.body.style.overflow = '';
    }
}

/**
 * Smooth Image Fade-In on Load
 */
function initImageFadeIn() {
    const images = document.querySelectorAll('img[loading="lazy"]');
    images.forEach(img => {
        if (img.complete) {
            img.classList.add('is-loaded');
        } else {
            img.addEventListener('load', () => img.classList.add('is-loaded'));
            img.addEventListener('error', () => img.classList.add('is-loaded'));
        }
    });
}

/**
 * Recently Viewed Produce Strip (Client-side localStorage)
 */
const RECENT_STORAGE_KEY = 'fc_recently_viewed';
const MAX_RECENT_ITEMS = 6;

window.FarmConnect.recordRecentlyViewed = function(item) {
    if (!item || !item.id) return;
    try {
        let list = JSON.parse(localStorage.getItem(RECENT_STORAGE_KEY) || '[]');
        // Filter out existing occurrence
        list = list.filter(x => String(x.id) !== String(item.id));
        // Add to front
        list.unshift(item);
        if (list.length > MAX_RECENT_ITEMS) {
            list = list.slice(0, MAX_RECENT_ITEMS);
        }
        localStorage.setItem(RECENT_STORAGE_KEY, JSON.stringify(list));
    } catch (e) {
        console.warn('Could not save recently viewed item to localStorage:', e);
    }
};

function initRecentlyViewed() {
    const section = document.getElementById('fcRecentlyViewedSection');
    const grid = document.getElementById('fcRecentGrid');
    const clearBtn = document.getElementById('fcClearRecentBtn');
    if (!section || !grid) return;

    try {
        const list = JSON.parse(localStorage.getItem(RECENT_STORAGE_KEY) || '[]');
        if (!list || list.length === 0) {
            section.style.display = 'none';
            return;
        }

        grid.innerHTML = '';
        list.slice(0, 4).forEach(item => {
            const card = document.createElement('div');
            card.className = 'fc-recent-card';
            card.innerHTML = `
                <a href="${escapeHtml(item.url)}" class="fc-recent-thumb">
                    <img src="${escapeHtml(item.image)}" alt="${escapeHtml(item.name)}" onerror="this.onerror=null;this.src='${escapeHtml(item.url.substring(0, item.url.indexOf('/product')))}/assets/img/placeholder-product.jpg';">
                </a>
                <div class="fc-recent-info">
                    <span class="fc-recent-cat">${escapeHtml(item.category || 'Produce')}</span>
                    <a href="${escapeHtml(item.url)}" class="fc-recent-name">${escapeHtml(item.name)}</a>
                    <div class="fc-recent-price">&#8377;${escapeHtml(item.price)}</div>
                </div>
            `;
            grid.appendChild(card);
        });

        section.style.display = 'block';

        if (clearBtn) {
            clearBtn.addEventListener('click', function() {
                localStorage.removeItem(RECENT_STORAGE_KEY);
                section.style.display = 'none';
                grid.innerHTML = '';
            });
        }
    } catch (e) {
        console.warn('Error reading recently viewed produce:', e);
        section.style.display = 'none';
    }
}

/**
 * Smooth Floating Back-to-Top Button
 */
function initBackToTop() {
    const btn = document.getElementById('fcBackToTop');
    if (!btn) return;

    window.addEventListener('scroll', function() {
        if (window.scrollY > 350) {
            btn.classList.add('is-visible');
        } else {
            btn.classList.remove('is-visible');
        }
    }, { passive: true });

    btn.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

