<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="FarmConnect - Direct Farmer-to-Customer Marketplace" />
</jsp:include>

<c:set var="hasActiveFilters" value="${not empty nameQuery or not empty param.name or not empty param.category or not empty param.season or not empty param.location or not empty param.pincode or param.verifiedOnly eq 'true' or not empty minPrice or not empty maxPrice or not empty param.minPrice or not empty param.maxPrice or not empty selectedSort or not empty param.sort}" />
<c:set var="isResultsMode" value="${hasActiveFilters or (not empty page and page > 1)}" />

<!-- Category lookup for active category chip/title -->
<c:if test="${not empty param.category}">
    <c:forEach var="cItem" items="${categories}">
        <c:if test="${param.category eq cItem.categoryId}">
            <c:set var="activeCatName" value="${cItem.name}"/>
        </c:if>
    </c:forEach>
</c:if>

<c:if test="${not isResultsMode}">
<!-- Hero Section with Lush Farm Photography (Browse Mode Only) -->
<section class="fc-hero">
    <div class="fc-hero-inner">
        <div class="fc-hero-pill">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12c0-2.5 1-4.5 2-6"/><path d="M12 2c0 4 2 8 8 10"/><path d="M7 17l5-5"/></svg>
            <span>100% Direct From Local Growers</span>
        </div>
        <h1 class="fc-hero-title">Fresh Harvest, Directly From Field to Family</h1>
        <p class="fc-hero-subtitle">
            Skip middlemen and supermarket storage. Support local farming families while enjoying peak freshness, fair prices, and certified natural produce delivered straight to your door.
        </p>
        <div class="fc-hero-actions">
            <a href="#marketplaceGrid" class="btn btn-primary btn-lg" style="background-color: #FFFFFF !important; color: #1F4D3A !important;">
                Browse In-Season Harvest &darr;
            </a>
            <c:choose>
                <c:when test="${empty role}">
                    <a href="${pageContext.request.contextPath}/register?role=FARMER" class="btn btn-secondary btn-lg" style="background: rgba(255,255,255,0.18) !important; color: #FFFFFF !important; border-color: rgba(255,255,255,0.4) !important;">
                        Register as Grower
                    </a>
                </c:when>
                <c:when test="${role eq 'FARMER'}">
                    <a href="${pageContext.request.contextPath}/farmer/dashboard" class="btn btn-secondary btn-lg" style="background: rgba(255,255,255,0.18) !important; color: #FFFFFF !important; border-color: rgba(255,255,255,0.4) !important;">
                        Go to Grower Console &rarr;
                    </a>
                </c:when>
                <c:when test="${role eq 'ADMIN'}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary btn-lg" style="background: rgba(255,255,255,0.18) !important; color: #FFFFFF !important; border-color: rgba(255,255,255,0.4) !important;">
                        Governance Console &rarr;
                    </a>
                </c:when>
            </c:choose>
        </div>
    </div>
</section>

<!-- Trust Value Strip (Browse Mode Only) -->
<div class="fc-trust-strip">
    <div class="fc-trust-grid">
        <div class="fc-trust-item">
            <div class="fc-trust-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
            </div>
            <div>
                <div class="fc-trust-label">Direct From Farmers</div>
                <div class="fc-trust-desc">Zero middlemen or wholesaler markups</div>
            </div>
        </div>

        <div class="fc-trust-item">
            <div class="fc-trust-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div>
                <div class="fc-trust-label">Peak Harvest Freshness</div>
                <div class="fc-trust-desc">Picked within days, never cold-stored</div>
            </div>
        </div>

        <div class="fc-trust-item">
            <div class="fc-trust-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"/><path d="M12 18V6"/></svg>
            </div>
            <div>
                <div class="fc-trust-label">Fair Farm-Gate Prices</div>
                <div class="fc-trust-desc">100% earnings go to rural growers</div>
            </div>
        </div>

        <div class="fc-trust-item">
            <div class="fc-trust-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <div>
                <div class="fc-trust-label">Verified Farms</div>
                <div class="fc-trust-desc">Admin inspected &amp; quality guaranteed</div>
            </div>
        </div>
    </div>
</div>

