package com.maverickviper.student;

import com.maverickviper.dao.QuestionDAO;
import com.maverickviper.dao.TestAttemptDAO;
import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.Question;
import com.maverickviper.model.StudentAnswer;
import com.maverickviper.model.TestAttempt;
import com.maverickviper.model.Week;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;

@WebServlet("/take-test")
public class TakeTestServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final WeekDAO weekDAO = new WeekDAO();
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
        int courseId = 1;

        String attemptIdParam = request.getParameter("attemptId");
        String mode = request.getParameter("mode"); // ALL_MCQ, WEEK_WISE, SHUFFLE

        // 1. If an active attempt is being viewed or resumed
        if (attemptIdParam != null && !attemptIdParam.trim().isEmpty()) {
            try {
                int attemptId = Integer.parseInt(attemptIdParam.trim());
                TestAttempt attempt = testAttemptDAO.getAttemptById(attemptId);

                if (attempt == null || attempt.getStudentId() != studentId) {
                    response.sendRedirect("take-test?error=unauthorized");
                    return;
                }

                if ("COMPLETED".equalsIgnoreCase(attempt.getStatus())) {
                    response.sendRedirect("test-results?attemptId=" + attemptId);
                    return;
                }

                List<Question> questions = (List<Question>) session.getAttribute("exam_q_" + attemptId);
                if (questions == null || questions.isEmpty()) {
                    // Fallback reload questions
                    if ("WEEK_WISE".equalsIgnoreCase(attempt.getTestType())) {
                        String name = attempt.getTestName();
                        int wNum = 0;
                        try {
                            wNum = Integer.parseInt(name.replaceAll("[^0-9]", ""));
                        } catch (Exception ignored) {}
                        questions = questionDAO.getQuestionsByWeek(courseId, wNum);
                    } else if ("SHUFFLE".equalsIgnoreCase(attempt.getTestType())) {
                        questions = questionDAO.getQuestionsForShuffle(courseId, attempt.getTotalQuestions());
                    } else {
                        questions = questionDAO.getAllQuestionsForReading(courseId);
                    }
                    session.setAttribute("exam_q_" + attemptId, questions);
                }

                // Load already answered questions for this attempt to preserve feedback state
                List<StudentAnswer> savedAnswers = testAttemptDAO.getStudentAnswersByAttempt(attemptId);
                Map<Integer, StudentAnswer> answersMap = new HashMap<>();
                for (StudentAnswer sa : savedAnswers) {
                    answersMap.put(sa.getQuestionId(), sa);
                }

                request.setAttribute("attempt", attempt);
                request.setAttribute("questions", questions);
                request.setAttribute("answersMap", answersMap);

                request.getRequestDispatcher("/exam.jsp").forward(request, response);
                return;

            } catch (NumberFormatException ignored) {}
        }

        // 2. If launching a new test
        if (mode != null && !mode.trim().isEmpty()) {
            launchNewTest(request, response, session, studentId, courseId, mode);
            return;
        }

        // 3. Otherwise show Test Selection Hub
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        int totalQuestions = questionDAO.countQuestions(courseId);

        request.setAttribute("weeks", weeks);
        request.setAttribute("totalQuestions", totalQuestions);

        request.getRequestDispatcher("/take-test.jsp").forward(request, response);
    }

    private void launchNewTest(HttpServletRequest request, HttpServletResponse response,
                               HttpSession session, int studentId, int courseId, String mode)
            throws IOException {

        List<Question> testQuestions = new ArrayList<>();
        String testName = "Examination";

        if ("ALL_MCQ".equalsIgnoreCase(mode)) {
            testName = "All NPTEL MCQs Comprehensive Exam";
            testQuestions = questionDAO.getAllQuestionsForReading(courseId);
        } else if ("WEEK_WISE".equalsIgnoreCase(mode)) {
            String weekParam = request.getParameter("week");
            int weekNumber = 0;
            if (weekParam != null) {
                try {
                    weekNumber = Integer.parseInt(weekParam.trim());
                } catch (NumberFormatException ignored) {}
            }
            testName = "Week " + weekNumber + " Examination";
            testQuestions = questionDAO.getQuestionsByWeek(courseId, weekNumber);
        } else if ("SHUFFLE".equalsIgnoreCase(mode)) {
            testName = "Shuffle Questions Randomized Test";
            String countParam = request.getParameter("count");
            int count = 25;
            if (countParam != null) {
                try {
                    count = Integer.parseInt(countParam.trim());
                } catch (NumberFormatException ignored) {}
            }
            testQuestions = questionDAO.getQuestionsForShuffle(courseId, count);
        }

        if (testQuestions == null || testQuestions.isEmpty()) {
            response.sendRedirect("take-test?error=no_questions");
            return;
        }

        // Check if option shuffling requested
        String shuffleOptsParam = request.getParameter("shuffleOptions");
        boolean shuffleOptions = "true".equalsIgnoreCase(shuffleOptsParam) || "on".equalsIgnoreCase(shuffleOptsParam);
        if (shuffleOptions) {
            for (Question q : testQuestions) {
                shuffleQuestionOptions(q);
            }
        }

        // Create new attempt record
        TestAttempt attempt = new TestAttempt();
        attempt.setStudentId(studentId);
        attempt.setTestName(testName);
        attempt.setTestType(mode.toUpperCase());
        attempt.setTotalQuestions(testQuestions.size());
        attempt.setAttempted(0);
        attempt.setCorrect(0);
        attempt.setIncorrect(0);
        attempt.setUnanswered(testQuestions.size());
        attempt.setScore(0.0);
        attempt.setAccuracy(0.0);
        attempt.setPercentage(0.0);
        attempt.setStatus("IN_PROGRESS");

        boolean created = testAttemptDAO.createAttempt(attempt);
        if (created) {
            session.setAttribute("exam_q_" + attempt.getAttemptId(), testQuestions);
            response.sendRedirect("take-test?attemptId=" + attempt.getAttemptId());
        } else {
            response.sendRedirect("take-test?error=create_failed");
        }
    }

    private void shuffleQuestionOptions(Question q) {
        // Collect current options
        class Opt {
            String letter;
            String text;
            Opt(String l, String t) { this.letter = l; this.text = t; }
        }
        List<Opt> list = new ArrayList<>();
        list.add(new Opt("A", q.getOptionA()));
        list.add(new Opt("B", q.getOptionB()));
        list.add(new Opt("C", q.getOptionC()));
        list.add(new Opt("D", q.getOptionD()));

        String correctText = "";
        for (Opt o : list) {
            if (o.letter.equalsIgnoreCase(q.getCorrectOption())) {
                correctText = o.text;
                break;
            }
        }

        Collections.shuffle(list);

        q.setOptionA(list.get(0).text);
        q.setOptionB(list.get(1).text);
        q.setOptionC(list.get(2).text);
        q.setOptionD(list.get(3).text);

        // Remap correct option letter
        if (q.getOptionA().equalsIgnoreCase(correctText)) q.setCorrectOption("A");
        else if (q.getOptionB().equalsIgnoreCase(correctText)) q.setCorrectOption("B");
        else if (q.getOptionC().equalsIgnoreCase(correctText)) q.setCorrectOption("C");
        else if (q.getOptionD().equalsIgnoreCase(correctText)) q.setCorrectOption("D");
    }
}
