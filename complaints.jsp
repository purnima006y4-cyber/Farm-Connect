<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="My Support Tickets - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/orders">My Orders</a></li>
            <li aria-current="page">Support Grievances</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Support Grievances &amp; Complaints</h1>
            <p class="fc-page-subtitle">Track resolutions for issues reported on your orders.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/customer/orders" class="fc-btn fc-btn-outline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 0.35rem;"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Back to Orders
            </a>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty complaints}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <h3 class="fc-empty-title">No support tickets found</h3>
                <p class="fc-empty-desc">You have no active or historical grievances. If you ever experience quality or delivery issues with an order, you can report it directly from your order details page.</p>
                <div style="margin-top: 1.25rem;">
                    <a href="${pageContext.request.contextPath}/customer/orders" class="fc-btn fc-btn-primary">View Past Orders</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Ticket ID</th>
                                <th>Order Ref</th>
                                <th>Reported Grievance</th>
                                <th>Resolution Status</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${complaints}">
                                <tr>
                                    <td>
                                        <span style="font-family: monospace; font-weight: 700; color: var(--color-neutral-700);">#TCK-<c:out value="${c.complaintId}"/></span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/customer/order?id=${c.orderId}" style="color: var(--color-primary-600); font-weight: 700; text-decoration: underline;">
                                            #<c:out value="${c.orderId}"/>
                                        </a>
                                    </td>
                                    <td style="max-width: 420px;">
                                        <div style="color: var(--color-neutral-800); font-size: 0.9375rem; line-height: 1.45;">
                                            <c:out value="${c.message}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status eq 'OPEN'}">
                                                <span class="fc-badge fc-badge-warning">In Review</span>
                                            </c:when>
                                            <c:when test="${c.status eq 'RESOLVED'}">
                                                <span class="fc-badge fc-badge-success">Resolved</span>
                                            </c:when>
                                            <c:when test="${c.status eq 'CLOSED'}">
                                                <span class="fc-badge fc-badge-neutral">Closed</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fc-badge fc-badge-info"><c:out value="${c.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <a href="${pageContext.request.contextPath}/customer/order?id=${c.orderId}" class="fc-btn fc-btn-sm fc-btn-outline">
                                            View Order
                                        </a>
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