<!-- How It Works: 3 Simple Steps (Browse Mode Only) -->
<section class="fc-how-it-works">
    <div class="fc-container">
        <div class="fc-section-intro">
            <span class="fc-section-tag">Farm-to-Door Process</span>
            <h2 class="fc-section-title">How FarmConnect Works</h2>
            <p class="fc-section-desc">Experience the freshest produce possible while putting fair value directly into farmers' hands.</p>
        </div>

        <div class="fc-steps-grid">
            <div class="fc-step-card">
                <div class="fc-step-num">1</div>
                <div class="fc-step-icon">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12c0-2.5 1-4.5 2-6"/><path d="M12 2c0 4 2 8 8 10"/><path d="M7 17l5-5"/></svg>
                </div>
                <h3 class="fc-step-title">Local Harvest Listed</h3>
                <p class="fc-step-desc">Farmers list crops picked at peak ripeness. You browse transparent prices with origin details and harvest dates.</p>
            </div>

            <div class="fc-step-card">
                <div class="fc-step-num">2</div>
                <div class="fc-step-icon">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                </div>
                <h3 class="fc-step-title">Direct Farm Packing</h3>
                <p class="fc-step-desc">Once ordered, the grower prepares and packs your items at the farm without intermediate warehousing or cold decay.</p>
            </div>

            <div class="fc-step-card">
                <div class="fc-step-num">3</div>
                <div class="fc-step-icon">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
                <h3 class="fc-step-title">Delivered Fresh to You</h3>
                <p class="fc-step-desc">Shipped straight to your doorstep with guaranteed direct delivery and flexible Cash on Delivery options.</p>
            </div>
        </div>
    </div>
</section>
</c:if>

