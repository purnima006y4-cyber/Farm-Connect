<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${param.title != null ? param.title : 'FarmConnect - Direct Farmer-to-Customer Marketplace'}"/></title>
    <!-- Modern Typography: Fraunces (Serif Display) + Inter (Sans Body/UI) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;0,9..144,700;1,9..144,600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/img/favicon.svg">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="${pageContext.request.contextPath}/js/main.js" defer></script>
</head>
<body>

<c:choose>
    <%-- =========================================================================
         1. FARMER & ADMIN DASHBOARD SHELL
         ========================================================================= --%>
    <c:when test="${role eq 'FARMER' || role eq 'ADMIN'}">
        <div class="fc-dashboard-layout">
            <!-- Left Fixed Sidebar -->
            <aside class="fc-sidebar" id="fcSidebar" aria-label="Dashboard Navigation">
                <div class="fc-sidebar-header">
                    <a href="${pageContext.request.contextPath}/products" class="fc-brand">
                        <div class="fc-brand-icon">
                            <svg width="22" height="22" viewBox="0 0 32 32" fill="none">
                                <rect width="32" height="32" rx="8" fill="#1F4D3A"/>
                                <circle cx="16" cy="13" r="3" fill="#E8A33D"/>
                                <path d="M16 25V15C16 11 20 10.5 22 10.5C22 13.5 20 17 16 18" stroke="#8AE39C" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M16 19C13 18.5 10 15.5 10 13C12 13 15 13.5 16 16.5" stroke="#D1FAE5" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span>FarmConnect</span>
                    </a>
                    <span class="fc-sidebar-role"><c:out value="${role}"/></span>
                </div>

                <nav class="fc-sidebar-nav">
                    <c:choose>
                        <%-- Farmer Navigation --%>
                        <c:when test="${role eq 'FARMER'}">
                            <span class="fc-sidebar-group-title">Grower Console</span>
                            <a href="${pageContext.request.contextPath}/farmer/dashboard" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'dashboard.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                <span>Overview</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/farmer/products" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'my-products.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                <span>My Produce Listings</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/farmer/products/add" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'add-product.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                <span>+ Add Harvest</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/farmer/orders" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'orders.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                                <span>Incoming Orders</span>
                                <c:if test="${not empty placedOrdersCount and placedOrdersCount > 0}">
                                    <span class="fc-badge-counter"><c:out value="${placedOrdersCount}"/></span>
                                </c:if>
                            </a>
                            <a href="${pageContext.request.contextPath}/farmer/sales" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'sales.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                                <span>Sales History</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/profile" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'profile.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                                <span>Grower Profile</span>
                            </a>
                        </c:when>

                        <%-- Admin Navigation --%>
                        <c:when test="${role eq 'ADMIN'}">
                            <span class="fc-sidebar-group-title">Governance</span>
                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'dashboard.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                <span>Overview</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/farmers" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'farmers.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                <span>Farmers &amp; Approvals</span>
                                <c:if test="${not empty pendingApprovalsCount and pendingApprovalsCount > 0}">
                                    <span class="fc-badge-counter"><c:out value="${pendingApprovalsCount}"/></span>
                                </c:if>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/users" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'users.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                                <span>Customers</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/categories" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'categories.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                                <span>Categories</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/products" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'products.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                <span>Global Catalogue</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/orders" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'orders.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                <span>Global Orders</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/complaints" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'complaints.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                <span>Disputes &amp; Complaints</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/reports" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'reports.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                                <span>Analytics &amp; Reports</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/profile" class="fc-sidebar-link ${fn:endsWith(pageContext.request.requestURI, 'profile.jsp') ? 'active' : ''}">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                                <span>Admin Profile</span>
                            </a>
                        </c:when>
                    </c:choose>
                </nav>

                <div class="fc-sidebar-footer">
                    <a href="${pageContext.request.contextPath}/products" class="fc-btn fc-btn-secondary fc-btn-sm fc-btn-block" style="margin-bottom: 8px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                        <span>View Marketplace</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="fc-btn fc-btn-ghost fc-btn-sm fc-btn-block" style="color: var(--color-terracotta);">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        <span>Sign Out</span>
                    </a>
                </div>
            </aside>

            <!-- Dashboard Main Area -->
            <div class="fc-sidebar-body">
                <header class="fc-dashboard-topbar">
                    <div class="fc-topbar-left">
                        <button class="fc-sidebar-toggle-btn" id="fcSidebarToggle" aria-label="Toggle Navigation Sidebar">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                        </button>
                        <div class="fc-topbar-breadcrumb">
                            <span>FarmConnect</span>
                            <span style="opacity: 0.4;">/</span>
                            <span style="font-weight: 600; color: var(--color-text);"><c:out value="${role}"/> Console</span>
                        </div>
                    </div>
                    <div class="fc-topbar-right">
                        <a href="${pageContext.request.contextPath}/profile" class="fc-btn fc-btn-ghost fc-btn-sm" title="My Profile" style="display: inline-flex; align-items: center; gap: 6px;">
                            <div class="fc-avatar" style="width: 28px; height: 28px; font-size: 0.75rem;">
                                <c:out value="${not empty userName ? fn:substring(userName, 0, 1) : fn:substring(role, 0, 1)}"/>
                            </div>
                            <span><c:out value="${not empty userName ? userName : role}"/></span>
                        </a>
                        <a href="${pageContext.request.contextPath}/logout" class="fc-btn fc-btn-ghost fc-btn-sm" style="color: var(--color-terracotta);">
                            Sign Out
                        </a>
                    </div>
                </header>

                <!-- Flash Notification Banner -->
                <div class="fc-alerts-wrapper">
                    <c:if test="${not empty error}">
                        <div class="fc-alert fc-alert-error" role="alert">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                <span><c:out value="${error}"/></span>
                            </div>
                            <button type="button" class="fc-alert-close" aria-label="Dismiss">&times;</button>
                        </div>
                    </c:if>
                    <c:if test="${not empty message}">
                        <div class="fc-alert fc-alert-success" role="status">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                <span><c:out value="${message}"/></span>
                            </div>
                            <button type="button" class="fc-alert-close" aria-label="Dismiss">&times;</button>
                        </div>
                    </c:if>
                </div>

                <main class="fc-dashboard-content">
    </c:when>

    <%-- =========================================================================
         2. PUBLIC STOREFRONT & CUSTOMER SHELL
         ========================================================================= --%>
    <c:otherwise>
        <div class="fc-public-layout">
            <header class="fc-public-navbar">
                <div class="fc-navbar-container">
                    <!-- Brand Wordmark & Leaf Logo -->
                    <a href="${pageContext.request.contextPath}/products" class="fc-brand">
                        <div class="fc-brand-icon">
                            <svg width="24" height="24" viewBox="0 0 32 32" fill="none">
                                <rect width="32" height="32" rx="8" fill="#1F4D3A"/>
                                <circle cx="16" cy="13" r="3" fill="#E8A33D"/>
                                <path d="M16 25V15C16 11 20 10.5 22 10.5C22 13.5 20 17 16 18" stroke="#8AE39C" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M16 19C13 18.5 10 15.5 10 13C12 13 15 13.5 16 16.5" stroke="#D1FAE5" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <span>FarmConnect</span>
                        <c:if test="${not empty role}">
                            <span class="fc-brand-badge"><c:out value="${role}"/></span>
                        </c:if>
                    </a>

                    <!-- Prominent Search Bar -->
                    <form action="${pageContext.request.contextPath}/products" method="get" class="fc-nav-search" role="search">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                        </svg>
                        <input type="text" name="name" placeholder="Search farm-fresh crops, fruits, grains..." value="<c:out value='${not empty nameQuery ? nameQuery : (not empty param.name ? param.name : param.search)}'/>">
                    </form>

                    <!-- Navigation Links & Profile Actions -->
                    <nav class="fc-nav-actions" id="fcNavLinks">
                        <a href="${pageContext.request.contextPath}/products" class="fc-nav-link ${fn:endsWith(pageContext.request.requestURI, 'home.jsp') ? 'active' : ''}">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            <span>Marketplace</span>
                        </a>

                        <c:choose>
                            <c:when test="${not empty role}">
                                <%-- Customer Specific Top Nav Links --%>
                                <c:if test="${role eq 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/customer/orders" class="fc-nav-link ${fn:endsWith(pageContext.request.requestURI, 'my-orders.jsp') ? 'active' : ''}">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                        <span>My Orders</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/complaints" class="fc-nav-link ${fn:endsWith(pageContext.request.requestURI, 'complaints.jsp') ? 'active' : ''}">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                                        <span>Grievances</span>
                                    </a>
                                </c:if>

                                <c:if test="${role eq 'FARMER'}">
                                    <a href="${pageContext.request.contextPath}/farmer/dashboard" class="fc-nav-link">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                        <span>Farmer Console</span>
                                    </a>
                                </c:if>

                                <c:if test="${role eq 'ADMIN'}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="fc-nav-link">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                        <span>Admin Console</span>
                                    </a>
                                </c:if>

                                <!-- Cart Icon Pill -->
                                <a href="${pageContext.request.contextPath}/cart" class="fc-cart-pill" aria-label="Shopping Cart">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
                                    </svg>
                                    <c:choose>
                                        <c:when test="${not empty cartCount and cartCount > 0}">
                                            <span class="fc-cart-count"><c:out value="${cartCount}"/></span>
                                        </c:when>
                                        <c:when test="${not empty cartItems and fn:length(cartItems) > 0}">
                                            <span class="fc-cart-count"><c:out value="${fn:length(cartItems)}"/></span>
                                        </c:when>
                                    </c:choose>
                                </a>

                                <!-- User Avatar Menu -->
                                <div class="fc-user-dropdown" id="fcUserDropdown">
                                    <button class="fc-user-trigger" id="fcUserTrigger" type="button" aria-expanded="false" aria-haspopup="true" aria-label="User account menu">
                                        <div class="fc-avatar">
                                            <c:out value="${not empty userName ? fn:substring(userName, 0, 1) : fn:substring(role, 0, 1)}"/>
                                        </div>
                                        <div class="fc-user-trigger-text">
                                            <span class="fc-user-trigger-name"><c:out value="${not empty userName ? userName : role}"/></span>
                                            <span class="fc-user-trigger-badge"><c:out value="${role}"/></span>
                                        </div>
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" class="fc-chevron-icon"><polyline points="6 9 12 15 18 9"/></svg>
                                    </button>
                                    <div class="fc-dropdown-menu" id="fcDropdownMenu" role="menu">
                                        <div class="fc-dropdown-header">
                                            <div class="fc-dropdown-name"><c:out value="${not empty userName ? userName : role}"/></div>
                                            <c:if test="${not empty userEmail}">
                                                <div class="fc-dropdown-email"><c:out value="${userEmail}"/></div>
                                            </c:if>
                                            <div class="fc-dropdown-badge-row">
                                                <span class="fc-badge fc-badge-info"><c:out value="${role}"/> ACCOUNT</span>
                                            </div>
                                        </div>
                                        <div class="fc-dropdown-section">
                                            <a href="${pageContext.request.contextPath}/profile" class="fc-dropdown-item" role="menuitem">
                                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                                                <span>My Profile &amp; Settings</span>
                                            </a>
                                        </div>
                                        <div class="fc-dropdown-section">
                                            <c:if test="${role eq 'CUSTOMER'}">
                                                <a href="${pageContext.request.contextPath}/customer/orders" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                                                    <span>My Orders</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/customer/complaints" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                                                    <span>Grievances &amp; Support</span>
                                                </a>
                                            </c:if>
                                            <c:if test="${role eq 'FARMER'}">
                                                <a href="${pageContext.request.contextPath}/farmer/dashboard" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                                    <span>Grower Dashboard</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/farmer/products" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                                    <span>My Produce Listings</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/farmer/orders" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                                                    <span>Incoming Orders</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/farmer/sales" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                                                    <span>Sales History</span>
                                                </a>
                                            </c:if>
                                            <c:if test="${role eq 'ADMIN'}">
                                                <a href="${pageContext.request.contextPath}/admin/dashboard" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                                                    <span>Governance Console</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/farmers" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                                    <span>Farmers &amp; Approvals</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/products" class="fc-dropdown-item" role="menuitem">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                                    <span>Catalogue Management</span>
                                                </a>
                                            </c:if>
                                        </div>
                                        <div class="fc-dropdown-section" style="border-bottom: none; margin-bottom: 0;">
                                            <a href="${pageContext.request.contextPath}/logout" class="fc-dropdown-item danger" role="menuitem">
                                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                                                <span>Sign Out</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>

                                <!-- Visible Standalone Log Out Button -->
                                <a href="${pageContext.request.contextPath}/logout" class="fc-nav-logout-btn" title="Sign Out of FarmConnect">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                                    <span class="fc-logout-label">Sign Out</span>
                                </a>
                            </c:when>

                            <%-- Guest / Visitor Links --%>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/cart" class="fc-cart-pill" aria-label="Shopping Cart">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
                                    </svg>
                                </a>
                                <a href="${pageContext.request.contextPath}/login" class="fc-btn fc-btn-ghost fc-btn-sm">
                                    Sign In
                                </a>
                                <a href="${pageContext.request.contextPath}/register" class="fc-btn fc-btn-primary fc-btn-sm">
                                    Join FarmConnect
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </nav>

                    <!-- Mobile Hamburger Toggle -->
                    <button class="fc-nav-toggle" id="fcNavToggle" aria-label="Open Navigation Menu" aria-expanded="false">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                    </button>
                </div>
            </header>

            <!-- Flash Notification Banner -->
            <div class="fc-alerts-wrapper">
                <c:if test="${not empty error}">
                    <div class="fc-alert fc-alert-error" role="alert">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            <span><c:out value="${error}"/></span>
                        </div>
                        <button type="button" class="fc-alert-close" aria-label="Dismiss">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty message}">
                    <div class="fc-alert fc-alert-success" role="status">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                            <span><c:out value="${message}"/></span>
                        </div>
                        <button type="button" class="fc-alert-close" aria-label="Dismiss">&times;</button>
                    </div>
                </c:if>
            </div>

            <main class="fc-public-main">
    </c:otherwise>
</c:choose>
