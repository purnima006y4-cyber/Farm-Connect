<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Farmer Dashboard - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li aria-current="page">Grower Console</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Farmer Dashboard</h1>
            <p class="fc-page-subtitle">Welcome back! Monitor harvests, live customer demand, and fulfillment status.</p>
        </div>
        <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/farmer/products/add" class="fc-btn fc-btn-primary">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="margin-right: 0.35rem;"><path d="M12 5v14M5 12h14"/></svg>
                Add New Harvest
            </a>
            <a href="${pageContext.request.contextPath}/farmer/sales" class="fc-btn fc-btn-outline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 0.35rem;"><path d="M18 20V10M12 20V4M6 20v-6"/></svg>
                Sales Trends
            </a>
        </div>
    </div>

    <!-- Stat KPIs -->
    <div class="fc-stat-grid">
        <div class="fc-stat-card">
            <span class="fc-stat-label">Total Revenue Earned</span>
            <div class="fc-stat-value" style="color: var(--color-primary-700);">
                &#8377;<fmt:formatNumber value="${totalSales}" pattern="#,##0.00"/>
            </div>
            <span class="fc-stat-subtext">Delivered &amp; completed orders</span>
        </div>

        <div class="fc-stat-card">
            <span class="fc-stat-label">Total Orders Handled</span>
            <div class="fc-stat-value"><c:out value="${totalOrders}"/></div>
            <span class="fc-stat-subtext">Across all fulfillment stages</span>
        </div>

        <div class="fc-stat-card">
            <span class="fc-stat-label">Active Listings</span>
            <div class="fc-stat-value" style="font-size: 1.5rem; padding-top: 0.25rem;">
                <a href="${pageContext.request.contextPath}/farmer/products" style="color: var(--color-primary-600); text-decoration: underline; font-weight: 700;">
                    Manage Inventory &rarr;
                </a>
            </div>
            <span class="fc-stat-subtext">View and update produce catalogue</span>
        </div>
    </div>

    <!-- Low Stock Alerts -->
    <c:if test="${not empty lowStock}">
        <div class="fc-alert fc-alert-warning" style="margin-top: 1.75rem; border-left: 5px solid #d97706; padding: 1.25rem 1.5rem;">
            <div style="display: flex; gap: 0.75rem; align-items: flex-start;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2" style="flex-shrink: 0; margin-top: 2px;">
                    <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                <div style="flex: 1;">
                    <div style="font-weight: 700; color: #92400e; font-size: 1rem; margin-bottom: 0.35rem;">
                        Low Inventory Alerts (Quantity under 10 units)
                    </div>
                    <p style="color: #b45309; font-size: 0.875rem; margin-bottom: 0.75rem;">
                        The following harvest batches are running low. Restock now to avoid missed customer sales:
                    </p>
                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                        <c:forEach var="item" items="${lowStock}">
                            <div style="display: flex; justify-content: space-between; align-items: center; background: rgba(255,255,255,0.7); padding: 0.5rem 0.85rem; border-radius: var(--radius-sm); border: 1px solid rgba(217,119,6,0.2);">
                                <div>
                                    <strong style="color: var(--color-neutral-900);"><c:out value="${item.name}"/></strong>
                                    <span style="margin-left: 0.5rem; color: var(--color-danger-600); font-weight: 700; font-size: 0.875rem;">
                                        Only <c:out value="${item.quantity}"/> remaining
                                    </span>
                                </div>
                                <a href="${pageContext.request.contextPath}/farmer/products/edit?id=${item.productId}" class="fc-btn fc-btn-sm fc-btn-primary" style="padding: 0.25rem 0.65rem;">
                                    Restock Produce
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Recent Orders Section -->
    <div class="fc-card" style="margin-top: 2rem; padding: 0; overflow: hidden;">
        <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-neutral-200); display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h3 style="font-size: 1.125rem; font-weight: 700; margin-bottom: 0.15rem; color: var(--color-neutral-900);">Recent Customer Orders</h3>
                <p style="font-size: 0.875rem; color: var(--color-neutral-500); margin: 0;">Incoming orders for your produce requiring fulfillment.</p>
            </div>
            <a href="${pageContext.request.contextPath}/farmer/orders" class="fc-btn fc-btn-sm fc-btn-outline">
                All Orders &rarr;
            </a>
        </div>

        <c:choose>
            <c:when test="${empty recentOrders}">
                <div style="padding: 3rem 1.5rem; text-align: center; color: var(--color-neutral-500);">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 0.75rem; opacity: 0.6;"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/></svg>
                    <p style="margin: 0; font-size: 0.9375rem;">No customer orders received yet.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Order Ref</th>
                                <th>Customer</th>
                                <th>Date Placed</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${recentOrders}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/farmer/order?id=${o.orderId}" style="font-family: monospace; font-weight: 700; color: var(--color-primary-700);">
                                            #<c:out value="${o.orderId}"/>
                                        </a>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600; color: var(--color-neutral-800);"><c:out value="${o.customerName}"/></span>
                                    </td>
                                    <td style="color: var(--color-neutral-600); font-size: 0.875rem;">
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy, hh:mm a"/>
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
                                    <td style="text-align: right;">
                                        <a href="${pageContext.request.contextPath}/farmer/order?id=${o.orderId}" class="fc-btn fc-btn-sm fc-btn-outline">
                                            Manage
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
