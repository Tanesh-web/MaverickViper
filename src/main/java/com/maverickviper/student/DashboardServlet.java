package com.maverickviper.student;

import com.maverickviper.dao.QuestionDAO;
import com.maverickviper.dao.StudentDAO;
import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.Student;
import com.maverickviper.model.TestAttempt;
import com.maverickviper.model.Week;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final WeekDAO weekDAO = new WeekDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        int courseId = 1; // Default course: Foundation of Digital Business

        Student student = studentDAO.findById(studentId);
        Map<String, Object> stats = testAttemptDAO.getStudentPerformanceStats(studentId);
        List<TestAttempt> recentAttempts = testAttemptDAO.getAttemptsByStudent(studentId);
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        int totalQuestions = questionDAO.countQuestions(courseId);

        request.setAttribute("student", student);
        request.setAttribute("stats", stats);
        request.setAttribute("recentAttempts", recentAttempts);
        request.setAttribute("weeks", weeks);
        request.setAttribute("totalQuestions", totalQuestions);

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}
