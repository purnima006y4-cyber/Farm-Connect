<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Order Fulfillment #${order.orderId} - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/orders">Incoming Orders</a></li>
            <li aria-current="page">Fulfillment #<c:out value="${order.orderId}"/></li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Order Packaging &amp; Fulfillment #<c:out value="${order.orderId}"/></h1>
            <p class="fc-page-subtitle">Review items to pack, customer destination address, and delivery timelines.</p>
        </div>
        <div style="display: flex; gap: var(--space-3);">
            <button type="button" class="fc-btn fc-btn-secondary" onclick="window.print();">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align: -2px; margin-right: 4px;"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                Print Packing Slip
            </button>
            <a href="${pageContext.request.contextPath}/farmer/orders" class="fc-btn fc-btn-outline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 0.35rem;"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Back to Orders
            </a>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; align-items: start;">
        <!-- Items to Pack Checklist -->
        <div class="fc-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-neutral-200); background: var(--color-neutral-50);">
                <h3 style="font-size: 1.125rem; font-weight: 700; color: var(--color-neutral-900); margin: 0;">Items to Pack &amp; Dispatch</h3>
            </div>

            <div class="fc-table-responsive">
                <table class="fc-table">
                    <thead>
                        <tr>
                            <th>Produce Item</th>
                            <th>Units Ordered</th>
                            <th>Unit Price</th>
                            <th style="text-align: right;">Line Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${items}">
                            <tr>
                                <td>
                                    <div style="font-weight: 600; color: var(--color-neutral-900);">
                                        <c:out value="${item.productName}"/>
                                    </div>
                                </td>
                                <td>
                                    <span style="font-weight: 700; color: var(--color-primary-700); font-size: 1rem;">
                                        <c:out value="${item.quantity}"/> units
                                    </span>
                                </td>
                                <td style="color: var(--color-neutral-700);">
                                    &#8377;<fmt:formatNumber value="${item.unitPrice}" pattern="#,##0.00"/>
                                </td>
                                <td style="text-align: right; font-weight: 700; color: var(--color-neutral-900);">
                                    &#8377;<fmt:formatNumber value="${item.lineTotal}" pattern="#,##0.00"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <div style="padding: 1.25rem 1.5rem; background: var(--color-neutral-50); border-top: 1px solid var(--color-neutral-200); display: flex; justify-content: space-between; align-items: center;">
                <span style="font-weight: 600; color: var(--color-neutral-700);">Total Order Value:</span>
                <span style="font-size: 1.375rem; font-weight: 800; color: var(--color-primary-700);">
                    &#8377;<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                </span>
            </div>
        </div>

        <!-- Customer & Delivery Logistics -->
        <div style="display: flex; flex-direction: column; gap: 1.5rem;">
            <div class="fc-card" style="padding: 1.5rem;">
                <h3 style="font-size: 1.125rem; font-weight: 700; margin-bottom: 1.25rem; color: var(--color-neutral-900); border-bottom: 1px solid var(--color-neutral-200); padding-bottom: 0.75rem;">
                    Delivery Information
                </h3>

                <div style="margin-bottom: 1rem;">
                    <span class="fc-stat-label">Recipient Customer</span>
                    <div style="font-weight: 700; color: var(--color-neutral-900); font-size: 1.05rem;">
                        <c:out value="${order.customerName}"/>
                    </div>
                </div>

                <div style="margin-bottom: 1rem;">
                    <span class="fc-stat-label">Current Fulfillment Status</span>
                    <div style="margin-top: 0.25rem;">
                        <c:choose>
                            <c:when test="${order.status eq 'PLACED'}"><span class="fc-badge fc-badge-warning">Placed</span></c:when>
                            <c:when test="${order.status eq 'CONFIRMED'}"><span class="fc-badge fc-badge-info">Confirmed</span></c:when>
                            <c:when test="${order.status eq 'PACKED'}"><span class="fc-badge fc-badge-info">Packed</span></c:when>
                            <c:when test="${order.status eq 'OUT_FOR_DELIVERY'}"><span class="fc-badge fc-badge-primary">In Transit</span></c:when>
                            <c:when test="${order.status eq 'DELIVERED'}"><span class="fc-badge fc-badge-success">Delivered</span></c:when>
                            <c:when test="${order.status eq 'CANCELLED'}"><span class="fc-badge fc-badge-danger">Cancelled</span></c:when>
                            <c:otherwise><span class="fc-badge fc-badge-neutral"><c:out value="${order.status}"/></span></c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div style="margin-bottom: 1rem;">
                    <span class="fc-stat-label">Order Placed On</span>
                    <div style="color: var(--color-neutral-800); font-size: 0.9375rem;">
                        <fmt:formatDate value="${order.orderDate}" pattern="dd MMM yyyy, hh:mm a"/>
                    </div>
                </div>

                <div style="margin-bottom: 1.25rem;">
                    <span class="fc-stat-label">Target Delivery Date</span>
                    <div style="color: var(--color-primary-700); font-weight: 700; font-size: 0.9375rem;">
                        <fmt:formatDate value="${order.expectedDeliveryDate}" pattern="dd MMM yyyy"/>
                    </div>
                </div>

                <div style="border-top: 1px solid var(--color-neutral-200); padding-top: 1rem;">
                    <span class="fc-stat-label">Shipping Destination</span>
                    <div style="color: var(--color-neutral-800); font-size: 0.9375rem; line-height: 1.5; margin-top: 0.25rem;">
                        <c:out value="${order.address}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
