package com.maverickviper.student;

import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.model.TestAttempt;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/student-performance")
public class StudentPerformanceServlet extends HttpServlet {

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

        int targetStudentId;
        if (isAdmin) {
            String studentIdParam = request.getParameter("studentId");
            if (studentIdParam != null && !studentIdParam.trim().isEmpty()) {
                try {
                    targetStudentId = Integer.parseInt(studentIdParam.trim());
                } catch (NumberFormatException e) {
                    response.sendRedirect("admin-students");
                    return;
                }
            } else {
                response.sendRedirect("admin-students");
                return;
            }
        } else {
            targetStudentId = (Integer) session.getAttribute("studentId");
        }

        Map<String, Object> stats = testAttemptDAO.getStudentPerformanceStats(targetStudentId);
        List<Map<String, Object>> weekStats = testAttemptDAO.getStudentWeekWiseStats(targetStudentId);
        List<TestAttempt> attempts = testAttemptDAO.getAttemptsByStudent(targetStudentId);

        request.setAttribute("stats", stats);
        request.setAttribute("weekStats", weekStats);
        request.setAttribute("attempts", attempts);
        request.setAttribute("targetStudentId", targetStudentId);

        request.getRequestDispatcher("/student-performance.jsp").forward(request, response);
    }
}
