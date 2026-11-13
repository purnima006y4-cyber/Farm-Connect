<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="List New Produce - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem; max-width: 760px;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/products">My Produce Listings</a></li>
            <li aria-current="page">List Produce</li>
        </ol>
    </nav>

    <div class="fc-page-header" style="margin-bottom: 1.5rem;">
        <div>
            <h1 class="fc-page-title">List New Produce or Crop</h1>
            <p class="fc-page-subtitle">Publish fresh harvest details directly to buyers on the FarmConnect marketplace.</p>
        </div>
    </div>

    <div class="fc-card" style="padding: 2rem;">
        <form action="${pageContext.request.contextPath}/farmer/products/add" method="post" enctype="multipart/form-data" novalidate id="addProductForm">
            <!-- Product Name -->
            <div class="fc-form-group">
                <label for="name" class="fc-label">Crop / Product Name <span style="color: var(--color-danger-600);">*</span></label>
                <input type="text" id="name" name="name" class="fc-input" required placeholder="e.g. Organic Farm-Fresh Red Tomatoes">
                <span class="fc-hint">Use a descriptive title highlighting freshness, variety, or organic practices.</span>
            </div>

            <!-- Category -->
            <div class="fc-form-group">
                <label for="categoryId" class="fc-label">Category <span style="color: var(--color-danger-600);">*</span></label>
                <select id="categoryId" name="categoryId" class="fc-select" required>
                    <option value="" disabled selected>Select a produce category</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}"><c:out value="${cat.name}"/></option>
                    </c:forEach>
                </select>
            </div>

            <!-- Price and Quantity -->
            <div class="fc-grid-2">
                <div class="fc-form-group">
                    <label for="price" class="fc-label">Price per Unit (&#8377;) <span style="color: var(--color-danger-600);">*</span></label>
                    <div style="position: relative;">
                        <span style="position: absolute; left: 0.875rem; top: 50%; transform: translateY(-50%); color: var(--color-neutral-500); font-weight: 600;">&#8377;</span>
                        <input type="number" id="price" name="price" class="fc-input" style="padding-left: 2rem;" step="0.01" min="0.01" required placeholder="45.00">
                    </div>
                    <span class="fc-hint">Direct farm-gate pricing in Rupees</span>
                </div>

                <div class="fc-form-group">
                    <label for="quantity" class="fc-label">Initial Stock / Quantity <span style="color: var(--color-danger-600);">*</span></label>
                    <input type="number" id="quantity" name="quantity" class="fc-input" min="0" required placeholder="100">
                    <span class="fc-hint">Quantity in kg, crates, or bunch units</span>
                </div>
            </div>

            <!-- Harvest Date & Season -->
            <div class="fc-grid-2">
                <div class="fc-form-group">
                    <label for="harvestDate" class="fc-label">Harvest Date</label>
                    <input type="date" id="harvestDate" name="harvestDate" class="fc-input">
                    <span class="fc-hint">Helps customers gauge crop freshness</span>
                </div>

                <div class="fc-form-group">
                    <label for="season" class="fc-label">Season Suitability</label>
                    <select id="season" name="season" class="fc-select">
                        <option value="ALL">All Seasons</option>
                        <option value="SUMMER">Summer</option>
                        <option value="MONSOON">Monsoon</option>
                        <option value="WINTER">Winter</option>
                    </select>
                </div>
            </div>

            <!-- Photo Upload -->
            <div class="fc-form-group" style="margin-top: 0.5rem;">
                <label for="image" class="fc-label">Produce Photo (Optional)</label>
                <div style="border: 2px dashed var(--color-neutral-300); border-radius: var(--radius-md); padding: 1.5rem; text-align: center; background: var(--color-neutral-50); transition: border-color 0.2s;" id="dropZone">
                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="var(--color-neutral-400)" stroke-width="1.75" style="margin: 0 auto 0.5rem auto; display: block;">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                        <circle cx="8.5" cy="8.5" r="1.5"/>
                        <polyline points="21 15 16 10 5 21"/>
                    </svg>
                    <p style="margin: 0 0 0.5rem 0; font-size: 0.875rem; color: var(--color-neutral-700);">
                        <strong>Click to select photo</strong> or drag &amp; drop
                    </p>
                    <input type="file" id="image" name="image" accept="image/jpeg,image/png" style="font-size: 0.875rem; color: var(--color-neutral-600);">
                    <div style="font-size: 0.75rem; color: var(--color-neutral-500); margin-top: 0.5rem;">
                        Accepted formats: JPG, PNG. Maximum file size: 2 MB.
                    </div>
                </div>
            </div>

            <!-- Form Actions -->
            <div style="display: flex; gap: 1rem; margin-top: 2rem; border-top: 1px solid var(--color-neutral-200); padding-top: 1.5rem;">
                <button type="submit" class="fc-btn fc-btn-primary" style="flex: 1; padding: 0.875rem;">
                    List Produce on Marketplace
                </button>
                <a href="${pageContext.request.contextPath}/farmer/products" class="fc-btn fc-btn-outline" style="flex: 0.5; padding: 0.875rem; text-align: center;">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
