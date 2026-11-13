<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Manage Farmers - FarmConnect Admin" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Overview</a></li>
            <li aria-current="page">Farmers &amp; Approvals</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Manage Farmers &amp; Verifications</h1>
            <p class="fc-page-subtitle">Approve new farm registrations, inspect locations, and manage account authorization status.</p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty farmers}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No farmer accounts found</h3>
                <p class="fc-empty-desc">No farmers have registered on the platform yet.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Grower Details</th>
                                <th>Farm Name &amp; Contact</th>
                                <th>Location &amp; Pincode</th>
                                <th>Verified</th>
                                <th>Account Status</th>
                                <th style="text-align: right;">Moderation Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="f" items="${farmers}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 700; color: var(--color-neutral-900); font-size: 0.9375rem;">
                                            <c:out value="${f.farmerName}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-500); font-family: monospace;">
                                            UID: #<c:out value="${f.userId}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--color-primary-800);">
                                            <c:out value="${f.farmName}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-600);">
                                            <c:out value="${f.email}"/> &bull; <c:out value="${f.phone}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="color: var(--color-neutral-800); font-size: 0.875rem;">
                                            <c:out value="${f.location}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-500);">
                                            PIN: <c:out value="${f.pincode}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${f.verified eq 'Y'}">
                                                <span class="fc-badge fc-badge-success" style="font-weight: 700;">
                                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" style="margin-right: 0.2rem;"><polyline points="20 6 9 17 4 12"/></svg>
                                                    Verified
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fc-badge fc-badge-neutral">Unverified</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${f.status eq 'ACTIVE'}">
                                                <span class="fc-badge fc-badge-success">Active</span>
                                            </c:when>
                                            <c:when test="${f.status eq 'PENDING'}">
                                                <span class="fc-badge fc-badge-warning" style="animation: pulse 2s infinite;">Pending Approval</span>
                                            </c:when>
                                            <c:when test="${f.status eq 'BLOCKED'}">
                                                <span class="fc-badge fc-badge-danger">Blocked</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fc-badge fc-badge-neutral"><c:out value="${f.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <div style="display: inline-flex; gap: 0.35rem; align-items: center; justify-content: flex-end; flex-wrap: wrap;">
                                            <c:if test="${f.status eq 'PENDING'}">
                                                <form action="${pageContext.request.contextPath}/admin/farmers" method="post" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="userId" value="${f.userId}">
                                                    <input type="hidden" name="action" value="approve">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                        Approve ✓
                                                    </button>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/admin/farmers" method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Reject registration for ${f.farmerName}?');">
                                                    <input type="hidden" name="userId" value="${f.userId}">
                                                    <input type="hidden" name="action" value="reject">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                        Reject
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${f.status eq 'ACTIVE'}">
                                                <form action="${pageContext.request.contextPath}/admin/farmers" method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Block farmer account ${f.farmerName}? Their product listings will be suspended.');">
                                                    <input type="hidden" name="userId" value="${f.userId}">
                                                    <input type="hidden" name="action" value="block">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                        Block
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${f.status eq 'BLOCKED'}">
                                                <form action="${pageContext.request.contextPath}/admin/farmers" method="post" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="userId" value="${f.userId}">
                                                    <input type="hidden" name="action" value="unblock">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                        Unblock
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
