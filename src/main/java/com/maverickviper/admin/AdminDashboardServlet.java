package com.maverickviper.admin;

import com.maverickviper.dao.*;
import com.maverickviper.model.LoginActivity;
import com.maverickviper.model.Student;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin-dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final WeekDAO weekDAO = new WeekDAO();
    private final TestDAO testDAO = new TestDAO();
    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();
    private final LoginActivityDAO loginActivityDAO = new LoginActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        int courseId = 1;

        int totalStudents = studentDAO.countStudents();
        int totalQuestions = questionDAO.countQuestions(courseId);
        int totalWeeks = weekDAO.countWeeks(courseId);
        int totalTests = testDAO.countTests(courseId);
        int totalAttempts = testAttemptDAO.countTotalAttempts();

        List<Student> recentStudents = studentDAO.getAllStudentsWithStats();
        if (recentStudents.size() > 5) {
            recentStudents = recentStudents.subList(0, 5);
        }

        List<LoginActivity> recentLogins = loginActivityDAO.getRecentActivity(8);

        request.setAttribute("totalStudents", totalStudents);
        request.setAttribute("totalQuestions", totalQuestions);
        request.setAttribute("totalWeeks", totalWeeks);
        request.setAttribute("totalTests", totalTests);
        request.setAttribute("totalAttempts", totalAttempts);
        request.setAttribute("recentStudents", recentStudents);
        request.setAttribute("recentLogins", recentLogins);

        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}