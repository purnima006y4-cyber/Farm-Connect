<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Create Account - FarmConnect" />
</jsp:include>

<c:set var="isFarmerInitial" value="${param.role eq 'FARMER'}" />

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
                <h2>Join the Direct Farm-to-Table Movement</h2>
                <p>Whether you grow high-quality produce or want nutritious food for your family, FarmConnect connects you directly without intermediaries.</p>
                <ul class="fc-auth-bullets">
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>For Buyers: Direct harvest freshness, 100% transparent pricing</span>
                    </li>
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>For Growers: List unlimited crops, keep 100% of fair value</span>
                    </li>
                    <li class="fc-auth-bullet">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8A33D" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <span>Zero subscription fees, verified farm certification guarantee</span>
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
        <div class="fc-auth-card" style="max-width: 520px;">
            <div class="fc-auth-header">
                <h1 class="fc-auth-title">Create Your Account</h1>
                <p class="fc-auth-subtitle">Select your account type to get started.</p>
            </div>

            <!-- Big Selectable Role Cards -->
            <div class="fc-role-selector">
                <div class="fc-role-card ${isFarmerInitial ? '' : 'active'}" data-role="CUSTOMER" id="cardCustomer">
                    <div class="fc-role-card-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                    </div>
                    <div class="fc-role-card-title">Customer</div>
                    <div class="fc-role-card-desc">I want fresh produce</div>
                </div>

                <div class="fc-role-card ${isFarmerInitial ? 'active' : ''}" data-role="FARMER" id="cardFarmer">
                    <div class="fc-role-card-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    </div>
                    <div class="fc-role-card-title">Farmer</div>
                    <div class="fc-role-card-desc">I want to sell crops</div>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/register" method="post" id="registerForm" novalidate>
                <input type="hidden" name="role" id="roleInput" value="${isFarmerInitial ? 'FARMER' : 'CUSTOMER'}">

                <div class="fc-form-group">
                    <label for="name" class="fc-label">Full Name <span style="color: var(--color-terracotta);">*</span></label>
                    <input type="text" id="name" name="name" class="fc-input" required placeholder="e.g. Ramesh Kumar">
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-4);">
                    <div class="fc-form-group">
                        <label for="email" class="fc-label">Email <span style="color: var(--color-terracotta);">*</span></label>
                        <input type="email" id="email" name="email" class="fc-input" required autocomplete="email" placeholder="ramesh@example.com">
                    </div>
                    <div class="fc-form-group">
                        <label for="phone" class="fc-label">Mobile Phone <span style="color: var(--color-terracotta);">*</span></label>
                        <input type="tel" id="phone" name="phone" class="fc-input" required placeholder="9876543210">
                    </div>
                </div>

                <div class="fc-form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <label for="password" class="fc-label" style="margin-bottom: 0;">Password (Min 8 chars) <span style="color: var(--color-terracotta);">*</span></label>
                        <button type="button" id="togglePasswordBtn" style="font-size: 0.78125rem; color: var(--color-primary); font-weight: 600; background: none; border: none; cursor: pointer;">
                            Show Password
                        </button>
                    </div>
                    <input type="password" id="password" name="password" class="fc-input" minlength="8" required placeholder="••••••••">
                </div>

                <!-- Conditional Farmer Fields Section -->
                <div id="farmerFields" style="display: ${isFarmerInitial ? 'block' : 'none'}; background: var(--color-bg); border: 1px solid var(--color-border); padding: var(--space-4); border-radius: var(--radius-md); margin-bottom: var(--space-4);">
                    <div style="font-weight: 700; color: var(--color-primary); font-size: 0.9rem; margin-bottom: var(--space-3); display: flex; align-items: center; gap: 6px;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                        <span>Grower &amp; Farm Profile Details</span>
                    </div>

                    <div class="fc-form-group">
                        <label for="farmName" class="fc-label">Farm / Estate Name <span style="color: var(--color-terracotta);">*</span></label>
                        <input type="text" id="farmName" name="farmName" class="fc-input" placeholder="e.g. Ramesh Green Acres">
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-4);">
                        <div class="fc-form-group">
                            <label for="location" class="fc-label">Farm Location / Town</label>
                            <input type="text" id="location" name="location" class="fc-input" placeholder="e.g. Pune / Nashik">
                        </div>
                        <div class="fc-form-group">
                            <label for="pincode" class="fc-label">Pincode (6 digits)</label>
                            <input type="text" id="pincode" name="pincode" class="fc-input" pattern="[0-9]{6}" maxlength="6" placeholder="411001">
                        </div>
                    </div>

                    <div style="background: var(--status-warning-bg); border: 1px solid var(--status-warning-border); padding: 8px 12px; border-radius: var(--radius-sm); font-size: 0.78125rem; color: var(--status-warning-text); line-height: 1.4;">
                        <strong>Admin Verification:</strong> To ensure produce quality and safety, newly registered farmer accounts start in <strong>PENDING</strong> status and are approved by the marketplace administrator before listing crops.
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: var(--space-4);">
                    Create Account
                </button>
            </form>

            <div style="margin-top: var(--space-6); text-align: center; font-size: 0.9rem; color: var(--color-text-muted);">
                Already have an account? 
                <a href="${pageContext.request.contextPath}/login" style="font-weight: 700; color: var(--color-primary); text-decoration: underline;">
                    Sign in here
                </a>
            </div>
        </div>
    </div>
</div>

<script>
const cardCustomer = document.getElementById('cardCustomer');
const cardFarmer = document.getElementById('cardFarmer');
const roleInput = document.getElementById('roleInput');
const farmerFields = document.getElementById('farmerFields');

function selectRegisterRole(role) {
    if (role === 'FARMER') {
        cardFarmer.classList.add('active');
        cardCustomer.classList.remove('active');
        roleInput.value = 'FARMER';
        farmerFields.style.display = 'block';
    } else {
        cardCustomer.classList.add('active');
        cardFarmer.classList.remove('active');
        roleInput.value = 'CUSTOMER';
        farmerFields.style.display = 'none';
    }
}

cardCustomer.addEventListener('click', function() {
    selectRegisterRole('CUSTOMER');
});

cardFarmer.addEventListener('click', function() {
    selectRegisterRole('FARMER');
});

// Check URL params on load if set
(function() {
    const params = new URLSearchParams(window.location.search);
    if ((params.get('role') || '').toUpperCase() === 'FARMER') {
        selectRegisterRole('FARMER');
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
