package com.maverickviper.admin;

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

@WebServlet("/admin-questions")
public class AdminQuestionsServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final WeekDAO weekDAO = new WeekDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        int courseId = 1;
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        request.setAttribute("weeks", weeks);

        String editIdParam = request.getParameter("editId");
        if (editIdParam != null && !editIdParam.trim().isEmpty()) {
            try {
                int editId = Integer.parseInt(editIdParam.trim());
                Question editQ = questionDAO.getQuestionById(editId);
                request.setAttribute("editQuestion", editQ);
            } catch (NumberFormatException ignored) {}
        }

        String keyword = request.getParameter("search");
        String weekParam = request.getParameter("week");
        String category = request.getParameter("category");

        Integer weekNumber = null;
        if (weekParam != null && !weekParam.trim().isEmpty() && !weekParam.equals("ALL")) {
            try {
                weekNumber = Integer.parseInt(weekParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<Question> questions = questionDAO.searchQuestions(courseId, keyword, weekNumber, category);
        request.setAttribute("questions", questions);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedWeek", weekParam);
        request.setAttribute("selectedCategory", category);

        request.getRequestDispatcher("/admin-questions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        int courseId = 1;

        if ("delete".equalsIgnoreCase(action)) {
            try {
                int qid = Integer.parseInt(request.getParameter("questionId"));
                questionDAO.deleteQuestion(qid);
                response.sendRedirect("admin-questions?success=deleted");
            } catch (Exception e) {
                response.sendRedirect("admin-questions?error=delete_failed");
            }
            return;
        }

        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");
        String weekNumberParam = request.getParameter("weekNumber");
        String category = request.getParameter("category");
        String explanation = request.getParameter("explanation");
        String questionIdParam = request.getParameter("questionId");

        if (questionText == null || optionA == null || optionB == null || optionC == null || optionD == null ||
            correctOption == null || weekNumberParam == null ||
            questionText.trim().isEmpty() || optionA.trim().isEmpty() || optionB.trim().isEmpty() ||
            optionC.trim().isEmpty() || optionD.trim().isEmpty() || correctOption.trim().isEmpty()) {
            response.sendRedirect("admin-questions?error=empty");
            return;
        }

        try {
            int weekNumber = Integer.parseInt(weekNumberParam.trim());
            Week matchedWeek = weekDAO.getWeekByNumber(courseId, weekNumber);
            Integer weekId = matchedWeek != null ? matchedWeek.getWeekId() : null;

            Question q = new Question();
            q.setCourseId(courseId);
            q.setWeekId(weekId);
            q.setWeekNumber(weekNumber);
            q.setQuestionText(questionText.trim());
            q.setOptionA(optionA.trim());
            q.setOptionB(optionB.trim());
            q.setOptionC(optionC.trim());
            q.setOptionD(optionD.trim());
            q.setCorrectOption(correctOption.trim().toUpperCase());
            q.setCategory((category == null || category.trim().isEmpty()) ? "WEEKWISE" : category.trim());
            q.setExplanation(explanation != null && !explanation.trim().isEmpty() ? explanation.trim() : null);

            if ("update".equalsIgnoreCase(action) && questionIdParam != null) {
                q.setQuestionId(Integer.parseInt(questionIdParam.trim()));
                boolean updated = questionDAO.updateQuestion(q);
                if (updated) {
                    response.sendRedirect("admin-questions?success=updated");
                } else {
                    response.sendRedirect("admin-questions?error=update_failed");
                }
            } else {
                boolean added = questionDAO.addQuestion(q);
                if (added) {
                    response.sendRedirect("admin-questions?success=added");
                } else {
                    response.sendRedirect("admin-questions?error=add_failed");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-questions?error=invalid_number");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-questions?error=failed");
        }
    }
}
