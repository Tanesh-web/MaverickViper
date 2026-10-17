package com.maverickviper.student;

import com.maverickviper.dao.StudentDAO;
import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.model.Student;
import com.maverickviper.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

@WebServlet("/student-profile")
public class StudentProfileServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        Student student = studentDAO.findById(studentId);
        Map<String, Object> stats = testAttemptDAO.getStudentPerformanceStats(studentId);

        request.setAttribute("student", student);
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/student-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || newPassword == null || confirmPassword == null ||
                currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            response.sendRedirect("student-profile?error=empty");
            return;
        }

        if (newPassword.length() < 6) {
            response.sendRedirect("student-profile?error=short_password");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("student-profile?error=mismatch");
            return;
        }

        Student student = studentDAO.findById(studentId);
        if (student == null || !PasswordUtil.verifyPassword(currentPassword, student.getPasswordHash())) {
            response.sendRedirect("student-profile?error=wrong_current");
            return;
        }

        try {
            String newHash = PasswordUtil.hashPassword(newPassword);
            // Update password
            String sql = "UPDATE students SET password_hash = ? WHERE student_id = ?";
            try (java.sql.Connection con = com.maverickviper.config.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, newHash);
                ps.setInt(2, studentId);
                ps.executeUpdate();
            }
            response.sendRedirect("student-profile?success=password_updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("student-profile?error=failed");
        }
    }
}
