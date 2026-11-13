<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Platform Analytics & Reports - FarmConnect Admin" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Overview</a></li>
            <li aria-current="page">Analytics &amp; Reports</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Marketplace Reports &amp; Analytics</h1>
            <p class="fc-page-subtitle">Platform-wide transaction trends, monthly volume, and top demanded farm produce.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="fc-btn fc-btn-outline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 0.35rem;"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Dashboard
            </a>
        </div>
    </div>

    <!-- Monthly Platform Sales Visualization -->
    <c:if test="${not empty monthlySales}">
        <div class="fc-card" style="margin-bottom: 2rem; padding: 1.5rem;">
            <h3 style="font-size: 1.125rem; font-weight: 700; margin-bottom: 1.25rem; color: var(--color-neutral-900);">
                Platform Revenue Growth Trends
            </h3>
            <div class="fc-chart-container">
                <c:forEach var="row" items="${monthlySales}">
                    <div class="fc-chart-row">
                        <span class="fc-chart-label"><c:out value="${row.month}"/></span>
                        <div class="fc-chart-bar-wrap">
                            <div class="fc-chart-bar" style="width: 80%;">
                                <span class="fc-chart-bar-value">&#8377;<fmt:formatNumber value="${row.totalSales}" pattern="#,##0"/></span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <div style="display: grid; grid-template-columns: 1.4fr 1fr; gap: 2rem; align-items: start;">
        <!-- Monthly Revenue Table -->
        <div class="fc-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-neutral-200); background: var(--color-neutral-50);">
                <h3 style="font-size: 1.125rem; font-weight: 700; color: var(--color-neutral-900); margin: 0;">Monthly Gross Volume</h3>
            </div>

            <c:choose>
                <c:when test="${empty monthlySales}">
                    <div style="padding: 3rem 1.5rem; text-align: center; color: var(--color-neutral-500);">
                        <p style="margin: 0;">No monthly transaction history compiled yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="fc-table-responsive">
                        <table class="fc-table">
                            <thead>
                                <tr>
                                    <th>Month</th>
                                    <th>Delivered Orders</th>
                                    <th style="text-align: right;">Gross Revenue</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="row" items="${monthlySales}">
                                    <tr>
                                        <td>
                                            <strong style="color: var(--color-neutral-900);"><c:out value="${row.month}"/></strong>
                                        </td>
                                        <td>
                                            <span class="fc-badge fc-badge-info"><c:out value="${row.orderCount}"/> orders</span>
                                        </td>
                                        <td style="text-align: right;">
                                            <strong style="color: var(--color-primary-700); font-size: 1.05rem;">
                                                &#8377;<fmt:formatNumber value="${row.totalSales}" pattern="#,##0.00"/>
                                            </strong>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Top Selling Products -->
        <div class="fc-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-neutral-200); background: var(--color-neutral-50);">
                <h3 style="font-size: 1.125rem; font-weight: 700; color: var(--color-neutral-900); margin: 0;">Top Demand Produce</h3>
            </div>

            <c:choose>
                <c:when test="${empty topProducts}">
                    <div style="padding: 3rem 1.5rem; text-align: center; color: var(--color-neutral-500);">
                        <p style="margin: 0;">No produce sales volume recorded yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="fc-table-responsive">
                        <table class="fc-table">
                            <thead>
                                <tr>
                                    <th>Produce Name</th>
                                    <th style="text-align: right;">Units Sold</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${topProducts}">
                                    <tr>
                                        <td>
                                            <strong style="color: var(--color-neutral-900);"><c:out value="${item.name}"/></strong>
                                        </td>
                                        <td style="text-align: right;">
                                            <span class="fc-badge fc-badge-success" style="font-size: 0.875rem;">
                                                <c:out value="${item.totalSold}"/> units
                                            </span>
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
</div>

<jsp:include page="/jsp/common/footer.jsp" />
