package com.maverickviper.student;

import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.model.StudentAnswer;
import com.maverickviper.model.TestAttempt;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/test-results")
public class TestResultServlet extends HttpServlet {

    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        boolean isStudent = (session != null && session.getAttribute("studentId") != null);
        boolean isAdmin = (session != null && session.getAttribute("adminId") != null);

        if (!isStudent && !isAdmin) {
            response.sendRedirect("login.html");
            return;
        }

        String attemptIdParam = request.getParameter("attemptId");
        if (attemptIdParam == null || attemptIdParam.trim().isEmpty()) {
            response.sendRedirect(isStudent ? "take-test" : "admin-dashboard");
            return;
        }

        try {
            int attemptId = Integer.parseInt(attemptIdParam.trim());
            TestAttempt attempt = testAttemptDAO.getAttemptById(attemptId);

            if (attempt == null) {
                response.sendRedirect(isStudent ? "take-test?error=not_found" : "admin-dashboard");
                return;
            }

            // Security check: if student, can only view own attempt
            if (isStudent && !isAdmin) {
                int studentId = (Integer) session.getAttribute("studentId");
                if (attempt.getStudentId() != studentId) {
                    response.sendRedirect("take-test?error=unauthorized");
                    return;
                }
            }

            List<StudentAnswer> answers = testAttemptDAO.getStudentAnswersByAttempt(attemptId);

            request.setAttribute("attempt", attempt);
            request.setAttribute("answers", answers);

            request.getRequestDispatcher("/test-results.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(isStudent ? "take-test" : "admin-dashboard");
        }
    }
}
