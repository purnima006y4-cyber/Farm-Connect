<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="My Harvest Inventory - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/dashboard">Grower Console</a></li>
            <li aria-current="page">My Produce Listings</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">My Harvest &amp; Produce Listings</h1>
            <p class="fc-page-subtitle">Manage crop availability, stock levels, harvest dates, and market prices.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/farmer/products/add" class="fc-btn fc-btn-primary">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="margin-right: 0.35rem;"><path d="M12 5v14M5 12h14"/></svg>
                + Add New Produce
            </a>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty products}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <path d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No produce listed yet</h3>
                <p class="fc-empty-desc">You haven't listed any farm produce for sale. Add your first crop with pricing, photos, and harvest dates to start receiving customer orders.</p>
                <div style="margin-top: 1.25rem;">
                    <a href="${pageContext.request.contextPath}/farmer/products/add" class="fc-btn fc-btn-primary">+ Add First Produce</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Produce Item</th>
                                <th>Category</th>
                                <th>Unit Price</th>
                                <th>Stock Level</th>
                                <th>Harvest Date</th>
                                <th>Season</th>
                                <th>Listing Status</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.875rem;">
                                            <div style="width: 48px; height: 48px; border-radius: var(--radius-sm); overflow: hidden; background: var(--color-neutral-100); flex-shrink: 0; border: 1px solid var(--color-neutral-200); display: flex; align-items: center; justify-content: center;">
                                                <c:choose>
                                                    <c:when test="${not empty p.imagePath}">
                                                        <img src="${pageContext.request.contextPath}/images/<c:out value='${p.imagePath}'/>" alt="<c:out value='${p.name}'/>" style="width: 100%; height: 100%; object-fit: cover;">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--color-primary-600)" stroke-width="1.5">
                                                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                                                        </svg>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <strong style="color: var(--color-neutral-900); display: block;"><c:out value="${p.name}"/></strong>
                                                <span style="font-size: 0.8125rem; color: var(--color-neutral-500); font-family: monospace;">#PRD-<c:out value="${p.productId}"/></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="fc-badge fc-badge-neutral"><c:out value="${p.categoryName}"/></span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--color-neutral-900);">&#8377;<fmt:formatNumber value="${p.price}" pattern="#,##0.00"/></strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.quantity lt 10}">
                                                <span style="font-weight: 700; color: var(--color-danger-600); display: inline-flex; align-items: center; gap: 0.25rem;">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                                                    <c:out value="${p.quantity}"/> units
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-weight: 600; color: var(--color-neutral-800);"><c:out value="${p.quantity}"/> units</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="color: var(--color-neutral-600); font-size: 0.875rem;">
                                        <fmt:formatDate value="${p.harvestDate}" pattern="dd MMM yyyy"/>
                                    </td>
                                    <td>
                                        <span style="font-size: 0.875rem; color: var(--color-neutral-700);"><c:out value="${p.season}"/></span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status eq 'AVAILABLE'}">
                                                <span class="fc-badge fc-badge-success">Available</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fc-badge fc-badge-danger"><c:out value="${p.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <div style="display: inline-flex; gap: 0.5rem; align-items: center;">
                                            <a href="${pageContext.request.contextPath}/farmer/products/edit?id=${p.productId}" class="fc-btn fc-btn-sm fc-btn-outline">
                                                Edit
                                            </a>
                                            <form action="${pageContext.request.contextPath}/farmer/products/delete" method="post" onsubmit="return confirm('Are you sure you want to delete this listing?');" style="display: inline; margin: 0;">
                                                <input type="hidden" name="productId" value="${p.productId}">
                                                <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                    Delete
                                                </button>
                                            </form>
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
