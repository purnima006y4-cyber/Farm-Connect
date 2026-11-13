<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="${farmerProfile.farmName} - Verified Grower Profile" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Breadcrumb -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li>Growers</li>
            <li aria-current="page"><c:out value="${farmerProfile.farmName}"/></li>
        </ol>
    </nav>

    <!-- Grower Profile Showcase Header Card -->
    <div class="fc-card" style="padding: var(--space-8); margin-bottom: var(--space-8); background: linear-gradient(135deg, #F4F8F5 0%, #FFFFFF 100%); border: 1px solid var(--color-border); border-radius: var(--radius-xl);">
        <div style="display: flex; gap: var(--space-6); align-items: flex-start; flex-wrap: wrap;">
            <!-- Farm Avatar / Emblem -->
            <div style="width: 80px; height: 80px; border-radius: var(--radius-lg); background: var(--color-primary); color: #FFFFFF; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: 700; flex-shrink: 0; box-shadow: var(--shadow-sm);">
                <c:out value="${fn:substring(farmerProfile.farmName, 0, 1)}"/>
            </div>

            <!-- Details -->
            <div style="flex: 1; min-width: 260px;">
                <div style="display: flex; align-items: center; gap: var(--space-3); flex-wrap: wrap; margin-bottom: var(--space-2);">
                    <h1 style="font-size: 2rem; font-weight: 700; color: var(--color-primary); margin: 0; line-height: 1.2;">
                        <c:out value="${farmerProfile.farmName}"/>
                    </h1>
                    <c:if test="${farmerProfile.verified eq 'Y'}">
                        <span class="product-verified-badge" style="font-size: 0.85rem; padding: 4px 10px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                            Verified Grower
                        </span>
                    </c:if>
                </div>

                <div style="display: flex; align-items: center; gap: var(--space-4); color: var(--color-text-muted); font-size: 0.95rem; flex-wrap: wrap; margin-bottom: var(--space-4);">
                    <span style="display: inline-flex; align-items: center; gap: 4px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                        Farmer: <strong><c:out value="${farmerProfile.farmerName}"/></strong>
                    </span>
                    <span style="display: inline-flex; align-items: center; gap: 4px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        <c:out value="${farmerProfile.location}"/> (PIN: <c:out value="${farmerProfile.pincode}"/>)
                    </span>
                    <c:if test="${avgRating > 0}">
                        <span style="display: inline-flex; align-items: center; gap: 4px; color: #B45309; font-weight: 700;">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="#E8A33D" stroke="#E8A33D"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <fmt:formatNumber value="${avgRating}" pattern="0.0"/> Rating
                        </span>
                    </c:if>
                </div>

                <p style="color: var(--color-text-muted); font-size: 0.95rem; line-height: 1.6; margin: 0; max-width: 720px;">
                    This farm works directly with FarmConnect to supply freshly picked crops directly to families without cold-storage delays or commission agent deductions.
                </p>
            </div>

            <div style="background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-lg); padding: var(--space-4) var(--space-6); text-align: center;">
                <span class="fc-caption" style="display: block; font-weight: 600; text-transform: uppercase;">Available Crops</span>
                <strong style="font-size: 2rem; color: var(--color-primary); font-family: var(--font-display);"><c:out value="${totalProducts}"/></strong>
            </div>
        </div>
    </div>

    <!-- Active Crops from this Farm -->
    <div class="fc-page-header" style="margin-bottom: var(--space-6);">
        <div>
            <h2 style="font-size: 1.5rem; margin: 0;">Fresh Produce from <c:out value="${farmerProfile.farmName}"/></h2>
            <p class="fc-caption" style="margin: 2px 0 0 0;">Picked and ready for direct farm-gate delivery.</p>
        </div>
    </div>

    <div class="fc-product-grid">
        <c:choose>
            <c:when test="${empty products}">
                <div class="fc-empty-state" style="grid-column: 1 / -1; padding: var(--space-12);">
                    <div class="fc-empty-icon">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    </div>
                    <h3 class="fc-empty-title">No Active Produce Listed</h3>
                    <p class="fc-empty-desc">This farm currently has no items in stock for the current harvest cycle. Check back soon for the next harvest batch.</p>
                    <a href="${pageContext.request.contextPath}/products" class="fc-btn fc-btn-primary">
                        Browse All Marketplace Produce
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <c:forEach var="p" items="${products}">
                    <%-- Fallback image selector --%>
                    <c:choose>
                        <c:when test="${not empty p.imagePath}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/images/${p.imagePath}"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'tomato')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/tomatoes.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'spinach') or fn:containsIgnoreCase(p.name, 'palak')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/spinach.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'mango')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/mangoes.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'wheat')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/wheat.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'onion')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/onions.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'potato')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/potatoes.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'pomegranate')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/pomegranate.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'coriander') or fn:containsIgnoreCase(p.name, 'mint')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/herbs.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'rice')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/rice.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.name, 'strawberr')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/strawberries.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.categoryName, 'veg')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/category-vegetables.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.categoryName, 'fruit')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/category-fruits.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.categoryName, 'grain')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/category-grains.jpg"/>
                        </c:when>
                        <c:otherwise>
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/placeholder-product.jpg"/>
                        </c:otherwise>
                    </c:choose>

                    <article class="fc-product-card">
                        <div class="product-media">
                            <img src="${prodImg}" alt="<c:out value='${p.name}'/>" loading="lazy" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/placeholder-product.jpg';">
                            <span class="product-season-badge">
                                <c:out value="${p.season}"/>
                            </span>
                            <c:if test="${p.quantity > 0 and p.quantity lt 10}">
                                <span class="product-badge-lowstock">Low Stock</span>
                            </c:if>
                        </div>

                        <div class="product-body">
                            <div class="product-category-meta">
                                <c:out value="${p.categoryName}"/>
                            </div>
                            <h2 class="product-title">
                                <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
                                    <c:out value="${p.name}"/>
                                </a>
                            </h2>

                            <div class="product-info-tags">
                                <span class="product-tag">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    Harvested <c:out value="${p.daysSinceHarvest}"/>d ago
                                </span>
                                <c:if test="${p.avgRating > 0}">
                                    <span class="product-tag" style="color: #B45309; font-weight: 700;">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#E8A33D" stroke="#E8A33D" stroke-width="1"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                        <fmt:formatNumber value="${p.avgRating}" pattern="0.0"/>
                                    </span>
                                </c:if>
                            </div>

                            <div class="product-price-row">
                                <div class="product-price">
                                    &#8377;<fmt:formatNumber value="${p.price}" pattern="#,##0.00"/>
                                    <span class="product-price-unit">/ unit</span>
                                </div>
                                <div class="product-stock">
                                    <c:choose>
                                        <c:when test="${p.quantity > 0}">
                                            In Stock: <strong><c:out value="${p.quantity}"/></strong>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--color-terracotta); font-weight: 700;">Sold Out</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="product-actions">
                                <a href="${pageContext.request.contextPath}/product?id=${p.productId}" class="btn btn-secondary btn-sm btn-view">
                                    Details
                                </a>
                                <c:choose>
                                    <c:when test="${p.quantity > 0 and p.status ne 'OUT_OF_STOCK'}">
                                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="fc-add-cart-form" data-product-name="<c:out value='${p.name}'/>" style="display: flex; gap: 4px; margin: 0;">
                                            <input type="hidden" name="productId" value="${p.productId}">
                                            <input type="number" name="quantity" value="1" min="1" max="${p.quantity}" aria-label="Quantity" style="width: 52px; padding: 4px 6px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.875rem; text-align: center;">
                                            <button type="submit" class="btn btn-primary btn-sm" title="Add to Cart">
                                                + Add
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-secondary btn-sm" disabled style="opacity: 0.6; cursor: not-allowed;">
                                            Out of Stock
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
