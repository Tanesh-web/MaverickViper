package com.maverickviper.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {
    "/admin-dashboard",
    "/admin-dashboard.jsp",
    "/admin-courses",
    "/admin-courses.jsp",
    "/admin-weeks",
    "/admin-weeks.jsp",
    "/admin-questions",
    "/admin-questions.jsp",
    "/add-question",
    "/add-question.jsp",
    "/bulk-question-upload",
    "/bulk-upload.jsp",
    "/admin-students",
    "/admin-students.jsp",
    "/admin-tests",
    "/admin-tests.jsp",
    "/admin-login-activity",
    "/admin-login-activity.jsp"
})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent caching for sensitive admin pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);

        boolean isAdminLoggedIn = (session != null && session.getAttribute("adminId") != null);

        if (isAdminLoggedIn) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin-login.html");
        }
    }

    @Override
    public void destroy() {}
}
