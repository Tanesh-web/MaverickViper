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
    "/dashboard",
    "/dashboard.jsp",
    "/read-mcqs",
    "/read-mcqs.jsp",
    "/take-test",
    "/take-test.jsp",
    "/exam.jsp",
    "/submit-test",
    "/test-results",
    "/test-results.jsp",
    "/student-performance",
    "/student-performance.jsp",
    "/student-profile",
    "/student-profile.jsp",
    "/profile",
    "/api/check-answer"
})
public class StudentAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent caching for sensitive authenticated pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);

        boolean isLoggedIn = (session != null && session.getAttribute("studentId") != null);

        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            String requestURI = httpRequest.getRequestURI();
            if (requestURI.contains("/api/")) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json");
                httpResponse.getWriter().write("{\"error\":\"Unauthorized. Please log in.\"}");
            } else {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.html");
            }
        }
    }

    @Override
    public void destroy() {}
}
