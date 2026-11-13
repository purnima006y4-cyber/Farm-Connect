<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Sign In - FarmConnect" />
</jsp:include>

<div class="fc-auth-wrapper">
    <!-- Visual Left Panel with Authentic Farm Photography -->
    <div class="fc-auth-visual">
        <div>
            <div class="fc-brand-icon" style="background: rgba(255, 255, 255, 0.2); color: #FFFFFF; margin-bottom: var(--space-6);">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                    <path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12c0-2.5 1-4.5 2-6"/>
                    <path d="M12 2c0 4 2 8 8 10"/>
                    <path d="M7 17l5-5"/>
                </svg>
            </div>
            <div class="fc-auth-visual-content">
                <h2>Direct from Soil to Doorstep</h2>
                <p>Join thousands of conscious consumers and rural farming families trading fresh harvest transparently with zero intermediary markups.</p>
                <ul class="fc-auth-bullets">
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Peak farm freshness harvested within 24 to 48 hours</span>
                    </li>
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Fair farm-gate returns empowering rural growers</span>
                    </li>
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Verified growers inspected and certified for safety</span>
                    </li>
                </ul>
            </div>
        </div>
        <div style="font-size: 0.8125rem; color: rgba(255, 255, 255, 0.7);">
            &copy; 2024 FarmConnect. Transparent agriculture.
        </div>
    </div>

    <!-- Right Side Form Panel -->
    <div class="fc-auth-form-side">
        <div class="fc-auth-card">

            <!-- Flash alerts for Logout and Registration Status -->
            <c:if test="${param.msg eq 'logged_out' and empty message}">
                <div class="fc-alert fc-alert-success" role="status" style="margin-bottom: var(--space-4);">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>You have been logged out successfully.</span>
                    </div>
                </div>
            </c:if>

            <c:if test="${param.registered eq 'farmer'}">
                <div class="fc-alert fc-alert-warning" role="status" style="margin-bottom: var(--space-4); background: #FEF3C7; border: 1px solid #F59E0B; color: #92400E; padding: 12px; border-radius: var(--radius-md);">
                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2" style="flex-shrink: 0; margin-top: 2px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        <div style="font-size: 0.85rem; line-height: 1.4;">
                            <strong style="display: block; margin-bottom: 2px;">Grower Application Received</strong>
                            Your grower application has been received and is pending admin approval. You will receive an email once approved.
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- 3-Way Segmented Role Selector -->
            <div class="fc-role-segmented-control" role="tablist" aria-label="Sign in role selection">
                <button type="button" class="fc-role-segment-btn active" data-role="CUSTOMER" id="tabCustomer" role="tab" aria-selected="true">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                    <span>Customer</span>
                </button>
                <button type="button" class="fc-role-segment-btn" data-role="FARMER" id="tabFarmer" role="tab" aria-selected="false">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    <span>Farmer</span>
                </button>
                <button type="button" class="fc-role-segment-btn" data-role="ADMIN" id="tabAdmin" role="tab" aria-selected="false">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                    <span>Admin</span>
                </button>
            </div>

            <div class="fc-auth-header">
                <h1 class="fc-auth-title" id="authTitle">Sign In as Customer</h1>
                <p class="fc-auth-subtitle" id="authSubtitle">Browse fresh crops, track orders, and connect directly with local growers.</p>
            </div>

            <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm" novalidate>
                <div class="fc-form-group">
                    <label for="email" class="fc-label">Email Address</label>
                    <input type="email" id="email" name="email" class="fc-input" required autocomplete="email" placeholder="you@example.com">
                </div>

                <div class="fc-form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <label for="password" class="fc-label" style="margin-bottom: 0;">Password</label>
                        <button type="button" id="togglePasswordBtn" style="font-size: 0.78125rem; color: var(--color-primary); font-weight: 600; background: none; border: none; cursor: pointer;">
                            Show Password
                        </button>
                    </div>
                    <input type="password" id="password" name="password" class="fc-input" required autocomplete="current-password" placeholder="••••••••">
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: var(--space-4);" id="loginSubmitBtn">
                    Sign In
                </button>
            </form>

            <div style="margin-top: var(--space-6); text-align: center; font-size: 0.9rem; color: var(--color-text-muted);" id="registerLinkContainer">
                Don't have an account? 
                <a href="${pageContext.request.contextPath}/register" style="font-weight: 700; color: var(--color-primary); text-decoration: underline;">
                    Register as Customer
                </a>
            </div>

        </div>
    </div>
</div>

<script>
const roleConfig = {
    CUSTOMER: {
        title: "Sign In as Customer",
        subtitle: "Browse fresh crops, track orders, and connect directly with local growers.",
        registerHtml: 'New to FarmConnect? <a href="${pageContext.request.contextPath}/register" style="font-weight: 700; color: var(--color-primary); text-decoration: underline;">Register as Customer</a>'
    },
    FARMER: {
        title: "Sign In as Farmer",
        subtitle: "Manage your harvest listings, review incoming orders, and track sales revenue.",
        registerHtml: 'Want to sell your harvest? <a href="${pageContext.request.contextPath}/register?role=FARMER" style="font-weight: 700; color: var(--color-primary); text-decoration: underline;">Register as a Grower</a>'
    },
    ADMIN: {
        title: "Admin Governance Sign In",
        subtitle: "Marketplace oversight, grower verification, dispute handling, and catalogue management.",
        registerHtml: '<span style="color: var(--color-text-subtle);">Admin accounts are provisioned internally by system administration.</span>'
    }
};

function setRoleTab(role) {
    const tabs = document.querySelectorAll('.fc-role-segment-btn');
    tabs.forEach(tab => {
        const isActive = tab.getAttribute('data-role') === role;
        tab.classList.toggle('active', isActive);
        tab.setAttribute('aria-selected', isActive ? 'true' : 'false');
    });

    const cfg = roleConfig[role] || roleConfig.CUSTOMER;
    const titleEl = document.getElementById('authTitle');
    const subtitleEl = document.getElementById('authSubtitle');
    const regContainer = document.getElementById('registerLinkContainer');

    if (titleEl) titleEl.textContent = cfg.title;
    if (subtitleEl) subtitleEl.textContent = cfg.subtitle;
    if (regContainer) regContainer.innerHTML = cfg.registerHtml;
}

document.querySelectorAll('.fc-role-segment-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        setRoleTab(this.getAttribute('data-role'));
    });
});


// Check URL param on load
(function() {
    const params = new URLSearchParams(window.location.search);
    const r = (params.get('role') || '').toUpperCase();
    if (roleConfig[r]) {
        setRoleTab(r);
    }
})();

document.getElementById('togglePasswordBtn').addEventListener('click', function() {
    const p = document.getElementById('password');
    if (p.type === 'password') {
        p.type = 'text';
        this.textContent = 'Hide Password';
    } else {
        p.type = 'password';
        this.textContent = 'Show Password';
    }
});
</script>

<jsp:include page="/jsp/common/footer.jsp" />
