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

@WebServlet("/submit-test")
public class SubmitTestServlet extends HttpServlet {

    private final TestAttemptDAO testAttemptDAO = new TestAttemptDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        String attemptIdParam = request.getParameter("attemptId");

        if (attemptIdParam == null || attemptIdParam.trim().isEmpty()) {
            response.sendRedirect("take-test");
            return;
        }

        try {
            int attemptId = Integer.parseInt(attemptIdParam.trim());
            TestAttempt attempt = testAttemptDAO.getAttemptById(attemptId);

            if (attempt == null || attempt.getStudentId() != studentId) {
                response.sendRedirect("take-test?error=unauthorized");
                return;
            }

            // If already completed, just redirect to results
            if ("COMPLETED".equalsIgnoreCase(attempt.getStatus())) {
                response.sendRedirect("test-results?attemptId=" + attemptId);
                return;
            }

            // Retrieve all answers saved during instant feedback
            List<StudentAnswer> answers = testAttemptDAO.getStudentAnswersByAttempt(attemptId);
            
            // Snapshot any unanswered questions from the session so they appear in review
            List<com.maverickviper.model.Question> sessionQuestions = (List<com.maverickviper.model.Question>) session.getAttribute("exam_q_" + attemptId);
            if (sessionQuestions != null) {
                java.util.Set<Integer> answeredQIds = new java.util.HashSet<>();
                for (StudentAnswer sa : answers) {
                    answeredQIds.add(sa.getQuestionId());
                }
                for (com.maverickviper.model.Question q : sessionQuestions) {
                    if (!answeredQIds.contains(q.getQuestionId())) {
                        StudentAnswer unans = new StudentAnswer();
                        unans.setAttemptId(attemptId);
                        unans.setQuestionId(q.getQuestionId());
                        unans.setSelectedOption(null);
                        unans.setCorrectOptionSnapshot(q.getCorrectOption());
                        unans.setCorrect(false);
                        unans.setQuestionTextSnapshot(q.getQuestionText());
                        unans.setOptionASnapshot(q.getOptionA());
                        unans.setOptionBSnapshot(q.getOptionB());
                        unans.setOptionCSnapshot(q.getOptionC());
                        unans.setOptionDSnapshot(q.getOptionD());
                        unans.setExplanationSnapshot(q.getExplanation());
                        testAttemptDAO.saveStudentAnswer(unans);
                    }
                }
            }

            int correctCount = 0;
            int incorrectCount = 0;

            for (StudentAnswer a : answers) {
                if (a.isCorrect()) {
                    correctCount++;
                } else if (a.getSelectedOption() != null) {
                    incorrectCount++;
                }
            }

            int attemptedCount = correctCount + incorrectCount;
            int totalQuestions = attempt.getTotalQuestions();
            if (totalQuestions <= 0) {
                totalQuestions = (sessionQuestions != null) ? sessionQuestions.size() : attemptedCount;
            }
            int unansweredCount = Math.max(0, totalQuestions - attemptedCount);

            // Calculations per formulas
            double marksPerQ = 1.0;
            double score = (correctCount * marksPerQ);

            double accuracy = 0.0;
            if (attemptedCount > 0) {
                accuracy = ((double) correctCount / (double) attemptedCount) * 100.0;
            }

            double percentage = 0.0;
            double maxMarks = totalQuestions * marksPerQ;
            if (maxMarks > 0) {
                percentage = (score / maxMarks) * 100.0;
            }

            // Update attempt record
            attempt.setAttempted(attemptedCount);
            attempt.setCorrect(correctCount);
            attempt.setIncorrect(incorrectCount);
            attempt.setUnanswered(unansweredCount);
            attempt.setScore(Math.round(score * 100.0) / 100.0);
            attempt.setAccuracy(Math.round(accuracy * 100.0) / 100.0);
            attempt.setPercentage(Math.round(percentage * 100.0) / 100.0);
            attempt.setStatus("COMPLETED");

            testAttemptDAO.updateAttempt(attempt);

            // Clear temporary exam session cache
            session.removeAttribute("exam_q_" + attemptId);

            response.sendRedirect("test-results?attemptId=" + attemptId);

        } catch (NumberFormatException e) {
            response.sendRedirect("take-test");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("take-test?error=submit_failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
