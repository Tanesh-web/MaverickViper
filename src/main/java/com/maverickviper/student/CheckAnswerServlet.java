package com.maverickviper.student;

import com.maverickviper.dao.QuestionDAO;
import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.model.Question;
import com.maverickviper.model.StudentAnswer;
import com.maverickviper.model.TestAttempt;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/check-answer")
public class CheckAnswerServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\":\"User not authenticated\"}");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");

        String attemptIdParam = request.getParameter("attemptId");
        String questionIdParam = request.getParameter("questionId");
        String selectedOption = request.getParameter("selectedOption");

        if (attemptIdParam == null || questionIdParam == null || selectedOption == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\":\"Missing required parameters\"}");
            return;
        }

        try {
            int attemptId = Integer.parseInt(attemptIdParam.trim());
            int questionId = Integer.parseInt(questionIdParam.trim());
            selectedOption = selectedOption.trim().toUpperCase();

            // Verify attempt ownership
            TestAttempt attempt = testAttemptDAO.getAttemptById(attemptId);
            if (attempt == null || attempt.getStudentId() != studentId) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.write("{\"error\":\"Access denied to this attempt\"}");
                return;
            }

            Question q = questionDAO.getQuestionById(questionId);
            if (q == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("{\"error\":\"Question not found\"}");
                return;
            }

            boolean isCorrect = selectedOption.equalsIgnoreCase(q.getCorrectOption());

            // Build snapshot answer record
            StudentAnswer answer = new StudentAnswer();
            answer.setAttemptId(attemptId);
            answer.setQuestionId(questionId);
            answer.setSelectedOption(selectedOption);
            answer.setCorrectOptionSnapshot(q.getCorrectOption());
            answer.setCorrect(isCorrect);
            answer.setQuestionTextSnapshot(q.getQuestionText());
            answer.setOptionASnapshot(q.getOptionA());
            answer.setOptionBSnapshot(q.getOptionB());
            answer.setOptionCSnapshot(q.getOptionC());
            answer.setOptionDSnapshot(q.getOptionD());
            answer.setExplanationSnapshot(q.getExplanation());

            // Save historical snapshot immediately
            testAttemptDAO.saveStudentAnswer(answer);

            // Escape strings for JSON
            String explanation = q.getExplanation() != null ? escapeJson(q.getExplanation()) : "";

            out.write(String.format(
                    "{\"success\":true,\"isCorrect\":%b,\"selectedOption\":\"%s\",\"correctOption\":\"%s\",\"explanation\":\"%s\"}",
                    isCorrect,
                    selectedOption,
                    q.getCorrectOption(),
                    explanation
            ));

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\":\"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\":\"Server error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
