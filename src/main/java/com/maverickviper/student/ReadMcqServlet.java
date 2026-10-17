package com.maverickviper.student;

import com.maverickviper.dao.QuestionDAO;
import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.Question;
import com.maverickviper.model.Week;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/read-mcqs")
public class ReadMcqServlet extends HttpServlet {

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

        int courseId = 1;
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        request.setAttribute("weeks", weeks);

        String mode = request.getParameter("mode"); // "all", "week", "mock"
        String weekParam = request.getParameter("week");
        String qIndexParam = request.getParameter("q");

        if (mode == null || mode.trim().isEmpty()) {
            mode = "all";
        }

        List<Question> questions;
        Integer activeWeek = null;

        if ("week".equalsIgnoreCase(mode) && weekParam != null && !weekParam.trim().isEmpty()) {
            try {
                activeWeek = Integer.parseInt(weekParam.trim());
                questions = questionDAO.getQuestionsByWeek(courseId, activeWeek);
            } catch (NumberFormatException e) {
                questions = questionDAO.getAllQuestionsForReading(courseId);
            }
        } else if ("mock".equalsIgnoreCase(mode)) {
            questions = questionDAO.getQuestionsByCategory(courseId, "NPTEL_MOCK_TEST");
        } else {
            questions = questionDAO.getAllQuestionsForReading(courseId);
        }

        int currentIndex = 0;
        if (qIndexParam != null && !qIndexParam.trim().isEmpty()) {
            try {
                int q = Integer.parseInt(qIndexParam.trim()) - 1;
                if (q >= 0 && q < questions.size()) {
                    currentIndex = q;
                }
            } catch (NumberFormatException ignored) {}
        }

        request.setAttribute("questions", questions);
        request.setAttribute("currentIndex", currentIndex);
        request.setAttribute("mode", mode);
        request.setAttribute("activeWeek", activeWeek);

        request.getRequestDispatcher("/read-mcqs.jsp").forward(request, response);
    }
}
