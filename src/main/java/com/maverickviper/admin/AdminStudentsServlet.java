package com.maverickviper.admin;

import com.maverickviper.dao.LoginActivityDAO;
import com.maverickviper.dao.StudentDAO;
import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.model.LoginActivity;
import com.maverickviper.model.Student;
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

@WebServlet("/admin-students")
public class AdminStudentsServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
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

        String search = request.getParameter("search");
        String studentIdParam = request.getParameter("studentId");

        if (studentIdParam != null && !studentIdParam.trim().isEmpty()) {
            try {
                int sid = Integer.parseInt(studentIdParam.trim());
                Student detailStudent = studentDAO.findById(sid);
                Map<String, Object> stats = testAttemptDAO.getStudentPerformanceStats(sid);
                List<TestAttempt> attempts = testAttemptDAO.getAttemptsByStudent(sid);
                List<LoginActivity> logins = loginActivityDAO.getStudentLoginHistory(sid);

                request.setAttribute("detailStudent", detailStudent);
                request.setAttribute("studentStats", stats);
                request.setAttribute("studentAttempts", attempts);
                request.setAttribute("studentLogins", logins);
            } catch (NumberFormatException ignored) {}
        }

        List<Student> students;
        if (search != null && !search.trim().isEmpty()) {
            students = studentDAO.searchStudents(search.trim());
        } else {
            students = studentDAO.getAllStudentsWithStats();
        }

        request.setAttribute("students", students);
        request.setAttribute("searchQuery", search);

        request.getRequestDispatcher("/admin-students.jsp").forward(request, response);
    }
}
