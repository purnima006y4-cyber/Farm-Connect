<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Global Product Catalog - FarmConnect Admin" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Overview</a></li>
            <li aria-current="page">Global Catalogue</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Global Produce Catalogue</h1>
            <p class="fc-page-subtitle">Monitor all live, pending, or sold-out produce listings across every registered farmer.</p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty products}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No produce listings found</h3>
                <p class="fc-empty-desc">No crops or items have been listed in this view or pagination range.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Produce Item</th>
                                <th>Farmer &amp; Origin</th>
                                <th>Category</th>
                                <th>Unit Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th style="text-align: right;">Season</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 700; color: var(--color-neutral-900);">
                                            <c:out value="${p.name}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-500); font-family: monospace;">
                                            #PRD-<c:out value="${p.productId}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--color-primary-800);">
                                            <c:out value="${p.farmerName}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-500);">
                                            <c:out value="${p.farmName}"/>
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
                                                <span style="color: var(--color-danger-600); font-weight: 700;"><c:out value="${p.quantity}"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span><c:out value="${p.quantity}"/></span>
                                            </c:otherwise>
                                        </c:choose>
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
                                    <td style="text-align: right; color: var(--color-neutral-700); font-size: 0.875rem;">
                                        <c:out value="${p.season}"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Toolbar -->
                <div class="fc-pagination" style="padding: 1rem 1.5rem; border-top: 1px solid var(--color-neutral-200); display: flex; justify-content: center; align-items: center; gap: 0.75rem;">
                    <c:if test="${page > 1}">
                        <a href="?page=${page - 1}" class="fc-btn fc-btn-sm fc-btn-outline">&laquo; Previous</a>
                    </c:if>
                    <span style="font-weight: 600; font-size: 0.875rem; color: var(--color-neutral-600); padding: 0 0.5rem;">
                        Page <c:out value="${page}"/>
                    </span>
                    <c:if test="${fn:length(products) eq 20}">
                        <a href="?page=${page + 1}" class="fc-btn fc-btn-sm fc-btn-outline">Next &raquo;</a>
                    </c:if>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
