<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Shopping Cart - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li aria-current="page">Shopping Cart</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Your Fresh Harvest Cart</h1>
            <p class="fc-page-subtitle">Review fresh items selected directly from local farms.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-outline btn-sm">
                &larr; Continue Shopping
            </a>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty cartItems}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">Your Cart is Currently Empty</h3>
                <p class="fc-empty-desc">You haven't added any fresh farm produce to your cart yet. Discover seasonal crops grown directly by verified local farmers!</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">
                    Explore Fresh Produce
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: var(--space-8); align-items: start;">
                <!-- Cart Items Table Card -->
                <div class="fc-card" style="padding: 0; overflow: hidden;">
                    <div class="fc-table-responsive">
                        <table class="fc-table">
                            <thead>
                                <tr>
                                    <th>Produce Item</th>
                                    <th>Farm Origin</th>
                                    <th>Price</th>
                                    <th>Quantity</th>
                                    <th>Total</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${cartItems}">
                                    <%-- Fallback image for cart item --%>
                                    <c:choose>
                                        <c:when test="${not empty item.imagePath}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/images/${item.imagePath}"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'tomato')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/tomatoes.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'spinach') or fn:containsIgnoreCase(item.productName, 'palak')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/spinach.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'mango')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/mangoes.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'wheat')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/wheat.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'onion')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/onions.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'potato')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/potatoes.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'pomegranate')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/pomegranate.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'coriander') or fn:containsIgnoreCase(item.productName, 'mint')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/herbs.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'rice')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/rice.jpg"/>
                                        </c:when>
                                        <c:when test="${fn:containsIgnoreCase(item.productName, 'strawberr')}">
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/strawberries.jpg"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="itemImg" value="${pageContext.request.contextPath}/assets/img/placeholder-product.jpg"/>
                                        </c:otherwise>
                                    </c:choose>

                                    <tr>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: var(--space-3);">
                                                <div style="width: 54px; height: 54px; border-radius: var(--radius-sm); overflow: hidden; background: var(--color-surface-muted); flex-shrink: 0; border: 1px solid var(--color-border);">
                                                    <img src="${itemImg}" alt="" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/placeholder-product.jpg';">
                                                </div>
                                                <div>
                                                    <a href="${pageContext.request.contextPath}/product?id=${item.productId}" style="font-weight: 700; color: var(--color-text);">
                                                        <c:out value="${item.productName}"/>
                                                    </a>
                                                    <c:if test="${item.availableQuantity lt 10}">
                                                        <span style="display: block; font-size: 0.75rem; color: var(--color-terracotta); font-weight: 600;">
                                                            Only <c:out value="${item.availableQuantity}"/> left in harvest!
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="product-tag">
                                                <c:out value="${item.farmerName}"/>
                                            </span>
                                        </td>
                                        <td>
                                            &#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/cart/update" method="post" style="display: flex; align-items: center; gap: 4px; margin: 0;">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <input type="number" name="quantity" value="${item.quantity}" min="1" max="${item.availableQuantity}" class="fc-input" style="width: 60px; padding: 4px 6px; text-align: center; font-weight: 700;" aria-label="Quantity">
                                                <button type="submit" class="btn btn-secondary btn-sm" title="Save quantity">
                                                    Update
                                                </button>
                                            </form>
                                        </td>
                                        <td>
                                            <strong style="color: var(--color-primary); font-size: 1rem;">
                                                &#8377;<fmt:formatNumber value="${item.lineTotal}" pattern="#,##0.00"/>
                                            </strong>
                                        </td>
                                        <td style="text-align: right;">
                                            <form action="${pageContext.request.contextPath}/cart/remove" method="post" onsubmit="return confirm('Remove this item from your cart?');" style="display: inline; margin: 0;">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--color-terracotta);" title="Remove item">
                                                    Remove
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Sticky Order Summary Card -->
                <div class="fc-card" style="padding: var(--space-6); position: sticky; top: calc(var(--navbar-height) + var(--space-4));">
                    <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: var(--space-4); border-bottom: 1px solid var(--color-border); padding-bottom: var(--space-3);">
                        Order Summary
                    </h3>

                    <div style="display: flex; justify-content: space-between; font-size: 0.9rem; color: var(--color-text-muted); margin-bottom: var(--space-2);">
                        <span>Items (<c:out value="${fn:length(cartItems)}"/>):</span>
                        <span>&#8377;<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></span>
                    </div>

                    <div style="display: flex; justify-content: space-between; font-size: 0.9rem; color: var(--color-text-muted); margin-bottom: var(--space-4);">
                        <span>Direct Farm Delivery:</span>
                        <span style="color: var(--status-success-text); font-weight: 600;">FREE (Promo)</span>
                    </div>

                    <div style="border-top: 1px solid var(--color-border); padding-top: var(--space-4); margin-bottom: var(--space-6); display: flex; justify-content: space-between; align-items: baseline;">
                        <span style="font-weight: 700; color: var(--color-text); font-size: 1.05rem;">Estimated Total:</span>
                        <span style="font-size: 1.75rem; font-weight: 700; color: var(--color-primary);" class="num-tabular">
                            &#8377;<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>
                        </span>
                    </div>

                    <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary btn-block btn-lg" style="margin-bottom: var(--space-4);">
                        Proceed to Checkout &rarr;
                    </a>

                    <div style="font-size: 0.78125rem; color: var(--color-text-subtle); line-height: 1.4; text-align: center;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline; vertical-align: -2px; margin-right: 4px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        Safe farm-to-table direct packaging &bull; Cash on Delivery
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