<div class="fc-container" id="marketplaceGrid" style="padding-bottom: var(--space-12);">

    <!-- Results Mode Header & Active Filter Chips -->
    <c:if test="${isResultsMode}">
        <div id="results" class="fc-results-header-box" style="margin-top: var(--space-6); margin-bottom: var(--space-6); padding: var(--space-6); background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-lg); box-shadow: var(--shadow-sm);">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: var(--space-3); margin-bottom: var(--space-4);">
                <div>
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                        <span class="fc-badge fc-badge-info" style="font-weight: 700;">Marketplace Search</span>
                        <a href="${pageContext.request.contextPath}/products" class="fc-btn fc-btn-ghost fc-btn-sm" style="font-size: 0.8125rem; color: var(--color-primary); padding: 2px 8px;">
                            &larr; Back to Browse All
                        </a>
                    </div>
                    <h1 style="font-family: var(--font-display); font-size: 1.75rem; color: var(--color-text); margin: 0;">
                        <c:choose>
                            <c:when test="${not empty nameQuery}">
                                Results for &ldquo;<c:out value="${nameQuery}"/>&rdquo;
                            </c:when>
                            <c:when test="${not empty activeCatName}">
                                Produce Category: <c:out value="${activeCatName}"/>
                            </c:when>
                            <c:when test="${not empty param.season}">
                                <c:out value="${param.season}"/> Season Harvest
                            </c:when>
                            <c:when test="${not empty param.location}">
                                Produce near <c:out value="${param.location}"/>
                            </c:when>
                            <c:otherwise>
                                Filtered Marketplace Produce
                            </c:otherwise>
                        </c:choose>
                    </h1>
                    <p style="color: var(--color-text-muted); font-size: 0.9rem; margin-top: 4px; margin-bottom: 0;">
                        Showing <strong><c:out value="${empty products ? 0 : fn:length(products)}"/></strong> available farm-fresh item<c:if test="${fn:length(products) ne 1}">s</c:if>
                        <c:if test="${page > 1}">&bull; Page <c:out value="${page}"/></c:if>
                    </p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary btn-sm" style="font-weight: 600;">
                        Clear All Filters
                    </a>
                </div>
            </div>

            <!-- Active Filter Chips -->
            <div class="fc-active-chips-row" style="display: flex; flex-wrap: wrap; gap: 8px; align-items: center;">
                <span style="font-size: 0.78125rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-subtle);">Active Filters:</span>
                
                <c:if test="${not empty nameQuery}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="name" title="Remove keyword filter">
                        <span>Keyword: "<strong><c:out value="${nameQuery}"/></strong>"</span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty activeCatName}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="category" title="Remove category filter">
                        <span>Category: <strong><c:out value="${activeCatName}"/></strong></span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty param.season}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="season" title="Remove season filter">
                        <span>Season: <strong><c:out value="${param.season}"/></strong></span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty param.location}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="location" title="Remove location filter">
                        <span>Location: <strong><c:out value="${param.location}"/></strong></span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty param.pincode}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="pincode" title="Remove pincode filter">
                        <span>PIN: <strong><c:out value="${param.pincode}"/></strong></span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${param.verifiedOnly eq 'true'}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="verifiedOnly" title="Remove verified only filter">
                        <span>Verified Growers Only</span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty minPrice or not empty maxPrice or not empty param.minPrice or not empty param.maxPrice}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="price" title="Remove price range filter">
                        <span>Price Range</span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <c:if test="${not empty selectedSort and selectedSort ne ''}">
                    <button type="button" class="fc-filter-chip fc-filter-chip-remove" data-remove="sort" title="Reset sort">
                        <span>Sort: <strong><c:out value="${selectedSort}"/></strong></span>
                        <span class="fc-chip-x">&times;</span>
                    </button>
                </c:if>

                <a href="${pageContext.request.contextPath}/products" style="font-size: 0.8125rem; font-weight: 600; color: var(--color-terracotta); text-decoration: underline; margin-left: 4px;">
                    Reset all
                </a>
            </div>
        </div>
    </c:if>

    <!-- Category Cards Strip (Browse Mode Only) -->
    <c:if test="${not isResultsMode and not empty categories}">
        <div class="fc-category-strip">
            <div class="fc-page-header" style="margin-bottom: var(--space-4);">
                <h3 style="font-size: 1.25rem;">Explore Produce Categories</h3>
                <span class="fc-caption">Hand-picked farm categories</span>
            </div>
            <div class="fc-category-grid">
                <c:forEach var="cat" items="${categories}">
                    <c:set var="catImg" value="${pageContext.request.contextPath}/assets/img/category-vegetables.jpg"/>
                    <c:choose>
                        <c:when test="${fn:containsIgnoreCase(cat.name, 'fruit')}">
                            <c:set var="catImg" value="${pageContext.request.contextPath}/assets/img/category-fruits.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(cat.name, 'grain')}">
                            <c:set var="catImg" value="${pageContext.request.contextPath}/assets/img/category-grains.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(cat.name, 'dairy')}">
                            <c:set var="catImg" value="${pageContext.request.contextPath}/assets/img/category-dairy.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(cat.name, 'herb') or fn:containsIgnoreCase(cat.name, 'spice')}">
                            <c:set var="catImg" value="${pageContext.request.contextPath}/assets/img/category-herbs.jpg"/>
                        </c:when>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/products?category=${cat.categoryId}" class="fc-category-card">
                        <img src="${catImg}" alt="<c:out value='${cat.name}'/>" loading="lazy">
                        <div class="fc-category-overlay">
                            <span class="fc-category-name"><c:out value="${cat.name}"/></span>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <c:if test="${not isResultsMode}">
        <div class="fc-page-header" style="margin-bottom: var(--space-4);">
            <div>
                <h2 style="font-size: 1.5rem; font-family: var(--font-display); color: var(--color-text); margin-bottom: 4px;">
                    Fresh In-Season Harvest
                </h2>
                <span class="fc-caption">Handpicked crops directly from verified regional growers</span>
            </div>
        </div>
    </c:if>

    <!-- Product Grid -->
    <div class="fc-product-grid">
        <c:choose>
            <c:when test="${empty products}">
                <div class="fc-empty-state" style="grid-column: 1 / -1;">
                    <div class="fc-empty-icon">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    </div>
                    <h3 class="fc-empty-title">No Produce Matches</h3>
                    <p class="fc-empty-desc">We couldn't find any products matching your active filters. Try adjusting your search keyword or exploring another produce category.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                        View All Products
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="p" items="${products}">
                    <%-- Fallback Image Selection Logic based on Product & Category Keywords --%>
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
                        <c:when test="${fn:containsIgnoreCase(p.categoryName, 'dairy')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/category-dairy.jpg"/>
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(p.categoryName, 'herb') or fn:containsIgnoreCase(p.categoryName, 'spice')}">
                            <c:set var="prodImg" value="${pageContext.request.contextPath}/assets/img/category-herbs.jpg"/>
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

                            <c:if test="${p.status eq 'OUT_OF_STOCK' or p.quantity <= 0}">
                                <span class="product-status-tag">Out of Stock</span>
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

                            <div class="product-farm-meta">
                                <a href="${pageContext.request.contextPath}/farmer-profile?id=${p.farmerId}" class="product-farm-link" title="View Grower Profile">
                                    <span><c:out value="${p.farmName}"/></span>
                                </a>
                                <c:if test="${p.farmerVerified eq 'Y'}">
                                    <span class="product-verified-badge" title="Verified Farm Grower">
                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                                        Verified
                                    </span>
                                </c:if>
                            </div>

                            <div class="product-info-tags">
                                <span class="product-tag">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                                    <c:out value="${p.farmerLocation}"/>
                                </span>
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

    <!-- Pagination Controls -->
    <c:if test="${page > 1 or fn:length(products) eq 12}">
        <nav class="fc-pagination" aria-label="Marketplace Pagination">
            <c:if test="${page > 1}">
                <a href="?page=${page - 1}&name=<c:out value='${param.name}'/>&category=<c:out value='${param.category}'/>&season=<c:out value='${param.season}'/>&location=<c:out value='${param.location}'/>&pincode=<c:out value='${param.pincode}'/>&verifiedOnly=<c:out value='${param.verifiedOnly}'/>&sort=<c:out value='${selectedSort}'/>&minPrice=<c:out value='${minPrice}'/>&maxPrice=<c:out value='${maxPrice}'/>" class="btn btn-secondary">
                    &laquo; Previous
                </a>
            </c:if>
            <span class="pagination-info">
                Page <c:out value="${page}"/>
            </span>
            <c:if test="${fn:length(products) eq 12}">
                <a href="?page=${page + 1}&name=<c:out value='${param.name}'/>&category=<c:out value='${param.category}'/>&season=<c:out value='${param.season}'/>&location=<c:out value='${param.location}'/>&pincode=<c:out value='${param.pincode}'/>&verifiedOnly=<c:out value='${param.verifiedOnly}'/>&sort=<c:out value='${selectedSort}'/>&minPrice=<c:out value='${minPrice}'/>&maxPrice=<c:out value='${maxPrice}'/>" class="btn btn-secondary">
                    Next &raquo;
                </a>
            </c:if>
        </nav>
    </c:if>

    <!-- Client-side Recently Viewed Produce Strip -->
    <section class="fc-recently-viewed" id="fcRecentlyViewedSection" style="display: none; margin-top: var(--space-8); border-top: 1px solid var(--color-border); padding-top: var(--space-6);">
        <div class="fc-page-header" style="margin-bottom: var(--space-4);">
            <div style="display: flex; align-items: center; justify-content: space-between;">
                <div>
                    <h3 style="font-size: 1.25rem; font-family: var(--font-display);">Recently Viewed Produce</h3>
                    <span class="fc-caption">Quickly revisit crops and harvests you looked at earlier</span>
                </div>
                <button type="button" id="fcClearRecentBtn" class="fc-btn fc-btn-ghost fc-btn-sm" style="font-size: 0.75rem;">Clear History</button>
            </div>
        </div>
        <div class="fc-recent-grid" id="fcRecentGrid"></div>
    </section>
