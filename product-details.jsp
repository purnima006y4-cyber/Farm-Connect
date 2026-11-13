<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="${product.name} - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: var(--space-6); padding-bottom: var(--space-12);">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/products?category=${product.categoryId}"><c:out value="${product.categoryName}"/></a></li>
            <li aria-current="page"><c:out value="${product.name}"/></li>
        </ol>
    </nav>

    <%-- Fallback Image Selection for Product Detail --%>
    <c:choose>
        <c:when test="${not empty product.imagePath}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/images/${product.imagePath}"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'tomato')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/tomatoes.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'spinach') or fn:containsIgnoreCase(product.name, 'palak')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/spinach.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'mango')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/mangoes.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'wheat')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/wheat.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'onion')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/onions.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'potato')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/potatoes.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'pomegranate')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/pomegranate.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'coriander') or fn:containsIgnoreCase(product.name, 'mint')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/herbs.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'rice')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/rice.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.name, 'strawberr')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/strawberries.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.categoryName, 'veg')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/category-vegetables.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.categoryName, 'fruit')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/category-fruits.jpg"/>
        </c:when>
        <c:when test="${fn:containsIgnoreCase(product.categoryName, 'grain')}">
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/category-grains.jpg"/>
        </c:when>
        <c:otherwise>
            <c:set var="detailImg" value="${pageContext.request.contextPath}/assets/img/placeholder-product.jpg"/>
        </c:otherwise>
    </c:choose>

    <!-- Two-Column Product Showcase -->
    <div style="background: var(--color-surface); border-radius: var(--radius-xl); border: 1px solid var(--color-border); box-shadow: var(--shadow-sm); padding: var(--space-8); margin-bottom: var(--space-8); display: grid; grid-template-columns: 1.1fr 1fr; gap: var(--space-10);">
        <!-- Product Media Frame -->
        <div>
            <div style="width: 100%; aspect-ratio: 4/3; border-radius: var(--radius-lg); overflow: hidden; background: var(--color-surface-muted); border: 1px solid var(--color-border); position: relative;">
                <img src="${detailImg}" alt="<c:out value='${product.name}'/>" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/placeholder-product.jpg';">
                <span class="product-season-badge" style="top: 14px; left: 14px;">
                    <c:out value="${product.season}"/> Season
                </span>
            </div>
        </div>

        <!-- Product Details & Controls -->
        <div style="display: flex; flex-direction: column;">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                <span class="product-category-meta"><c:out value="${product.categoryName}"/></span>
                <span style="color: var(--color-text-subtle);">&bull;</span>
                <c:if test="${product.avgRating > 0}">
                    <span style="color: #B45309; font-weight: 700; font-size: 0.875rem; display: inline-flex; align-items: center; gap: 3px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="#E8A33D" stroke="#E8A33D"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <fmt:formatNumber value="${product.avgRating}" pattern="0.0"/> (<c:out value="${fn:length(reviews)}"/> reviews)
                    </span>
                </c:if>
            </div>

            <h1 style="font-size: 2.25rem; font-weight: 600; color: var(--color-text); margin-bottom: var(--space-4); line-height: 1.2;">
                <c:out value="${product.name}"/>
            </h1>

            <div style="display: flex; align-items: baseline; gap: var(--space-3); margin-bottom: var(--space-6);">
                <div style="font-size: 2.5rem; font-weight: 700; color: var(--color-primary); line-height: 1;" class="num-tabular">
                    &#8377;<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/>
                </div>
                <span style="color: var(--color-text-muted); font-size: 0.9375rem;">direct farm-gate price</span>
            </div>

            <!-- Harvest & Stock Metric Card -->
            <div style="background: var(--color-bg); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: var(--space-4); margin-bottom: var(--space-6); display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--space-4);">
                <div>
                    <span style="font-size: 0.75rem; color: var(--color-text-subtle); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 2px;">Stock</span>
                    <c:choose>
                        <c:when test="${product.quantity > 0}">
                            <strong style="color: var(--color-primary); font-size: 1.1rem;"><c:out value="${product.quantity}"/> units</strong>
                        </c:when>
                        <c:otherwise>
                            <strong style="color: var(--color-terracotta); font-size: 1.1rem;">Sold Out</strong>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <span style="font-size: 0.75rem; color: var(--color-text-subtle); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 2px;">Harvest Date</span>
                    <strong style="color: var(--color-text); font-size: 1rem;">
                        <fmt:formatDate value="${product.harvestDate}" pattern="dd MMM yyyy"/>
                    </strong>
                </div>
                <div>
                    <span style="font-size: 0.75rem; color: var(--color-text-subtle); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 2px;">Freshness</span>
                    <strong style="color: var(--color-primary); font-size: 1rem;">
                        <c:out value="${product.daysSinceHarvest}"/>d ago
                    </strong>
                </div>
            </div>

            <!-- Grower Verification Card -->
            <div style="background: var(--color-primary-tint); border: 1px solid rgba(31, 77, 58, 0.2); border-radius: var(--radius-md); padding: var(--space-4); margin-bottom: var(--space-6);">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 4px;">
                    <div style="font-weight: 700; color: var(--color-primary); font-size: 1rem;">
                        <a href="${pageContext.request.contextPath}/farmer-profile?id=${product.farmerId}" class="product-farm-link" style="color: var(--color-primary); text-decoration: underline;">
                            <c:out value="${product.farmName}"/>
                        </a>
                    </div>
                    <c:if test="${product.farmerVerified eq 'Y'}">
                        <span class="product-verified-badge">
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                            Verified Grower
                        </span>
                    </c:if>
                </div>
                <div style="color: var(--color-text-muted); font-size: 0.875rem;">
                    Grower: <strong><a href="${pageContext.request.contextPath}/farmer-profile?id=${product.farmerId}" style="color: inherit;"><c:out value="${product.farmerName}"/></a></strong> &bull; Location: <c:out value="${product.farmerLocation}"/> (PIN: <c:out value="${product.farmerPincode}"/>)
                </div>
            </div>

            <!-- Add to Cart Form -->
            <div style="margin-top: auto;">
                <c:choose>
                    <c:when test="${product.quantity > 0 and product.status ne 'OUT_OF_STOCK'}">
                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="fc-add-cart-form" data-product-name="<c:out value='${product.name}'/>" style="display: flex; gap: var(--space-3); max-width: 380px;">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <input type="number" name="quantity" value="1" min="1" max="${product.quantity}" class="fc-input" style="width: 80px; text-align: center; font-weight: 700;" aria-label="Quantity">
                            <button type="submit" class="btn btn-primary btn-lg" style="flex: 1;">
                                Add to Cart
                            </button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <div class="fc-alert fc-alert-warning" style="margin-bottom: 0;">
                            Produce is currently sold out. Check back soon for the next harvest batch.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Customer Reviews Section -->
    <section class="fc-card" style="padding: var(--space-8);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-6); flex-wrap: wrap; gap: var(--space-4);">
            <div>
                <h2 style="font-size: 1.5rem; margin-bottom: 2px;">Customer Experiences &amp; Reviews</h2>
                <p class="fc-caption">Verified feedback from customers with delivered orders.</p>
            </div>
        </div>

        <!-- Review Submission Form for Authenticated Customers -->
        <c:if test="${not empty role and role eq 'CUSTOMER'}">
            <div style="background: var(--color-bg); border: 1px solid var(--color-border); padding: var(--space-6); border-radius: var(--radius-lg); margin-bottom: var(--space-8);">
                <h3 style="font-size: 1.125rem; margin-bottom: 4px;">Leave a Produce Review</h3>
                <p class="fc-caption" style="margin-bottom: var(--space-4);">
                    Note: Marketplace rules require that you have received this produce in a <strong>DELIVERED</strong> order before submitting a review.
                </p>
                <form action="${pageContext.request.contextPath}/customer/review" method="post">
                    <input type="hidden" name="productId" value="${product.productId}">
                    <div class="fc-form-group" style="max-width: 260px;">
                        <label for="rating" class="fc-label">Quality Rating (1 to 5 Stars)</label>
                        <select name="rating" id="rating" required class="fc-select">
                            <option value="5">5 - Outstanding Freshness</option>
                            <option value="4">4 - Very Good</option>
                            <option value="3">3 - Average</option>
                            <option value="2">2 - Below Expectations</option>
                            <option value="1">1 - Unsatisfactory</option>
                        </select>
                    </div>
                    <div class="fc-form-group">
                        <label for="reviewText" class="fc-label">Review Details</label>
                        <textarea name="reviewText" id="reviewText" rows="3" class="fc-textarea" placeholder="Tell other buyers about taste, packing freshness, and condition..."></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        Submit Review
                    </button>
                </form>
            </div>
        </c:if>

        <!-- Reviews Feed -->
        <c:choose>
            <c:when test="${empty reviews}">
                <div class="fc-empty-state" style="padding: var(--space-8);">
                    <p class="fc-empty-desc" style="margin-bottom: 0;">No reviews written yet. Be the first to share your experience once delivered!</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: var(--space-4);">
                    <c:forEach var="r" items="${reviews}">
                        <div style="padding: var(--space-4); border: 1px solid var(--color-border-subtle); border-radius: var(--radius-md); background: var(--color-bg);">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <div class="fc-avatar" style="width: 28px; height: 28px; font-size: 0.75rem;">
                                        <c:out value="${fn:substring(r.userName, 0, 1)}"/>
                                    </div>
                                    <strong style="color: var(--color-text); font-size: 0.925rem;"><c:out value="${r.userName}"/></strong>
                                </div>
                                <div style="color: #B45309; font-weight: 700; font-size: 0.875rem;">
                                    <c:out value="${r.rating}"/> / 5
                                </div>
                            </div>
                            <p style="color: var(--color-text-muted); font-size: 0.9rem; line-height: 1.5; margin: 0;">
                                <c:out value="${r.reviewText}"/>
                            </p>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        if (window.FarmConnect && window.FarmConnect.recordRecentlyViewed) {
            window.FarmConnect.recordRecentlyViewed({
                id: '${product.productId}',
                name: '<c:out value="${product.name}"/>',
                price: '<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/>',
                image: '${detailImg}',
                farmName: '<c:out value="${product.farmName}"/>',
                category: '<c:out value="${product.categoryName}"/>',
                url: '${pageContext.request.contextPath}/product?id=${product.productId}'
            });
        }
    });
</script>

<jsp:include page="/jsp/common/footer.jsp" />
