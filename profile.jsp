<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="My Profile - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Page Header & Role Indicator -->
    <div class="fc-page-header" style="margin-bottom: var(--space-6);">
        <div>
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                <span class="fc-badge fc-badge-info" style="text-transform: uppercase; font-weight: 700; letter-spacing: 0.04em;">
                    <c:out value="${user.userRole}"/> ACCOUNT
                </span>
                <span class="fc-badge ${user.status eq 'ACTIVE' ? 'fc-badge-success' : 'fc-badge-warning'}">
                    <c:out value="${user.status}"/>
                </span>
            </div>
            <h1 style="font-size: 2rem; font-weight: 700; color: var(--color-text); margin: 0;">Account Profile &amp; Settings</h1>
            <p class="fc-caption" style="margin-top: 4px;">Manage your contact details, security credentials, and account preferences.</p>
        </div>
        <div style="display: flex; gap: var(--space-3);">
            <c:if test="${user.userRole eq 'FARMER'}">
                <a href="${pageContext.request.contextPath}/farmer/dashboard" class="fc-btn fc-btn-secondary fc-btn-sm">
                    &larr; Back to Dashboard
                </a>
            </c:if>
            <c:if test="${user.userRole eq 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="fc-btn fc-btn-secondary fc-btn-sm">
                    &larr; Back to Dashboard
                </a>
            </c:if>
            <c:if test="${user.userRole eq 'CUSTOMER'}">
                <a href="${pageContext.request.contextPath}/products" class="fc-btn fc-btn-secondary fc-btn-sm">
                    &larr; Back to Marketplace
                </a>
            </c:if>
        </div>
    </div>

    <!-- Feedback Alerts -->
    <c:if test="${not empty successMessage}">
        <div class="fc-alert fc-alert-success" style="margin-bottom: var(--space-6);">
            <div style="display: flex; align-items: center; gap: 8px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                <span><c:out value="${successMessage}"/></span>
            </div>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="fc-alert fc-alert-error" style="margin-bottom: var(--space-6);">
            <div style="display: flex; align-items: center; gap: 8px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <span><c:out value="${errorMessage}"/></span>
            </div>
        </div>
    </c:if>

    <!-- Role Summary Metric Cards -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-4); margin-bottom: var(--space-8);">
        <c:choose>
            <c:when test="${user.userRole eq 'CUSTOMER'}">
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Total Orders Placed</span>
                    <strong class="fc-stat-value"><c:out value="${totalOrders}"/></strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Total Spend on Fresh Produce</span>
                    <strong class="fc-stat-value">&#8377;<fmt:formatNumber value="${totalSpent}" pattern="#,##0.00"/></strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Member Since</span>
                    <strong class="fc-stat-value" style="font-size: 1.15rem; font-weight: 600;">
                        <fmt:formatDate value="${user.createdAt}" pattern="dd MMM yyyy"/>
                    </strong>
                </div>
            </c:when>

            <c:when test="${user.userRole eq 'FARMER'}">
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Active Listed Crops</span>
                    <strong class="fc-stat-value"><c:out value="${activeProducts}"/></strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Orders Received</span>
                    <strong class="fc-stat-value"><c:out value="${totalOrders}"/></strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Average Customer Rating</span>
                    <strong class="fc-stat-value" style="color: #B45309;">
                        <c:choose>
                            <c:when test="${avgRating > 0}">
                                &#9733; <fmt:formatNumber value="${avgRating}" pattern="0.0"/> / 5.0
                            </c:when>
                            <c:otherwise>New Grower</c:otherwise>
                        </c:choose>
                    </strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Grower Verification</span>
                    <strong class="fc-stat-value" style="font-size: 1.15rem; font-weight: 600;">
                        <c:choose>
                            <c:when test="${farmerProfile.verified eq 'Y'}">
                                <span style="color: var(--color-primary);">&#10003; Verified</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #B45309;">Pending Inspection</span>
                            </c:otherwise>
                        </c:choose>
                    </strong>
                </div>
            </c:when>

            <c:when test="${user.userRole eq 'ADMIN'}">
                <div class="fc-stat-card">
                    <span class="fc-stat-label">System Registered Users</span>
                    <strong class="fc-stat-value"><c:out value="${totalUsers}"/></strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Pending Farmer Approvals</span>
                    <strong class="fc-stat-value" style="color: ${pendingFarmers > 0 ? 'var(--color-terracotta)' : 'var(--color-primary)'};">
                        <c:out value="${pendingFarmers}"/>
                    </strong>
                </div>
                <div class="fc-stat-card">
                    <span class="fc-stat-label">Platform Role</span>
                    <strong class="fc-stat-value" style="font-size: 1.15rem; font-weight: 600; color: var(--color-primary);">System Administrator</strong>
                </div>
            </c:when>
        </c:choose>
    </div>

    <!-- Two-Column Profile Editor Grid -->
    <div style="display: grid; grid-template-columns: 1.2fr 1fr; gap: var(--space-8); align-items: start;">
        <!-- Card 1: Account Information -->
        <div class="fc-card" style="padding: var(--space-8);">
            <div style="border-bottom: 1px solid var(--color-border); padding-bottom: var(--space-4); margin-bottom: var(--space-6);">
                <h2 style="font-size: 1.25rem; font-weight: 600; margin: 0 0 4px 0;">Personal &amp; Contact Information</h2>
                <p class="fc-caption" style="margin: 0;">Update your display name and primary mobile number.</p>
            </div>

            <form action="${pageContext.request.contextPath}/profile" method="post">
                <input type="hidden" name="action" value="updateProfile">

                <div class="fc-form-group">
                    <label for="name" class="fc-label">Full Name</label>
                    <input type="text" id="name" name="name" class="fc-input" required value="<c:out value='${user.name}'/>">
                </div>

                <div class="fc-form-group">
                    <label for="email" class="fc-label">Email Address (Login ID)</label>
                    <input type="email" id="email" class="fc-input" disabled value="<c:out value='${user.email}'/>" style="background-color: var(--color-surface-muted); color: var(--color-text-muted); cursor: not-allowed;">
                    <span class="fc-caption" style="font-size: 0.75rem;">Account email addresses are linked to authentication credentials and cannot be modified.</span>
                </div>

                <div class="fc-form-group">
                    <label for="phone" class="fc-label">Contact Phone</label>
                    <input type="tel" id="phone" name="phone" class="fc-input" placeholder="e.g. 9876543210" value="<c:out value='${user.phone}'/>">
                </div>

                <c:if test="${user.userRole eq 'FARMER'}">
                    <div style="border-top: 1px dashed var(--color-border); padding-top: var(--space-6); margin-top: var(--space-6);">
                        <h3 style="font-size: 1.1rem; font-weight: 600; margin-bottom: var(--space-4); color: var(--color-primary);">
                            Farm &amp; Agriculture Details
                        </h3>

                        <div class="fc-form-group">
                            <label for="farmName" class="fc-label">Farm / Orchard Name</label>
                            <input type="text" id="farmName" name="farmName" class="fc-input" required value="<c:out value='${farmerProfile.farmName}'/>">
                        </div>

                        <div class="fc-form-group">
                            <label for="location" class="fc-label">Farm Location (Village / District / State)</label>
                            <input type="text" id="location" name="location" class="fc-input" required value="<c:out value='${farmerProfile.location}'/>">
                        </div>

                        <div class="fc-form-group">
                            <label for="pincode" class="fc-label">Postal Pincode</label>
                            <input type="text" id="pincode" name="pincode" class="fc-input" maxlength="6" pattern="[0-9]{6}" required value="<c:out value='${farmerProfile.pincode}'/>">
                        </div>
                    </div>
                </c:if>

                <div style="margin-top: var(--space-6);">
                    <button type="submit" class="fc-btn fc-btn-primary">
                        Save Changes
                    </button>
                </div>
            </form>
        </div>

        <!-- Card 2: Password & Security -->
        <div class="fc-card" style="padding: var(--space-8);">
            <div style="border-bottom: 1px solid var(--color-border); padding-bottom: var(--space-4); margin-bottom: var(--space-6);">
                <h2 style="font-size: 1.25rem; font-weight: 600; margin: 0 0 4px 0;">Security &amp; Password</h2>
                <p class="fc-caption" style="margin: 0;">Keep your account safe by updating your password periodically.</p>
            </div>

            <form action="${pageContext.request.contextPath}/profile" method="post">
                <input type="hidden" name="action" value="changePassword">

                <div class="fc-form-group">
                    <label for="currentPassword" class="fc-label">Current Password</label>
                    <input type="password" id="currentPassword" name="currentPassword" class="fc-input" required autocomplete="current-password">
                </div>

                <div class="fc-form-group">
                    <label for="newPassword" class="fc-label">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" class="fc-input" minlength="8" required autocomplete="new-password">
                    <span class="fc-caption" style="font-size: 0.75rem;">Must be at least 8 characters long.</span>
                </div>

                <div class="fc-form-group">
                    <label for="confirmPassword" class="fc-label">Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="fc-input" minlength="8" required autocomplete="new-password">
                </div>

                <div style="margin-top: var(--space-6);">
                    <button type="submit" class="fc-btn fc-btn-secondary">
                        Update Password
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