</div>

<!-- Floating Back to Top Button -->
<button type="button" class="fc-back-to-top" id="fcBackToTop" aria-label="Back to Top" title="Back to Top">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="18 15 12 9 6 15"/></svg>
</button>

<c:if test="${not isResultsMode}">
<!-- Newsletter / CTA Band (Browse Mode Only) -->
<section class="fc-newsletter-band">
    <div class="fc-container">
        <div class="fc-newsletter-inner">
            <div class="fc-newsletter-content">
                <span class="fc-hero-pill" style="margin-bottom: var(--space-3); background: rgba(232, 241, 234, 0.15); color: #E8F1EA; border-color: rgba(232, 241, 234, 0.25);">
                    Seasonal Harvest Calendar
                </span>
                <h2 style="font-family: var(--font-display); font-size: 1.85rem; color: #FFFFFF; margin-bottom: var(--space-2);">
                    Stay Ahead of the Season's Best Pick
                </h2>
                <p style="color: #C6D8CC; font-size: 0.95rem; max-width: 580px; margin: 0; line-height: 1.55;">
                    Receive weekly notifications when fresh Alphonso mangoes, strawberries, and winter vegetables arrive from regional farms. Zero spam, unsubscribe anytime.
                </p>
            </div>
            <form class="fc-newsletter-form" onsubmit="event.preventDefault(); if (window.FarmConnect) { window.FarmConnect.showToast('Thank you for subscribing to weekly harvest updates!', 'success'); } this.reset();">
                <input type="email" placeholder="Enter your email address..." required class="fc-newsletter-input" aria-label="Email for harvest newsletter">
                <button type="submit" class="btn btn-primary" style="background: #E8A33D !important; color: #1C2420 !important; font-weight: 700; white-space: nowrap;">
                    Subscribe Free
                </button>
            </form>
        </div>
    </div>
</section>
</c:if>

<script>
// Filter Chip Removal Handler
document.querySelectorAll('.fc-filter-chip-remove').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
        e.preventDefault();
        const paramToRemove = this.getAttribute('data-remove');
        const url = new URL(window.location.href);
        if (paramToRemove === 'price') {
            url.searchParams.delete('minPrice');
            url.searchParams.delete('maxPrice');
        } else {
            url.searchParams.delete(paramToRemove);
        }
        url.searchParams.delete('page'); // reset to page 1
        window.location.href = url.pathname + (url.searchParams.toString() ? '?' + url.searchParams.toString() : '');
    });
});

// Smooth Scroll to Results on load if in Results Mode
<c:if test="${isResultsMode}">
window.addEventListener('DOMContentLoaded', function() {
    const el = document.getElementById('results');
    if (el) {
        const yOffset = -90; // offset for sticky navbar
        const y = el.getBoundingClientRect().top + window.pageYOffset + yOffset;
        window.scrollTo({ top: Math.max(0, y), behavior: 'smooth' });
    }
});
</c:if>
</script>

<jsp:include page="/jsp/common/footer.jsp" />
