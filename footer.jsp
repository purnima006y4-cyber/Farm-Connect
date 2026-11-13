<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:choose>
    <%-- =========================================================================
         1. FARMER & ADMIN SLIM DASHBOARD FOOTER
         ========================================================================= --%>
    <c:when test="${role eq 'FARMER' || role eq 'ADMIN'}">
                </main><!-- /.fc-dashboard-content -->

                <footer class="fc-dashboard-footer">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background-color: #10B981;"></span>
                        <span>FarmConnect Platform &bull; Operational &amp; Connected</span>
                    </div>
                    <div>
                        &copy; 2024 FarmConnect Inc. Direct farm-to-table commerce.
                    </div>
                </footer>
            </div><!-- /.fc-sidebar-body -->
        </div><!-- /.fc-dashboard-layout -->
    </c:when>

    <%-- =========================================================================
         2. PUBLIC STOREFRONT RICH FOOTER
         ========================================================================= --%>
    <c:otherwise>
            </main><!-- /.fc-public-main -->

            <footer class="fc-public-footer">
                <div class="fc-footer-main">
                    <!-- Brand Mission Column -->
                    <div>
                        <div class="fc-footer-brand-title">
                            <div style="width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                <svg width="28" height="28" viewBox="0 0 32 32" fill="none">
                                    <rect width="32" height="32" rx="8" fill="#2E5A44"/>
                                    <circle cx="16" cy="13" r="3" fill="#E8A33D"/>
                                    <path d="M16 25V15C16 11 20 10.5 22 10.5C22 13.5 20 17 16 18" stroke="#8AE39C" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M16 19C13 18.5 10 15.5 10 13C12 13 15 13.5 16 16.5" stroke="#D1FAE5" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <span>FarmConnect</span>
                        </div>
                        <p class="fc-footer-desc">
                            Empowering rural growers and families by cutting out middlemen. Delivering fresh, seasonal produce directly from soil to doorstep with fair, transparent pricing.
                        </p>
                        <div style="display: inline-flex; align-items: center; gap: 8px; padding: 6px 12px; background: rgba(255, 255, 255, 0.06); border-radius: 999px; font-size: 0.78125rem; color: #E8F1EA; border: 1px solid rgba(255, 255, 255, 0.1);">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <span>100% Verified Farm Guarantee</span>
                        </div>
                    </div>

                    <!-- Marketplace Links -->
                    <div>
                        <div class="fc-footer-col-title">Marketplace</div>
                        <ul class="fc-footer-links">
                            <li><a href="${pageContext.request.contextPath}/products">Browse Catalog</a></li>
                            <li><a href="${pageContext.request.contextPath}/products?season=SUMMER">Summer Harvests</a></li>
                            <li><a href="${pageContext.request.contextPath}/products?season=WINTER">Winter Specials</a></li>
                            <li><a href="${pageContext.request.contextPath}/products?verifiedOnly=on">Verified Farmers Only</a></li>
                        </ul>
                    </div>

                    <!-- For Farmers -->
                    <div>
                        <div class="fc-footer-col-title">Grower Community</div>
                        <ul class="fc-footer-links">
                            <li><a href="${pageContext.request.contextPath}/register">Register Your Farm</a></li>
                            <li><a href="${pageContext.request.contextPath}/login">Grower Sign In</a></li>
                            <li><a href="${pageContext.request.contextPath}/products">Zero-Middleman Fair Trade</a></li>
                            <li><a href="${pageContext.request.contextPath}/products">Fulfillment Standards</a></li>
                        </ul>
                    </div>

                    <!-- Trust & Support -->
                    <div>
                        <div class="fc-footer-col-title">Customer Care</div>
                        <ul class="fc-footer-links">
                            <li><a href="${pageContext.request.contextPath}/cart">View Cart &amp; Checkout</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/orders">Track Order Status</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/complaints">Dispute Resolution</a></li>
                            <li><a href="${pageContext.request.contextPath}/products">Direct Delivery Guarantee</a></li>
                        </ul>
                    </div>
                </div>

                <div class="fc-footer-bottom">
                    <div class="fc-footer-bottom-inner">
                        <div>
                            &copy; 2024 FarmConnect. Connecting growers and communities directly.
                        </div>
                        <div style="display: flex; gap: 16px;">
                            <span>Ethical Agriculture</span>
                            <span>&bull;</span>
                            <span>Transparent Sourcing</span>
                            <span>&bull;</span>
                            <span>Fresh Pick Guarantee</span>
                        </div>
                    </div>
                </div>
            </footer>
        </div><!-- /.fc-public-layout -->
    </c:otherwise>
</c:choose>

</body>
</html>
