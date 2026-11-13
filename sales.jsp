<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Monthly Sales History - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/dashboard">Grower Console</a></li>
            <li aria-current="page">Sales History</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Monthly Sales Performance</h1>
            <p class="fc-page-subtitle">Track completed orders and revenue aggregated month-over-month.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/farmer/dashboard" class="fc-btn fc-btn-outline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 0.35rem;"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Dashboard
            </a>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty monthlySales}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <line x1="18" y1="20" x2="18" y2="10"/>
                        <line x1="12" y1="20" x2="12" y2="4"/>
                        <line x1="6" y1="20" x2="6" y2="14"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No completed sales records yet</h3>
                <p class="fc-empty-desc">Once customer orders reach DELIVERED status, monthly sales and revenue figures will automatically compile here.</p>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Visual Bar Comparison -->
            <div class="fc-card" style="margin-bottom: 2rem; padding: 1.5rem;">
                <h3 style="font-size: 1.125rem; font-weight: 700; margin-bottom: 1.25rem; color: var(--color-neutral-900);">
                    Revenue Breakdown by Period
                </h3>
                <div class="fc-chart-container">
                    <c:forEach var="row" items="${monthlySales}">
                        <div class="fc-chart-row">
                            <span class="fc-chart-label"><c:out value="${row.month}"/></span>
                            <div class="fc-chart-bar-wrap">
                                <div class="fc-chart-bar" style="width: 85%;">
                                    <span class="fc-chart-bar-value">&#8377;<fmt:formatNumber value="${row.totalSales}" pattern="#,##0"/></span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Tabular Sales Summary -->
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Month Period</th>
                                <th>Fulfilled Orders</th>
                                <th style="text-align: right;">Total Net Revenue</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="${monthlySales}">
                                <tr>
                                    <td>
                                        <strong style="color: var(--color-neutral-900);"><c:out value="${row.month}"/></strong>
                                    </td>
                                    <td>
                                        <span class="fc-badge fc-badge-info"><c:out value="${row.orderCount}"/> fulfilled orders</span>
                                    </td>
                                    <td style="text-align: right;">
                                        <strong style="color: var(--color-primary-700); font-size: 1.125rem;">
                                            &#8377;<fmt:formatNumber value="${row.totalSales}" pattern="#,##0.00"/>
                                        </strong>
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
