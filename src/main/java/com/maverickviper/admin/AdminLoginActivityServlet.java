package com.maverickviper.admin;

import com.maverickviper.dao.LoginActivityDAO;
import com.maverickviper.model.LoginActivity;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin-login-activity")
public class AdminLoginActivityServlet extends HttpServlet {

    private final LoginActivityDAO loginActivityDAO = new LoginActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        List<LoginActivity> activities = loginActivityDAO.getRecentActivity(100);
        request.setAttribute("activities", activities);

        request.getRequestDispatcher("/admin-login-activity.jsp").forward(request, response);
    }
}
