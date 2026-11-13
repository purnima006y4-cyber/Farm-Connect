<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="My Orders & Delivery Tracking - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li aria-current="page">My Orders</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">My Orders &amp; Delivery Tracking</h1>
            <p class="fc-page-subtitle">Track farm preparation, dispatch routes, and delivered produce.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-outline btn-sm">
                + Order More Produce
            </a>
        </div>
    </div>

    <c:if test="${param.success eq 'true'}">
        <div class="fc-alert fc-alert-success" role="status" style="margin-bottom: var(--space-6);">
            <div style="display: flex; align-items: center; gap: 8px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                <div>
                    <strong>Order Placed Successfully!</strong> The growers have received your request and are packing produce freshly picked from the farm.
                </div>
            </div>
            <button type="button" class="fc-alert-close" aria-label="Dismiss">&times;</button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No Orders Placed Yet</h3>
                <p class="fc-empty-desc">You haven't ordered any fresh harvest yet. Browse dozens of seasonal fruits, vegetables, and grains direct from certified farms.</p>
                <div style="margin-top: 1.25rem;">
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">
                        Start Shopping Now 🛒
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Order Ref</th>
                                <th>Date Placed</th>
                                <th>Grower / Farm</th>
                                <th>Order Value</th>
                                <th>Status</th>
                                <th>Expected Delivery</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/customer/order?id=${o.orderId}" style="font-weight: 700; color: var(--color-primary); font-family: monospace;">
                                            #<c:out value="${o.orderId}"/>
                                        </a>
                                    </td>
                                    <td style="color: var(--color-text-muted); font-size: 0.875rem;">
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy, hh:mm a"/>
                                    </td>
                                    <td>
                                        <span class="product-tag">
                                            🏡 <c:out value="${o.farmerName}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--color-text); font-size: 1rem;" class="num-tabular">
                                            &#8377;<fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/>
                                        </strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.status eq 'PLACED'}"><span class="fc-badge fc-badge-warning">Placed</span></c:when>
                                            <c:when test="${o.status eq 'CONFIRMED'}"><span class="fc-badge fc-badge-info">Confirmed</span></c:when>
                                            <c:when test="${o.status eq 'PACKED'}"><span class="fc-badge fc-badge-info">Packed</span></c:when>
                                            <c:when test="${o.status eq 'OUT_FOR_DELIVERY'}"><span class="fc-badge fc-badge-primary">In Transit</span></c:when>
                                            <c:when test="${o.status eq 'DELIVERED'}"><span class="fc-badge fc-badge-success">Delivered</span></c:when>
                                            <c:when test="${o.status eq 'CANCELLED'}"><span class="fc-badge fc-badge-danger">Cancelled</span></c:when>
                                            <c:otherwise><span class="fc-badge fc-badge-neutral"><c:out value="${o.status}"/></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-size: 0.875rem; color: var(--color-text-muted);">
                                        <c:choose>
                                            <c:when test="${not empty o.expectedDeliveryDate}">
                                                📅 <fmt:formatDate value="${o.expectedDeliveryDate}" pattern="dd MMM yyyy"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--color-text-subtle);">Estimating...</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <div style="display: inline-flex; gap: 0.5rem; align-items: center; justify-content: flex-end; flex-wrap: wrap;">
                                            <a href="${pageContext.request.contextPath}/customer/order?id=${o.orderId}" class="btn btn-sm btn-secondary">
                                                Receipt
                                            </a>

                                            <c:if test="${o.status eq 'PLACED'}">
                                                <form action="${pageContext.request.contextPath}/customer/orders/cancel" method="post" onsubmit="return confirm('Cancel this order? Your reserved items will be restored to the farmer inventory.');" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <button type="submit" class="btn btn-sm btn-danger">
                                                        Cancel
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
