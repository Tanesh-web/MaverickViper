package com.maverickviper.student;

import com.maverickviper.dao.LoginActivityDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private final LoginActivityDAO loginActivityDAO = new LoginActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            Integer studentId = (Integer) session.getAttribute("studentId");
            Integer loginId = (Integer) session.getAttribute("loginId");

            if (studentId != null) {
                loginActivityDAO.recordLogout(studentId, loginId != null ? loginId : -1);
            }

            session.invalidate();
        }

        response.sendRedirect("login.html?logout=true");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
