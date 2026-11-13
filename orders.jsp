<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Incoming Farm Orders - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/dashboard">Grower Console</a></li>
            <li aria-current="page">Incoming Orders</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Manage Customer Orders</h1>
            <p class="fc-page-subtitle">Advance order fulfillment from confirmation to packing, dispatch, and final delivery.</p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                        <path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No orders placed yet</h3>
                <p class="fc-empty-desc">When buyers order your crops and farm produce, they will appear here with shipping addresses and packing checklists.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Order Ref</th>
                                <th>Customer Name</th>
                                <th>Order Value</th>
                                <th>Current Status</th>
                                <th>Date Placed</th>
                                <th>Target Delivery</th>
                                <th style="text-align: right;">Fulfillment Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/farmer/order?id=${o.orderId}" style="font-family: monospace; font-weight: 700; color: var(--color-primary-700);">
                                            #<c:out value="${o.orderId}"/>
                                        </a>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600; color: var(--color-neutral-800);"><c:out value="${o.customerName}"/></span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--color-neutral-900);">&#8377;<fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/></strong>
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
                                    <td style="color: var(--color-neutral-600); font-size: 0.875rem;">
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy, hh:mm a"/>
                                    </td>
                                    <td style="color: var(--color-neutral-600); font-size: 0.875rem;">
                                        <fmt:formatDate value="${o.expectedDeliveryDate}" pattern="dd MMM yyyy"/>
                                    </td>
                                    <td style="text-align: right;">
                                        <div style="display: inline-flex; gap: 0.35rem; align-items: center; justify-content: flex-end; flex-wrap: wrap;">
                                            <a href="${pageContext.request.contextPath}/farmer/order?id=${o.orderId}" class="fc-btn fc-btn-sm fc-btn-outline">
                                                View
                                            </a>

                                            <!-- Order lifecycle state transitions -->
                                            <c:choose>
                                                <c:when test="${o.status eq 'PLACED'}">
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/advance" method="post" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                            Confirm
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/reject" method="post" onsubmit="return confirm('Reject order #${o.orderId}? Reserved stock will be restored.');" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                            Reject
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.status eq 'CONFIRMED'}">
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/advance" method="post" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                            Mark Packed
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/reject" method="post" onsubmit="return confirm('Reject order #${o.orderId}? Reserved stock will be restored.');" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                            Reject
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.status eq 'PACKED'}">
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/advance" method="post" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary" style="background: var(--color-earth-700);">
                                                            Dispatch
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.status eq 'OUT_FOR_DELIVERY'}">
                                                    <form action="${pageContext.request.contextPath}/farmer/orders/advance" method="post" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                            Mark Delivered ✓
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size: 0.8125rem; color: var(--color-neutral-500); padding: 0.25rem 0.5rem;">Completed</span>
                                                </c:otherwise>
                                            </c:choose>
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
