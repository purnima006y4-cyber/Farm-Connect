<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Order Checkout - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
            <li aria-current="page">Checkout</li>
        </ol>
    </nav>

    <!-- Multi-Step Checkout Progress -->
    <div class="fc-checkout-stepper" aria-label="Checkout Progress">
        <div class="fc-step-item completed">
            <span class="fc-step-badge">✓</span>
            <span class="fc-step-label">1. Basket Review</span>
        </div>
        <div class="fc-step-divider active"></div>
        <div class="fc-step-item active">
            <span class="fc-step-badge">2</span>
            <span class="fc-step-label">2. Delivery Address</span>
        </div>
        <div class="fc-step-divider"></div>
        <div class="fc-step-item upcoming">
            <span class="fc-step-badge">3</span>
            <span class="fc-step-label">3. Confirmation</span>
        </div>
    </div>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Finalize Your Harvest Order</h1>
            <p class="fc-page-subtitle">Review items to be harvested and enter your direct delivery location.</p>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1.4fr 1fr; gap: var(--space-8); align-items: start;">
        <!-- Items Breakdown Card -->
        <div class="fc-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-border); background: var(--color-surface-hover); display: flex; justify-content: space-between; align-items: center;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--color-primary);"><path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12c0-2.5 1-4.5 2-6"/><path d="M12 2c0 4 2 8 8 10"/><path d="M7 17l5-5"/></svg>
                    <h3 style="font-size: 1.1rem; font-weight: 700; margin: 0; color: var(--color-text);">Harvest Items in Your Shipment</h3>
                </div>
                <span class="fc-badge fc-badge-info"><c:out value="${fn:length(cartItems)}"/> items</span>
            </div>

            <div style="padding: 1rem 1.5rem 0.5rem 1.5rem; background: var(--color-primary-tint); border-bottom: 1px solid var(--color-border); font-size: 0.8125rem; color: var(--color-text-muted); line-height: 1.5;">
                ℹ️ <strong>Farm-Direct Fulfillment Notice:</strong> If your basket includes produce from multiple independent growers, separate sub-orders are generated per farm so each grower packs fresh from their field.
            </div>

            <div class="fc-table-responsive">
                <table class="fc-table">
                    <thead>
                        <tr>
                            <th>Produce Item</th>
                            <th>Fulfilling Grower</th>
                            <th>Quantity</th>
                            <th>Unit Price</th>
                            <th style="text-align: right;">Line Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${cartItems}">
                            <tr>
                                <td>
                                    <strong style="color: var(--color-text);"><c:out value="${item.productName}"/></strong>
                                </td>
                                <td>
                                    <span class="product-tag">
                                        <c:out value="${item.farmerName}"/>
                                    </span>
                                </td>
                                <td>
                                    <span style="font-weight: 600;"><c:out value="${item.quantity}"/> units</span>
                                </td>
                                <td>
                                    &#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>
                                </td>
                                <td style="text-align: right;">
                                    <strong style="color: var(--color-primary); font-size: 1.05rem;" class="num-tabular">
                                        &#8377;<fmt:formatNumber value="${item.lineTotal}" pattern="#,##0.00"/>
                                    </strong>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <div style="padding: 1.25rem 1.5rem; background: var(--color-surface-hover); border-top: 1px solid var(--color-border); display: flex; justify-content: space-between; align-items: center;">
                <span style="font-size: 1.05rem; font-weight: 600; color: var(--color-text-muted);">Total Order Amount:</span>
                <span style="font-size: 1.75rem; font-weight: 800; color: var(--color-primary);" class="num-tabular">
                    &#8377;<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>
                </span>
            </div>
        </div>

        <!-- Shipping Address & Confirmation Form Card -->
        <div class="fc-card" style="padding: var(--space-6);">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: var(--space-4); border-bottom: 1px solid var(--color-border); padding-bottom: var(--space-3);">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--color-primary);"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <h3 style="font-size: 1.15rem; font-weight: 700; margin: 0; color: var(--color-text);">Delivery Destination</h3>
            </div>

            <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">
                <div class="fc-form-group">
                    <label for="address" class="fc-label">Full Delivery Address <span style="color: var(--color-terracotta);">*</span></label>
                    <textarea id="address" name="address" rows="4" required minlength="10" class="fc-textarea" placeholder="Flat / House number, Apartment or Building, Street / Landmark, City, State, Pincode..."></textarea>
                    <span class="fc-hint">Minimum 10 characters required for accurate rural-to-urban route dispatch.</span>
                </div>

                <!-- Fulfillment Guarantee Banner -->
                <div style="background: var(--color-primary-light); border: 1px solid var(--color-primary-tint); padding: 1.25rem; border-radius: var(--radius-md); font-size: 0.84375rem; color: var(--color-primary-dark); margin-bottom: var(--space-6); line-height: 1.6;">
                    <div style="font-weight: 700; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 6px;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        FarmConnect Direct Guarantee
                    </div>
                    &bull; Inspected &amp; packaged at the farm within 24 hours of harvest<br>
                    &bull; Atomic inventory locking prevents out-of-stock cancellations<br>
                    &bull; Transparent direct payout to the fulfilling grower
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg" style="padding: 1rem; font-weight: 700; margin-bottom: var(--space-3);">
                    Confirm &amp; Place Order 🛍️
                </button>
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-secondary btn-block" style="text-align: center;">
                    &larr; Return to Cart
                </a>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
